// Created by Volodymyr Magazii <vmagaziy@gmail.com>

import UIKit
import iCarousel

class RootViewController: UITableViewController {
    let maxNumber: Int = 40
    let numbersCount: Int = 5
    let animationDuration: TimeInterval = 0.2
    let animationDelay: TimeInterval = 0.1
    let nextIterationDelay: TimeInterval = 0.35
    
    var carousel: iCarousel!
    var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var generateLabel: UILabel!
    @IBOutlet var copyLabel: UILabel!
    @IBOutlet var numbersLabel: UILabel!
    
    var randomNumbers: [Int] = []
    var currentNumberIndex: Int = -1
    var currentNumber: Int = 0
    
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
        
        navigationController?.navigationBar.barStyle = .black 
        navigationController?.navigationBar.barTintColor = UIColor.brandDarkColor()
        
        let infoButton = UIButton(type: .infoDark)
        infoButton.addTarget(self, action: #selector(RootViewController.showInfo), for: .touchUpInside)
        infoButton.tintColor = UIColor.brandLightColor()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
    }
    
    func setUpCarouselView() {
        let screenHeight = UIScreen.main.bounds.height
        carousel = iCarousel(frame: CGRect(x: 0, y: 0, width: 1, height: screenHeight / 3)) // will be expanded horizontally
        carousel.type = .invertedWheel
        carousel.delegate = self
        carousel.dataSource = self
        carousel.isUserInteractionEnabled = false
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
        
        let height = 2 * activityIndicator.bounds.height
        let contentView = UIView(frame:CGRect(x: 0.0, y: 0.0, width: 1.0, height: height)) // will be expanded horizontally
        contentView.addSubview(activityIndicator)
        
        tableView.tableFooterView = contentView
    }
    
    func centerActivityIndicator() {
        let size = tableView.tableFooterView!.bounds.size
        activityIndicator.center = CGPoint(x: size.width / 2, y: size.height / 2)
    }
}

// MARK: Carousel

extension RootViewController: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        var numberOfItems = Int(maxNumber)
        if currentNumberIndex > 0 {
            numberOfItems -= currentNumberIndex
        }
        
        return numberOfItems
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var view = view
        var label: UILabel? = nil
        
        // Create a new view if no view is available for recycling,
        // otherwise get a reference to the label in the recycled view
        if let view = view {
            label = view.viewWithTag(1) as? UILabel
        } else {
            let dimension = carousel.bounds.height / 2
            view = UIView(frame: CGRect(x: 0, y: 0, width: dimension, height: dimension))
            
            view!.layer.cornerRadius = dimension / 2
            view!.layer.borderWidth = 1.0
            view!.layer.borderColor = UIColor.brandDarkColor().cgColor
            
            label = UILabel(frame: view!.bounds)
            label!.textAlignment = .center
            label!.backgroundColor = UIColor.clear
            label!.font = label!.font.withSize(50)
            label!.tag = 1
            view!.addSubview(label!)
        }
        
        var selected = false
        var currentIndex = currentNumberIndex
        if carousel.isScrolling {
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
        
        view?.backgroundColor = index % 2 == 0 ? .brandDarkColor() : .brandLightColor()
        label?.textColor = index % 2 == 0 ? .brandLightColor() : .brandDarkColor()
        view?.alpha = selected ? 0.5 : 1.0
        
        label?.text = NumberFormatter.localizedString(from: NSNumber(value: index + 1), number: .none) // Set item label
        
        return view!
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .wrap {
            return 1.0
        } else if option == .spacing {
            return value * 1.1
        }
        
        return value
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        if currentNumberIndex >= 0 {
            let number = randomNumbers[currentNumberIndex]
            carousel.reloadItem(at: Int(number) - 1, animated: true)
        }
        
        if randomNumbers.count != 0 {
            Timer.scheduledTimer(timeInterval: nextIterationDelay,
                                                   target: self,
                                                 selector: #selector(visualizeGeneration),
                                                 userInfo: nil,
                                                  repeats: false)
        }
    }
}

// MARK: Table view

extension RootViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 15.0 : 0.0
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 0) {
            return false
        }
        
        if (indexPath.section == 2) {
            return randomNumbers.count != 0
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        assert(indexPath.section != 0, "Wrong state")
        tableView.deselectRow(at: indexPath, animated: true) // Remove selection right away
        
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
        tableView.isUserInteractionEnabled = false // Avoid further interactions
        activityIndicator.startAnimating()
        
        randomNumbers = RandomNumberGenerator.generateWithCount(numbersCount, max: maxNumber, min: 1)
        currentNumberIndex = -1
        carousel.reloadData()
        
        visualizeGeneration()
    }
    
    func copyNumbers() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = numbersText()
    }
    
    func showInfo() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AboutViewController") as UIViewController
        
        vc.title = NSLocalizedString("About", comment: "")
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(RootViewController.dismissInfo))
        barButtonItem.tintColor = UIColor.brandLightColor()
        vc.navigationItem.rightBarButtonItem = barButtonItem
        
        let nc = UINavigationController(rootViewController: vc)
        nc.navigationBar.barStyle = .black 
        nc.navigationBar.barTintColor = UIColor.brandDarkColor()
        
        nc.modalTransitionStyle = .flipHorizontal
        present(nc, animated: true, completion: nil)
    }
    
    func dismissInfo() {
        dismiss(animated: true, completion: nil)
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
            
            if (i != Int(numbersCount) - 1) {
                text += " "
            }
        }
        
        return text
    }
    
    func visualizeGeneration() {
        numbersLabel.text = numbersText()
        
        if (currentNumberIndex == numbersCount - 1) {
            tableView.isUserInteractionEnabled = true // Renable interactions
            activityIndicator.stopAnimating()
            return
        }
        
        currentNumberIndex += 1
        
        Timer.scheduledTimer(timeInterval: animationDelay,
                                   target: self,
                                 selector: #selector(showNumber),
                                 userInfo: nil,
                                  repeats: false)
    }
    
    func showNumber() {
        let number = randomNumbers[currentNumberIndex]
        var difference = abs(currentNumber - number)
        if currentNumber == 0 {
            difference = min(difference, abs(maxNumber - number))
        }
        
        let duration = animationDuration * TimeInterval(difference)
        currentNumber = number
        carousel.scrollToItem(at: currentNumber - 1, duration: duration)
    }
}
