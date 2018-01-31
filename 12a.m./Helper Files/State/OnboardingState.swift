//
//  OnboardingState.swift
//  12a.m.
//
//  Created by Nick Reichard on 1/28/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import Foundation

class OnboardingState {
    
    // MARK: - Additional Types
    
    enum PageType {
        case welcome
        case uxInfo
        case selection
        case permissions
    }
    
    enum Page: Int {
        case welcome
        case uxInfo
        case selection
        case permissions
        
        var type: PageType {
            switch self {
            case .welcome: return .welcome
            case .uxInfo: return .uxInfo
            case .selection: return .selection
            case .permissions: return .permissions
            }
        }
        
        static var all: [Page] = [.welcome, .uxInfo, .selection, .permissions]
    }
    
    // MARK: - Internal Properties
    
    var page: Page
    
    // MARK: - Initializers
    
    init(currentPage: Page) {
        self.page = currentPage
    }
    
    // MARK: - Internal methods
    
    func previousPage() -> Page {
        switch page {
        case .welcome: page = .welcome
        case .uxInfo: page = .welcome
        case .selection: page = .uxInfo
        case .permissions: page = .selection
        }
        return page
    }
    
    func nextPage() -> Page {
        switch page {
        case .welcome: page = .uxInfo
        case .uxInfo: page = .selection
        case .selection: page = .permissions
        case .permissions: page = .welcome
        }
        return page
    }
    
}
