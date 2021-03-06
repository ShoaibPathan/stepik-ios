//
//  LessonsAssembly.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 30/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class LessonsAssembly: BaseAssembly, LessonsAssemblyProtocol {
    func module(navigationController: UINavigationController, topicId: String) -> UIViewController {
        let controller = LessonsTableViewController()
        let router = LessonsRouter(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )

        let knowledgeGraph = serviceFactory.knowledgeGraphProvider.knowledgeGraph
        let presenter = LessonsPresenter(
            view: controller,
            router: router,
            topicId: topicId,
            knowledgeGraph: knowledgeGraph,
            lessonsService: serviceFactory.lessonsService,
            courseService: serviceFactory.courseService
        )
        controller.presenter = presenter
        controller.hidesBottomBarWhenPushed = true
        controller.title = NSLocalizedString("LessonsViewControllerTitle", comment: "")

        return controller
    }
}
