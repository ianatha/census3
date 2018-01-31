//
//  TransitionSegue.swift
//  i3
//
//  Created by Ian Atha on 9/9/15.
//  Copyright (c) 2018 Mamabear, Inc. All rights reserved.
//

import Cocoa

class TransitionSegue: NSStoryboardSegue {
    class MyTransitionAnimator: NSObject, NSViewControllerPresentationAnimator {
        func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
            let bottomVC = fromViewController
            let topVC = viewController
            
            topVC.view.wantsLayer = true
            topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
            topVC.view.alphaValue = 0
            bottomVC.view.addSubview(topVC.view)
            topVC.view.frame = bottomVC.view.frame
            
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                context.duration = 2
                topVC.view.animator().alphaValue = 1
            }, completionHandler: nil)
        }
        
        func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
            let topVC = viewController
            
            topVC.view.wantsLayer = true
            topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                context.duration = 2
                topVC.view.animator().alphaValue = 0
                }, completionHandler: {
                    topVC.view.removeFromSuperview()
            })
        }
    }

    override func perform() {
        super.perform()
    }
}
