//
//  ViewController.swift
//  TouchDownAnimation
//
//  Created by Konstantin Safronov on 2/2/17.
//  Copyright © 2017 Konstantin Safronov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet fileprivate var touchDownImageView: UIImageView!
    @IBOutlet fileprivate var navigationBarTopSpace: NSLayoutConstraint!
    @IBOutlet fileprivate var copyrightLabelBottomSpace: NSLayoutConstraint!
    @IBOutlet fileprivate var tradeMarksSpacerWidth: NSLayoutConstraint!
    
    @IBOutlet fileprivate var touchDownView: UIView!
    @IBOutlet fileprivate var vinylView: UIView!
    @IBOutlet fileprivate var tradeMarkView: UIView!
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Width / Heights not depends on the view size (which can be incorrect in view did load)
        // therefore it is OK to round corners here.
        RoundedViewDecorator().decorate(views: [touchDownView, vinylView])
    }
    
    // MARK: - UI updates
    
    fileprivate func updateMarksLayout(withStatus hidden: Bool) {
        copyrightLabelBottomSpace.priority = hidden ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh
        navigationBarTopSpace.priority = hidden ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        
        tradeMarksSpacerWidth.constant = hidden ? view.frame.width : 8.0
        let duration = hidden ? 0.1 : 0.8
        let animation: (() -> Void) = {
            self.tradeMarkView.layoutIfNeeded()
        }
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.3,
            options: .curveEaseIn,
            animations: animation,
            completion: nil)
    }
}

extension ViewController: TouchDownControlDelegate {
    
    func touchDownControl(control: TouchDownControl, didChangeState state: TouchDownState) {
        switch state {
        case .expanding:
            touchDownImageView.image = UIImage(named: "camera_icon_black")
            updateMarksLayout(withStatus: true)
        case .collapsing:
            touchDownImageView.image = UIImage(named: "camera_icon")
            updateMarksLayout(withStatus: false)
        case .expanded:
            print("Ready to dissmiss")
        default:
            break
        }
    }
    
}

