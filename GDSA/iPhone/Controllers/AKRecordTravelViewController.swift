import CoreLocation
import Foundation
import Mapbox
import UIKit

class AKRecordTravelViewController: AKCustomViewController, MGLMapViewDelegate
{
    // MARK: Properties
    private let infoOverlayViewContainer: AKTravelInfoOverlayView = AKTravelInfoOverlayView()
    private var infoOverlayViewSubView: UIView!
    private var travel: AKTravel! = AKTravel()
    private var startAnnotation: MGLPolygon?
    private var endAnnotation: MGLPolygon?
    private var currentPosition: UserLocation?
    private var coordinates: [CLLocationCoordinate2D] = []
    
    // MARK: Outlets
    @IBOutlet weak var stopRecordingTravel: UIButton!
    @IBOutlet weak var map: MGLMapView!
    
    // MARK: Actions
    @IBAction func stopRecordingTravel(sender: AnyObject)
    {
        self.stopRecording({ Void -> Void in self.navigationController?.popViewControllerAnimated(true) })
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
        self.map.maximumZoomLevel = 15
        self.map.zoomLevel = 14
        self.map.userTrackingMode = MGLUserTrackingMode.Follow
        
        // Add map overlay for travel information.
        self.infoOverlayViewSubView = self.infoOverlayViewContainer.customView
        self.infoOverlayViewContainer.controller = self
        self.infoOverlayViewSubView.frame = CGRect(x: 0, y: 0, width: self.map.bounds.width, height: 21)
        self.infoOverlayViewSubView.translatesAutoresizingMaskIntoConstraints = true
        self.infoOverlayViewSubView.clipsToBounds = true
        self.infoOverlayViewSubView.autoresizingMask = [.FlexibleWidth]
        
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
        self.travel.addTravelOrigin(UserLocation(latitude: AKDelegate().currentLatitude, longitude: AKDelegate().currentLongitude))
        
        do {
            // Append origin to coordinates and center map.
            self.coordinates.append(try self.travel.computeTravelOriginAsCoordinate())
            self.map.centerCoordinate = try self.travel.computeTravelOriginAsCoordinate()
            
            // Add start annotation.
            self.startAnnotation = self.createCircleForCoordinate(
                GlobalConstants.AKTravelStartAnnotationTitle,
                coordinate: try self.travel.computeTravelOriginAsCoordinate(), withMeterRadius: 25.0)
            self.map.addAnnotation(self.startAnnotation!)
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
        self.travel.addTravelDestination(UserLocation(latitude: self.currentPosition!.latitude, longitude: self.currentPosition!.longitude))
        
        do {
            // Append origin to coordinates and center map.
            self.coordinates.append(try self.travel.computeTravelDestinationAsCoordinate())
            self.map.centerCoordinate = try self.travel.computeTravelDestinationAsCoordinate()
            
            // Add end annotation.
            self.endAnnotation = self.createCircleForCoordinate(
                GlobalConstants.AKTravelEndAnnotationTitle,
                coordinate: try self.travel.computeTravelDestinationAsCoordinate(),
                withMeterRadius: 25.0)
            self.map.addAnnotation(self.endAnnotation!)
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
                return 2.5
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
            case GlobalConstants.AKTravelStartAnnotationTitle, GlobalConstants.AKTravelEndAnnotationTitle, GlobalConstants.AKTravelSegmentAnnotationTitle:
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
            case GlobalConstants.AKTravelStartAnnotationTitle, GlobalConstants.AKTravelEndAnnotationTitle, GlobalConstants.AKTravelSegmentAnnotationTitle:
                return GlobalConstants.AKTravelPathMarkerColor
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
            self.currentPosition = UserLocation(latitude: travelSegment.pointB.latitude, longitude: travelSegment.pointB.longitude)
            
            // If point is within 50 meters of the origin, discard it.
            do {
                let travelOrigin = try self.travel.computeTravelOrigin()
                if AKComputeDistanceBetweenTwoPoints(pointA: travelOrigin, pointB: self.currentPosition!) < GlobalConstants.AKPointDiscardRadius {
                    NSLog("=> DISCARDING POINT BECAUSE IT'S TOO CLOSE TO ORIGIN!")
                    return
                }
            }
            catch {
                AKPresentMessageFromError("\(error)", controller: self)
                return
            }
            
            let coordinate = CLLocationCoordinate2DMake(self.currentPosition!.latitude, self.currentPosition!.longitude)
            self.travel.addSegment(travelSegment.travelDistance)
            self.infoOverlayViewContainer.distance.text = String(format: "%.3fkm", self.travel.computeTravelDistance()/1000)
            self.coordinates.append(coordinate)
            self.map.centerCoordinate = coordinate
            self.drawPolyline()
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
                    case GlobalConstants.AKTravelStartAnnotationTitle, GlobalConstants.AKTravelEndAnnotationTitle:
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
    
    func createCircleForCoordinate(title: String, coordinate: CLLocationCoordinate2D, withMeterRadius: Double) -> MGLPolygon
    {
        let degreesBetweenPoints = 8.0
        let numberOfPoints = floor(360.0 / degreesBetweenPoints)
        let distRadians: Double = withMeterRadius / 6371000.0
        let centerLatRadians: Double = coordinate.latitude * M_PI / 180
        let centerLonRadians: Double = coordinate.longitude * M_PI / 180
        var coordinates = [CLLocationCoordinate2D]()
        
        for index in 0 ..< Int(numberOfPoints) {
            let degrees: Double = Double(index) * Double(degreesBetweenPoints)
            let degreeRadians: Double = degrees * M_PI / 180
            let pointLatRadians: Double = asin(sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(degreeRadians))
            let pointLonRadians: Double = centerLonRadians + atan2(sin(degreeRadians) * sin(distRadians) * cos(centerLatRadians), cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians))
            let pointLat: Double = pointLatRadians * 180 / M_PI
            let pointLon: Double = pointLonRadians * 180 / M_PI
            let point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(pointLat, pointLon)
            
            coordinates.append(point)
        }
        
        let polygon = MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
        polygon.title = title
        
        return polygon
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
