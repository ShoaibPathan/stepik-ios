//
//  InAppTestViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 29/01/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import UIKit
import StoreKit
import SnapKit

final class InAppTestViewController: UIViewController {
    private static var courseID = 51351
    private lazy var coursesNetworkService = CoursesNetworkService(coursesAPI: CoursesAPI())

    private static var storeProductIdentifiers = [
        "com.AlexKarpov.Stepic.CourseTier1"
    ]

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.requestStoreProducts()
    }

    override func loadView() {
        self.view = InAppTestView(frame: UIScreen.main.bounds)
    }

    // MARK: - StoreKit usage

    private func requestStoreProducts() {
        let request = SKProductsRequest(
            productIdentifiers: Set<String>(InAppTestViewController.storeProductIdentifiers)
        )
        request.delegate = self
        request.start()
    }
}

extension InAppTestViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.products.count, response.invalidProductIdentifiers)
        for product in response.products {
            print(product)
        }
    }
}

final class InAppTestView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        self.backgroundColor = .white
    }
}
