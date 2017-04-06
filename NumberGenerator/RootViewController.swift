import UIKit
import iCarousel

@objc class RootViewController: UITableViewController, iCarouselDataSource, iCarouselDelegate {
    private let maxNumber = 40
    private let numbersCount = 5
    private let animationDuration: TimeInterval = 0.2
    private let animationDelay: TimeInterval = 0.1
    private let nextIterationDelay: TimeInterval = 0.35
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var carousel: iCarousel?
    @IBOutlet var generateLabel: UILabel?
    @IBOutlet var copyLabel: UILabel?
    @IBOutlet var numbersLabel: UILabel?
    
    private var randomNumbers: [Int] = []
    private var currentNumberIndex = -1
    private var currentNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBar()
        setUpCarousel()
        setUpLabels()
        setUpActivityIndicator()
    }

    // MARK: Set up
    
    private func setUpNavBar() {
        title = NSLocalizedString("Number Generator", comment: "")
        
        navigationController?.navigationBar.barStyle = .black 
        navigationController?.navigationBar.barTintColor = .brandDarkColor
        
        let infoButton = UIButton(type: .infoDark)
        infoButton.addTarget(self, action: #selector(RootViewController.showInfo), for: .touchUpInside)
        infoButton.tintColor = .brandLightColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
    }
    
    private func setUpCarousel() {
        let height = view.bounds.height
        carousel?.frame = CGRect(x: 0, y: 0, width: 0, height: height / 3)
        carousel?.type = .invertedWheel
        carousel?.isUserInteractionEnabled = false
        carousel?.dataSource = self
        carousel?.delegate = self
    }
    
    private func setUpLabels() {
        generateLabel?.text = NSLocalizedString("Generate", comment: "")
        generateLabel?.textColor = .brandDarkColor
        
        copyLabel?.text = NSLocalizedString("Copy", comment: "")
        copyLabel?.textColor = .brandDarkColor
        
        numbersLabel?.text = numbersText
        numbersLabel?.textColor = .brandDarkColor
    }
    
    private func setUpActivityIndicator() {
        activityIndicator?.color = .brandDarkColor
    }

    // MARK: iCarouselDataSource

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
            view!.layer.borderColor = UIColor.brandDarkColor.cgColor
            
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
        
        view?.backgroundColor = index % 2 == 0 ? .brandDarkColor : .brandLightColor
        label?.textColor = index % 2 == 0 ? .brandLightColor : .brandDarkColor
        view?.alpha = selected ? 0.5 : 1.0
        
        label?.text = NumberFormatter.localizedString(from: NSNumber(value: index + 1), number: .none) // Set item label
        
        return view!
    }
    
    // MARK: iCarouselDelegate
    
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

    // MARK: Table view

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

    // MARK: Action handlers

    @objc private func generateNumbers() {
        tableView.isUserInteractionEnabled = false // Avoid further interactions
        
        for section in 1...2 {
            tableView.cellForRow(at: IndexPath(row: 0, section: section))?.textLabel?.alpha = 0.5
        }
        
        activityIndicator?.startAnimating()
        
        randomNumbers = RandomNumberGenerator.generate(numbersCount, max: maxNumber, min: 1)
        currentNumberIndex = -1
        carousel?.reloadData()
        
        visualizeGeneration()
    }
    
    @objc private func copyNumbers() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = numbersText
    }
    
    @objc private func showInfo() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AboutViewController")
        
        viewController.title = NSLocalizedString("About", comment: "")
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(RootViewController.dismissInfo))
        barButtonItem.tintColor = .brandLightColor
        viewController.navigationItem.rightBarButtonItem = barButtonItem
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.barTintColor = .brandDarkColor
        
        navigationController.modalTransitionStyle = .flipHorizontal
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc private func dismissInfo() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: Implementation
    
    private var numbersText: String {
        var text = ""
        
        for i in 0...numbersCount - 1 {
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
    
    @objc private func visualizeGeneration() {
        numbersLabel?.text = numbersText
        
        if (currentNumberIndex == numbersCount - 1) {
            tableView.isUserInteractionEnabled = true // Renable interactions
            
            for section in 1...2 {
                tableView.cellForRow(at: IndexPath(row: 0, section: section))?.textLabel?.alpha = 1
            }
            
            activityIndicator?.stopAnimating()
            return
        }
        
        currentNumberIndex += 1
        
        Timer.scheduledTimer(timeInterval: animationDelay,
                                   target: self,
                                 selector: #selector(showNumber),
                                 userInfo: nil,
                                  repeats: false)
    }
    
    @objc private func showNumber() {
        let number = randomNumbers[currentNumberIndex]
        var difference = abs(currentNumber - number)
        if currentNumber == 0 {
            difference = min(difference, abs(maxNumber - number))
        }
        
        let duration = animationDuration * TimeInterval(difference)
        currentNumber = number
        carousel?.scrollToItem(at: currentNumber - 1, duration: duration)
    }
}
