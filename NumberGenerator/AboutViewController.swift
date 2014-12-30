// Created by Vladimir Magaziy <vmagaziy@gmail.com>

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet var aboutLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutLabel.text = NSLocalizedString("Created by Vladimir Magaziy", comment: "")
        aboutLabel.textColor = UIColor.brandDarkColor()
    }
}
