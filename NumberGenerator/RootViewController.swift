// Created by Vladimir Magaziy <vmagaziy@gmail.com>

import UIKit

class RootViewController: UITableViewController {
    let maxNumber: UInt = 40
    let numbersCount: UInt = 5
    let animationDuration: NSTimeInterval = 0.2
    let animationDelay: NSTimeInterval = 0.1
    let nextIterationDelay: NSTimeInterval = 0.35
    
    var carousel: iCarousel!
    var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var generateLabel: UILabel!
    @IBOutlet var copyLabel: UILabel!
    @IBOutlet var numbersLabel: UILabel!
    
    var randomNumbers: [UInt] = []
    var currentNumberIndex: Int = -1
    var currentNumber: UInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBar()
        setUpCarouselView()
        setUpLabels()
        setUpActivityIndicator()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerActivityIndicator()
    }
}

// MARK: Set up

extension RootViewController {
    func setUpNavBar() {
        title = NSLocalizedString("Number Generator", comment: "")
        
        navigationController?.navigationBar.barStyle = .Black 
        navigationController?.navigationBar.barTintColor = UIColor.brandDarkColor()
        
        let infoButton = UIButton.buttonWithType(.InfoDark) as UIButton
        infoButton.addTarget(self, action: "showInfo", forControlEvents: .TouchUpInside)
        infoButton.tintColor = UIColor.brandLightColor()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
    }
    
    func setUpCarouselView() {
        let screenHeight = CGRectGetHeight(UIScreen.mainScreen().bounds)
        carousel = iCarousel(frame:CGRect(x: 0.0, y: 0.0, width: 1.0, height: screenHeight / 3)) // will be expanded horizontally
        carousel.type = .InvertedWheel
        carousel.delegate = self
        carousel.dataSource = self
        carousel.userInteractionEnabled = false
        tableView.tableHeaderView = carousel
    }
    
    func setUpLabels() {
        generateLabel.text = NSLocalizedString("Generate", comment: "")
        generateLabel.textColor = UIColor.brandDarkColor()
        
        copyLabel.text = NSLocalizedString("Copy", comment: "")
        copyLabel.textColor = UIColor.brandDarkColor()
        
        numbersLabel.text = numbersText()
        numbersLabel.textColor = UIColor.brandDarkColor()
    }
    
    func setUpActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = UIColor.brandDarkColor()
        activityIndicator.sizeToFit()
        
        let height = 2 * CGRectGetHeight(activityIndicator.bounds)
        let contentView = UIView(frame:CGRect(x: 0.0, y: 0.0, width: 1.0, height: height)) // will be expanded horizontally
        contentView.addSubview(activityIndicator)
        
        tableView.tableFooterView = contentView
    }
    
    func centerActivityIndicator() {
        var size = tableView.tableFooterView!.bounds.size
        activityIndicator.center = CGPoint(x: size.width / 2, y: size.height / 2)
    }
}

// MARK: Carousel

extension RootViewController: iCarouselDataSource, iCarouselDelegate {
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int {
        var numberOfItems = Int(maxNumber)
        if currentNumberIndex > 0 {
            numberOfItems -= currentNumberIndex
        }
        
        return numberOfItems
    }
    
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, var reusingView view: UIView!) -> UIView! {
        var label: UILabel! = nil
        
        // Create a new view if no view is available for recycling,
        // otherwise get a reference to the label in the recycled view
        if (view == nil) {
            var dimension = CGRectGetHeight(carousel.bounds) / 2
            view = UIView(frame:CGRectMake(0.0, 0.0, dimension, dimension))
            
            view.layer.cornerRadius = dimension / 2
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor.brandDarkColor().CGColor
            
            label = UILabel(frame:view.bounds)
            label.textAlignment = .Center
            label.backgroundColor = UIColor.clearColor()
            label.font = label.font.fontWithSize(50)
            label.tag = 1
            view.addSubview(label)
        } else {
            label = view.viewWithTag(1) as UILabel!
        }
        
        var selected = false
        var currentIndex = currentNumberIndex
        if carousel.scrolling {
            currentIndex -= 1
        }
        
        if currentIndex >= 0 {
            for i in 0...currentIndex {
                if (Int(randomNumbers[i]) == index + 1) {
                    selected = true
                    break
                }
            }
        }
        
        view.backgroundColor = index % 2 == 0 ? UIColor.brandDarkColor() : UIColor.brandLightColor()
        label.textColor = index % 2 == 0 ? UIColor.brandLightColor() : UIColor.brandDarkColor()
        view.alpha = selected ? 0.5 : 1.0
        
        label.text = "\(index + 1)" // Set item label
        
        return view
    }
    
    func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .Wrap {
            return 1.0
        } else if option == .Spacing {
            return value * 1.1
        }
        
        return value
    }
    
    func carouselDidEndScrollingAnimation(carousel: iCarousel!) {
        if currentNumberIndex >= 0 {
            let number = randomNumbers[currentNumberIndex]
            carousel.reloadItemAtIndex(Int(number) - 1, animated: true)
        }
        
        if randomNumbers.count != 0 {
            NSTimer.scheduledTimerWithTimeInterval(nextIterationDelay,
                                                   target: self,
                                                 selector: Selector("visualizeGeneration"),
                                                 userInfo: nil,
                                                  repeats: false)
        }
    }
}

// MARK: Table view

extension RootViewController : UITableViewDataSource, UITableViewDelegate {
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 15.0 : 0.0
    }

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (indexPath.section == 0) {
            return false
        }
        
        if (indexPath.section == 2) {
            return randomNumbers.count != 0
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        assert(indexPath.section != 0, "Wrong state")
        tableView.deselectRowAtIndexPath(indexPath, animated: true) // Remove selection right away
        
        if indexPath.section == 1 {
            generateNumbers()
        } else if indexPath.section == 2 {
            copyNumbers()
        }
            
    }
}

// MARK: Action handlers

extension RootViewController {
    func generateNumbers() {
        tableView.userInteractionEnabled = false // Avoid further interactions
        activityIndicator.startAnimating()
        
        randomNumbers = RandomNumberGenerator.generateWithCount(numbersCount, max:maxNumber, min:1, allowDuplicates: false)
        currentNumberIndex = -1
        carousel.reloadData()
        
        visualizeGeneration()
    }
    
    func copyNumbers() {
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.string = numbersText()
    }
    
    func showInfo() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("AboutViewController") as UIViewController
        
        vc.title = NSLocalizedString("About", comment: "")
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismissInfo")
        barButtonItem.tintColor = UIColor.brandLightColor()
        vc.navigationItem.rightBarButtonItem = barButtonItem
        
        var nc = UINavigationController(rootViewController: vc)
        nc.navigationBar.barStyle = .Black 
        nc.navigationBar.barTintColor = UIColor.brandDarkColor()
        
        nc.modalTransitionStyle = .FlipHorizontal
        presentViewController(nc, animated: true, completion: nil)
    }
    
    func dismissInfo() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: Implementation

extension RootViewController {
    func numbersText() -> String {
        var text = ""
        
        for i in 0...Int(numbersCount) - 1 {
            if currentNumberIndex < 0 || i > currentNumberIndex {
                text += "—"
            } else {
                text += "\(randomNumbers[i])"
            }
            
            if (i != numbersCount - 1) {
                text += " "
            }
        }
        
        return text
    }
    
    func visualizeGeneration() {
        numbersLabel.text = numbersText()
        
        if (currentNumberIndex == Int(numbersCount) - 1) {
            tableView.userInteractionEnabled = true // Renable interactions
            activityIndicator.stopAnimating()
            return
        }
        
        currentNumberIndex++
        
        NSTimer.scheduledTimerWithTimeInterval(animationDelay,
                                               target: self,
                                             selector: Selector("showNumber"),
                                             userInfo: nil,
                                              repeats: false)
    }
    
    func showNumber() {
        let number = randomNumbers[currentNumberIndex]
        var difference = abs(currentNumber - number)
        if currentNumber == 0 {
            difference = min(difference, abs(maxNumber - number))
        }
        
        let duration = animationDuration * NSTimeInterval(difference)
        currentNumber = number
        carousel.scrollToItemAtIndex(currentNumber - 1, duration: duration)
    }
}
