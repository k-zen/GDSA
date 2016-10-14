import UIKit

class AKPreviousTravelsViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Outlets
    @IBOutlet weak var travelsTable: UITableView!
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.travelsTable.reloadData()
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let e = AKObtainMasterFile().travels![(indexPath as NSIndexPath).row]
        
        let cell = self.travelsTable.dequeueReusableCell(withIdentifier: "Travels_Table_Cell") as! AKTravelsTableViewCell
        cell.origin.text = String(format: "%f, %f", e.computeOrigin().latitude, e.computeOrigin().longitude)
        cell.distance.text = String(format: "%.1fkm", e.computeDistance(UnitOfLength.kilometer))
        cell.destination.text = String(format: "%f, %f", e.computeDestination().latitude, e.computeDestination().longitude)
        
        // Custom L&F.
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerCell = UIView(frame: CGRect(x: 8, y: 0, width: 276, height: 22))
        headerCell.backgroundColor = GlobalConstants.AKTableHeaderCellBg
        
        let title = UILabel(frame: headerCell.frame)
        title.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 14.0)
        title.textColor = UIColor.white
        title.text = "Travels"
        
        headerCell.addSubview(title)
        
        AKAddBorderDeco(headerCell,
                        color: GlobalConstants.AKTableHeaderLeftBorderBg.cgColor,
                        thickness: GlobalConstants.AKDefaultBorderThickness,
                        position: CustomBorderDecorationPosition.left)
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (AKObtainMasterFile().travels?.count)!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.delete {
            AKObtainMasterFile().travels?.remove(at: (indexPath as NSIndexPath).row)
            self.travelsTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        return UITableViewCellEditingStyle.delete
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // AKObtainMasterFile().travels![(indexPath as NSIndexPath).row]
        
        // MOVE TO VIEW HERE.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 62 }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 22 }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return CGFloat.leastNormalMagnitude }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.shouldCheckLoggedUser = false
        super.setup()
        
        // Custom Components
        self.travelsTable.register(UINib(nibName: "AKTravelsTableViewCell", bundle: nil), forCellReuseIdentifier: "Travels_Table_Cell")
        
        // Add UITableView's DataSource & Delegate.
        self.travelsTable?.dataSource = self
        self.travelsTable?.delegate = self
    }
}
