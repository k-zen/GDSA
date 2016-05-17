import CoreLocation
import Foundation
import UIKit

@UIApplicationMain
class AKAppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate
{
    // MARK: Properties
    let locationManager: CLLocationManager! = CLLocationManager()
    var window: UIWindow?
    private var currentLatitude: Double = 0.0
    private var currentLongitude: Double = 0.0
    private var lastSavedLatitude: Double = 0.0
    private var lastSavedLongitude: Double = 0.0
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
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Manage Location Services
        if CLLocationManager.locationServicesEnabled() {
            // Configure Location Services
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
        
        return true
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let currentLocation = locations.last
        
        // Always save the current location.
        self.currentLatitude = (currentLocation?.coordinate.latitude)!
        self.currentLongitude = (currentLocation?.coordinate.longitude)!
        
        // Compute travel segment in regular intervals.
        if Int(NSDate().timeIntervalSince1970 - self.lastSavedTime) < GlobalConstants.AKLocationUpdateInterval {
            return
        }
        else {
            let travelSegment = AKTravelSegment(pointALatitude: self.lastSavedLatitude,
                                                pointALongitude: self.lastSavedLongitude,
                                                pointBLatitude: self.currentLatitude,
                                                pointBLongitude: self.currentLongitude,
                                                travelTime: (NSDate().timeIntervalSince1970 - self.lastSavedTime))
            
            if travelSegment.shouldSave() {
                travelSegment.printObject()
                
                NSNotificationCenter.defaultCenter().postNotificationName("LocationUpdate", object: self, userInfo: [ "data" : travelSegment ])
            }
            
            self.lastSavedTime = NSDate().timeIntervalSince1970
            self.lastSavedLatitude = self.currentLatitude
            self.lastSavedLongitude = self.currentLongitude
        }
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
            break
        case .Restricted, .Denied:
            NSLog("=> LOCATION SERVICES ==> DENIED")
            break
        default:
            break
        }
    }
}
