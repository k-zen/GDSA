import Foundation

class AKMasterFile: NSObject, NSCoding
{
    // MARK: Constants
    struct Keys {
        static let masterFile = "AKMF.travels"
    }
    
    // MARK: Properties
    var travels: [AKTravel]?
    
    // MARK: Initializers
    override init()
    {
        self.travels = []
    }
    
    init(travels: [AKTravel])
    {
        self.travels = travels
    }
    
    // MARK: Utilities
    func addTravel(_ travel: AKTravel)
    {
        self.travels?.append(travel)
        
        if GlobalConstants.AKDebug {
            NSLog("=> ### ADDED TRAVEL")
            NSLog("%@", travel.printObject("=> "))
            NSLog("=> ### ADDED TRAVEL")
        }
    }
    
    // MARK: NSCoding Implementation
    required convenience init(coder aDecoder: NSCoder)
    {
        let travels = aDecoder.decodeObject(forKey: Keys.masterFile) as! [AKTravel]
        
        if GlobalConstants.AKDebug {
            NSLog("=> ### READING TRAVELS FROM FILE")
            if travels.count > 0 {
                for travel in travels {
                    NSLog("%@", travel.printObject("=> "))
                }
            }
            else {
                NSLog("=> NO TRAVELS IN FILE")
            }
            NSLog("=> ### READING TRAVELS FROM FILE")
        }
        
        self.init(travels: travels)
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.travels, forKey: Keys.masterFile)
        
        if GlobalConstants.AKDebug {
            NSLog("=> ### WRITING TRAVELS TO FILE")
            if (self.travels?.count)! > 0 {
                for travel in self.travels! {
                    NSLog("%@", travel.printObject("=> "))
                }
            }
            else {
                NSLog("=> NO TRAVELS RECORDED")
            }
            NSLog("=> ### WRITING TRAVELS TO FILE")
        }
    }
}
