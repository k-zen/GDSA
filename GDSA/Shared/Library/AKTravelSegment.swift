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
    private var str: CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var end: CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var time: Double = 0.0
    private var distance: Double = 0.0
    private var speed: Double = 0.0
    private var stopID: String = ""
    private var stop: Bool = false
    private var stopTime: Double = 0.0
    
    // MARK: Initializers
    init(str: CLLocationCoordinate2D, end: CLLocationCoordinate2D, time: Double)
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
    
    init(str: CLLocationCoordinate2D, end: CLLocationCoordinate2D, time: Double, distance: Double, speed: Double, stopID: String, stop: Bool, stopTime: Double)
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
    
    func computeEnd() -> CLLocationCoordinate2D { return self.end }
    
    func computeTime(_ unit: UnitOfTime) -> Double
    {
        switch unit {
        case UnitOfTime.second:
            return self.time
        case UnitOfTime.minute:
            return self.time / 60
        case UnitOfTime.hour:
            return self.time / 3600
        }
    }
    
    func computeDistance(_ unit: UnitOfLength) -> Double
    {
        switch unit {
        case UnitOfLength.meter:
            return self.distance
        case UnitOfLength.kilometer:
            return self.distance / 1000
        }
    }
    
    func computeSpeed(_ unit: UnitOfSpeed) -> Int32
    {
        switch unit {
        case UnitOfSpeed.metersPerSecond:
            return Int32(self.speed)
        case UnitOfSpeed.kilometersPerHour:
            return Int32(self.speed * 3.6)
        case UnitOfSpeed.milesPerHour:
            return Int32(self.speed * 2.23694)
        }
    }
    
    func computeStop() -> Bool { return self.stop }
    
    func markAsStop(_ stopID: String, stopTime: Double) { self.stopID = stopID; self.stop = true; self.stopTime = stopTime }
    
    func shouldSave() -> Bool
    {
        return CLLocationCoordinate2DIsValid(self.str) && CLLocationCoordinate2DIsValid(self.end)
    }
    
    func printObject(_ padding: String = "") -> String
    {
        let string: NSMutableString = NSMutableString()
        
        string.append("\n")
        string.appendFormat("%@****** TRAVEL SEGMENT ******\n", padding)
        string.appendFormat("%@\t>>> Start = Lat: %f, Lon: %f\n", padding, self.str.latitude, self.str.longitude)
        string.appendFormat("%@\t>>> End = Lat: %f, Lon: %f\n", padding, self.end.latitude, self.end.longitude)
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
        let str = CLLocationCoordinate2D(latitude: aDecoder.decodeDouble(forKey: Keys.strLat), longitude: aDecoder.decodeDouble(forKey: Keys.strLon))
        let end = CLLocationCoordinate2D(latitude: aDecoder.decodeDouble(forKey: Keys.endLat), longitude: aDecoder.decodeDouble(forKey: Keys.endLon))
        let time = aDecoder.decodeDouble(forKey: Keys.time)
        let distance = aDecoder.decodeDouble(forKey: Keys.distance)
        let speed = aDecoder.decodeDouble(forKey: Keys.speed)
        let stopID = aDecoder.decodeObject(forKey: Keys.stopID) as! String
        let stop = aDecoder.decodeBool(forKey: Keys.stop)
        let stopTime = aDecoder.decodeDouble(forKey: Keys.stopTime)
        
        self.init(str: str, end: end, time: time, distance: distance, speed: speed, stopID: stopID, stop: stop, stopTime: stopTime)
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.str.latitude, forKey: Keys.strLat)
        aCoder.encode(self.str.longitude, forKey: Keys.strLon)
        aCoder.encode(self.end.latitude, forKey: Keys.endLat)
        aCoder.encode(self.end.longitude, forKey: Keys.endLon)
        aCoder.encode(self.time, forKey: Keys.time)
        aCoder.encode(self.distance, forKey: Keys.distance)
        aCoder.encode(self.speed, forKey: Keys.speed)
        aCoder.encode(self.stopID, forKey: Keys.stopID)
        aCoder.encode(self.stop, forKey: Keys.stop)
        aCoder.encode(self.stopTime, forKey: Keys.stopTime)
    }
}
