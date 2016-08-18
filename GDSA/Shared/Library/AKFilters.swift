import Foundation
import MapKit
import UIKit

class AKFilters: NSObject
{
    // MARK: Functions
    static func filter(let map: MKMapView, let travel: AKTravel, let travelSegment: AKTravelSegment) -> Bool
    {
        var result: Int8 = 0
        
        result += AKFilters.filterOriginDistance(map, travel: travel, travelSegment: travelSegment)
        
        return result == 0
    }
    
    // MARK: Filters
    /// This filters excludes points which are too close to the origin.
    private static func filterOriginDistance(let map: MKMapView, let travel: AKTravel, let travelSegment: AKTravelSegment) -> Int8
    {
        NSLog("=> FILTERS: *ORIGIN DISTANCE*")
        
        do {
            let currentPosition = UserLocation(lat: travelSegment.computeEnd().lat, lon: travelSegment.computeEnd().lon)
            let travelOrigin = try travel.computeOrigin()
            
            if AKComputeDistanceBetweenTwoPoints(pointA: travelOrigin, pointB: currentPosition) < GlobalConstants.AKPointDiscardRadius {
                return 1
            }
        }
        catch {
            NSLog("=> ERROR: \(error)")
            return 1
        }
        
        return 0
    }
}