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
    override func loadView() {
        self.view = InAppTestView(frame: UIScreen.main.bounds)
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
