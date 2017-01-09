import UIKit

class AKTravelsTableViewCell: UITableViewCell
{
    // MARK: Outlets
    @IBOutlet weak var entryDate: UILabel!
    @IBOutlet weak var distance: UILabel!
    
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
