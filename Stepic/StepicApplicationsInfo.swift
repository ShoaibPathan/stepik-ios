//
//  StepicApplicationsInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

struct StepicApplicationsInfo {

    // Dictionary with auth (encrypted)
    private static let stepikAuthDic = ApplicationInfo(plist: "Auth")
    // Dictionary with configutation
    private static let stepikConfigDic = ApplicationInfo(plist: "Config")

    // Structure
    typealias Root = ApplicationInfo.Path

    // Section: AuthInfo
    typealias AuthInfo = (clientId: String, clientSecret: String, redirectUri: String, credentials: String)

    private static func initAuthInfo(idPath: String, secretPath: String, redirectPath: String) -> AuthInfo {
        let id = StepicApplicationsInfo.stepikAuthDic?.get(for: idPath) as? String ?? ""
        let secret = StepicApplicationsInfo.stepikAuthDic?.get(for: secretPath) as? String ?? ""
        let redirect = StepicApplicationsInfo.stepikAuthDic?.get(for: redirectPath) as? String ?? ""
        let credentials = "\(id):\(secret)".data(using: String.Encoding.utf8)!.base64EncodedString(options: [])
        return (clientId: id, clientSecret: secret, redirectUri: redirect, credentials: credentials)
    }

    static let social: AuthInfo? = !(StepicApplicationsInfo.stepikAuthDic?.has(path: Root.AuthType.social) ?? false) ? nil :
                                    StepicApplicationsInfo.initAuthInfo(idPath: Root.AuthType.Social.id,
                                                                       secretPath: Root.AuthType.Social.secret,
                                                                       redirectPath: Root.AuthType.Social.redirect)
    static let password: AuthInfo? = !(StepicApplicationsInfo.stepikAuthDic?.has(path: Root.AuthType.password) ?? false) ? nil :
                                    StepicApplicationsInfo.initAuthInfo(idPath: Root.AuthType.Password.id,
                                                                       secretPath: Root.AuthType.Password.secret,
                                                                       redirectPath: Root.AuthType.Password.redirect)

    // Section: URL
    static let appId = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.URL.appId) as? String ?? ""
    static let urlScheme = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.URL.scheme) as? String ?? ""
    static let apiURL = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.URL.api) as? String ?? ""
    static let oauthURL = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.URL.oauth) as? String ?? ""
    static let stepicURL = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.URL.stepik) as? String ?? ""
    static let versionInfoURL = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.URL.version) as? String ?? ""
    static let adaptiveRatingURL = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.URL.adaptiveRating) as? String ?? ""

    // Section: Cookie
    static let cookiePrefix = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.Cookie.prefix) as? String ?? ""

    // Section: Feature
    static let doesAllowCourseUnenrollment = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.Feature.courseUnenrollment) as? Bool ?? true
    static let inAppUpdatesAvailable = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.Feature.inAppUpdates) as? Bool ?? false
    static let streaksEnabled = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.Feature.streaks) as? Bool ?? true
    static let shouldRegisterNotifications = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.Feature.notifications) as? Bool ?? true

    // Section: Adaptive
    static let adaptiveSupportedCourses = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.Adaptive.supportedCourses) as? [Int] ?? []
    static let isAdaptive = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.Adaptive.isAdaptive) as? Bool ?? false
    static let adaptiveCoursesInfoURL = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.Adaptive.coursesInfoURL) as? String ?? ""

    // Section: RateApp
    struct RateApp {
        static let correctSubmissionsThreshold = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.RateApp.submissionsThreshold) as? Int ?? 4
        static let appStoreURL = URL(string: StepicApplicationsInfo.stepikConfigDic?.get(for: Root.RateApp.appStoreLink) as? String ?? "")
    }

    // Section: Social
    struct SocialInfo {
        struct AppIds {
            static let vk = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.SocialProviders.vkId) as? String ?? ""
            static let facebook = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.SocialProviders.facebookId) as? String ?? ""
        }
    }

    // Section: Colors
    struct Colors {
        static var mainGreen = UIColor(hex: StepicApplicationsInfo.stepikConfigDic?.get(for: Root.Colors.mainGreen) as? Int ?? 0x66cc66)
        static var mainText = UIColor(hex: StepicApplicationsInfo.stepikConfigDic?.get(for: Root.Colors.mainText) as? Int ?? 0x000000)
        static var mainDark = UIColor(hex: StepicApplicationsInfo.stepikConfigDic?.get(for: Root.Colors.mainDark) as? Int ?? 0x000000)
    }

    // Section: Modules
    struct Modules {
        static let tabs = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.Modules.tabs) as? [String]
    }

    // Section: Versions
    struct Versions {
        static let stories = StepicApplicationsInfo.stepikConfigDic?.get(for: Root.Versions.stories) as? Int
    }
}
