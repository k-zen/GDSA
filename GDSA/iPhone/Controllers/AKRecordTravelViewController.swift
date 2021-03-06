import CoreLocation
import Foundation
import MapKit
import TSMessages
import UIKit

class AKOriginPointAnnotation: MKPointAnnotation {}
class AKDestinationPointAnnotation: MKPointAnnotation {}
class AKRoutePolyline: MKPolyline {}

class AKRecordTravelViewController: AKCustomViewController, MKMapViewDelegate
{
    // MARK: Properties
    private let addDIMOverlay = false
    private let originAnnotation: AKOriginPointAnnotation = AKOriginPointAnnotation()
    private let destinationAnnotation: AKDestinationPointAnnotation = AKDestinationPointAnnotation()
    private let infoOverlayViewContainer: AKTravelInfoOverlayView = AKTravelInfoOverlayView()
    private let stopsOverlayViewContainer: AKTravelStopsOverlayView = AKTravelStopsOverlayView()
    private let startRecordingPreRoutine: (AKRecordTravelViewController) -> Void = { (controller) -> Void in
        // Clear map.
        controller.clearMap()
    }
    private let startRecordingPostRoutine: (AKRecordTravelViewController) -> Void = { (controller) -> Void in
        // Change color of the info overlay.
        controller.infoOverlayViewSubView.backgroundColor = GlobalConstants.AKRed3
        controller.infoOverlayViewContainer.distance.backgroundColor = GlobalConstants.AKRed4
        controller.infoOverlayViewContainer.speed.backgroundColor = GlobalConstants.AKRed4
        controller.infoOverlayViewContainer.time.backgroundColor = GlobalConstants.AKRed4
        controller.infoOverlayViewContainer.coordinates.backgroundColor = GlobalConstants.AKRed4
        
        // Disable Record button.
        controller.startRecordingTravel.isEnabled = false
        UIView.animate(withDuration: 1.0, animations: { () -> () in
            controller.startRecordingTravel.backgroundColor = GlobalConstants.AKRed4
        })
        
        // Start stopwatch.
        controller.startTimeTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: controller,
            selector: #selector(AKRecordTravelViewController.stopWatchTicked as (AKRecordTravelViewController) -> () -> ()),
            userInfo: nil,
            repeats: true
        )
    }
    private let stopRecordingPreRoutine: (AKRecordTravelViewController) -> Void = { (controller) -> Void in
        // Revert color of info overlay.
        controller.infoOverlayViewSubView.backgroundColor = GlobalConstants.AKOverlaysBg
        controller.infoOverlayViewContainer.distance.backgroundColor = GlobalConstants.AKBg1
        controller.infoOverlayViewContainer.speed.backgroundColor = GlobalConstants.AKBg1
        controller.infoOverlayViewContainer.time.backgroundColor = GlobalConstants.AKBg1
        controller.infoOverlayViewContainer.coordinates.backgroundColor = GlobalConstants.AKBg1
        
        // Enable Record button.
        controller.startRecordingTravel.isEnabled = true
        UIView.animate(withDuration: 1.0, animations: { () -> () in
            controller.startRecordingTravel.backgroundColor = GlobalConstants.AKEnabledButtonBg
        })
        
        // Stop stopwatch.
        if let timer = controller.startTimeTimer {
            if timer.isValid {
                timer.invalidate()
            }
        }
    }
    private let stopRecordingPostRoutine: (AKRecordTravelViewController) -> Void = { (controller) -> Void in
        // Clear map.
        controller.clearMap()
    }
    private var infoOverlayViewSubView: UIView!
    private var stopsOverlayViewSubView: UIView!
    private var travel: AKTravel! = AKTravel()
    private var currentPosition: CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var coordinates: [CLLocationCoordinate2D] = []
    private var startTimeTimer: Timer?
    private var startTime: Int64 = 0
    
    // MARK: Outlets
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var startRecordingTravel: UIButton!
    @IBOutlet weak var pauseRecordingTravel: UIButton!
    @IBOutlet weak var stopRecordingTravel: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Actions
    @IBAction func startRecordingTravel(_ sender: AnyObject) { self.startRecording() }
    
    @IBAction func pauseRecordingTravel(_ sender: AnyObject) { }
    
    @IBAction func stopRecordingTravel(_ sender: AnyObject) { self.stopRecording() }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Clear previous data.
        self.clearMap()
    }
    
    // MARK: Recording Methods
    func startRecording()
    {
        self.startRecordingPreRoutine(self)
        defer {
            self.startRecordingPostRoutine(self)
        }
        
        NSLog("=> LOCATION SERVICES ==> START RECORDING TRAVEL ...")
        AKDelegate().recordingTravel = true
        
        // Compute travel origin.
        self.travel.addOrigin(AKDelegate().currentPosition)
        
        let origin = self.travel.computeOrigin()
        if CLLocationCoordinate2DIsValid(origin) {
            // Append origin to coordinates and center map.
            self.coordinates.append(origin)
            self.mapView.centerCoordinate = origin
            
            // Add start annotation.
            self.originAnnotation.coordinate = origin
            self.originAnnotation.title = "Origen"
            self.originAnnotation.subtitle = String(format: "Lat: %f, Lng: %f", origin.latitude, origin.longitude)
            self.mapView.addAnnotation(self.originAnnotation)
        }
        else {
            AKPresentTopMessage(self, type: TSMessageNotificationType.error, message: "Error en coordenadas. No es posible grabar el trayecto.")
        }
    }
    
    func stopRecording()
    {
        self.stopRecordingPreRoutine(self)
        
        if AKDelegate().recordingTravel {
            NSLog("=> LOCATION SERVICES ==> STOP RECORDING TRAVEL ...")
            AKDelegate().recordingTravel = false
            
            // Compute travel destination.
            self.travel.addDestination(self.currentPosition)
            
            let destination = self.travel.computeDestination()
            if CLLocationCoordinate2DIsValid(destination) {
                // Append origin to coordinates and center map.
                self.coordinates.append(destination)
                self.mapView.centerCoordinate = destination
                
                // Add end annotation.
                self.destinationAnnotation.coordinate = destination
                self.destinationAnnotation.title = "Destino"
                self.destinationAnnotation.subtitle = String(format: "Lat: %f, Lng: %f", destination.latitude, destination.longitude)
                self.mapView.addAnnotation(self.destinationAnnotation)
            }
            else {
                AKPresentTopMessage(self, type: TSMessageNotificationType.error, message: "Error en coordenadas. No es posible grabar el trayecto.")
            }
        }
        
        // Show menu.
        super.showMenu()
    }
    
    // MARK: MKMapViewDelegate Implementation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.isKind(of: AKOriginPointAnnotation.self) || annotation.isKind(of: AKDestinationPointAnnotation.self) {
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.title!!) {
                return annotationView
            }
            else {
                let customView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.title!!)
                customView.canShowCallout = true
                customView.layer.backgroundColor = UIColor.clear.cgColor
                customView.layer.cornerRadius = 6.0
                customView.layer.borderWidth = 0.0
                customView.layer.masksToBounds = true
                customView.image = AKCircleImageWithRadius(
                    10,
                    strokeColor: UIColor.white,
                    strokeAlpha: 1.00,
                    fillColor: GlobalConstants.AKOrange2,
                    fillAlpha: 1.00
                )
                customView.clipsToBounds = false
                
                return customView
            }
        }
        else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        if overlay.isKind(of: AKRoutePolyline.self) {
            let customOverlay = AKPathRenderer(polyline: overlay as! MKPolyline, colors: [GlobalConstants.AKTravelPathMarkerStrokeColor])
            customOverlay.lineWidth = 6.0
            customOverlay.border = true
            customOverlay.borderColor = UIColor.white
            
            return customOverlay
        }
        else if overlay.isKind(of: AKDIMOverlay.self) {
            return AKDIMOverlayRenderer(overlay: overlay, mapView: self.mapView)
        }
        else {
            return MKPolylineRenderer(overlay: overlay)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationCanShowCallout annotation: MKAnnotation) -> Bool { return true }
    
    // MARK: Observers
    func locationUpdated(_ notification: Notification)
    {
        OperationQueue.main.addOperation({ () -> Void in
            let travelSegment = (notification as NSNotification).userInfo!["data"] as! AKTravelSegment
            self.currentPosition = travelSegment.computeEnd()
            self.travel.addSegment(travelSegment)
            
            // Execute filters.
            if !AKFilters.filter(self.mapView, travel: self.travel, travelSegment: travelSegment) {
                if GlobalConstants.AKDebug {
                    NSLog("=> FILTERED POINT!")
                }
            }
            else {
                self.travel.addDistance(travelSegment.computeDistance(UnitOfLength.meter))
                self.infoOverlayViewContainer.distance.text = String(format: "%.1fkm", self.travel.computeDistance(UnitOfLength.kilometer))
                self.infoOverlayViewContainer.speed.text = String(format: "%ikm/h", travelSegment.computeSpeed(UnitOfSpeed.kilometersPerHour))
                self.coordinates.append(self.currentPosition)
                self.mapView.centerCoordinate = self.currentPosition
                self.drawPolyline()
            }
            
            // Execute detections.
            AKDetection.detect(self.mapView, travel: self.travel, travelSegment: travelSegment)
            
            // Update info labels.
            self.infoOverlayViewContainer.coordinates.text = String(format: "%f : %f", self.currentPosition.latitude, self.currentPosition.longitude)
            
            // Update stops labels.
            self.stopsOverlayViewContainer.stopsValue.text = String(format: "%i", self.travel.computeOverallStopCounter())
            let totalStopTime = Int32(self.travel.computeOverallStopTime(UnitOfTime.second))
            self.stopsOverlayViewContainer.totalStopsTimeValue.text = String(format: "%02d:%02d:%02d", (totalStopTime / 3600), ((totalStopTime / 60) % 60), (totalStopTime % 60))
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
                    return overlay.isKind(of: AKRoutePolyline.self)
                }
            }
            self.mapView.removeOverlays(overlaysToRemove)
        }
        
        self.mapView.add(line, level: MKOverlayLevel.aboveRoads)
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
            object: nil
        )
        
        // Configure map.
        self.mapView.userTrackingMode = MKUserTrackingMode.follow
        // self.mapView.showsScale = true
        // self.mapView.showsCompass = true
        self.mapView.showsTraffic = false
        
        // Add map overlay for travel information.
        self.infoOverlayViewSubView = self.infoOverlayViewContainer.customView
        self.infoOverlayViewContainer.controller = self
        self.infoOverlayViewSubView.frame = CGRect(x: 0, y: 0, width: self.mapView.bounds.width, height: 60)
        self.infoOverlayViewSubView.translatesAutoresizingMaskIntoConstraints = true
        self.infoOverlayViewSubView.clipsToBounds = true
        self.infoOverlayViewSubView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.mapView.addSubview(self.infoOverlayViewSubView)
        self.mapView.addConstraint(NSLayoutConstraint(
            item: self.infoOverlayViewSubView,
            attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal,
            toItem: self.mapView,
            attribute: NSLayoutAttribute.width,
            multiplier: 1.0,
            constant: 0.0
        ))
        
        // Add map overlay for travel stops.
        self.stopsOverlayViewSubView = self.stopsOverlayViewContainer.customView
        self.stopsOverlayViewContainer.controller = self
        self.stopsOverlayViewSubView.frame = CGRect(x: 0, y: self.mapView.bounds.height - 62, width: self.mapView.bounds.width, height: 62)
        self.stopsOverlayViewSubView.translatesAutoresizingMaskIntoConstraints = true
        self.stopsOverlayViewSubView.clipsToBounds = true
        self.stopsOverlayViewSubView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.mapView.addSubview(self.stopsOverlayViewSubView)
        self.mapView.addConstraint(NSLayoutConstraint(
            item: self.stopsOverlayViewSubView,
            attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal,
            toItem: self.mapView,
            attribute: NSLayoutAttribute.width,
            multiplier: 1.0,
            constant: 0.0
        ))
        
        if addDIMOverlay {
            self.mapView.add(
                AKDIMOverlay(mapView: self.mapView),
                level: MKOverlayLevel.aboveLabels
            )
        }
        
        // Set the menu.
        self.setupMenu("Verificación", message: "Qué desea hacer ... ?", type: UIAlertControllerStyle.actionSheet)
        self.addMenuAction(
            "Guardar Viaje",
            style: UIAlertActionStyle.default,
            handler: { (action) -> Void in
                AKDelegate().masterFile.addTravel(self.travel)
                self.stopRecordingPostRoutine(self)
        }
        )
        self.addMenuAction(
            "Descartar Viaje",
            style: UIAlertActionStyle.destructive,
            handler: { (action) -> Void in
                self.stopRecordingPostRoutine(self)
        }
        )
        self.addMenuAction(
            "Nada",
            style: UIAlertActionStyle.cancel,
            handler: { (action) -> Void in }
        )
        
        // Delegates
        self.mapView.delegate = self
        
        // Custom L&F.
        self.infoOverlayViewSubView.backgroundColor = GlobalConstants.AKOverlaysBg
        self.infoOverlayViewSubView.alpha = GlobalConstants.AKTravelInfoOlAlpha
        self.stopsOverlayViewSubView.backgroundColor = GlobalConstants.AKOverlaysBg
        self.stopsOverlayViewSubView.alpha = GlobalConstants.AKTravelInfoOlAlpha
        self.startRecordingTravel.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.pauseRecordingTravel.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.stopRecordingTravel.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        
        AKAddBorderDeco(
            self.actionView,
            color: GlobalConstants.AKDefaultViewBorderBg.cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness,
            position: CustomBorderDecorationPosition.bottom
        )
        AKAddBorderDeco(
            self.stopsOverlayViewSubView,
            color: GlobalConstants.AKDefaultViewBorderBg.cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness,
            position: CustomBorderDecorationPosition.bottom
        )
    }
    
    func clearMap()
    {
        self.coordinates.removeAll()
        
        if self.mapView.annotations.count > 0 {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        if self.mapView.overlays.count > 0 {
            let overlaysToRemove = self.mapView.overlays.filter({ (overlay) -> Bool in
                if overlay.isKind(of: AKRoutePolyline.self) {
                    return true
                }
                else {
                    return false
                }
            })
            self.mapView.removeOverlays(overlaysToRemove)
        }
        
        self.infoOverlayViewContainer.time.text = String(format: "00:00:00")
        self.infoOverlayViewContainer.distance.text = String(format: "%.1fkm", 0.0)
        self.infoOverlayViewContainer.speed.text = String(format: "%ikm/h", 0.0)
        self.infoOverlayViewContainer.coordinates.text = String(format: "%f : %f", 0.0, 0.0)
        
        // Reset
        self.startTime = 0
    }
    
    func stopWatchTicked()
    {
        self.startTime += 1
        self.infoOverlayViewContainer.time.text = String(format: "%02d:%02d:%02d", (startTime / 3600), ((startTime / 60) % 60), (startTime % 60))
    }
}
