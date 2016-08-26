import TSMessages
import UIKit

class AKMainTabController: UITabBarController, UITabBarControllerDelegate
{
    // MARK: UIViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    // MARK: UITabBarControllerDelegate Implementation
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
        if AKDelegate().recordingTravel {
            AKPresentTopMessage(self, type: TSMessageNotificationType.warning, message: "Estas grabando un viaje, paralo primero.")
        }
        
        return !AKDelegate().recordingTravel
    }
}
