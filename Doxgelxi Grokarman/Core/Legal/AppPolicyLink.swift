//
//  AppPolicyLink.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import Foundation

enum AppPolicyLink: String, CaseIterable {
    case privacy
    case terms

    /// Replace with your live URLs before release.
    var urlString: String {
        switch self {
        case .privacy:
            return "https://doxgelxigrokarman.com/privacy-policy.html"
        case .terms:
            return "https://doxgelxigrokarman.com/support.html"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }

    var title: String {
        switch self {
        case .privacy: return "Privacy Policy"
        case .terms: return "Terms of Use"
        }
    }

    var subtitle: String {
        switch self {
        case .privacy: return "How we handle your data"
        case .terms: return "Terms and conditions"
        }
    }

    var systemImage: String {
        switch self {
        case .privacy: return "lock.shield.fill"
        case .terms: return "doc.text.fill"
        }
    }
}
