import Foundation
import MapKit
import UIKit

class AKDetection: NSObject
{
    // MARK: Functions
    static func detect(_ map: MKMapView, travel: AKTravel, travelSegment: AKTravelSegment)
    {
        AKDetection.detectStops(map, travel: travel, travelSegment: travelSegment)
        AKDetection.detectResumeTravel(map, travel: travel, travelSegment: travelSegment)
    }
    
    // MARK: Detection
    private static func detectStops(_ map: MKMapView, travel: AKTravel, travelSegment: AKTravelSegment)
    {
        NSLog("=> DETECTION: *STOPS*")
        
        let segments = travel.computeSegments()
        let elementsToCount: Int = GlobalConstants.AKStopDetectionSegmentsToCount
        var totalDistance: Double = 0.0
        var isStop: Int8 = 0
        
        if segments.count < elementsToCount {
            return
        }
        
        let lastIndex = segments.endIndex - 1 // EndIndex - 1 = Last Element, so EndIndex - 2 = Penultimate Element
        let firstIndex = lastIndex - elementsToCount + 1
        for k in (firstIndex ... lastIndex).reversed() { // Iterate in reverse order.
            totalDistance += segments[k].computeDistance(UnitOfLength.meter)
        }
        
        isStop = totalDistance <= GlobalConstants.AKStopDetectionMaxDistance ? 1 : 0 // If it's 1 then is a STOP.
        if isStop == 1 {
            NSLog("=> DETECTION: *STOPS* IS A STOP!")
            
            let stopID: String = UUID().uuidString
            var stopTime: Double = 0.0
            
            // Sum stop time.
            for k in (firstIndex ... lastIndex).reversed() { // Iterate in reverse order.
                stopTime += segments[k].computeTime(UnitOfTime.second)
            }
            
            // Mark all segments with the STOP flag and sum time.
            for k in (firstIndex ... lastIndex).reversed() { // Iterate in reverse order.
                segments[k].markAsStop(stopID, stopTime: stopTime)
            }
            
            // Update the travel object with new info.
            travel.updateOverallStopCounter()
            travel.updateOverallStopTime(Int64(stopTime))
        }
    }
    
    private static func detectResumeTravel(_ map: MKMapView, travel: AKTravel, travelSegment: AKTravelSegment)
    {
        NSLog("=> DETECTION: *RESUME TRAVEL*")
        
        let segments = travel.computeSegments()
        var isResume: Int8 = 0
        
        if segments.count < 2 {
            return
        }
        
        isResume = (!segments[segments.endIndex - 1].computeStop() && segments[segments.endIndex - 2].computeStop()) ? 1 : 0 // If it's 1 then is a STOP.
        if isResume == 1 {
            NSLog("=> DETECTION: *RESUME TRAVEL* IS A RESUME!")
            
            // Add PIN.
            let annotation = MKPointAnnotation()
            annotation.coordinate = segments[segments.endIndex - 2].computeEnd()
            annotation.title = "Stop Point"
            annotation.subtitle = String(format: "Stop Time: %.0f", travel.computeOverallStopTime(UnitOfTime.second))
            map.addAnnotation(annotation)
            map.selectAnnotation(annotation, animated: true)
        }
    }
}
