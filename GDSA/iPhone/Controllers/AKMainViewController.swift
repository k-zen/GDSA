import UIKit

class AKMainViewController: AKCustomViewController
{
    // MARK: Outlets
    @IBOutlet weak var startRecordingTravel: UIButton!
    
    // MARK: Actions
    @IBAction func startRecordingTravel(sender: AnyObject)
    {
        NSLog("=> LOCATION SERVICES ==> RECORDING TRAVEL ...")
        AKDelegate().recordingTravel = true
        
        let travel = AKTravel()
        travel.addTravelOrigin(UserLocation(latitude: AKDelegate().currentLatitude, longitude: AKDelegate().currentLongitude))
        
        self.performSegueWithIdentifier("RecordTravelSegue", sender: travel)
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "RecordTravelSegue" {
            if let recordTravelViewController = segue.destinationViewController as? AKRecordTravelViewController {
                recordTravelViewController.travel = sender as? AKTravel
            }
        }
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.shouldCheckLoggedUser = false
        super.setup()
        
        // Custom L&F.
        self.startRecordingTravel.layer.cornerRadius = 4.0
    }
}
