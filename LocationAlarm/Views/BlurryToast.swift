//
//  BlurryToast.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 9/1/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit

class BlurryToast: UIView {
    
    var fadeInDuration = 0.3
    var messageDuration = 0.6
    var fadeOutDuration = 0.3
    var message = "Hello! :)"
    
    fileprivate func getBlurrySubView() -> UIView {
        var subView: UIView!
        if UIAccessibility.isReduceTransparencyEnabled == false {
            //view.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .extraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            subView = blurEffectView
        }
        else {
            //view.backgroundColor = UIColor.lightGray
            subView = UIView()
            subView.backgroundColor = UIColor.lightGray
        }
        //always fill the view
        subView.frame = self.bounds
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subView.alpha = 0.0
        return subView
    }
    
    fileprivate func getToastLabel() -> UILabel {
        let label = UILabel(frame: self.bounds)
        label.text = message
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.alpha = 0.0
        return label
    }
    
    func showThenHide(completion: @escaping () -> ()) {
        
        let blurView = getBlurrySubView()
        let label = getToastLabel()
        
        self.addSubview(blurView)
        self.addSubview(label)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeInDuration + messageDuration + 0.2) {
            label.fade(to: 0.0, with: self.fadeOutDuration)
            blurView.fade(to: 0.0, with: self.fadeOutDuration)
            DispatchQueue.main.asyncAfter(deadline: .now() + self.fadeOutDuration + 0.2) {
                self.removeFromSuperview()
                completion()
            }
        }
        
        blurView.fade(to: 0.7, with: fadeInDuration)
        label.fade(to: 1.0, with: fadeInDuration)
        
    }

}

extension UIView {
    func fade(to alphaValue: CGFloat, with duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alphaValue
        })
    }
}
