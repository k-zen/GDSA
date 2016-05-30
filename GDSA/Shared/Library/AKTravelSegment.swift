import Foundation

class AKTravelSegment: NSObject, NSCoding
{
    // MARK: Structures
    struct Keys {
        static let strLat = "AKTS.start.lat"
        static let strLon = "AKTS.start.lon"
        static let endLat = "AKTS.end.lat"
        static let endLon = "AKTS.end.lon"
        static let time = "AKTS.time"
        static let distance = "AKTS.distance"
        static let speed = "AKTS.speed"
    }
    
    // MARK: Properties
    private var str: UserLocation = UserLocation(lat: 0.0, lon: 0.0)
    private var end: UserLocation = UserLocation(lat: 0.0, lon: 0.0)
    private var time: Double = 0.0
    private var distance: Double = 0.0
    private var speed: Double = 0.0
    
    // MARK: Initializers
    init(str: UserLocation, end: UserLocation, time: Double)
    {
        self.str = str
        self.end = end
        self.time = time
        self.distance = AKComputeDistanceBetweenTwoPoints(pointA: self.str, pointB: self.end)
        self.speed = self.distance / (self.time > 0 ? self.time : 0.00001)
        
        super.init()
    }
    
    init(str: UserLocation, end: UserLocation, time: Double, distance: Double, speed: Double)
    {
        self.str = str
        self.end = end
        self.time = time
        self.distance = distance
        self.speed = speed
        
        super.init()
    }
    
    func computeEnd() -> UserLocation { return self.end }
    
    func computeDistance() -> Double { return self.distance }
    
    func shouldSave() -> Bool
    {
        // The logic to discard a segment can be:
        //  1. That the Latitude and Longitude are both 0 for some point.
        if self.str.lat + self.str.lon == 0.0 || self.end.lat + self.end.lon == 0.0 {
            return false
        }
        
        return true
    }
    
    func printObject()
    {
        let string: NSMutableString = NSMutableString()
        
        string.appendString("\n")
        string.appendString("****** TRAVEL SEGMENT ******\n")
        string.appendFormat("\t>>> Start = Lat: %f, Lon: %f\n", self.str.lat, self.str.lon)
        string.appendFormat("\t>>> End = Lat: %f, Lon: %f\n", self.end.lat, self.end.lon)
        string.appendFormat("\t>>> Time = %f\n", self.time)
        string.appendFormat("\t>>> Distance = %f\n", self.distance)
        string.appendFormat("\t>>> Speed = %f\n", self.speed)
        string.appendString("****** TRAVEL SEGMENT ******\n")
        
        NSLog("%@", string)
    }
    
    // MARK: NSCoding Implementation
    required convenience init(coder aDecoder: NSCoder)
    {
        let str = UserLocation(lat: aDecoder.decodeDoubleForKey(Keys.strLat), lon: aDecoder.decodeDoubleForKey(Keys.strLon))
        let end = UserLocation(lat: aDecoder.decodeDoubleForKey(Keys.endLat), lon: aDecoder.decodeDoubleForKey(Keys.endLon))
        let time = aDecoder.decodeDoubleForKey(Keys.time)
        let distance = aDecoder.decodeDoubleForKey(Keys.distance)
        let speed = aDecoder.decodeDoubleForKey(Keys.speed)
        
        self.init(str: str, end: end, time: time, distance: distance, speed: speed)
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeDouble(self.str.lat, forKey: Keys.strLat)
        aCoder.encodeDouble(self.str.lon, forKey: Keys.strLon)
        aCoder.encodeDouble(self.end.lat, forKey: Keys.endLat)
        aCoder.encodeDouble(self.end.lon, forKey: Keys.endLon)
        aCoder.encodeDouble(self.time, forKey: Keys.time)
        aCoder.encodeDouble(self.distance, forKey: Keys.distance)
        aCoder.encodeDouble(self.speed, forKey: Keys.speed)
    }
}
