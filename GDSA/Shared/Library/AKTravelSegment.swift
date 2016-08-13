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
        static let stopID = "AKTS.stop.id"
        static let stop = "AKTS.stop"
        static let stopTime = "AKTS.stop.time"
    }
    
    // MARK: Properties
    private var str: UserLocation = UserLocation(lat: 0.0, lon: 0.0)
    private var end: UserLocation = UserLocation(lat: 0.0, lon: 0.0)
    private var time: Double = 0.0
    private var distance: Double = 0.0
    private var speed: Double = 0.0
    private var stopID: String = ""
    private var stop: Bool = false
    private var stopTime: Double = 0.0
    
    // MARK: Initializers
    init(str: UserLocation, end: UserLocation, time: Double)
    {
        self.str = str
        self.end = end
        self.time = time
        self.distance = AKComputeDistanceBetweenTwoPoints(pointA: self.str, pointB: self.end)
        self.speed = self.distance / (self.time > 0 ? self.time : 0.00001)
        self.stopID = ""
        self.stop = false
        self.stopTime = 0.0
        
        super.init()
    }
    
    init(str: UserLocation, end: UserLocation, time: Double, distance: Double, speed: Double, stopID: String, stop: Bool, stopTime: Double)
    {
        self.str = str
        self.end = end
        self.time = time
        self.distance = distance
        self.speed = speed
        self.stopID = ""
        self.stop = false
        self.stopTime = 0.0
        
        super.init()
    }
    
    func computeEnd() -> UserLocation { return self.end }
    
    func computeTime(let unit: UnitOfTime) -> Double
    {
        switch unit {
        case UnitOfTime.Second:
            return self.time
        case UnitOfTime.Minute:
            return self.time / 60
        case UnitOfTime.Hour:
            return self.time / 3600
        }
    }
    
    func computeDistance(let unit: UnitOfLength) -> Double
    {
        switch unit {
        case UnitOfLength.Meter:
            return self.distance
        case UnitOfLength.Kilometer:
            return self.distance / 1000
        }
    }
    
    func computeSpeed(let unit: UnitOfSpeed) -> Int16
    {
        switch unit {
        case UnitOfSpeed.MetersPerSecond:
            return Int16(self.speed)
        case UnitOfSpeed.KilometersPerHour:
            return Int16(self.speed * 3.6)
        case UnitOfSpeed.MilesPerHour:
            return Int16(self.speed * 2.23694)
        }
    }
    
    func computeStop() -> Bool { return self.stop }
    
    func markAsStop(let stopID: String, stopTime: Double) { self.stopID = stopID; self.stop = true; self.stopTime = stopTime }
    
    func shouldSave() -> Bool
    {
        // The logic to discard a segment can be:
        //  1. That the Latitude and Longitude are both 0 for some point.
        if self.str.lat + self.str.lon == 0.0 || self.end.lat + self.end.lon == 0.0 {
            return false
        }
        
        return true
    }
    
    func printObject(let padding: String = "") -> String
    {
        let string: NSMutableString = NSMutableString()
        
        string.appendString("\n")
        string.appendFormat("%@****** TRAVEL SEGMENT ******\n", padding)
        string.appendFormat("%@\t>>> Start = Lat: %f, Lon: %f\n", padding, self.str.lat, self.str.lon)
        string.appendFormat("%@\t>>> End = Lat: %f, Lon: %f\n", padding, self.end.lat, self.end.lon)
        string.appendFormat("%@\t>>> Time = %f\n", padding, self.time)
        string.appendFormat("%@\t>>> Distance = %f\n", padding, self.distance)
        string.appendFormat("%@\t>>> Speed = %f\n", padding, self.speed)
        string.appendFormat("%@\t>>> Stop ID = %@\n", padding, self.stopID)
        string.appendFormat("%@\t>>> Stop = %@\n", padding, self.stop ? "YES" : "NO")
        string.appendFormat("%@\t>>> Stop Time = %f\n", padding, self.stopTime)
        string.appendFormat("%@****** TRAVEL SEGMENT ******\n", padding)
        
        return string as String
    }
    
    // MARK: NSCoding Implementation
    required convenience init(coder aDecoder: NSCoder)
    {
        let str = UserLocation(lat: aDecoder.decodeDoubleForKey(Keys.strLat), lon: aDecoder.decodeDoubleForKey(Keys.strLon))
        let end = UserLocation(lat: aDecoder.decodeDoubleForKey(Keys.endLat), lon: aDecoder.decodeDoubleForKey(Keys.endLon))
        let time = aDecoder.decodeDoubleForKey(Keys.time)
        let distance = aDecoder.decodeDoubleForKey(Keys.distance)
        let speed = aDecoder.decodeDoubleForKey(Keys.speed)
        let stopID = aDecoder.decodeObjectForKey(Keys.stopID) as! String
        let stop = aDecoder.decodeBoolForKey(Keys.stop)
        let stopTime = aDecoder.decodeDoubleForKey(Keys.stopTime)
        
        self.init(str: str, end: end, time: time, distance: distance, speed: speed, stopID: stopID, stop: stop, stopTime: stopTime)
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
        aCoder.encodeObject(self.stopID, forKey: Keys.stopID)
        aCoder.encodeBool(self.stop, forKey: Keys.stop)
        aCoder.encodeDouble(self.stopTime, forKey: Keys.stopTime)
    }
}
