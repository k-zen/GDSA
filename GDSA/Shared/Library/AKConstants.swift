import AudioToolbox
import CoreLocation
import Foundation
import TSMessages
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
    static let AKLocationUpdateInterval = 6
    static let AKLocationUpdateNotificationName = "LocationUpdate"
    static let AKNotificationBarDismissDelay = 8
    static let AKNotificationBarSound = 1057
    static let AKPointDiscardRadius = 50.0
    static let AKTravelStartAnnotationTitle = "Start_Annotation"
    static let AKTravelEndAnnotationTitle = "End_Annotation"
    static let AKTravelSegmentAnnotationTitle = "Travel_Segment"
    static let AKTravelPathMarkerColor: UIColor = AKHexColor(0x0D9FB6)
}

// MARK: Global Enumerations
enum ErrorCodes: Int {
    case GENERIC = 1000
}

enum Exceptions: ErrorType
{
    case NotInitialized(String)
    case EmptyData(String)
    case InvalidLength(String)
    case NotValid(String)
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
/// - Parameter pointA: Point A location.
/// - Parameter pointB: Point B location.
///
/// - Returns: TRUE if within range, FALSE otherwise.
func AKComputeDistanceBetweenTwoPoints(pointA pointA: UserLocation,
                                              pointB: UserLocation) -> CLLocationDistance
{
    let pointA = CLLocation(latitude: pointA.latitude, longitude: pointA.longitude)
    let pointB = CLLocation(latitude: pointB.latitude, longitude: pointB.longitude)
    
    return pointA.distanceFromLocation(pointB)
}

/// Computes and generates a **UIColor** object based
/// on it's hexadecimal representation.
///
/// - Parameter hex: The hexadecimal representation of the color.
///
/// - Returns: A **UIColor** object.
func AKHexColor(hex: UInt) -> UIColor
{
    let red = CGFloat((hex >> 16) & 0xFF) / 255.0
    let green = CGFloat((hex >> 8) & 0xFF) / 255.0
    let blue = CGFloat((hex) & 0xFF) / 255.0
    
    return UIColor.init(red: red, green: green, blue: blue, alpha: 1)
}

func AKPresentTopMessageInfo(presenter: AKCustomViewController!, title: String! = "Information", message: String!)
{
    TSMessage.showNotificationInViewController(
        presenter,
        title: title,
        subtitle: message,
        image: nil,
        type: TSMessageNotificationType.Message,
        duration: NSTimeInterval(GlobalConstants.AKNotificationBarDismissDelay),
        callback: nil,
        buttonTitle: nil,
        buttonCallback: {},
        atPosition: TSMessageNotificationPosition.Top,
        canBeDismissedByUser: true
    )
    AudioServicesPlaySystemSound(UInt32(GlobalConstants.AKNotificationBarSound))
}

func AKPresentTopMessageWarn(presenter: AKCustomViewController!, title: String! = "Warning", message: String!)
{
    TSMessage.showNotificationInViewController(
        presenter,
        title: title,
        subtitle: message,
        image: nil,
        type: TSMessageNotificationType.Warning,
        duration: NSTimeInterval(GlobalConstants.AKNotificationBarDismissDelay),
        callback: nil,
        buttonTitle: nil,
        buttonCallback: {},
        atPosition: TSMessageNotificationPosition.Top,
        canBeDismissedByUser: true
    )
    AudioServicesPlaySystemSound(UInt32(GlobalConstants.AKNotificationBarSound))
}

func AKPresentTopMessageError(presenter: AKCustomViewController!, title: String! = "Error", message: String!)
{
    TSMessage.showNotificationInViewController(
        presenter,
        title: title,
        subtitle: message,
        image: nil,
        type: TSMessageNotificationType.Error,
        duration: NSTimeInterval(GlobalConstants.AKNotificationBarDismissDelay),
        callback: nil,
        buttonTitle: nil,
        buttonCallback: {},
        atPosition: TSMessageNotificationPosition.Top,
        canBeDismissedByUser: true
    )
    AudioServicesPlaySystemSound(UInt32(GlobalConstants.AKNotificationBarSound))
}

func AKPresentTopMessageSuccess(presenter: AKCustomViewController!, title: String! = "Message", message: String!)
{
    TSMessage.showNotificationInViewController(
        presenter,
        title: title,
        subtitle: message,
        image: nil,
        type: TSMessageNotificationType.Success,
        duration: NSTimeInterval(GlobalConstants.AKNotificationBarDismissDelay),
        callback: nil,
        buttonTitle: nil,
        buttonCallback: {},
        atPosition: TSMessageNotificationPosition.Top,
        canBeDismissedByUser: true
    )
    AudioServicesPlaySystemSound(UInt32(GlobalConstants.AKNotificationBarSound))
}

func AKPresentMessageFromError(errorMessage: String = "", controller: AKCustomViewController!)
{
    do {
        let input = errorMessage
        let regex = try NSRegularExpression(pattern: ".*\"(.*)\"", options: NSRegularExpressionOptions.CaseInsensitive)
        let matches = regex.matchesInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        
        if let match = matches.first {
            let range = match.rangeAtIndex(1)
            if let swiftRange = AKRangeFromNSRange(range, forString: input) {
                let msg = input.substringWithRange(swiftRange)
                AKPresentTopMessageError(controller, message: msg)
            }
        }
    }
    catch {
        NSLog("=> Generic Error ==> %@", "\(error)")
    }
}

func AKRangeFromNSRange(nsRange: NSRange, forString str: String) -> Range<String.Index>?
{
    let fromUTF16 = str.utf16.startIndex.advancedBy(nsRange.location, limit: str.utf16.endIndex)
    let toUTF16 = fromUTF16.advancedBy(nsRange.length, limit: str.utf16.endIndex)
    
    if let from = String.Index(fromUTF16, within: str), let to = String.Index(toUTF16, within: str) {
        return from ..< to
    }
    
    return nil
}
