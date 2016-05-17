import Mapbox
import UIKit

class CustomAnnotationView: MGLPointAnnotation {}

class AKRecordTravelViewController: AKCustomViewController, MGLMapViewDelegate
{
    // MARK: Properties
    var travel: AKTravel!
    private let startAnnotation = CustomAnnotationView()
    private let endAnnotation = CustomAnnotationView()
    private var coordinates: [CLLocationCoordinate2D] = []
    
    // MARK: Outlets
    @IBOutlet weak var distanceTraveled: UILabel!
    @IBOutlet weak var map: MGLMapView!
    
    // MARK: Actions
    @IBAction func stopRecordingTravel(sender: AnyObject)
    {
        NSLog("=> LOCATION SERVICES ==> STOP RECORDING TRAVEL ...")
        AKDelegate().locationManager.stopUpdatingLocation()
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
            try self.coordinates.append(CLLocationCoordinate2DMake(self.travel.computeTravelOrigin().latitude, self.travel.computeTravelOrigin().longitude))
            try startAnnotation.coordinate = CLLocationCoordinate2DMake(self.travel.computeTravelOrigin().latitude, self.travel.computeTravelOrigin().longitude)
            
            startAnnotation.title = "Start"
            endAnnotation.title = "End"
            
            self.map.addAnnotation(startAnnotation)
            try self.map.centerCoordinate = CLLocationCoordinate2DMake(self.travel.computeTravelOrigin().latitude, self.travel.computeTravelOrigin().longitude)
            self.map.zoomLevel = 14
            // self.map.userTrackingMode = MGLUserTrackingMode.FollowWithHeading
        }
        catch {
            AKPresentMessageFromError("\(error)", controller: self)
            return
        }
    }
    
    // MARK: MGLMapViewDelegate Implementation
    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat { return 1 }
    
    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat { return 4.0 }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor
    {
        if (annotation.title == "Crema to Council Crest" && annotation is MGLPolyline) {
            return UIColor(red: 59/255, green:178/255, blue:208/255, alpha:1)
        }
        else {
            return UIColor.redColor()
        }
    }
    
    // MARK: Observers
    func locationUpdated(notification: NSNotification)
    {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            let travelSegment = notification.userInfo!["data"] as! AKTravelSegment
            
            self.travel.addSegment(travelSegment.travelDistance)
            self.distanceTraveled.text = String(format: "%.0f", self.travel.computeTravelDistance())
            
            let coordinate = CLLocationCoordinate2DMake(travelSegment.pointB.latitude, travelSegment.pointB.longitude)
            self.coordinates.append(coordinate)
            
            self.map.centerCoordinate = coordinate
            
            self.drawPolyline()
        })
    }
    
    // MARK: Utilities
    func drawPolyline() {
        let line = MGLPolyline(coordinates: &self.coordinates, count: UInt(coordinates.count))
        line.title = "Crema to Council Crest"
        
        if self.map.annotations?.count > 0 {
            let annotationsToRemove = self.map.annotations!.filter { $0 !== self.startAnnotation }
            self.map.removeAnnotations(annotationsToRemove)
        }
        self.map.addAnnotation(line)
    }
}
