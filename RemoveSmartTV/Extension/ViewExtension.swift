//
//  ViewExtension.swift
//  Dayshee
//
//  Created by haiphan on 11/1/20.
//  Copyright © 2020 ThanhPham. All rights reserved.
//

import UIKit

extension UIView {
    static var nib: UINib? {
        let bundle = Bundle(for: self)
        let name = "\(self)"
        guard bundle.path(forResource: name, ofType: "nib") != nil else {
            return nil
        }
        return UINib(nibName: name, bundle: nil)
    }
    
    
    static var identifier: String {
        return "\(self)"
    }
}

protocol LoadXibProtocol {}
extension LoadXibProtocol where Self: UIView {
    static func loadXib() -> Self {
        let bundle = Bundle(for: self)
        let name = "\(self)"
        guard let view = UINib(nibName: name, bundle: bundle).instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("error xib \(name)")
        }
        return view
    }
}
extension UIView: LoadXibProtocol {}
extension UIView {
    func applyShadowAndRadius(sizeX: CGFloat, sizeY: CGFloat,shadowRadius: CGFloat, shadowColor: UIColor) {
        self.backgroundColor = UIColor.clear
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: sizeX, height: sizeY) //x,
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = shadowRadius //blur
        
        // add the border to subview
        //        let borderView = UIView()
        //        borderView.frame = self.bounds
        //        borderView.layer.cornerRadius = 10
        //
        //        borderView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.16)
        //        borderView.layer.borderWidth = 0.1
        //        borderView.layer.masksToBounds = true
        //        self.addSubview(borderView)
    }
}
extension UIView {

    var safeAreaBottom: CGFloat {
         if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.bottom
            }
         }
         return 0
    }

    var safeAreaTop: CGFloat {
         if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.top
            }
         }
         return 0
    }
}

extension UIApplication {
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }
}
