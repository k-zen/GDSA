import Foundation

class AKTravelSegment: NSObject
{
    let pointALatitude: Double!
    let pointALongitude: Double!
    let pointBLatitude: Double!
    let pointBLongitude: Double!
    let travelTime: Double!
    let travelDistance: Double!
    let travelSpeed: Double!
    
    override init()
    {
        self.pointALatitude = 0.0
        self.pointALongitude = 0.0
        self.pointBLatitude = 0.0
        self.pointBLongitude = 0.0
        self.travelTime = 0.0
        self.travelDistance = 0.0
        self.travelSpeed = 0.0
    }
    
    init(pointALatitude: Double, pointALongitude: Double, pointBLatitude: Double, pointBLongitude: Double, travelTime: Double)
    {
        self.pointALatitude = pointALatitude
        self.pointALongitude = pointALongitude
        self.pointBLatitude = pointBLatitude
        self.pointBLongitude = pointBLongitude
        self.travelTime = travelTime
        self.travelDistance = AKComputeDistanceBetweenTwoPoints(
            pointALat: self.pointALatitude,
            pointALon: self.pointALongitude,
            pointBLat: self.pointBLatitude,
            pointBLon: self.pointBLongitude)
        self.travelSpeed = self.travelDistance / (self.travelTime > 0 ? self.travelTime : 0.00001)
    }
    
    func shouldSave() -> Bool
    {
        // The logic to discard a segment can be:
        //  1. That the Latitude and Longitude are both 0 for some point.
        if (self.pointALatitude + self.pointALongitude) == 0.0 || (self.pointBLatitude + self.pointBLongitude) == 0.0 {
            return false
        }
        
        return true
    }
    
    func printObject()
    {
        let string: NSMutableString = NSMutableString()
        
        string.appendString("\n")
        string.appendString("****** TRAVEL SEGMENT ******\n")
        string.appendFormat("\t>>> Point A Latitude = %f\n", self.pointALatitude)
        string.appendFormat("\t>>> Point A Longitude = %f\n", self.pointALongitude)
        string.appendFormat("\t>>> Point B Latitude = %f\n", self.pointBLatitude)
        string.appendFormat("\t>>> Point B Longitude = %f\n", self.pointBLongitude)
        string.appendFormat("\t>>> Segment Time = %f\n", self.travelTime)
        string.appendFormat("\t>>> Segment Distance = %f\n", self.travelDistance)
        string.appendFormat("\t>>> Segment Speed = %f\n", self.travelSpeed)
        string.appendString("****** TRAVEL SEGMENT ******\n")
        
        NSLog("%@", string)
    }
}