import CoreLocation
import Foundation

class AKTravel
{
    // MARK: Properties
    private var travelOrigin: UserLocation?
    private var travelDestination: UserLocation?
    private var travelDistance: Double! = 0.0
    
    func addTravelOrigin(travelOrigin: UserLocation)
    {
        if self.travelOrigin == nil {
            self.travelOrigin = travelOrigin
        }
    }
    
    func addTravelDestination(travelDestination: UserLocation)
    {
        if self.travelDestination == nil {
            self.travelDestination = travelDestination
        }
    }
    
    func addSegment(segment: Double)
    {
        self.travelDistance = self.travelDistance + segment
    }
    
    func computeTravelOrigin() throws -> UserLocation
    {
        if self.travelOrigin != nil {
            return self.travelOrigin!
        }
        else {
            throw Exceptions.NotInitialized("The travel origin has not been set!")
        }
    }
    
    func computeTravelOriginAsCoordinate() throws -> CLLocationCoordinate2D
    {
        if self.travelOrigin != nil {
            return CLLocationCoordinate2DMake(self.travelOrigin!.latitude, self.travelOrigin!.longitude)
        }
        else {
            throw Exceptions.NotInitialized("The travel origin has not been set!")
        }
    }
    
    func computeTravelDestination() throws -> UserLocation
    {
        if self.travelDestination != nil {
            return self.travelDestination!
        }
        else {
            throw Exceptions.NotInitialized("The travel destination has not been set!")
        }
    }
    
    func computeTravelDestinationAsCoordinate() throws -> CLLocationCoordinate2D
    {
        if self.travelDestination != nil {
            return CLLocationCoordinate2DMake(self.travelDestination!.latitude, self.travelDestination!.longitude)
        }
        else {
            throw Exceptions.NotInitialized("The travel destination has not been set!")
        }
    }
    
    func computeTravelDistance() -> Double
    {
        return self.travelDistance
    }
    
    func printObject()
    {
        let string: NSMutableString = NSMutableString()
        
        string.appendString("\n")
        string.appendString("****** TRAVEL ******\n")
        if self.travelOrigin != nil {
            string.appendFormat("\t>>> Travel Origin = Lat: %f, Lon: %f\n", self.travelOrigin!.latitude, self.travelOrigin!.longitude)
        }
        else {
            string.appendFormat("\t>>> Travel Origin = NOT SET\n")
        }
        string.appendFormat("\t>>> Travel Distance = %f\n", self.travelDistance)
        if self.travelDestination != nil {
            string.appendFormat("\t>>> Travel Destination = Lat: %f, Lon: %f\n", self.travelDestination!.latitude, self.travelDestination!.longitude)
        }
        else {
            string.appendFormat("\t>>> Travel Destination = NOT SET\n")
        }
        string.appendString("****** TRAVEL ******\n")
        
        NSLog("%@", string)
    }
}
