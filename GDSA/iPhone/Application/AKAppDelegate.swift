import CoreLocation
import Foundation
import UIKit

@UIApplicationMain
class AKAppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate
{
    // MARK: Properties
    let locationManager: CLLocationManager! = CLLocationManager()
    var masterFile: AKMasterFile?
    var window: UIWindow?
    // ### USER POSITION ### //
    var currentPosition: UserLocation = UserLocation()
    var currentHeading: CLLocationDirection = CLLocationDirection(0.0)
    private var lastSavedPosition: UserLocation = UserLocation()
    // ### USER POSITION ### //
    var recordingTravel: Bool = false
    private var lastSavedTime: Double = 0.0
    // The state of the App. False = Disabled because Location Service is disabled.
    var applicationActive: Bool! = true {
        didSet {
            if !applicationActive {
                NSLog("=> THE APP HAS BEEN DISABLED!")
            }
        }
    }
    
    // MARK: UIApplicationDelegate Implementation
    func applicationWillResignActive(application: UIApplication)
    {
        do {
            NSLog("=> SAVING *MASTER FILE* TO FILE.")
            try AKFileUtils.write(GlobalConstants.AKMasterFileName, newData: self.masterFile!)
        }
        catch {
            NSLog("=> ERROR: \(error)")
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        do {
            NSLog("=> READING *MASTER FILE* FROM FILE.")
            self.masterFile = try AKFileUtils.read(GlobalConstants.AKMasterFileName) as? AKMasterFile
        }
        catch {
            NSLog("=> ERROR: \(error)")
        }
        
        // LOOK & FEEL CUSTOMIZATIONS.
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBold", size: 16.0)!]
        
        // Manage Location Services
        if CLLocationManager.locationServicesEnabled() {
            // Configure Location Services
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
        
        // Start heading updates.
        if CLLocationManager.headingAvailable() {
            self.locationManager.headingFilter = 5
        }
        else {
            NSLog("=> HEADING NOT AVAILABLE.")
        }
        
        return true
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let currentLocation = locations.last
        
        // Always save the current location.
        self.currentPosition.lat = (currentLocation?.coordinate.latitude)!
        self.currentPosition.lon = (currentLocation?.coordinate.longitude)!
        
        NSLog("=> CURRENT LAT: %f, CURRENT LON: %f", self.currentPosition.lat, self.currentPosition.lon)
        
        if !self.recordingTravel {
            return
        }
        
        // Compute travel segment in regular intervals.
        if Int(NSDate().timeIntervalSince1970 - self.lastSavedTime) < GlobalConstants.AKLocationUpdateInterval {
            return
        }
        else {
            let pointA = UserLocation(lat: self.lastSavedPosition.lat, lon: self.lastSavedPosition.lon)
            let pointB = UserLocation(lat: self.currentPosition.lat, lon: self.currentPosition.lon)
            
            let travelSegment = AKTravelSegment(str: pointA, end: pointB, time: (NSDate().timeIntervalSince1970 - self.lastSavedTime))
            
            if travelSegment.shouldSave() {
                if GlobalConstants.AKDebug {
                    NSLog("=> ### NEWLY DETECTED SEGMENT")
                    NSLog("%@", travelSegment.printObject("=> "))
                    NSLog("=> ### NEWLY DETECTED SEGMENT")
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.AKLocationUpdateNotificationName, object: self, userInfo: [ "data" : travelSegment ])
            }
            
            self.lastSavedTime = NSDate().timeIntervalSince1970
            self.lastSavedPosition.lat = self.currentPosition.lat
            self.lastSavedPosition.lon = self.currentPosition.lon
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    {
        if newHeading.headingAccuracy < 0 { return }
        
        self.currentHeading = ((newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading)
        NSLog("=> CURRENT HEADING: %f", self.currentHeading)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) { NSLog("=> LOCATION SERVICES ERROR ==> %@", error.description) }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) { NSLog("=> LOCATION SERVICES HAS PAUSED.") }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) { NSLog("=> LOCATION SERVICES HAS RESUMED.") }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedWhenInUse:
            NSLog("=> LOCATION SERVICES ==> AUTHORIZED WHEN IN USE")
            NSLog("=> READY TO START RECORDING TRAVELS.")
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
            break
        case .Restricted, .Denied:
            NSLog("=> LOCATION SERVICES ==> DENIED")
            break
        default:
            break
        }
    }
}
