import CoreLocation
import Foundation
import Mapbox
import SCLAlertView
import UIKit

class AKRecordTravelViewController: AKCustomViewController, MGLMapViewDelegate
{
    // MARK: Local Structures
    struct Defaults {
        static let AKDefaultStrokeAndFillColor = UIColor.clear()
        static let AKDefaultAlpha = 1.0
        static let AKDefaultLineWidth = 1.0
    }
    
    // MARK: Properties
    private let startAnnotation: MGLPointAnnotation = MGLPointAnnotation()
    private let endAnnotation: MGLPointAnnotation = MGLPointAnnotation()
    private let infoOverlayViewContainer: AKTravelInfoOverlayView = AKTravelInfoOverlayView()
    private var infoOverlayViewSubView: UIView!
    private var travel: AKTravel! = AKTravel()
    private var currentPosition: UserLocation = UserLocation()
    private var coordinates: [CLLocationCoordinate2D] = []
    private var filteredPointsCounter: Int = 0
    
    // MARK: Outlets
    @IBOutlet weak var stopRecordingTravel: UIButton!
    @IBOutlet weak var map: MGLMapView!
    
    // MARK: Actions
    @IBAction func stopRecordingTravel(_ sender: AnyObject)
    {
        self.stopRecording({ Void -> Void in
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Configure map.
        self.map.minimumZoomLevel = 8
        self.map.maximumZoomLevel = 18
        self.map.zoomLevel = 14
        self.map.userTrackingMode = MGLUserTrackingMode.follow
        
        // Add map overlay for travel information.
        self.infoOverlayViewSubView = self.infoOverlayViewContainer.customView
        self.infoOverlayViewContainer.controller = self
        self.infoOverlayViewSubView.frame = CGRect(x: 0, y: 0, width: self.map.bounds.width, height: 22)
        self.infoOverlayViewSubView.translatesAutoresizingMaskIntoConstraints = true
        self.infoOverlayViewSubView.clipsToBounds = true
        self.infoOverlayViewSubView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.map.addSubview(self.infoOverlayViewSubView)
        
        let constraintWidth = NSLayoutConstraint(
            item: self.infoOverlayViewSubView,
            attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal,
            toItem: self.map,
            attribute: NSLayoutAttribute.width,
            multiplier: 1.0,
            constant: 0.0
        )
        self.map.addConstraint(constraintWidth)
        
        // Start recording.
        self.startRecording({})
    }
    
    // MARK: Recording Methods
    func startRecording(_ completionTask: (Void) -> Void)
    {
        defer {
            completionTask()
        }
        
        NSLog("=> LOCATION SERVICES ==> START RECORDING TRAVEL ...")
        AKDelegate().recordingTravel = true
        
        // Compute travel origin.
        self.travel.addOrigin(UserLocation(lat: AKDelegate().currentPosition.lat, lon: AKDelegate().currentPosition.lon))
        
        do {
            // Append origin to coordinates and center map.
            self.coordinates.append(try self.travel.computeOriginAsCoordinate())
            self.map.centerCoordinate = try self.travel.computeOriginAsCoordinate()
            
            // Add start annotation.
            self.startAnnotation.coordinate = try self.travel.computeOriginAsCoordinate()
            self.startAnnotation.title = GlobalConstants.AKTravelStartAnnotationTitle
            self.startAnnotation.subtitle = String(format: "Lat: %f, Lon: %f", try self.travel.computeOrigin().lat, try self.travel.computeOrigin().lon)
            self.map.addAnnotation(self.startAnnotation)
        }
        catch {
            AKPresentMessageFromError("\(error)", controller: self)
            return
        }
    }
    
    func stopRecording(_ completionTask: (Void) -> Void)
    {
        NSLog("=> LOCATION SERVICES ==> STOP RECORDING TRAVEL ...")
        AKDelegate().recordingTravel = false
        
        do {
            // Compute travel destination.
            self.travel.addDestination(UserLocation(lat: self.currentPosition.lat, lon: self.currentPosition.lon))
            
            // Append origin to coordinates and center map.
            self.coordinates.append(try self.travel.computeDestinationAsCoordinate())
            self.map.centerCoordinate = try self.travel.computeDestinationAsCoordinate()
            
            // Add end annotation.
            self.endAnnotation.coordinate = try self.travel.computeDestinationAsCoordinate()
            self.endAnnotation.title = GlobalConstants.AKTravelEndAnnotationTitle
            self.endAnnotation.subtitle = String(format: "Lat: %f, Lon: %f", try self.travel.computeDestination().lat, try self.travel.computeDestination().lon)
            self.map.addAnnotation(self.endAnnotation)
        }
        catch {
            AKPresentMessageFromError("\(error)", controller: self)
        }
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: GlobalConstants.AKDefaultFont, size: 20)!,
            kTextFont: UIFont(name: GlobalConstants.AKDefaultFont, size: 14)!,
            kButtonFont: UIFont(name: GlobalConstants.AKDefaultFont, size: 14)!,
            showCloseButton: true
        )
        let alertController = SCLAlertView(appearance: appearance)
        
        alertController.addButton("Save & Exit", action: { () -> Void in
            AKDelegate().masterFile?.addTravel(self.travel)
            completionTask()
        })
        alertController.addButton("Discard", action: { () -> Void in completionTask() })
        
        alertController.showNotice(
            "Stop Travel",
            subTitle: "Do you want to save the travel...?",
            closeButtonTitle: nil,
            duration: 0.0
        )
    }
    
    // MARK: MGLMapViewDelegate Implementation
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool { return true }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat
    {
        if annotation.title == nil {
            return CGFloat(Defaults.AKDefaultAlpha)
        }
        else {
            switch annotation.title! {
            case GlobalConstants.AKTravelSegmentAnnotationTitle:
                return CGFloat(GlobalConstants.AKTravelPathLineAlpha)
            case GlobalConstants.AKTravelStopPointMarkTitle:
                return CGFloat(GlobalConstants.AKTravelStopPointMarkAlpha)
            default:
                return CGFloat(Defaults.AKDefaultAlpha)
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat
    {
        if annotation.title == nil {
            return CGFloat(Defaults.AKDefaultLineWidth)
        }
        else {
            switch annotation.title! {
            case GlobalConstants.AKTravelSegmentAnnotationTitle:
                return CGFloat(GlobalConstants.AKTravelPathLineWidth)
            default:
                return CGFloat(Defaults.AKDefaultLineWidth)
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor
    {
        if annotation.title == nil {
            return Defaults.AKDefaultStrokeAndFillColor
        }
        else {
            switch annotation.title! {
            case GlobalConstants.AKTravelSegmentAnnotationTitle:
                return GlobalConstants.AKTravelPathLineColor
            default:
                return Defaults.AKDefaultStrokeAndFillColor
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor
    {
        if annotation.title == nil {
            return Defaults.AKDefaultStrokeAndFillColor
        }
        else {
            switch annotation.title! {
            case GlobalConstants.AKTravelSegmentAnnotationTitle:
                return GlobalConstants.AKTravelPathLineColor
            case GlobalConstants.AKTravelStopPointMarkTitle:
                return GlobalConstants.AKTravelStopPointMarkColor
            default:
                return Defaults.AKDefaultStrokeAndFillColor
            }
        }
    }
    
    // MARK: Observers
    func locationUpdated(_ notification: Notification)
    {
        OperationQueue.main.addOperation({ () -> Void in
            let travelSegment = (notification as NSNotification).userInfo!["data"] as! AKTravelSegment
            self.currentPosition = UserLocation(lat: travelSegment.computeEnd().lat, lon: travelSegment.computeEnd().lon)
            self.travel.addSegment(travelSegment)
            
            // Execute filters.
            if !AKFilters.filter(self.map, travel: self.travel, travelSegment: travelSegment) {
                self.filteredPointsCounter += 1
                self.infoOverlayViewContainer.filteredPoints.text = String(format: "%iFP", self.filteredPointsCounter)
            }
            else {
                self.travel.addDistance(travelSegment.computeDistance(UnitOfLength.meter))
                self.infoOverlayViewContainer.distance.text = String(format: "%.1fkm", self.travel.computeDistance(UnitOfLength.kilometer))
                self.infoOverlayViewContainer.speed.text = String(format: "%ikm/h", travelSegment.computeDistance(UnitOfLength.kilometer) / travelSegment.computeTime(UnitOfTime.hour))
                self.coordinates.append(CLLocationCoordinate2DMake(self.currentPosition.lat, self.currentPosition.lon))
                self.map.centerCoordinate = CLLocationCoordinate2DMake(self.currentPosition.lat, self.currentPosition.lon)
                self.drawPolyline()
            }
            
            // Execute detections.
            AKDetection.detect(self.map, travel: self.travel, travelSegment: travelSegment)
        })
    }
    
    // MARK: Utilities
    func drawPolyline() {
        let line = MGLPolyline(coordinates: &self.coordinates, count: UInt(coordinates.count))
        line.title = GlobalConstants.AKTravelSegmentAnnotationTitle
        
        if self.map.annotations?.count > 0 {
            let annotationsToRemove = self.map.annotations!.filter {
                let annotation = $0
                
                if annotation.title == nil {
                    return true
                }
                else {
                    switch annotation.title!! {
                    case GlobalConstants.AKTravelStartAnnotationTitle, GlobalConstants.AKTravelEndAnnotationTitle, GlobalConstants.AKTravelStopPointMarkTitle, GlobalConstants.AKTravelStopPointPinTitle:
                        return false
                    default:
                        return true
                    }
                }
            }
            self.map.removeAnnotations(annotationsToRemove)
        }
        
        self.map.addAnnotation(line)
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.shouldCheckLoggedUser = false
        super.setup()
        
        // Custom notifications.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AKRecordTravelViewController.locationUpdated(_:)),
            name: NSNotification.Name(rawValue: GlobalConstants.AKLocationUpdateNotificationName),
            object: nil)
        
        // Delegates
        self.map.delegate = self
        
        // Custom L&F.
        self.stopRecordingTravel.layer.cornerRadius = CGFloat(GlobalConstants.AKButtonCornerRadius)
        
        // Configure NavigationController.
        self.navigationItem.hidesBackButton = true
    }
}
