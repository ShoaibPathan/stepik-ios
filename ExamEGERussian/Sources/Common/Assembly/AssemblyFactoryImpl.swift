//
//  AssemblyFactoryImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AssemblyFactoryImpl: AssemblyFactory {
    var applicationAssembly: ApplicationAssembly {
        return ApplicationAssemblyImpl(assemblyFactory: self, serviceFactory: serviceFactory)
    }

    var authAssembly: AuthAssembly {
        return AuthAssemblyImpl(assemblyFactory: self, serviceFactory: serviceFactory)
    }

    var learningAssembly: LearningAssemblyProtocol {
        return LearningAssembly(assemblyFactory: self, serviceFactory: serviceFactory)
    }

    var trainingAssembly: TrainingAssemblyProtocol {
        return TrainingAssembly(assemblyFactory: self, serviceFactory: serviceFactory)
    }

    var lessonsAssembly: LessonsAssemblyProtocol {
        return LessonsAssembly(assemblyFactory: self, serviceFactory: serviceFactory)
    }

    var stepsAssembly: StepsAssemblyProtocol {
        return StepsAssembly(assemblyFactory: self, serviceFactory: serviceFactory)
    }

    private let serviceFactory: ServiceFactory

    init(serviceFactory: ServiceFactory) {
        self.serviceFactory = serviceFactory
    }
}
