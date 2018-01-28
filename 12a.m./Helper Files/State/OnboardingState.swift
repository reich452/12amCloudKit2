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
        case selection
        case permissions
    }
    
    enum Page: Int {
        case welcome
        case genre1
        case permissions
        
        var type: PageType {
            switch self {
            case .welcome: return .welcome
            case .genre1: return .selection
            case .permissions: return .permissions
            }
        }
        
        static var all: [Page] = [.welcome, .genre1, .permissions]
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
        case .genre1: page = .welcome
        case .permissions: page = .genre1
        }
        return page
    }
    
    func nextPage() -> Page {
        switch page {
        case .welcome: page = .genre1
        case .genre1: page = .permissions
        case .permissions: page = .permissions
        }
        return page
    }
    
}
