//
//  UIViewController+Util.swift
//  Sift
//
//  Created by Alex Grinman on 12/23/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showWarning(title:String, body:String, then:(()->Void)? = nil) {
        DispatchQueue.main.async {
            
            let alertController:UIAlertController = UIAlertController(title: title, message: body,
                                                                      preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction!) -> Void in
                then?()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showSettings(with title:String, message:String, dnd:String? = nil, then:(()->Void)? = nil) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
            
            then?()
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            then?()
        }
        alertController.addAction(cancelAction)
        
        if let dndKey = dnd {
            alertController.addAction(UIAlertAction(title: "Don't ask again", style: UIAlertActionStyle.destructive) { (action) in
                UserDefaults.standard.set(true, forKey: dndKey)
            })
            
        }
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func askConfirmationIn(title:String, text:String, accept:String, cancel:String, handler: @escaping ((_ confirmed:Bool) -> Void)) {
        
        let alertController:UIAlertController = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        
        
        alertController.addAction(UIAlertAction(title: accept, style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) -> Void in
            
            handler(true)
            
        }))
        
        alertController.addAction(UIAlertAction(title: cancel, style: UIAlertActionStyle.cancel, handler: { (action:UIAlertAction) -> Void in
            
            handler(false)
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
// Based on https://gist.github.com/edc0der/e4bed05b4c6653ffcd36c0609f27c7c6

fileprivate let overlayViewTag = 999
fileprivate let activityIndicatorTag = 1000

extension UIViewController {
    public func displayActivityIndicator(shouldDisplay: Bool) -> Void {
        if shouldDisplay {
            setActivityIndicator()
        } else {
            removeActivityIndicator()
        }
    }

    private func setActivityIndicator() -> Void {
        guard !isDisplayingActivityIndicatorOverlay() else { return }
        guard let parentViewForOverlay = navigationController?.view ?? view else { return }

        //configure overlay
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black
        overlay.alpha = 0.5
        overlay.tag = overlayViewTag

        //configure activity indicator
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tag = activityIndicatorTag

        //add subviews
        overlay.addSubview(activityIndicator)
        parentViewForOverlay.addSubview(overlay)

        //add overlay constraints
        overlay.heightAnchor.constraint(equalTo: parentViewForOverlay.heightAnchor).isActive = true
        overlay.widthAnchor.constraint(equalTo: parentViewForOverlay.widthAnchor).isActive = true

        //add indicator constraints
        activityIndicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor).isActive = true

        //animate indicator
        activityIndicator.startAnimating()
    }

    private func removeActivityIndicator() -> Void {
        let activityIndicator = getActivityIndicator()

        if let overlayView = getOverlayView() {
            UIView.animate(withDuration: 0.2, animations: {
                overlayView.alpha = 0.0
                activityIndicator?.stopAnimating()
            }) { (finished) in
                activityIndicator?.removeFromSuperview()
                overlayView.removeFromSuperview()
            }
        }
    }

    private func isDisplayingActivityIndicatorOverlay() -> Bool {
        if let _ = getActivityIndicator(), let _ = getOverlayView() {
            return true
        }
        return false
    }

    private func getActivityIndicator() -> UIActivityIndicatorView? {
        return (navigationController?.view.viewWithTag(activityIndicatorTag) ?? view.viewWithTag(activityIndicatorTag)) as? UIActivityIndicatorView
    }

    private func getOverlayView() -> UIView? {
        return navigationController?.view.viewWithTag(overlayViewTag) ?? view.viewWithTag(overlayViewTag)
    }
}
