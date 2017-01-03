import AudioToolbox
import CoreLocation
import Foundation
import MapKit
import TSMessages
import UIKit

// MARK: Extensions
extension Int
{
    func modulo(_ divisor: Int) -> Int
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
        return self.components(separatedBy: CharacterSet.newlines)
    }
}

// MARK: Structures

// MARK: Global Constants
struct GlobalConstants {
    static let AKDebug = true
    static let AKLocationUpdateInterval = 5
    static let AKStartRecordingTravelNotificationName = "StartRecordingTravel"
    static let AKStopRecordingTravelNotificationName = "StopRecordingTravel"
    static let AKLocationUpdateNotificationName = "LocationUpdate"
    static let AKNotificationBarDismissDelay = 4
    static let AKNotificationBarSound = 1057
    static let AKPointDiscardRadius = 50.0
    static let AKTravelPathMarkerStrokeColor = AKHexColor(0x429867)
    static let AKMasterFileName = "MasterFile.dat"
    static let AKDefaultFont = "HelveticaNeue-CondensedBold"
    
    // Colors: https://github.com/morhetz/gruvbox
    static let AKDefaultBg = AKHexColor(0x1D2021)
    static let AKDefaultFg = AKHexColor(0xA89984)
    static let AKTabBarBg = AKHexColor(0x101010)
    static let AKTabBarTint = AKHexColor(0xD65D0E)
    static let AKOverlaysBg = GlobalConstants.AKDefaultBg
    static let AKDefaultViewBorderBg = AKHexColor(0x3C3836)
    
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
    // StopDetection
    static let AKStopDetectionMaxDistance = 10.0
    static let AKStopDetectionSegmentsToCount = 5
}

// MARK: Global Enumerations
enum ErrorCodes: Int {
    case generic = 1000
}

enum Exceptions: Error {
    case notInitialized(msg: String)
    case emptyData(msg: String)
    case invalidLength(msg: String)
    case notValid(msg: String)
}

enum UnitOfLength: Int {
    case meter = 1
    case kilometer = 2
}

enum UnitOfTime: Int {
    case second = 1
    case minute = 2
    case hour = 3
}

enum UnitOfSpeed: Int {
    case metersPerSecond = 1
    case kilometersPerHour = 2
    case milesPerHour = 3
}

enum CustomBorderDecorationPosition: Int {
    case top = 0
    case right = 1
    case bottom = 2
    case left = 3
}

// MARK: Global Functions
/// Computes the App's build version.
///
/// - Returns: The App's build version.
func AKAppBuild() -> String
{
    if let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
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
    if let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
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
func AKDelay(_ delay: Double, task: @escaping (Void) -> Void)
{
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: task)
}

/// Returns the App's delegate object.
///
/// - Returns: The App's delegate object.
func AKDelegate() -> AKAppDelegate { return UIApplication.shared.delegate as! AKAppDelegate }

/// Returns the App's master file object.
///
/// - Returns The App's master file.
func AKObtainMasterFile() -> AKMasterFile
{
    return AKDelegate().masterFile
}

/// Computes the distance between two points and returns the distance in meters.
///
/// - Parameter pointA: Point A location.
/// - Parameter pointB: Point B location.
///
/// - Returns: TRUE if within range, FALSE otherwise.
func AKComputeDistanceBetweenTwoPoints(pointA: CLLocationCoordinate2D,
                                       pointB: CLLocationCoordinate2D) -> CLLocationDistance
{
    let pointA = CLLocation(latitude: pointA.latitude, longitude: pointA.longitude)
    let pointB = CLLocation(latitude: pointB.latitude, longitude: pointB.longitude)
    
    return pointA.distance(from: pointB)
}

/// Create a polygon with the form of a circle.
///
/// - Parameter title:           The title of the polygon.
/// - Parameter coordinate:      The location in coordinates of the center of the polygon.
/// - Parameter withMeterRadius: The radius of the circle.
///
/// - Returns: A polygon object in the form of a circle.
func AKCreateCircleForCoordinate(_ title: String, coordinate: CLLocationCoordinate2D, withMeterRadius: Double) -> MKPolygon
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
func AKCircleImageWithRadius(_ radius: Int, strokeColor: UIColor, strokeAlpha: Float, fillColor: UIColor, fillAlpha: Float) -> UIImage
{
    let buffer = 2
    let rect = CGRect(x: 0, y: 0, width: radius * 2 + buffer, height: radius * 2 + buffer)
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
    
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(fillColor.withAlphaComponent(CGFloat(fillAlpha)).cgColor)
    context?.setStrokeColor(strokeColor.withAlphaComponent(CGFloat(strokeAlpha)).cgColor)
    context?.setLineWidth(2)
    context?.fillEllipse(in: rect.insetBy(dx: CGFloat(buffer * 2), dy: CGFloat(buffer * 2)))
    context?.strokeEllipse(in: rect.insetBy(dx: CGFloat(buffer * 2), dy: CGFloat(buffer * 2)))
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return image!
}

/// Computes and generates a **UIColor** object based
/// on it's hexadecimal representation.
///
/// - Parameter hex: The hexadecimal representation of the color.
///
/// - Returns: A **UIColor** object.
func AKHexColor(_ hex: UInt) -> UIColor
{
    let red = CGFloat((hex >> 16) & 0xFF) / 255.0
    let green = CGFloat((hex >> 8) & 0xFF) / 255.0
    let blue = CGFloat((hex) & 0xFF) / 255.0
    
    return UIColor.init(red: red, green: green, blue: blue, alpha: 1)
}

func AKPresentTopMessage(_ presenter: UIViewController!, type: TSMessageNotificationType, message: String!)
{
    let title: String
    switch type {
    case .message:
        title = "Información"
    case .warning:
        title = "Advertencia"
    case .error:
        title = "Error"
    case .success:
        title = "👍"
    }
    
    TSMessage.showNotification(
        in: presenter,
        title: title,
        subtitle: message,
        image: nil,
        type: type,
        duration: TimeInterval(GlobalConstants.AKNotificationBarDismissDelay),
        callback: nil,
        buttonTitle: nil,
        buttonCallback: {},
        at: TSMessageNotificationPosition.top,
        canBeDismissedByUser: true
    )
    AudioServicesPlaySystemSound(UInt32(GlobalConstants.AKNotificationBarSound))
}

func AKPresentMessageFromError(_ errorMessage: String = "", controller: UIViewController!)
{
    do {
        let input = errorMessage
        let regex = try NSRegularExpression(pattern: ".*\"(.*)\"", options: NSRegularExpression.Options.caseInsensitive)
        let matches = regex.matches(in: input, options: [], range: NSMakeRange(0, input.characters.count))
        
        if let match = matches.first {
            let range = match.rangeAt(1)
            if let swiftRange = AKRangeFromNSRange(range, forString: input) {
                let msg = input.substring(with: swiftRange)
                AKPresentTopMessage(controller, type: TSMessageNotificationType.error, message: msg)
            }
        }
    }
    catch {
        NSLog("=> Generic Error ==> %@", "\(error)")
    }
}

func AKRangeFromNSRange(_ nsRange: NSRange, forString str: String) -> Range<String.Index>?
{
    let fromUTF16 = str.utf16.startIndex.advanced(by: nsRange.location)
    let toUTF16 = fromUTF16.advanced(by: nsRange.length)
    
    if let from = String.Index(fromUTF16, within: str), let to = String.Index(toUTF16, within: str) {
        return from ..< to
    }
    
    return nil
}

func AKAddBorderDeco(_ component: UIView, color: CGColor, thickness: Double, position: CustomBorderDecorationPosition) -> Void
{
    let border = CALayer()
    border.backgroundColor = color
    switch position {
    case .top:
        border.frame = CGRect(x: 0, y: 0, width: component.frame.width, height: CGFloat(thickness))
        break
    case .right:
        border.frame = CGRect(x: (component.frame.width - CGFloat(thickness)), y: 0, width: CGFloat(thickness), height: component.frame.height)
        break
    case .bottom:
        border.frame = CGRect(x: 0, y: (component.frame.height - CGFloat(thickness)), width: component.frame.width, height: CGFloat(thickness))
        break
    case .left:
        border.frame = CGRect(x: 0, y: 0, width: CGFloat(thickness), height: component.frame.height)
        break
    }
    
    component.layer.addSublayer(border)
}
