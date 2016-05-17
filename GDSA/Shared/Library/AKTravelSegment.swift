import Foundation

class AKTravelSegment: NSObject
{
    let pointA: UserLocation!
    let pointB: UserLocation!
    let travelTime: Double!
    let travelDistance: Double!
    let travelSpeed: Double!
    
    override init()
    {
        self.pointA = UserLocation(latitude: 0.0, longitude: 0.0)
        self.pointB = UserLocation(latitude: 0.0, longitude: 0.0)
        self.travelTime = 0.0
        self.travelDistance = 0.0
        self.travelSpeed = 0.0
    }
    
    init(pointA: UserLocation, pointB: UserLocation, travelTime: Double)
    {
        self.pointA = pointA
        self.pointB = pointB
        self.travelTime = travelTime
        self.travelDistance = AKComputeDistanceBetweenTwoPoints(pointA: self.pointA, pointB: self.pointB)
        self.travelSpeed = self.travelDistance / (self.travelTime > 0 ? self.travelTime : 0.00001)
    }
    
    func shouldSave() -> Bool
    {
        // The logic to discard a segment can be:
        //  1. That the Latitude and Longitude are both 0 for some point.
        if (self.pointA.latitude + self.pointA.longitude) == 0.0 || (self.pointB.latitude + self.pointB.longitude) == 0.0 {
            return false
        }
        
        return true
    }
    
    func printObject()
    {
        let string: NSMutableString = NSMutableString()
        
        string.appendString("\n")
        string.appendString("****** TRAVEL SEGMENT ******\n")
        if self.pointA != nil {
            string.appendFormat("\t>>> Point A = Lat: %f, Lon: %f\n", self.pointA.latitude, self.pointA.longitude)
        }
        else {
            string.appendFormat("\t>>> Point A = NOT SET\n")
        }
        if self.pointB != nil {
            string.appendFormat("\t>>> Point B = Lat: %f, Lon: %f\n", self.pointB.latitude, self.pointB.longitude)
        }
        else {
            string.appendFormat("\t>>> Point B = NOT SET\n")
        }
        string.appendFormat("\t>>> Segment Time = %f\n", self.travelTime)
        string.appendFormat("\t>>> Segment Distance = %f\n", self.travelDistance)
        string.appendFormat("\t>>> Segment Speed = %f\n", self.travelSpeed)
        string.appendString("****** TRAVEL SEGMENT ******\n")
        
        NSLog("%@", string)
    }
}