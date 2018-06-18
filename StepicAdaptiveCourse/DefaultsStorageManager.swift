//
//  DefaultsStorageManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 08.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class DefaultsStorageManager {
    static let shared = DefaultsStorageManager()

    private let onboardingFinishedKey = "isOnboardingShown"
    private let onboardingRatingFinishedKey = "isRatingOnboardingShown"
    private let accountEmailKey = "account_email"
    private let accountPasswordKey = "account_password"
    private let lastCourseIdKey = "last_course_id"

    let defaults = UserDefaults.standard

    var isOnboardingFinished: Bool {
        get {
            return defaults.bool(forKey: onboardingFinishedKey)
        }
        set {
            defaults.set(newValue, forKey: onboardingFinishedKey)
        }
    }

    var isRatingOnboardingFinished: Bool {
        get {
            return defaults.bool(forKey: onboardingRatingFinishedKey)
        }
        set {
            defaults.set(newValue, forKey: onboardingRatingFinishedKey)
        }
    }

    var accountEmail: String? {
        get {
            return defaults.string(forKey: accountEmailKey)
        }
        set {
            return defaults.set(newValue, forKey: accountEmailKey)
        }
    }

    var accountPassword: String? {
        get {
            return defaults.string(forKey: accountPasswordKey)
        }
        set {
            return defaults.set(newValue, forKey: accountPasswordKey)
        }
    }

    var lastCourseId: Int? {
        get {
            if let value = defaults.object(forKey: lastCourseIdKey) as? Int {
                return value
            } else {
                return nil
            }
        }
        set {
            if newValue == nil {
                defaults.removeObject(forKey: lastCourseIdKey)
            } else {
                defaults.set(newValue, forKey: lastCourseIdKey)
            }
        }
    }
}
