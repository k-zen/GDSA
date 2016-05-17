import UIKit

class AKMainViewController: AKCustomViewController
{
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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "RecordTravelSegue" {
            if let recordTravelViewController = segue.destinationViewController as? AKRecordTravelViewController {
                recordTravelViewController.travel = sender as? AKTravel
            }
        }
    }
}
