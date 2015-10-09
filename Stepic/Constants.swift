//
//  Constants.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

class Constants: NSObject {
    static var sharedConstants = Constants()
    private override init() {}
    
    let stepicURLString = "https://stepic.org/"
    
    private let client_id = "1r15RgyxPvb91KSSDGwDZlFWzEXlegD9uz52MN4O"
    private let client_secret = "plKrsCERhQJG9j83LvX2kGZOGj1F4GIzvgazrz1W0Ji8nQxvndrbiIpmx1tMuD1ciiN32Rp3fb4ce5JFpfL3Zq0S3LqDAnHjaDB6wLTtnwB25VlngSO58cDBLVqk7dGA"
    
    let placeholderImage = UIImage(named: "stepic_logo_black_and_white")!
    
    let joinCourseButtonText = "Join the course"
    let alreadyJoinedCourseButtonText = "Studying"
}
