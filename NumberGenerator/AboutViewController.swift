// Created by Volodymyr Magazii <vmagaziy@gmail.com>

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet var aboutLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutLabel.numberOfLines = 0
        aboutLabel.text = NSLocalizedString("Created by Volodymyr Magazii\n<vmagaziy@gmail.com>", comment: "")
        aboutLabel.textColor = UIColor.brandDarkColor()
    }
}
