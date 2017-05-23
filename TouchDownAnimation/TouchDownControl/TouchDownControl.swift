//
//  TouchDownControl.swift
//  TouchDownAnimation
//
//  Created by Konstantin Safronov on 2/2/17.
//  Copyright © 2017 Konstantin Safronov. All rights reserved.
//

import Foundation
import UIKit

@objc enum TouchDownState: Int {
    case defaultState, collapsed, collapsing, expanding, expanded
}

@objc protocol TouchDownControlDelegate {
    
    @objc func touchDownControl(control: TouchDownControl, didChangeState state: TouchDownState)
}

final class TouchDownControl: UIControl {
    
    private var transitionToken = ""
    private(set) var currentState: TouchDownState = .defaultState {
        didSet {
            delegate?.touchDownControl(control: self, didChangeState: currentState)
        }
    }
    
    var delegate: TouchDownControlDelegate?
    
    @IBOutlet private var ibDelegate: AnyObject? {
        get { return delegate }
        set { delegate = newValue as? TouchDownControlDelegate }
    }
    
    @IBOutlet private var backgroundView: UIView! {
        didSet {
            backgroundView.addSubview(subview: supplementaryBackground, options: .Overlay)
            backgroundView.sendSubview(toBack: supplementaryBackground)
            backgroundView.backgroundColor = bgStartColor
            supplementaryBackground.layer.opacity = 0.0
            supplementaryBackground.backgroundColor = bgFinishColor
        }
    }
    
    @IBOutlet private var touchDownView: UIView! {
        didSet {
            let longPressRecognizer = UILongPressGestureRecognizer(
                target: self,
                action: #selector(longPressRecognizerHandler(recognizer:))
            )
            longPressRecognizer.minimumPressDuration = 0.0
            touchDownView.addGestureRecognizer(longPressRecognizer)
        }
    }
    
    @IBOutlet private var vinylView: UIView! {
        didSet {
            vinylView.layer.opacity = 0.0
            vinylView.backgroundColor = vinylStartColor
        }
    }
    
    @IBOutlet private var loaderView: UIView!
    
    private var supplementaryBackground = UIView()
    // Use short names to make constants legible in IB
    @IBInspectable var bgStartColor: UIColor = UIColor.black
    @IBInspectable var bgFinishColor: UIColor = UIColor.white
    @IBInspectable var vinylStartColor: UIColor = UIColor.black
    @IBInspectable var vinylFinishColor: UIColor = UIColor.white
    
    @objc private func longPressRecognizerHandler(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            expand()
        case .ended:
            collapse()
        default:
            break
        }
    }
    
    private func expand() {
        currentState = .expanding
        let token = NSUUID().uuidString
        transitionToken = token
        animateExpansion {
            if self.transitionToken == token {
                self.currentState = .expanded
            }
        }
    }
    
    private func collapse() {
        currentState = .collapsing
        let token = NSUUID().uuidString
        transitionToken = token
        animateCollapse {
            if self.transitionToken == token {
                self.currentState = .collapsed
            }
        }
    }
    
    private func animateExpansion(_ completion: @escaping (Void) -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        expandTouchDownView()
        expandLoaderView()
        expandVinylView()
        expandBackground()
        
        CATransaction.commit()
    }
    
    private func animateCollapse(_ completion: @escaping (Void) -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        collapseTouchDownView()
        collapseLoaderView()
        collapseVinylView()
        collapseBackground()
        
        CATransaction.commit()
    }
    
    private let scaleAnimationKey = "transform.scale"
    private let rotationAnimationKey = "transform.rotation"
    private let opacityAnimationKey = "opacity"
    private let backgroundColorAnimationKey = "backgroundColor"
    
    private let expandAnimationKey = "expandAnimation"
    private let collapseAnimationKey = "collapseAnimation"
    
    private func expandTouchDownView() {
        let scaleAnimation = Animationfactory.animation(for: scaleAnimationKey, toValue: 1.7, duration: 0.07)
        touchDownView.layer.add(scaleAnimation, forKey: expandAnimationKey)
    }
    
    private func expandLoaderView() {
        let degree: Double = 240 * Double.pi / 180.0
        let rotationAnimation = Animationfactory.animation(
            for: rotationAnimationKey,
            toValue: degree,
            timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        )
        let scaleAnimation = Animationfactory.animation(for: scaleAnimationKey, toValue: 3.0)
        let opacityAnimation = Animationfactory.animation(for: opacityAnimationKey, toValue: 0.0)
        let group = Animationfactory.animationGroup(with: 0.2)
        group.animations = [rotationAnimation, scaleAnimation, opacityAnimation]
        loaderView.layer.add(group, forKey: expandAnimationKey)
    }
    
    private func expandVinylView() {
        let scaleAnimation = Animationfactory.springAnimation(
            for: scaleAnimationKey,
            toValue: 1.7,
            timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut),
            damping: 10.0,
            velocity: 35.0
        )
        let opacityAnimation = Animationfactory.springAnimation(for: opacityAnimationKey, toValue: 1.0)
        let colorAnimation = Animationfactory.springAnimation(for: backgroundColorAnimationKey, toValue: vinylFinishColor.cgColor)
        let group = Animationfactory.animationGroup(with: 0.7)
        group.animations = [scaleAnimation, opacityAnimation, colorAnimation]
        vinylView.layer.add(group, forKey: expandAnimationKey)
    }
    
    private func expandBackground() {
        let colorAnimation = Animationfactory.animation(for: backgroundColorAnimationKey, toValue: UIColor.clear.cgColor, duration: 0.5)
        backgroundView.layer.add(colorAnimation, forKey: expandAnimationKey)
        let opacityAnimation = Animationfactory.animation(for: opacityAnimationKey, toValue: 0.3, duration: 0.2, autoreverses: true)
        supplementaryBackground.layer.add(opacityAnimation, forKey: expandAnimationKey)
    }
    
    private func collapseTouchDownView() {
        let scaleAnimation = Animationfactory.springAnimation(for: scaleAnimationKey, toValue: 1.0, duration: 0.5, damping: 12.5, velocity: 10.0)
        touchDownView.layer.add(scaleAnimation, forKey: collapseAnimationKey)
    }
    
    private func collapseLoaderView() {
        let rotationAnimation = Animationfactory.animation(for: rotationAnimationKey, toValue: 0.0)
        loaderView.layer.add(rotationAnimation, forKey: "collapseRotationAnimation")
        let scaleAnimation = Animationfactory.springAnimation(for: scaleAnimationKey, toValue: 1.0, damping: 10.5, velocity: 3.0)
        let opacityAnimation = Animationfactory.springAnimation(for: opacityAnimationKey, toValue: 1.0)
        let group = Animationfactory.animationGroup(with: 1.0)
        group.animations = [scaleAnimation, opacityAnimation]
        loaderView.layer.add(group, forKey: collapseAnimationKey)
    }
    
    private func collapseVinylView() {
        let scaleAnimation = Animationfactory.animation(for: scaleAnimationKey, toValue: 1.0)
        let opacityAnimation = Animationfactory.animation(
            for: opacityAnimationKey,
            toValue: 0.0,
            timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        )
        let colorAnimation = Animationfactory.animation(for: backgroundColorAnimationKey, toValue: vinylStartColor.cgColor)
        
        let group = Animationfactory.animationGroup(with: 0.3)
        group.animations = [scaleAnimation, opacityAnimation, colorAnimation]
        vinylView.layer.add(group, forKey: collapseAnimationKey)
    }
    
    private func collapseBackground() {
        let colorAnimation = Animationfactory.animation(for: backgroundColorAnimationKey, toValue: bgStartColor.cgColor, duration: 0.2)
        backgroundView.layer.add(colorAnimation, forKey: collapseAnimationKey)
        
        let opacityAnimation = Animationfactory.animation(for: opacityAnimationKey, toValue: 0.3, duration: 0.1, autoreverses: true)
        supplementaryBackground.layer.add(opacityAnimation, forKey: collapseAnimationKey)
    }
    
}

class Animationfactory {
    
    static func springAnimation(for keyPath: String,
                                toValue: Any,
                                duration: CFTimeInterval? = nil,
                                autoreverses: Bool? = nil,
                                timingFunction: CAMediaTimingFunction? = nil,
                                damping: CGFloat? = nil,
                                velocity: CGFloat? = nil) -> CASpringAnimation {
        
        let animation = CASpringAnimation(keyPath: keyPath)
        if let duration = duration {
            animation.duration = duration
        }
        animation.toValue = toValue
        animation.autoreverses = autoreverses ?? false
        animation.timingFunction = timingFunction
        if let damping = damping, let velocity = velocity {
            animation.damping = damping
            animation.initialVelocity = velocity
        }
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    static func animation(for keyPath: String,
                          toValue: Any,
                          duration: CFTimeInterval? = nil,
                          autoreverses: Bool? = nil,
                          timingFunction: CAMediaTimingFunction? = nil) -> CAAnimation {
        
        let animation = CABasicAnimation(keyPath: keyPath)
        if let duration = duration {
            animation.duration = duration
        }
        animation.toValue = toValue
        animation.autoreverses = autoreverses ?? false
        animation.timingFunction = timingFunction
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    static func animationGroup(with duration: CFTimeInterval) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.duration = duration
        group.fillMode = kCAFillModeForwards
        group.isRemovedOnCompletion = false
        return group
    }
    
}
