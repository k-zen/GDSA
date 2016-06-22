import UIKit

class AKMainViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Outlets
    @IBOutlet weak var travelsTable: UITableView!
    @IBOutlet weak var startRecordingTravel: UIButton!
    
    // MARK: Actions
    @IBAction func startRecordingTravel(sender: AnyObject)
    {
        self.performSegueWithIdentifier("RecordTravelSegue", sender: sender)
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.travelsTable.reloadData()
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        do {
            let e = try AKObtainMasterFile().travels![indexPath.row]
            
            let cell = self.travelsTable.dequeueReusableCellWithIdentifier("Travels_Table_Cell") as! AKTravelsTableViewCell
            cell.origin.text = String(format: "%f, %f", try e.computeOrigin().lat, try e.computeOrigin().lon)
            cell.distance.text = String(format: "%.1fkm", e.computeDistance(UnitOfLength.Kilometer))
            cell.destination.text = String(format: "%f, %f", try e.computeDestination().lat, try e.computeDestination().lon)
            
            // Custom L&F.
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }
        catch {
            NSLog("=> ERROR: \(error)")
            
            let defaultCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Default_Table_Cell")
            defaultCell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return defaultCell
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerCell = UIView(frame: CGRectMake(8, 0, 276, 22))
        headerCell.backgroundColor = GlobalConstants.AKTableHeaderCellBg
        
        let title = UILabel(frame: headerCell.frame)
        title.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 14.0)
        title.textColor = UIColor.whiteColor()
        title.text = "Travels"
        
        headerCell.addSubview(title)
        
        AKAddBorderDeco(headerCell,
                        color: GlobalConstants.AKTableHeaderLeftBorderBg.CGColor,
                        thickness: GlobalConstants.AKDefaultBorderThickness,
                        position: CustomBorderDecorationPosition.Left)
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        do {
            return (try AKObtainMasterFile().travels?.count)!
        }
        catch {
            NSLog("=> ERROR: \(error)")
            
            return 0
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool { return true }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String?
    {
        return "Delete"
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            do {
                try AKObtainMasterFile().travels?.removeAtIndex(indexPath.row)
                self.travelsTable.reloadData()
            }
            catch {
                NSLog("=> ERROR: \(error)")
            }
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return UITableViewCellEditingStyle.Delete
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        do {
            _ = try AKObtainMasterFile().travels![indexPath.row]
        }
        catch {
            NSLog("=> ERROR: \(error)")
        }
        
        // MOVE TO VIEW HERE.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat { return 62 }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 22 }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return CGFloat.min }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.shouldCheckLoggedUser = false
        super.setup()
        
        // Custom Components
        self.travelsTable.registerNib(UINib(nibName: "AKTravelsTableViewCell", bundle: nil), forCellReuseIdentifier: "Travels_Table_Cell")
        
        // Add UITableView's DataSource & Delegate.
        self.travelsTable?.dataSource = self
        self.travelsTable?.delegate = self
        
        // Custom L&F.
        self.startRecordingTravel.layer.cornerRadius = 4.0
    }
}
