import CoreLocation
import Foundation
import Mapbox
import UIKit

class AKRecordTravelViewController: AKCustomViewController, MGLMapViewDelegate
{
    // MARK: Properties
    private let startAnnotation: MGLPointAnnotation = MGLPointAnnotation()
    private let endAnnotation: MGLPointAnnotation = MGLPointAnnotation()
    private let infoOverlayViewContainer: AKTravelInfoOverlayView = AKTravelInfoOverlayView()
    private var infoOverlayViewSubView: UIView!
    private var travel: AKTravel! = AKTravel()
    private var currentPosition: UserLocation?
    private var coordinates: [CLLocationCoordinate2D] = []
    private var filteredPointsCounter: Int = 0
    
    // MARK: Outlets
    @IBOutlet weak var stopRecordingTravel: UIButton!
    @IBOutlet weak var map: MGLMapView!
    
    // MARK: Actions
    @IBAction func stopRecordingTravel(sender: AnyObject)
    {
        self.stopRecording({ Void -> Void in
            // self.navigationController?.popViewControllerAnimated(true)
        })
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Configure map.
        self.map.minimumZoomLevel = 8
        self.map.maximumZoomLevel = 18
        self.map.zoomLevel = 14
        self.map.userTrackingMode = MGLUserTrackingMode.Follow
        
        // Add map overlay for travel information.
        self.infoOverlayViewSubView = self.infoOverlayViewContainer.customView
        self.infoOverlayViewContainer.controller = self
        self.infoOverlayViewSubView.frame = CGRect(x: 0, y: 0, width: self.map.bounds.width, height: 22)
        self.infoOverlayViewSubView.translatesAutoresizingMaskIntoConstraints = true
        self.infoOverlayViewSubView.clipsToBounds = true
        self.infoOverlayViewSubView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.map.addSubview(self.infoOverlayViewSubView)
        
        let constraintWidth = NSLayoutConstraint(
            item: self.infoOverlayViewSubView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.map,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1.0,
            constant: 0.0
        )
        self.map.addConstraint(constraintWidth)
        
        // Start recording.
        self.startRecording({})
    }
    
    // MARK: Recording Methods
    func startRecording(completionTask: Void -> Void)
    {
        defer {
            completionTask()
        }
        
        NSLog("=> LOCATION SERVICES ==> START RECORDING TRAVEL ...")
        AKDelegate().recordingTravel = true
        
        // Compute travel origin.
        self.travel.addOrigin(UserLocation(lat: AKDelegate().currentLatitude, lon: AKDelegate().currentLongitude))
        
        do {
            // Append origin to coordinates and center map.
            self.coordinates.append(try self.travel.computeOriginAsCoordinate())
            self.map.centerCoordinate = try self.travel.computeOriginAsCoordinate()
            
            // Add start annotation.
            self.startAnnotation.coordinate = try self.travel.computeOriginAsCoordinate()
            self.startAnnotation.title = GlobalConstants.AKTravelStartAnnotationTitle
            self.map.addAnnotation(self.startAnnotation)
        }
        catch {
            AKPresentMessageFromError("\(error)", controller: self)
            return
        }
    }
    
    func stopRecording(completionTask: Void -> Void)
    {
        defer {
            completionTask()
        }
        
        NSLog("=> LOCATION SERVICES ==> STOP RECORDING TRAVEL ...")
        AKDelegate().recordingTravel = false
        
        // Compute travel destination.
        self.travel.addDestination(UserLocation(lat: self.currentPosition!.lat, lon: self.currentPosition!.lon))
        
        do {
            // Append origin to coordinates and center map.
            self.coordinates.append(try self.travel.computeDestinationAsCoordinate())
            self.map.centerCoordinate = try self.travel.computeDestinationAsCoordinate()
            
            // Add end annotation.
            self.endAnnotation.coordinate = try self.travel.computeDestinationAsCoordinate()
            self.endAnnotation.title = GlobalConstants.AKTravelEndAnnotationTitle
            self.map.addAnnotation(self.endAnnotation)
        }
        catch {
            AKPresentMessageFromError("\(error)", controller: self)
            return
        }
    }
    
    // MARK: MGLMapViewDelegate Implementation
    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat
    {
        if annotation.title == nil {
            return 1.0
        }
        else {
            switch annotation.title! {
            case GlobalConstants.AKTravelSegmentAnnotationTitle:
                return 0.75
            case GlobalConstants.AKTravelStopPointMarkTitle:
                return 0.5
            default:
                return 1.0
            }
        }
    }
    
    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat
    {
        if annotation.title == nil {
            return 1.0
        }
        else {
            switch annotation.title! {
            case GlobalConstants.AKTravelSegmentAnnotationTitle:
                return 6.0
            default:
                return 1.0
            }
        }
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor
    {
        if annotation.title == nil {
            return UIColor.clearColor()
        }
        else {
            switch annotation.title! {
            case GlobalConstants.AKTravelSegmentAnnotationTitle:
                return GlobalConstants.AKTravelPathMarkerColor
            default:
                return UIColor.clearColor()
            }
        }
    }
    
    func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor
    {
        if annotation.title == nil {
            return UIColor.clearColor()
        }
        else {
            switch annotation.title! {
            case GlobalConstants.AKTravelSegmentAnnotationTitle:
                return GlobalConstants.AKTravelPathMarkerColor
            case GlobalConstants.AKTravelStopPointMarkTitle:
                return UIColor.redColor()
            default:
                return UIColor.clearColor()
            }
        }
    }
    
    // MARK: Observers
    func locationUpdated(notification: NSNotification)
    {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            let travelSegment = notification.userInfo!["data"] as! AKTravelSegment
            self.currentPosition = UserLocation(lat: travelSegment.computeEnd().lat, lon: travelSegment.computeEnd().lon)
            self.travel.addSegment(travelSegment)
            
            // Execute filters.
            if !AKFilters.filter(self.map, travel: self.travel, travelSegment: travelSegment) {
                self.filteredPointsCounter += 1
                self.infoOverlayViewContainer.filteredPoints.text = String(format: "%iFP", self.filteredPointsCounter)
            }
            else {
                self.travel.addDistance(travelSegment.computeDistance(UnitOfLength.Meter))
                self.infoOverlayViewContainer.distance.text = String(format: "%.1fkm", self.travel.computeDistance(UnitOfLength.Kilometer))
                self.infoOverlayViewContainer.speed.text = String(format: "%ikm/h", travelSegment.computeDistance(UnitOfLength.Kilometer) / travelSegment.computeTime(UnitOfTime.Hour))
                self.coordinates.append(CLLocationCoordinate2DMake(self.currentPosition!.lat, self.currentPosition!.lon))
                self.map.centerCoordinate = CLLocationCoordinate2DMake(self.currentPosition!.lat, self.currentPosition!.lon)
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
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(AKRecordTravelViewController.locationUpdated(_:)),
            name: GlobalConstants.AKLocationUpdateNotificationName,
            object: nil)
        
        // Delegates
        self.map.delegate = self
        
        // Custom L&F.
        self.stopRecordingTravel.layer.cornerRadius = 4.0
        
        // Configure NavigationController.
        self.navigationItem.hidesBackButton = true
    }
}
