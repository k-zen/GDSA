import UIKit

class AKMainViewController: AKCustomViewController
{
    // MARK: Actions
    @IBAction func startRecordingTravel(sender: AnyObject)
    {
        self.performSegueWithIdentifier("RecordTravelSegue", sender: self)
        
        NSLog("=> LOCATION SERVICES ==> RECORDING TRAVEL ...")
        AKDelegate().locationManager.startUpdatingLocation()
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}
