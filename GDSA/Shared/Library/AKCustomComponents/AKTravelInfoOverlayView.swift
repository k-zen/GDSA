import UIKit

class AKTravelInfoOverlayView: AKCustomView
{
    // MARK: Properties
    let animation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
    var controller: AKCustomViewController?
    
    // MARK: Outlets
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var coordinates: UILabel!
    
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
        NSLog("=> ENTERING SETUP ON FRAME: AKTravelInfoOverlayView")
        
        self.animation.fromValue = 0.85
        self.animation.toValue = 0.65
        self.animation.duration = 2.0
        self.animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.animation.autoreverses = true
        self.animation.repeatCount = 20000
        
        // Custom L&F.
        self.distance.layer.cornerRadius = 4.0
        self.distance.layer.masksToBounds = true
        self.speed.layer.cornerRadius = 4.0
        self.speed.layer.masksToBounds = true
        self.time.layer.cornerRadius = 4.0
        self.time.layer.masksToBounds = true
        self.coordinates.layer.cornerRadius = 4.0
        self.coordinates.layer.masksToBounds = true
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
