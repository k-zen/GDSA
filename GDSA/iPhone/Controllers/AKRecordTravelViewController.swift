import CoreLocation
import Foundation
import MapKit
import SCLAlertView
import UIKit

class AKOriginPointAnnotation: MKPointAnnotation {}
class AKDestinationPointAnnotation: MKPointAnnotation {}
class AKRoutePolyline: MKPolyline {}

class AKRecordTravelViewController: AKCustomViewController, MKMapViewDelegate
{
    // MARK: Properties
    private let originAnnotation: AKOriginPointAnnotation = AKOriginPointAnnotation()
    private let destinationAnnotation: AKDestinationPointAnnotation = AKDestinationPointAnnotation()
    private let infoOverlayViewContainer: AKTravelInfoOverlayView = AKTravelInfoOverlayView()
    private var infoOverlayViewSubView: UIView!
    private var travel: AKTravel! = AKTravel()
    private var currentPosition: UserLocation = UserLocation()
    private var coordinates: [CLLocationCoordinate2D] = []
    private var filteredPointsCounter: Int = 0
    
    // MARK: Outlets
    @IBOutlet weak var startRecordingTravel: UIButton!
    @IBOutlet weak var stopRecordingTravel: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
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
                UIView.animateWithDuration(1.0, animations: { () -> () in self.startRecordingTravel.backgroundColor = AKHexColor(0x9B2C32) })
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
        self.mapView.userTrackingMode = MKUserTrackingMode.Follow
        // self.mapView.showsScale = true
        // self.mapView.showsCompass = true
        self.mapView.showsTraffic = false
        
        // Add map overlay for travel information.
        self.infoOverlayViewSubView = self.infoOverlayViewContainer.customView
        self.infoOverlayViewContainer.controller = self
        self.infoOverlayViewSubView.frame = CGRect(x: 0, y: 0, width: self.mapView.bounds.width, height: 60)
        self.infoOverlayViewSubView.translatesAutoresizingMaskIntoConstraints = true
        self.infoOverlayViewSubView.clipsToBounds = true
        self.infoOverlayViewSubView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.mapView.addSubview(self.infoOverlayViewSubView)
        
        let constraintWidth = NSLayoutConstraint(
            item: self.infoOverlayViewSubView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.mapView,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1.0,
            constant: 0.0
        )
        self.mapView.addConstraint(constraintWidth)
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
            self.mapView.centerCoordinate = try self.travel.computeOriginAsCoordinate()
            
            // Add start annotation.
            self.originAnnotation.coordinate = try self.travel.computeOriginAsCoordinate()
            self.originAnnotation.title = "Origen"
            self.originAnnotation.subtitle = String(format: "Lat: %f, Lng: %f", try self.travel.computeOrigin().lat, try self.travel.computeOrigin().lon)
            self.mapView.addAnnotation(self.originAnnotation)
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
            self.mapView.centerCoordinate = try self.travel.computeDestinationAsCoordinate()
            
            // Add end annotation.
            self.destinationAnnotation.coordinate = try self.travel.computeDestinationAsCoordinate()
            self.destinationAnnotation.title = "Destino"
            self.destinationAnnotation.subtitle = String(format: "Lat: %f, Lng: %f", try self.travel.computeDestination().lat, try self.travel.computeDestination().lon)
            self.mapView.addAnnotation(self.destinationAnnotation)
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
    
    // MARK: MKMapViewDelegate Implementation
    func mapView(mapView: MKMapView, alphaForShapeAnnotation annotation: MKShape) -> CGFloat
    {
        if annotation.title == nil {
            return 1.0
        }
        else {
            switch annotation.title! {
            default:
                return 1.0
            }
        }
    }
    
    func mapView(mapView: MKMapView, lineWidthForPolylineAnnotation annotation: MKPolyline) -> CGFloat
    {
        if annotation.title == nil {
            return 1.0
        }
        else {
            switch annotation.title! {
            default:
                return 1.0
            }
        }
    }
    
    func mapView(mapView: MKMapView, strokeColorForShapeAnnotation annotation: MKShape) -> UIColor
    {
        if annotation.title == nil {
            return UIColor.clearColor()
        }
        else {
            switch annotation.title! {
            default:
                return UIColor.clearColor()
            }
        }
    }
    
    func mapView(mapView: MKMapView, fillColorForPolygonAnnotation annotation: MKPolygon) -> UIColor
    {
        if annotation.title == nil {
            return UIColor.clearColor()
        }
        else {
            switch annotation.title! {
            default:
                return UIColor.redColor()
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.isKindOfClass(AKOriginPointAnnotation) || annotation.isKindOfClass(AKDestinationPointAnnotation) {
            if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotation.title!!) {
                return annotationView
            }
            else {
                let customView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.title!!)
                customView.canShowCallout = true
                customView.layer.backgroundColor = UIColor.clearColor().CGColor
                customView.layer.cornerRadius = 6.0
                customView.layer.borderWidth = 0.0
                customView.layer.masksToBounds = true
                customView.image = AKCircleImageWithRadius(10, strokeColor: AKHexColor(0x000000), strokeAlpha: 1.0, fillColor: annotation.isKindOfClass(AKOriginPointAnnotation) ? AKHexColor(0x429867) : AKHexColor(0xE02130), fillAlpha: 1.0)
                customView.clipsToBounds = false
                
                return customView
            }
        }
        else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer
    {
        if overlay.isKindOfClass(AKRoutePolyline) {
            let customOverlay = MKPolylineRenderer(overlay: overlay)
            customOverlay.alpha = 1.0
            customOverlay.lineWidth = 3.5
            customOverlay.strokeColor = GlobalConstants.AKTravelPathMarkerStrokeColor
            customOverlay.lineDashPattern = [5]
            customOverlay.lineCap = CGLineCap.Square
            customOverlay.lineJoin = CGLineJoin.Round
            
            return customOverlay
        }
        else {
            return MKPolylineRenderer(overlay: overlay)
        }
    }
    
    func mapView(mapView: MKMapView, annotationCanShowCallout annotation: MKAnnotation) -> Bool { return true }
    
    // MARK: Observers
    func locationUpdated(notification: NSNotification)
    {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            let travelSegment = notification.userInfo!["data"] as! AKTravelSegment
            self.currentPosition = UserLocation(lat: travelSegment.computeEnd().lat, lon: travelSegment.computeEnd().lon)
            self.travel.addSegment(travelSegment)
            
            // Execute filters.
            if !AKFilters.filter(self.mapView, travel: self.travel, travelSegment: travelSegment) {
                self.filteredPointsCounter += 1
                self.infoOverlayViewContainer.filteredPoints.text = String(format: "%iFP", self.filteredPointsCounter)
            }
            else {
                self.travel.addDistance(travelSegment.computeDistance(UnitOfLength.Meter))
                self.infoOverlayViewContainer.distance.text = String(format: "%.1fkm", self.travel.computeDistance(UnitOfLength.Kilometer))
                self.infoOverlayViewContainer.speed.text = String(format: "%ikm/h", travelSegment.computeSpeed(UnitOfSpeed.KilometersPerHour))
                self.coordinates.append(CLLocationCoordinate2DMake(self.currentPosition.lat, self.currentPosition.lon))
                self.mapView.centerCoordinate = CLLocationCoordinate2DMake(self.currentPosition.lat, self.currentPosition.lon)
                self.drawPolyline()
            }
            
            // Execute detections.
            AKDetection.detect(self.mapView, travel: self.travel, travelSegment: travelSegment)
            
            // Update info label.
            self.infoOverlayViewContainer.coordinates.text = String(format: "%f : %f", self.currentPosition.lat, self.currentPosition.lon)
        })
    }
    
    // MARK: Utilities
    func drawPolyline() {
        let line = AKRoutePolyline(coordinates: &self.coordinates, count: Int(coordinates.count))
        
        if self.mapView.overlays.count > 0 {
            let overlaysToRemove = self.mapView.overlays.filter {
                let overlay = $0
                
                if overlay.title == nil {
                    return true
                }
                else {
                    return overlay.isKindOfClass(AKRoutePolyline)
                }
            }
            self.mapView.removeOverlays(overlaysToRemove)
        }
        
        self.mapView.addOverlay(line, level: MKOverlayLevel.AboveRoads)
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
        self.mapView.delegate = self
        
        // Custom L&F.
        self.startRecordingTravel.layer.cornerRadius = 4.0
        self.stopRecordingTravel.layer.cornerRadius = 4.0
        
        // Configure NavigationController.
        self.navigationItem.hidesBackButton = true
    }
    
    func clearMap()
    {
        self.coordinates.removeAll()
        
        if self.mapView.annotations.count > 0 {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        if self.mapView.overlays.count > 0 {
            self.mapView.removeOverlays(self.mapView.overlays)
        }
        
        self.infoOverlayViewContainer.filteredPoints.text = String(format: "%iFP", 0)
        self.infoOverlayViewContainer.distance.text = String(format: "%.1fkm", 0.0)
        self.infoOverlayViewContainer.speed.text = String(format: "%ikm/h", 0.0)
        self.infoOverlayViewContainer.coordinates.text = String(format: "%f : %f", 0.0, 0.0)
    }
}
