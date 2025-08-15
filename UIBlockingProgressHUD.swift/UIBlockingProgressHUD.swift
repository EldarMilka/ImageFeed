//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 18.06.2025.
//

import UIKit
import ProgressHUD


final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.show("Loading…")
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
