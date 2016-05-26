import UIKit

class AKMainViewController: AKCustomViewController
{
    // MARK: Outlets
    @IBOutlet weak var startRecordingTravel: UIButton!
    
    // MARK: Actions
    @IBAction func startRecordingTravel(sender: AnyObject)
    {
        self.performSegueWithIdentifier("RecordTravelSegue", sender: sender)
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
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
