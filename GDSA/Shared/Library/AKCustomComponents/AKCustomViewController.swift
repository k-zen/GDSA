import CoreLocation
import Foundation
import UIKit

class AKCustomViewController: UIViewController, UIGestureRecognizerDelegate
{
    // MARK: Properties
    var tapGestureRecognizer: UITapGestureRecognizer!
    var shouldCheckLoggedUser: Bool = true
    var shouldDisableGesture: Bool = false
    var customOperationsWhenTaped: () -> Void = {}
    var bottomMenu: UIAlertController?
    
    // MARK: UIViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        NSLog("=> VIEW DID APPEAR ON: \(self.dynamicType)")
        
        // Checks
        self.manageAccessToLocationServices()
    }
    
    // MARK: UIGestureRecognizerDelegate Implementation
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { return !self.shouldDisableGesture }
    
    // MARK: Miscellaneous
    func setup()
    {
        self.tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(AKCustomViewController.tap(_:)))
        
        if !self.shouldDisableGesture {
            // Add support to close editing mode by tapping somewhere in the screen.
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
        
        self.definesPresentationContext = true
    }
    
    func tap(_ gesture: UIGestureRecognizer?)
    {
        self.view.endEditing(true)
        self.customOperationsWhenTaped()
    }
    
    func tap() { self.tap(nil) }
    
    func setupMenu(_ title: String!, message: String!, type: UIAlertControllerStyle!)
    { self.bottomMenu = UIAlertController.init(title: title, message: message, preferredStyle: type) }
    
    func addMenuAction(_ title: String!, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?)
    {
        if let menu = self.bottomMenu {
            menu.addAction(UIAlertAction(title: title, style: style, handler: handler))
        }
    }
    
    func showMenu()
    {
        if let menu = self.bottomMenu {
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    // MARK: Utility functions
    func manageAccessToLocationServices()
    {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            AKDelegate().locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "The App cannot be used if \"Location Access\" is disabled. Please enabled it in \"Settings\".",
                preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in AKDelegate().applicationActive = false }))
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (action) in
                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                    AKDelay(0.0, task: { () in UIApplication.shared.openURL(url) })
                }})
            
            self.present(alertController, animated: true, completion: nil)
            break
        default:
            break
        }
    }
}
