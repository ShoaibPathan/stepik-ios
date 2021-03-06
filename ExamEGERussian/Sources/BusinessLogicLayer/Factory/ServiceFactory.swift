//
//  ServiceFactory.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol ServiceFactory: class {
    var authAPI: AuthAPI { get }
    var stepicsAPI: StepicsAPI { get }
    var profilesAPI: ProfilesAPI { get }
    var coursesAPI: CoursesAPI { get }
    var enrollmentsAPI: EnrollmentsAPI { get }
    var lessonsAPI: LessonsAPI { get }
    var progressesAPI: ProgressesAPI { get }
    var recommendationsAPI: RecommendationsAPI { get }
    var unitsAPI: UnitsAPI { get }
    var viewsAPI: ViewsAPI { get }
    var defaultsStorageManager: DefaultsStorageManager { get }

    var userRegistrationService: UserRegistrationService { get }
    var graphService: GraphServiceProtocol { get }
    var lessonsService: LessonsService { get }
    var courseService: CourseService { get }
    var enrollmentService: EnrollmentService { get }
    var stepsService: StepsService { get }
    var progressService: ProgressService { get }
    var recommendationsService: RecommendationsServiceProtocol { get }
    var reactionService: ReactionServiceProtocol { get }
    var viewsService: ViewsServiceProtocol { get }

    var knowledgeGraphProvider: KnowledgeGraphProviderProtocol { get }
}
