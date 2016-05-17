import UIKit

class AKRecordTravelViewController: AKCustomViewController
{
    // MARK: Properties
    private let travel: AKTravel = AKTravel(travelDistance: 0.0)
    
    // MARK: Outlets
    @IBOutlet weak var distanceTraveled: UILabel!
    
    // MARK: Actions
    @IBAction func stopRecordingTravel(sender: AnyObject)
    {
        NSLog("=> LOCATION SERVICES ==> STOP RECORDING TRAVEL ...")
        AKDelegate().locationManager.stopUpdatingLocation()
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(AKRecordTravelViewController.locationUpdated),
                                                         name: "LocationUpdate",
                                                         object: nil)
    }
    
    // MARK: Observers
    func locationUpdated(notification: NSNotification)
    {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.travel.addSegment((notification.userInfo!["data"] as! AKTravelSegment).travelDistance)
            
            self.distanceTraveled.text = String(format: "%.0f", self.travel.travelDistance)
        })
    }
}
