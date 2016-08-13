import CoreLocation
import Foundation
import Mapbox
import SCLAlertView
import UIKit

class AKRecordTravelViewController: AKCustomViewController, MGLMapViewDelegate
{
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
    @IBOutlet weak var startRecordingTravel: UIButton!
    @IBOutlet weak var stopRecordingTravel: UIButton!
    @IBOutlet weak var map: MGLMapView!
    
    // MARK: Actions
    @IBAction func startRecordingTravel(sender: AnyObject)
    {
        self.startRecording(
            { Void -> Void in
                // Clear map.
                self.clearMap()
            }, completionTask: { Void -> Void in
                // Change color of the info overlay.
                self.infoOverlayViewSubView.backgroundColor = AKHexColor(0xBB5C5A)
                self.infoOverlayViewContainer.distance.backgroundColor = AKHexColor(0x9B2C32)
                self.infoOverlayViewContainer.speed.backgroundColor = AKHexColor(0x9B2C32)
                self.infoOverlayViewContainer.filteredPoints.backgroundColor = AKHexColor(0x9B2C32)
                self.infoOverlayViewContainer.coordinates.backgroundColor = AKHexColor(0x9B2C32)
                
                self.infoOverlayViewContainer.startAnimation()
                
                // Disable Record button.
                self.startRecordingTravel.enabled = false
                UIView.animateWithDuration(1.0, animations: { () -> () in self.startRecordingTravel.backgroundColor = AKHexColor(0xBB5C5A) })
            }
        )
    }
    
    @IBAction func stopRecordingTravel(sender: AnyObject)
    {
        self.stopRecording(
            { Void -> Void in
                // Revert color of info overlay.
                self.infoOverlayViewSubView.backgroundColor = AKHexColor(0x253B49)
                self.infoOverlayViewContainer.distance.backgroundColor = AKHexColor(0x08303A)
                self.infoOverlayViewContainer.speed.backgroundColor = AKHexColor(0x08303A)
                self.infoOverlayViewContainer.filteredPoints.backgroundColor = AKHexColor(0x08303A)
                self.infoOverlayViewContainer.coordinates.backgroundColor = AKHexColor(0x08303A)
                
                self.infoOverlayViewContainer.stopAnimation()
                
                // Enable Record button.
                self.startRecordingTravel.enabled = true
                UIView.animateWithDuration(1.0, animations: { () -> () in self.startRecordingTravel.backgroundColor = GlobalConstants.AKEnabledButtonBg })
            }, completionTask: { Void -> Void in
                // Clear map.
                self.clearMap()
            }
        )
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
        
        // Clear previous data.
        self.clearMap()
        
        // Configure map.
        self.map.minimumZoomLevel = 8
        self.map.maximumZoomLevel = 18
        self.map.zoomLevel = 14
        self.map.userTrackingMode = MGLUserTrackingMode.Follow
        
        // Add map overlay for travel information.
        self.infoOverlayViewSubView = self.infoOverlayViewContainer.customView
        self.infoOverlayViewContainer.controller = self
        self.infoOverlayViewSubView.frame = CGRect(x: 0, y: 0, width: self.map.bounds.width, height: 60)
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
    }
    
    // MARK: Recording Methods
    func startRecording(beforeTask: Void -> Void, completionTask: Void -> Void)
    {
        beforeTask()
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
            self.startAnnotation.subtitle = String(format: "Lat: %f, Lng: %f", try self.travel.computeOrigin().lat, try self.travel.computeOrigin().lon)
            self.map.addAnnotation(self.startAnnotation)
        }
        catch {
            AKPresentMessageFromError("\(error)", controller: self)
            return
        }
    }
    
    func stopRecording(beforeTask: Void -> Void, completionTask: Void -> Void)
    {
        beforeTask()
        
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
            self.endAnnotation.subtitle = String(format: "Lat: %f, Lng: %f", try self.travel.computeDestination().lat, try self.travel.computeDestination().lon)
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
        alertController.addButton("Save", action: { () -> Void in
            AKDelegate().masterFile?.addTravel(self.travel)
            completionTask()
        })
        alertController.addButton("Discard", action: { () -> Void in
            completionTask()
        })
        alertController.showNotice(
            "Stop Travel",
            subTitle: "Do you want to save the travel...?",
            closeButtonTitle: nil,
            duration: 0.0
        )
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
                return GlobalConstants.AKTravelPathMarkerStrokeColor
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
            case GlobalConstants.AKTravelStopPointMarkTitle:
                return UIColor.redColor()
            default:
                return UIColor.clearColor()
            }
        }
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage?
    {
        if annotation.title == nil {
            return nil
        }
        else {
            switch annotation.title!! {
            case GlobalConstants.AKTravelStartAnnotationTitle, GlobalConstants.AKTravelEndAnnotationTitle:
                if let annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier(annotation.title!!) {
                    return annotationImage
                }
                else {
                    return MGLAnnotationImage(
                        image: AKCircleImageWithRadius(
                            10,
                            strokeColor: AKHexColor(0x000000),
                            strokeAlpha: 1.0,
                            fillColor: annotation.title!! == GlobalConstants.AKTravelStartAnnotationTitle ? AKHexColor(0x429867) : AKHexColor(0xE02130),
                            fillAlpha: 1.0), reuseIdentifier: annotation.title!!)
                }
            default:
                return nil
            }
        }
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool
    {
        return true
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
                self.infoOverlayViewContainer.speed.text = String(format: "%ikm/h", travelSegment.computeSpeed(UnitOfSpeed.KilometersPerHour))
                self.coordinates.append(CLLocationCoordinate2DMake(self.currentPosition.lat, self.currentPosition.lon))
                self.map.centerCoordinate = CLLocationCoordinate2DMake(self.currentPosition.lat, self.currentPosition.lon)
                self.drawPolyline()
            }
            
            // Execute detections.
            AKDetection.detect(self.map, travel: self.travel, travelSegment: travelSegment)
            
            // Update info label.
            self.infoOverlayViewContainer.coordinates.text = String(format: "%f : %f", self.currentPosition.lat, self.currentPosition.lon)
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
        self.startRecordingTravel.layer.cornerRadius = 4.0
        self.stopRecordingTravel.layer.cornerRadius = 4.0
        
        // Configure NavigationController.
        self.navigationItem.hidesBackButton = true
    }
    
    func clearMap()
    {
        self.coordinates.removeAll()
        
        if let annotations = self.map.annotations {
            self.map.removeAnnotations(annotations)
        }
        
        self.infoOverlayViewContainer.filteredPoints.text = String(format: "%iFP", 0)
        self.infoOverlayViewContainer.distance.text = String(format: "%.1fkm", 0.0)
        self.infoOverlayViewContainer.speed.text = String(format: "%ikm/h", 0.0)
        self.infoOverlayViewContainer.coordinates.text = String(format: "%f : %f", 0.0, 0.0)
    }
}
