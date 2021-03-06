import CoreLocation
import Foundation

class AKTravel: NSObject, NSCoding
{
    // MARK: Constants
    struct Keys {
        static let entryDate = "AKT.entry.date"
        static let originLat = "AKT.origin.lat"
        static let originLon = "AKT.origin.lon"
        static let destinationLat = "AKT.destination.lat"
        static let destinationLon = "AKT.destination.lon"
        static let segments = "AKT.segments"
        static let distance = "AKT.distance"
        static let overallStopCounter = "AKT.overall.stop.counter"
        static let overallStopTime = "AKT.overall.stop.time"
    }
    
    // MARK: Properties
    private var entryDate: Date
    private var origin: CLLocationCoordinate2D
    private var destination: CLLocationCoordinate2D
    private var segments: [AKTravelSegment]
    private var distance: Double
    private var overallStopCounter: Int32
    private var overallStopTime: Int64
    
    // MARK: Initializers
    override init()
    {
        self.entryDate = Date()
        self.origin = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        self.destination = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        self.segments = []
        self.distance = 0.0
        self.overallStopCounter = 0
        self.overallStopTime = 0
    }
    
    init(entryDate: Date,
         origin: CLLocationCoordinate2D,
         destination: CLLocationCoordinate2D,
         segments: [AKTravelSegment],
         distance: Double,
         overallStopCounter: Int32,
         overallStopTime: Int64)
    {
        self.entryDate = entryDate
        self.origin = origin
        self.destination = destination
        self.segments = segments
        self.distance = distance
        self.overallStopCounter = overallStopCounter
        self.overallStopTime = overallStopTime
        
        super.init()
    }
    
    // MARK: Utilities
    func addSegment(_ segment: AKTravelSegment) { self.segments.append(segment) }
    
    func addOrigin(_ origin: CLLocationCoordinate2D) { self.origin = origin }
    
    func addDestination(_ destination: CLLocationCoordinate2D) { self.destination = destination }
    
    func addDistance(_ segmentDistance: Double) { self.distance = self.distance + segmentDistance }
    
    func computeOrigin() -> CLLocationCoordinate2D
    {
        return self.origin.latitude + self.origin.longitude != 0.0 ? self.origin : kCLLocationCoordinate2DInvalid
    }
    
    func computeDestination() -> CLLocationCoordinate2D
    {
        return self.destination.latitude + self.destination.longitude != 0.0 ? self.destination : kCLLocationCoordinate2DInvalid
    }
    
    func computeSegments() -> [AKTravelSegment] { return self.segments }
    
    func computeDistance(_ unit: UnitOfLength) -> Double
    {
        switch unit {
        case UnitOfLength.meter:
            return self.distance
        case UnitOfLength.kilometer:
            return self.distance / 1000
        }
    }
    
    func computeEntryDate() -> String { return self.entryDate.description }
    
    func updateOverallStopCounter() { self.overallStopCounter += 1 }
    
    func updateOverallStopTime(_ time: Int64) { self.overallStopTime += time }
    
    func computeOverallStopCounter() -> Int32 { return self.overallStopCounter }
    
    func computeOverallStopTime(_ unit: UnitOfTime) -> Double
    {
        switch unit {
        case UnitOfTime.second:
            return Double(self.overallStopTime)
        case UnitOfTime.minute:
            return Double(self.overallStopTime) / 60
        case UnitOfTime.hour:
            return Double(self.overallStopTime) / 3600
        }
    }
    
    func printObject(_ padding: String = "") -> String
    {
        let string: NSMutableString = NSMutableString()
        
        string.append("\n")
        string.appendFormat("%@****** TRAVEL ******\n", padding)
        string.appendFormat("%@\t>>> Entry Date = %@\n", padding, self.entryDate.description)
        string.appendFormat("%@\t>>> Origin = Lat: %f, Lon: %f\n", padding, self.origin.latitude, self.origin.longitude)
        string.appendFormat("%@\t>>> Distance = %f\n", padding, self.distance)
        string.appendFormat("%@\t>>> Destination = Lat: %f, Lon: %f\n", padding, self.destination.latitude, self.destination.longitude)
        for segment in segments {
            string.appendFormat("%@", segment.printObject("\t"))
        }
        string.appendFormat("%@\t>>> Overall Stop Counter = %i\n", padding, self.overallStopCounter)
        string.appendFormat("%@\t>>> Overall Stop Time = %f\n", padding, self.computeOverallStopTime(UnitOfTime.second))
        string.appendFormat("%@****** TRAVEL ******\n", padding)
        
        return string as String
    }
    
    // MARK: NSCoding Implementation
    required convenience init(coder aDecoder: NSCoder)
    {
        let entryDate = aDecoder.decodeObject(forKey: Keys.entryDate) as! Date
        let origin = CLLocationCoordinate2D(latitude: aDecoder.decodeDouble(forKey: Keys.originLat), longitude: aDecoder.decodeDouble(forKey: Keys.originLon))
        let destination = CLLocationCoordinate2D(latitude: aDecoder.decodeDouble(forKey: Keys.destinationLat), longitude: aDecoder.decodeDouble(forKey: Keys.destinationLon))
        let segments = aDecoder.decodeObject(forKey: Keys.segments) as! [AKTravelSegment]
        let distance = aDecoder.decodeDouble(forKey: Keys.distance)
        let overallStopCounter = aDecoder.decodeInt32(forKey: Keys.overallStopCounter)
        let overallStopTime = aDecoder.decodeInt64(forKey: Keys.overallStopTime)
        
        self.init(entryDate: entryDate,
                  origin: origin,
                  destination: destination,
                  segments: segments,
                  distance: distance,
                  overallStopCounter: overallStopCounter,
                  overallStopTime: overallStopTime)
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.entryDate, forKey: Keys.entryDate)
        aCoder.encode(self.origin.latitude, forKey: Keys.originLat)
        aCoder.encode(self.origin.longitude, forKey: Keys.originLon)
        aCoder.encode(self.destination.latitude, forKey: Keys.destinationLat)
        aCoder.encode(self.destination.longitude, forKey: Keys.destinationLon)
        aCoder.encode(self.segments, forKey: Keys.segments)
        aCoder.encode(self.distance, forKey: Keys.distance)
        aCoder.encode(self.overallStopCounter, forKey: Keys.overallStopCounter)
        aCoder.encode(self.overallStopTime, forKey: Keys.overallStopTime)
    }
}
