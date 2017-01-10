import UIKit

class AKTravelStopsOverlayView: AKCustomView
{
    // MARK: Properties
    let animation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
    var controller: AKCustomViewController?
    
    // MARK: Outlets
    @IBOutlet weak var stops: UILabel!
    @IBOutlet weak var stopsValue: UILabel!
    @IBOutlet weak var totalStopsTime: UILabel!
    @IBOutlet weak var totalStopsTimeValue: UILabel!
    
    // MARK: UIView Overriding
    convenience init()
    {
        NSLog("=> DEFAULT init()")
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect)
    {
        NSLog("=> FRAME init()")
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        NSLog("=> CODER init()")
        super.init(coder: aDecoder)!
    }
    
    // MARK: Miscellaneous
    func setup()
    {
        NSLog("=> ENTERING SETUP ON FRAME: AKTravelStopsOverlayView")
        
        self.animation.fromValue = 1.00
        self.animation.toValue = 0.90
        self.animation.duration = 2.0
        self.animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.animation.autoreverses = true
        self.animation.repeatCount = 20000
        
        // Custom L&F.
        self.stops.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.stops.layer.masksToBounds = true
        self.stopsValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.stopsValue.layer.masksToBounds = true
        self.totalStopsTime.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.totalStopsTime.layer.masksToBounds = true
        self.totalStopsTimeValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.totalStopsTimeValue.layer.masksToBounds = true
    }
    
    func startAnimation()
    {
        self.customView.layer.add(animation, forKey: "opacity")
    }
    
    func stopAnimation()
    {
        self.customView.layer.removeAllAnimations()
    }
}
