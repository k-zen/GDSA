import Foundation
import Mapbox
import UIKit

class AKDetection: NSObject
{
    // MARK: Functions
    static func detect(let map: MGLMapView, let travel: AKTravel, let travelSegment: AKTravelSegment)
    {
        AKDetection.detectStops(map, travel: travel, travelSegment: travelSegment)
    }
    
    // MARK: Detection
    private static func detectStops(let map: MGLMapView, let travel: AKTravel, let travelSegment: AKTravelSegment)
    {
        NSLog("=> DETECTION: *STOPS*")
        
        let segments = travel.computeSegments()
        let elementsToCount: Int = 5
        var totalDistance: Double = 0.0
        var isStop: Int8 = 0
        var lastSegment: AKTravelSegment?
        
        if segments.count <= elementsToCount {
            return
        }
        
        let lastIndex = segments.endIndex - 2 // EndIndex - 1 = Last Element, so EndIndex - 2 = Penultimate Element
        let firstIndex = lastIndex - elementsToCount + 1
        for k in (firstIndex ... lastIndex).reverse() { // Iterate in reverse order.
            totalDistance += segments[k].computeDistance(UnitOfLength.Meter)
            lastSegment = segments[k]
        }
        
        isStop = totalDistance <= 10 ? 1 : 0 // If it's 1 then is a STOP.
        
        if isStop == 1 {
            let stopID: String = NSUUID().UUIDString
            var stopTime: Double = 0.0
            
            // Sum stop time.
            for k in (firstIndex ... lastIndex).reverse() { // Iterate in reverse order.
                stopTime += segments[k].computeTime(UnitOfTime.Second)
            }
            
            // Mark all segments with the STOP flag and sum time.
            for k in (firstIndex ... lastIndex).reverse() { // Iterate in reverse order.
                segments[k].markAsStop(stopID, stopTime: stopTime)
            }
            
            map.addAnnotation(AKCreateCircleForCoordinate(
                GlobalConstants.AKTravelStopPointMarkTitle,
                coordinate: CLLocationCoordinate2DMake((lastSegment?.computeEnd().lat)!, lastSegment!.computeEnd().lon),
                withMeterRadius: 10.0)
            )
            
            // Add PIN.
            let annotation = MGLPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake((lastSegment?.computeEnd().lat)!, lastSegment!.computeEnd().lon)
            annotation.title = GlobalConstants.AKTravelStopPointPinTitle
            annotation.subtitle = String(format: "Stop ID: %@, Stop Time: %.1f", stopID, stopTime)
            map.addAnnotation(annotation)
        }
    }
}