//
//  UIViewExtension.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-02.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            self.clipsToBounds = true
        }
    }
    
    @IBInspectable var isRounded: Bool {
        get {
            return self.isRounded
        }
        set {
            self.isRounded = newValue
            self.cornerRadius = newValue ? self.frame.height / 2 : self.cornerRadius
        }
    }
}
