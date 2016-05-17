import CoreLocation
import Foundation
import UIKit

// MARK: Extensions
extension Int
{
    func modulo(divisor: Int) -> Int
    {
        var result = self % divisor
        if (result < 0) {
            result += divisor
        }
        
        return result
    }
}

extension String
{
    func splitOnNewLine () -> [String]
    {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }
}

// MARK: Structures
/// The user's location.
struct UserLocation {
    /// Denotes the user's geographic latitude.
    var latitude: Double
    /// Denotes the user's geographic longitude.
    var longitude: Double
}

// MARK: Global Constants
struct GlobalConstants {
    static let AKLocationUpdateInterval = 15
}

// MARK: Global Enumerations
enum ErrorCodes: Int {
    case GENERIC = 1000
}

// MARK: Global Functions
/// Executes a function with a delay.
///
/// - Parameter delay: The delay.
/// - Parameter task:  The function to execute.
func AKDelay(delay: Double, task: Void -> Void)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), task)
}

/// Returns the App's delegate object.
///
/// - Returns: The App's delegate object.
func AKDelegate() -> AKAppDelegate { return UIApplication.sharedApplication().delegate as! AKAppDelegate }

/// Computes the distance between two points and returns the distance in meters.
///
/// - Parameter pointALat: Point A latitude. (Y)
/// - Parameter pointALon: Point A longitude. (X)
/// - Parameter pointBLat: Point B latitude. (Y)
/// - Parameter pointBLon: Point B longitude. (X)
///
/// - Returns: TRUE if within range, FALSE otherwise.
func AKComputeDistanceBetweenTwoPoints(pointALat pointALat: CLLocationDegrees,
                                                 pointALon: CLLocationDegrees,
                                                 pointBLat: CLLocationDegrees,
                                                 pointBLon: CLLocationDegrees) -> CLLocationDistance
{
    let pointA = CLLocation(latitude: pointALat, longitude: pointALon)
    let pointB = CLLocation(latitude: pointBLat, longitude: pointBLon)
    
    return pointA.distanceFromLocation(pointB)
}
