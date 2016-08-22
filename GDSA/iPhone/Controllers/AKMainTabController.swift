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
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool
    {
        if AKDelegate().recordingTravel {
            AKPresentTopMessageWarn(self, message: "Estas grabando un viaje, paralo primero.")
        }
        
        return !AKDelegate().recordingTravel
    }
}
