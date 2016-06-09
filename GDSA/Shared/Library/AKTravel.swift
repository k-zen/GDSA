import CoreLocation
import Foundation

class AKTravel: NSObject, NSCoding
{
    struct Keys {
        static let originLat = "AKT.origin.lat"
        static let originLon = "AKT.origin.lon"
        static let destinationLat = "AKT.destination.lat"
        static let destinationLon = "AKT.destination.lon"
        static let segments = "AKT.segments"
        static let distance = "AKT.distance"
    }
    
    // MARK: Properties
    private var origin: UserLocation
    private var destination: UserLocation
    private var segments: [AKTravelSegment]
    private var distance: Double
    
    // MARK: Initializers
    override init()
    {
        self.origin = UserLocation(lat: 0.0, lon: 0.0)
        self.destination = UserLocation(lat: 0.0, lon: 0.0)
        self.segments = []
        self.distance = 0.0
    }
    
    init(origin: UserLocation, destination: UserLocation, segments: [AKTravelSegment], distance: Double)
    {
        self.origin = origin
        self.destination = destination
        self.segments = segments
        self.distance = distance
        
        super.init()
    }
    
    func addSegment(segment: AKTravelSegment)
    {
        self.segments.append(segment)
    }
    
    func addOrigin(origin: UserLocation)
    {
        self.origin = origin
        
        printObject()
    }
    
    func addDestination(destination: UserLocation)
    {
        self.destination = destination
    }
    
    func addDistance(segmentDistance: Double)
    {
        self.distance = self.distance + segmentDistance
    }
    
    func computeOrigin() throws -> UserLocation
    {
        if self.origin.lat + self.origin.lon != 0.0 {
            return self.origin
        }
        else {
            throw Exceptions.NotInitialized("The travel origin has not been set!")
        }
    }
    
    func computeOriginAsCoordinate() throws -> CLLocationCoordinate2D
    {
        if self.origin.lat + self.origin.lon != 0.0 {
            return CLLocationCoordinate2DMake(self.origin.lat, self.origin.lon)
        }
        else {
            throw Exceptions.NotInitialized("The travel origin has not been set!")
        }
    }
    
    func computeDestination() throws -> UserLocation
    {
        if self.destination.lat + self.destination.lon != 0.0 {
            return self.destination
        }
        else {
            throw Exceptions.NotInitialized("The travel destination has not been set!")
        }
    }
    
    func computeDestinationAsCoordinate() throws -> CLLocationCoordinate2D
    {
        if self.destination.lat + self.destination.lon != 0.0 {
            return CLLocationCoordinate2DMake(self.destination.lat, self.destination.lon)
        }
        else {
            throw Exceptions.NotInitialized("The travel destination has not been set!")
        }
    }
    
    func computeSegments() -> [AKTravelSegment] { return self.segments }
    
    func computeDistance(let unit: UnitOfLength) -> Double
    {
        switch unit {
        case UnitOfLength.Meter:
            return self.distance
        case UnitOfLength.Kilometer:
            return self.distance / 1000
        }
    }
    
    func printObject()
    {
        let string: NSMutableString = NSMutableString()
        
        string.appendString("\n")
        string.appendString("****** TRAVEL ******\n")
        string.appendFormat("\t>>> Origin = Lat: %f, Lon: %f\n", self.origin.lat, self.origin.lon)
        string.appendFormat("\t>>> Distance = %f\n", self.distance)
        string.appendFormat("\t>>> Destination = Lat: %f, Lon: %f\n", self.destination.lat, self.destination.lon)
        string.appendString("****** TRAVEL ******\n")
        
        NSLog("%@", string)
    }
    
    // MARK: NSCoding Implementation
    required convenience init(coder aDecoder: NSCoder)
    {
        let origin = UserLocation(lat: aDecoder.decodeDoubleForKey(Keys.originLat), lon: aDecoder.decodeDoubleForKey(Keys.originLon))
        let destination = UserLocation(lat: aDecoder.decodeDoubleForKey(Keys.destinationLat), lon: aDecoder.decodeDoubleForKey(Keys.destinationLon))
        let segments = aDecoder.decodeObject() as! [AKTravelSegment]
        let distance = aDecoder.decodeDoubleForKey(Keys.distance)
        
        self.init(origin: origin, destination: destination, segments: segments, distance: distance)
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeDouble(self.origin.lat, forKey: Keys.originLat)
        aCoder.encodeDouble(self.origin.lon, forKey: Keys.originLon)
        aCoder.encodeDouble(self.destination.lat, forKey: Keys.destinationLat)
        aCoder.encodeDouble(self.destination.lon, forKey: Keys.destinationLon)
        aCoder.encodeObject(self.segments)
        aCoder.encodeDouble(self.distance, forKey: Keys.distance)
    }
}
