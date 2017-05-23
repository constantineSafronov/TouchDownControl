//
//  UIView+ATLAppearance.swift
//  Achievity
//
//  Created by Konstantin Safronov on 2/10/16.
//  Copyright © 2016 Konstantin Safronov. All rights reserved.
//

import UIKit

private typealias SubviewTreeModifier = ((Void) -> UIView)

struct AppearanceOptions: OptionSet {
  let rawValue: Int
  static let Overlay  = AppearanceOptions(rawValue: 1 << 0)
  static let UseAutoresize = AppearanceOptions(rawValue: 1 << 1)
}

extension UIView {
  
  private func addSubviewUsingOptions(
    options: AppearanceOptions,
    modifier: SubviewTreeModifier
    ) {
    let subview: UIView = modifier()
    if options.union(.Overlay) == .Overlay {
      if options.union(.UseAutoresize) != .UseAutoresize {
        subview.translatesAutoresizingMaskIntoConstraints = false
        let views = dictionaryOfNames(views: [subview])
        let horisontalConstraints = NSLayoutConstraint.constraints(
          withVisualFormat: "|[subview]|",
          options: [],
          metrics: nil,
          views: views
        )
        addConstraints(horisontalConstraints)
        let verticalConstraints = NSLayoutConstraint.constraints(
          withVisualFormat: "V:|[subview]|",
          options: [],
          metrics: nil,
          views: views
        )
        addConstraints(verticalConstraints)
      } else {
        frame = bounds
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      }
    }
  }
  
  private func dictionaryOfNames(views: [UIView]) -> Dictionary <String, UIView> {
    var container = Dictionary <String, UIView> ()
    for (_, value) in views.enumerated() {
      container["subview"] = value
    }
    return container
  }
  
  // MARK: Interface methods
  
  internal func addSubview(subview: UIView, options: AppearanceOptions) {
    if subview.superview == self {
      return
    }
    addSubviewUsingOptions(options: options) { [weak self] in
      self?.addSubview(subview)
      return subview
    }
  }
  
  internal func insertSubview(subview: UIView, index: NSInteger, options: AppearanceOptions) {
    if subview.superview == self {
      return
    }
    addSubviewUsingOptions(options: options) { [weak self] in
      self?.insertSubview(subview, at: index)
      return subview
    }
  }
  
}
