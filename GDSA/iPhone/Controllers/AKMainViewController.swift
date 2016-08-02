import UIKit

class AKMainViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Outlets
    @IBOutlet weak var travelsTable: UITableView!
    @IBOutlet weak var startRecordingTravel: UIButton!
    
    // MARK: Actions
    @IBAction func startRecordingTravel(_ sender: AnyObject)
    {
        self.performSegue(withIdentifier: "RecordTravelSegue", sender: sender)
    }
    
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
        do {
            let e = try AKObtainMasterFile().travels![(indexPath as NSIndexPath).row]
            
            let cell = self.travelsTable.dequeueReusableCell(withIdentifier: "Travels_Table_Cell") as! AKTravelsTableViewCell
            cell.origin.text = String(format: "%f, %f", try e.computeOrigin().lat, try e.computeOrigin().lon)
            cell.distance.text = String(format: "%.1fkm", e.computeDistance(UnitOfLength.kilometer))
            cell.destination.text = String(format: "%f, %f", try e.computeDestination().lat, try e.computeDestination().lon)
            
            // Custom L&F.
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        }
        catch {
            NSLog("=> ERROR: \(error)")
            
            let defaultCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Default_Table_Cell")
            defaultCell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return defaultCell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerCell = UIView(frame: CGRect(x: 8, y: 0, width: 276, height: 30))
        headerCell.backgroundColor = GlobalConstants.AKTableHeaderCellBg
        
        let title = UILabel(frame: headerCell.frame)
        title.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 16.0)
        title.textColor = UIColor.white()
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
        do {
            return (try AKObtainMasterFile().travels?.count)!
        }
        catch {
            NSLog("=> ERROR: \(error)")
            
            return 0
        }
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
            do {
                try AKObtainMasterFile().travels?.remove(at: (indexPath as NSIndexPath).row)
                self.travelsTable.reloadData()
            }
            catch {
                NSLog("=> ERROR: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        return UITableViewCellEditingStyle.delete
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        do {
            _ = try AKObtainMasterFile().travels![(indexPath as NSIndexPath).row]
        }
        catch {
            NSLog("=> ERROR: \(error)")
        }
        
        // MOVE TO VIEW HERE.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 62 }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 30 }
    
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
        
        // Custom L&F.
        self.startRecordingTravel.layer.cornerRadius = CGFloat(GlobalConstants.AKButtonCornerRadius)
    }
}
