import CoreLocation
import Foundation
import Mapbox
import UIKit

class AKRecordTravelViewController: AKCustomViewController, MGLMapViewDelegate
{
    // MARK: Properties
    var travel: AKTravel!
    private var startAnnotation: MGLPointAnnotation = MGLPointAnnotation()
    private var endAnnotation: MGLPointAnnotation = MGLPointAnnotation()
    private var currentPosition: UserLocation?
    private var coordinates: [CLLocationCoordinate2D] = []
    
    // MARK: Outlets
    @IBOutlet weak var distanceTraveled: UILabel!
    @IBOutlet weak var map: MGLMapView!
    
    // MARK: Actions
    @IBAction func stopRecordingTravel(sender: AnyObject)
    {
        NSLog("=> LOCATION SERVICES ==> STOP RECORDING TRAVEL ...")
        AKDelegate().recordingTravel = false
        
        self.travel.addTravelDestination(UserLocation(latitude: self.currentPosition!.latitude, longitude: self.currentPosition!.longitude))
        
        do {
            self.endAnnotation.coordinate = try self.travel.computeTravelDestinationAsCoordinate()
            self.endAnnotation.title = GlobalConstants.AKTravelEndAnnotationTitle
            self.map.addAnnotation(endAnnotation)
        }
        catch {
            AKPresentMessageFromError("\(error)", controller: self)
            return
        }
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AKRecordTravelViewController.locationUpdated), name: GlobalConstants.AKLocationUpdateNotificationName, object: nil)
        
        // Delegates
        self.map.delegate = self
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        do {
            self.coordinates.append(try self.travel.computeTravelOriginAsCoordinate())
            self.map.centerCoordinate = try self.travel.computeTravelOriginAsCoordinate()
            self.startAnnotation.coordinate = try self.travel.computeTravelOriginAsCoordinate()
            self.startAnnotation.title = GlobalConstants.AKTravelStartAnnotationTitle
            
            self.map.addAnnotation(startAnnotation)
            self.map.minimumZoomLevel = 8
            self.map.maximumZoomLevel = 15
            self.map.zoomLevel = 14
            self.map.userTrackingMode = MGLUserTrackingMode.Follow
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
            case "Travel_Segment":
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
            case "Travel_Segment":
                return AKHexColor(0x0D9FB6)
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
            case "Travel_Segment":
                return AKHexColor(0x0D9FB6)
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
            self.distanceTraveled.text = String(format: "%.0f", self.travel.computeTravelDistance())
            self.coordinates.append(coordinate)
            self.map.centerCoordinate = coordinate
            self.drawPolyline()
        })
    }
    
    // MARK: Utilities
    func drawPolyline() {
        let line = MGLPolyline(coordinates: &self.coordinates, count: UInt(coordinates.count))
        line.title = "Travel_Segment"
        
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
}
