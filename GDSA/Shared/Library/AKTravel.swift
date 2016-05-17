import Foundation

class AKTravel: NSObject
{
    var travelDistance: Double! = 0.0
    
    init(travelDistance: Double)
    {
        self.travelDistance = self.travelDistance + travelDistance
    }
    
    func addSegment(segment: Double)
    {
        self.travelDistance = self.travelDistance + segment
    }
    
    func printObject()
    {
        let string: NSMutableString = NSMutableString()
        
        string.appendString("\n")
        string.appendString("****** TRAVEL ******\n")
        string.appendFormat("\t>>> Travel Distance = %f\n", self.travelDistance)
        string.appendString("****** TRAVEL ******\n")
        
        NSLog("%@", string)
    }
}
