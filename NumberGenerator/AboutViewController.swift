import UIKit

final class AboutViewController: UIViewController {
    @IBOutlet var aboutLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutLabel?.text = NSLocalizedString("Created by Volodymyr Magazii\n<vmagaziy@gmail.com>", comment: "")
        aboutLabel?.textColor = .brandDarkColor
    }
}
