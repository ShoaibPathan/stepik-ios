//
//  LessonTableViewCell.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class LessonTableViewCell: UITableViewCell, Reusable, NibLoadable {

    @IBOutlet var numberLabel: UILabel!

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var subtitleLabel: UILabel!

}
