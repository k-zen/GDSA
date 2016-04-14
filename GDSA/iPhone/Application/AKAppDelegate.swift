import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    // MARK: Properties
    let menu: AMSlideOutNavigationController = AMSlideOutNavigationController.slideOutNavigation() as! AMSlideOutNavigationController
    var window: UIWindow?
    
    // MARK: UIApplicationDelegate Implementation
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // LOOK & FEEL CUSTOMIZATIONS.
        // [[UINavigationBar appearance] setBarTintColor:HEXCOLOR(0x2A363B)];
        // [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:HEXCOLOR(0xFFFFFF),
        //     NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18.0],
        //     NSFontAttributeName, nil]];
        
        self.menu.setSlideoutOptions(AMSlideOutGlobals.defaultFlatOptions())
        self.menu.addSectionWithTitle("Recording")
        self.menu.addViewControllerToLastSection(AKRecordTravelViewController(nibName: "AKRecordTravelView", bundle: nil), tagged: 1, withTitle: "Record Travel", andIcon: nil)
//        self.menu.setSlideoutOptions([
//            AMOptionsButtonIcon : UIImage(imageLiteral:"0002-044px.png"),
//            AMOptionsSlideValue : (240.0),
//            AMOptionsHeaderSeparatorUpper : UIColor.clearColor(),
//            AMOptionsHeaderSeparatorLower : UIColor.clearColor(),
//            AMOptionsHeaderGradientUp : UIColor.clearColor(),
//            AMOptionsHeaderGradientDown : UIColor.clearColor(),
//            AMOptionsHeaderFont : UIFont(name:"HelveticaNeue-CondensedBold", size:18.0)!,
//            AMOptionsHeaderFontColor : UIColor.whiteColor(),
//            AMOptionsHeaderPadding : (10.0),
//            AMOptionsHeaderHeight : (60),
//            AMOptionsImageOffsetByY : (5.0),
//            AMOptionsImageHeight : (24.0),
//            AMOptionsImagePadding : (44.0),
//            AMOptionsImageLeftPadding : (10.0),
//            AMOptionsTableIconMaxSize : (24.0),
//            AMOptionsSelectionBackground : UIColor.clearColor(),
//            AMOptionsCellSelectionFontColor : UIColor.whiteColor(),
//            AMOptionsTableBackground : UIImage(),
//            AMOptionsTableInsetX : (0.0),
//            AMOptionsTableOffsetY : (100.0),
//            AMOptionsTableCellHeight : (34.0),
//            AMOptionsTextPadding : (0.0),
//            AMOptionsBackground : UIColor.clearColor(),
//            AMOptionsCellBackground : UIColor.clearColor(),
//            AMOptionsCellFont : UIFont(name:"HelveticaNeue-CondensedBold", size:16.0)!,
//            AMOptionsCellFontColor : UIColor.whiteColor(),
//            AMOptionsCellSeparatorUpper : UIColor.clearColor(),
//            AMOptionsCellSeparatorLower : UIColor.clearColor(),
//            AMOptionsTableCellHeight : (60),
//            AMOptionsNavbarTranslucent : false,
//            AMOptionsEnableShadow : false
//            ]);
        
        self.window?.rootViewController = self.menu
        self.window?.makeKeyAndVisible()
        
        return true
    }
}
