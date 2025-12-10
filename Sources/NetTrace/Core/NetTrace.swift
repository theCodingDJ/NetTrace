//
//  NetTrace.swift
//  NetTrace
//
//  Created by Lyubomir Marinov on 4.12.25.
//

import UIKit

@MainActor
public class NetTrace {
    public static let shared = NetTrace()
    
    private var overlayWindow: OverlayWindow?
    
    private init() {
        URLSession.startSwizzling()
    }
    
    public func start() {
        show()
    }
    
    // Show the logger UI
    public func show() {
        if overlayWindow == nil {
            overlayWindow = OverlayWindow()
        }
        overlayWindow?.show()
    }
    
    // Hide and cleanup
    public func hide() {
        overlayWindow?.hide()
        overlayWindow = nil
    }
}
