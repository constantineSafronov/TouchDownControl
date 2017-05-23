//
//  Layout.swift
//  TouchDownAnimation
//
//  Created by Konstantin Safronov on 2/4/17.
//  Copyright © 2017 Konstantin Safronov. All rights reserved.
//

import UIKit

struct RoundedViewDecorator {
    
    func decorate(views: [UIView]) {
        views.forEach { view in
            view.layer.cornerRadius = view.frame.height / 2
            view.clipsToBounds = true
        }
    }
    
}
