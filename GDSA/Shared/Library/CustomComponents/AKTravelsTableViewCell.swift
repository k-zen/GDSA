import UIKit

class AKTravelsTableViewCell: UITableViewCell
{
    // MARK: Outlets
    @IBOutlet weak var origin: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var mapIcon: UIImageView!
    
    // MARK: UITableViewCell Overriding
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
