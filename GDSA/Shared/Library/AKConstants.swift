import AudioToolbox
import CoreLocation
import Foundation
import Mapbox
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
    static let AKNotificationBarDismissDelay = 8
    static let AKNotificationBarSound = 1057
    static let AKPointDiscardRadius = 50.0
    static let AKTravelStartAnnotationTitle = "Origin"
    static let AKTravelEndAnnotationTitle = "Destination"
    static let AKTravelSegmentAnnotationTitle = "Segment"
    static let AKTravelStopPointMarkTitle = "Stop Circle"
    static let AKTravelStopPointMarkAlpha = 0.25
    static let AKTravelStopPointMarkColor = UIColor.red
    static let AKTravelStopPointPinTitle = "Stop"
    static let AKTravelPathLineColor = AKHexColor(0xE09E9F)
    static let AKTravelPathLineWidth = 6.0
    static let AKTravelPathLineAlpha = 0.5
    static let AKMasterFileName = "MasterFile.dat"
    static let AKDefaultFont = "HelveticaNeue-CondensedBold"
    static let AKDisabledButtonBg = AKHexColor(0xEEEEEE)
    static let AKEnabledButtonBg = AKHexColor(0xCCCCCC)
    static let AKTableHeaderCellBg = AKHexColor(0x333333)
    static let AKTableHeaderLeftBorderBg = AKHexColor(0x72BF44)
    static let AKHeaderLeftBorderBg = AKHexColor(0x555555)
    static let AKHeaderTopBorderBg = AKHexColor(0x72BF44)
    static let AKButtonCornerRadius = 4.0
    static let AKDefaultBorderThickness = 2.0
}

// MARK: Global Enumerations
enum ErrorCodes: Int {
    case generic = 1000
}

enum Exceptions: Error {
    case notInitialized(text: String)
    case emptyData(text: String)
    case invalidLength(text: String)
    case notValid(text: String)
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
func AKDelay(_ delay: Double, task: (Void) -> Void)
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
func AKObtainMasterFile() throws -> AKMasterFile
{
    if let mf = AKDelegate().masterFile {
        return mf
    }
    else {
        throw Exceptions.notInitialized(text: "The *Master File* has not been initialized.")
    }
}

/// Computes the distance between two points and returns the distance in meters.
///
/// - Parameter pointA: Point A location.
/// - Parameter pointB: Point B location.
///
/// - Returns: TRUE if within range, FALSE otherwise.
func AKComputeDistanceBetweenTwoPoints(pointA: UserLocation,
                                       pointB: UserLocation) -> CLLocationDistance
{
    let pointA = CLLocation(latitude: pointA.lat, longitude: pointA.lon)
    let pointB = CLLocation(latitude: pointB.lat, longitude: pointB.lon)
    
    return pointA.distance(from: pointB)
}

/// Create a polygon with the form of a circle.
///
/// - Parameter title:           The title of the polygon.
/// - Parameter coordinate:      The location in coordinates of the center of the polygon.
/// - Parameter withMeterRadius: The radius of the circle.
///
/// - Returns: A polygon object in the form of a circle.
func AKCreateCircleForCoordinate(_ title: String, coordinate: CLLocationCoordinate2D, withMeterRadius: Double) -> MGLPolygon
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

func AKPresentTopMessageInfo(_ presenter: AKCustomViewController!, title: String! = "Information", message: String!)
{
    TSMessage.showNotification(
        in: presenter,
        title: title,
        subtitle: message,
        image: nil,
        type: TSMessageNotificationType.message,
        duration: TimeInterval(GlobalConstants.AKNotificationBarDismissDelay),
        callback: nil,
        buttonTitle: nil,
        buttonCallback: {},
        at: TSMessageNotificationPosition.top,
        canBeDismissedByUser: true
    )
    AudioServicesPlaySystemSound(UInt32(GlobalConstants.AKNotificationBarSound))
}

func AKPresentTopMessageWarn(_ presenter: AKCustomViewController!, title: String! = "Warning", message: String!)
{
    TSMessage.showNotification(
        in: presenter,
        title: title,
        subtitle: message,
        image: nil,
        type: TSMessageNotificationType.warning,
        duration: TimeInterval(GlobalConstants.AKNotificationBarDismissDelay),
        callback: nil,
        buttonTitle: nil,
        buttonCallback: {},
        at: TSMessageNotificationPosition.top,
        canBeDismissedByUser: true
    )
    AudioServicesPlaySystemSound(UInt32(GlobalConstants.AKNotificationBarSound))
}

func AKPresentTopMessageError(_ presenter: AKCustomViewController!, title: String! = "Error", message: String!)
{
    TSMessage.showNotification(
        in: presenter,
        title: title,
        subtitle: message,
        image: nil,
        type: TSMessageNotificationType.error,
        duration: TimeInterval(GlobalConstants.AKNotificationBarDismissDelay),
        callback: nil,
        buttonTitle: nil,
        buttonCallback: {},
        at: TSMessageNotificationPosition.top,
        canBeDismissedByUser: true
    )
    AudioServicesPlaySystemSound(UInt32(GlobalConstants.AKNotificationBarSound))
}

func AKPresentTopMessageSuccess(_ presenter: AKCustomViewController!, title: String! = "Message", message: String!)
{
    TSMessage.showNotification(
        in: presenter,
        title: title,
        subtitle: message,
        image: nil,
        type: TSMessageNotificationType.success,
        duration: TimeInterval(GlobalConstants.AKNotificationBarDismissDelay),
        callback: nil,
        buttonTitle: nil,
        buttonCallback: {},
        at: TSMessageNotificationPosition.top,
        canBeDismissedByUser: true
    )
    AudioServicesPlaySystemSound(UInt32(GlobalConstants.AKNotificationBarSound))
}

func AKPresentMessageFromError(_ errorMessage: String = "", controller: AKCustomViewController!)
{
    do {
        let input = errorMessage
        let regex = try NSRegularExpression(pattern: ".*\"(.*)\"", options: NSRegularExpression.Options.caseInsensitive)
        let matches = regex.matches(in: input, options: [], range: NSMakeRange(0, input.characters.count))
        
        if let match = matches.first {
            let range = match.rangeAt(1)
            if let swiftRange = AKRangeFromNSRange(range, forString: input) {
                let msg = input.substring(with: swiftRange)
                AKPresentTopMessageError(controller, message: msg)
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
