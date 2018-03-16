//
//  UIViewController+Extensions.swift
//  PersonalyDemo
//
//  Created by Sergei Kvasov on 5/30/17.
//  Copyright © 2017 Personaly. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public static func topMostViewController() -> UIViewController? {
        
        guard let keyWindow = UIApplication.shared.keyWindow else { return nil }
        
        if var topViewController = keyWindow.rootViewController {
            
            while let presentedViewController = topViewController.presentedViewController {
                
                topViewController = presentedViewController
            }
            
            return topViewController
        }
        
        return nil
    }
}
