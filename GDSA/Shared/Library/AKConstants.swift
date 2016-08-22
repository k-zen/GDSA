import AudioToolbox
import CoreLocation
import Foundation
import MapKit
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
    var lat: Double = 0.0
    /// Denotes the user's geographic longitude.
    var lon: Double = 0.0
}

// MARK: Global Constants
struct GlobalConstants {
    static let AKDebug = true
    static let AKLocationUpdateInterval = 6
    static let AKStartRecordingTravelNotificationName = "StartRecordingTravel"
    static let AKStopRecordingTravelNotificationName = "StopRecordingTravel"
    static let AKLocationUpdateNotificationName = "LocationUpdate"
    static let AKNotificationBarDismissDelay = 4
    static let AKNotificationBarSound = 1057
    static let AKPointDiscardRadius = 50.0
    static let AKTravelPathMarkerStrokeColor = AKHexColor(0x333333)
    static let AKMasterFileName = "MasterFile.dat"
    static let AKDefaultFont = "HelveticaNeue-CondensedBold"
    static let AKDisabledButtonBg = AKHexColor(0xEEEEEE)
    static let AKEnabledButtonBg = AKHexColor(0x030C22)
    static let AKTableHeaderCellBg = AKHexColor(0x333333)
    static let AKTableHeaderLeftBorderBg = AKHexColor(0x72BF44)
    static let AKHeaderLeftBorderBg = AKHexColor(0x555555)
    static let AKHeaderTopBorderBg = AKHexColor(0x72BF44)
    static let AKButtonCornerRadius = 4.0
    static let AKDefaultBorderThickness = 2.0
    static let AKRecordTravelTab = 1
    static let AKPreviousTravelsTab = 2
    static let AKHeatmapTab = 3
}

// MARK: Global Enumerations
enum ErrorCodes: Int {
    case GENERIC = 1000
}

enum Exceptions: ErrorType {
    case NotInitialized(String)
    case EmptyData(String)
    case InvalidLength(String)
    case NotValid(String)
}

enum UnitOfLength: Int {
    case Meter = 1
    case Kilometer = 2
}

enum UnitOfTime: Int {
    case Second = 1
    case Minute = 2
    case Hour = 3
}

enum UnitOfSpeed: Int {
    case MetersPerSecond = 1
    case KilometersPerHour = 2
    case MilesPerHour = 3
}

enum CustomBorderDecorationPosition: Int {
    case Top = 0
    case Right = 1
    case Bottom = 2
    case Left = 3
}

// MARK: Global Functions
/// Computes the App's build version.
///
/// - Returns: The App's build version.
func AKAppBuild() -> String
{
    if let b = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
        return b
    }
    else {
        return "0"
    }
}

/// Computes the App's version.
///
/// - Returns: The App's version.
func AKAppVersion() -> String
{
    if let v = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
        return v
    }
    else {
        return "0"
    }
}

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

/// Returns the App's master file object.
///
/// - Returns The App's master file.
func AKObtainMasterFile() throws -> AKMasterFile
{
    if let mf = AKDelegate().masterFile {
        return mf
    }
    else {
        throw Exceptions.NotInitialized("The *Master File* has not been initialized.")
    }
}

/// Computes the distance between two points and returns the distance in meters.
///
/// - Parameter pointA: Point A location.
/// - Parameter pointB: Point B location.
///
/// - Returns: TRUE if within range, FALSE otherwise.
func AKComputeDistanceBetweenTwoPoints(pointA pointA: UserLocation,
                                              pointB: UserLocation) -> CLLocationDistance
{
    let pointA = CLLocation(latitude: pointA.lat, longitude: pointA.lon)
    let pointB = CLLocation(latitude: pointB.lat, longitude: pointB.lon)
    
    return pointA.distanceFromLocation(pointB)
}

/// Create a polygon with the form of a circle.
///
/// - Parameter title:           The title of the polygon.
/// - Parameter coordinate:      The location in coordinates of the center of the polygon.
/// - Parameter withMeterRadius: The radius of the circle.
///
/// - Returns: A polygon object in the form of a circle.
func AKCreateCircleForCoordinate(title: String, coordinate: CLLocationCoordinate2D, withMeterRadius: Double) -> MKPolygon
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
    
    let polygon = MKPolygon(coordinates: &coordinates, count: Int(coordinates.count))
    polygon.title = title
    
    return polygon
}

/// Create an image with the form of a circle.
///
/// - Parameter radius:      The radius of the circle.
/// - Parameter strokeColor: The color of the stroke.
/// - Parameter strokeAlpha: The alpha factor of the stroke.
/// - Parameter fillColor:   The color of the fill.
/// - Parameter fillAlpha:   The alpha factor of the fill.
///
/// - Returns: An image object in the form of a circle.
func AKCircleImageWithRadius(
    radius: Int,
    strokeColor: UIColor,
    strokeAlpha: Float,
    fillColor: UIColor,
    fillAlpha: Float) -> UIImage
{
    let buffer = 2
    let rect = CGRect(x: 0, y: 0, width: radius * 2 + buffer, height: radius * 2 + buffer)
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
    
    let context = UIGraphicsGetCurrentContext()
    CGContextSetFillColorWithColor(context, fillColor.colorWithAlphaComponent(CGFloat(fillAlpha)).CGColor)
    CGContextSetStrokeColorWithColor(context, strokeColor.colorWithAlphaComponent(CGFloat(strokeAlpha)).CGColor)
    CGContextSetLineWidth(context, 2)
    CGContextFillEllipseInRect(context, CGRectInset(rect, CGFloat(buffer * 2), CGFloat(buffer * 2)))
    CGContextStrokeEllipseInRect(context, CGRectInset(rect, CGFloat(buffer * 2), CGFloat(buffer * 2)))
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return image
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

func AKPresentTopMessageInfo(presenter: UIViewController!, title: String! = "Información", message: String!)
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

func AKPresentTopMessageWarn(presenter: UIViewController!, title: String! = "Advertencia", message: String!)
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

func AKPresentTopMessageError(presenter: UIViewController!, title: String! = "Error", message: String!)
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

func AKPresentTopMessageSuccess(presenter: UIViewController!, title: String! = "Mensaje", message: String!)
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

func AKPresentMessageFromError(errorMessage: String = "", controller: UIViewController!)
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

func AKAddBorderDeco(component: UIView, color: CGColorRef, thickness: Double, position: CustomBorderDecorationPosition) -> Void
{
    let border = CALayer()
    border.backgroundColor = color
    switch position {
    case .Top:
        border.frame = CGRectMake(0, 0, component.frame.width, CGFloat(thickness))
        break
    case .Right:
        border.frame = CGRectMake((component.frame.width - CGFloat(thickness)), 0, CGFloat(thickness), component.frame.height)
        break
    case .Bottom:
        border.frame = CGRectMake(0, (component.frame.height - CGFloat(thickness)), component.frame.width, CGFloat(thickness))
        break
    case .Left:
        border.frame = CGRectMake(0, 0, CGFloat(thickness), component.frame.height)
        break
    }
    
    component.layer.addSublayer(border)
}
