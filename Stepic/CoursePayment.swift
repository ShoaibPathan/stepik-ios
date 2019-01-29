//
//  CoursePayment.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 29/01/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

final class CoursePayment {
    typealias Data = [String: Any]

    final class DataFactory {
        static func generateDataForAppleProvider(
            receiptData: String,
            bundleID: String,
            amount: Float,
            currency: String
        ) -> Data {
            return [
                "receipt_data": receiptData,
                "bundle_id": bundleID,
                "amount": amount,
                "currency": currency
            ]
        }
    }

    enum PaymentProvider {
        case google
        case apple
        case unknown

        init(value: String?) {
            guard let name = value else {
                self = .unknown
                return
            }

            switch name {
            case "apple":
                self = .apple
            case "google":
                self = .google
            default:
                self = .unknown
            }
        }

        var value: String {
            switch self {
            case .apple:
                return "apple"
            case .google:
                return "google"
            case .unknown:
                fatalError("Unknown provider")
            }
        }
    }

    typealias IdType = Int

    var id: IdType?
    var userID: User.IdType?
    var courseID: Course.IdType?
    var isPaid: Bool?
    var paymentProvider: PaymentProvider
    var data: Data?

    init(paymentProvider: PaymentProvider, data: Data) {
        self.paymentProvider = paymentProvider
        self.data = data
    }

    required init(json: JSON) {
        self.id = json["id"].intValue
        self.userID = json["user"].intValue
        self.courseID = json["course"].intValue
        self.isPaid = json["is_paid"].boolValue
        self.paymentProvider = PaymentProvider(value: json["payment_provider"].string)
        self.data = json["data"].dictionaryObject
    }

    var json: JSON {
        var dict: JSON = ["payment_provider": self.paymentProvider.value]
        if let data = self.data {
            dict["data"] = JSON(data)
        }
        return dict
    }
}
