//
//  StepPresenterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 01/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class StepPresenterImpl: StepPresenter {
    private weak var view: StepView?
    weak var delegate: StepPresenterDelegate?
    private let router: StepRouterProtocol

    private(set) var step: StepPlainObject
    private let lesson: LessonPlainObject
    private let quizViewControllerBuilder: QuizViewControllerBuilder
    private var quizViewController: QuizViewController?

    private let stepsService: StepsService

    var isInputEmpty: Bool {
        return quizViewController?.getReply() == nil
    }

    init(view: StepView,
         step: StepPlainObject,
         lesson: LessonPlainObject,
         router: StepRouterProtocol,
         quizViewControllerBuilder: QuizViewControllerBuilder,
         delegate: StepPresenterDelegate?,
         stepsService: StepsService
    ) {
        self.view = view
        self.step = step
        self.lesson = lesson
        self.quizViewControllerBuilder = quizViewControllerBuilder
        self.router = router
        self.delegate = delegate
        self.stepsService = stepsService
    }

    func refreshStep() {
        view?.update(with: step.text)
        updateQuiz()
    }

    func submit() {
        var isSelected = false

        switch step.type {
        case .choice:
            (quizViewController as? ChoiceQuizViewController)?.choices.forEach {
                isSelected = isSelected || $0
            }
        case .string, .number:
            isSelected = true
        default:
            break
        }

        if isSelected {
            quizViewController?.submitPressed()
        }
    }

    func retry() {
        quizViewController?.submitPressed()
    }

    // MARK: - Private API

    private func showError(
        title: String = NSLocalizedString("Error", comment: ""),
        message: String = NSLocalizedString("ErrorMessage", comment: "")
    ) {
        view?.displayError(title: title, message: message)
    }
}

// MARK: - StepPresenterImpl (QuizViewController API) -

extension StepPresenterImpl {
    private func updateQuiz() {
        if step.type == .text {
            quizViewController = nil
        } else {
            showQuizViewController()
        }
    }

    private func showQuizViewController() {
        quizViewController = quizViewControllerBuilder.build()
        guard let quizViewController = quizViewController else {
            return showUnknownQuizTypeContent()
        }

        setupQuizViewController(quizViewController)
        view?.updateQuiz(with: quizViewController)
        quizViewController.isSubmitButtonHidden = quizViewControllerBuilder.isSubmitButtonHidden
    }

    private func setupQuizViewController(_ quizViewController: QuizViewController) {
        guard let step = Step.getStepWithId(self.step.id) else {
            showError(message: NSLocalizedString("ErrorMessage", comment: ""))
            return print("\(#file): Unable to instantiate QuizViewController")
        }

        quizViewController.step = step
        quizViewController.delegate = self
    }

    private func showUnknownQuizTypeContent() {
        let controller = UnknownTypeQuizViewController()
        let stepUrl = "\(StepicApplicationsInfo.stepicURL)/lesson/\(lesson.slug)/step/\(step.id)?from_mobile_app=true"
        controller.stepUrl = stepUrl

        view?.updateQuiz(with: controller)
    }
}

// MARK: - StepPresenterImpl: QuizControllerDelegate -

extension StepPresenterImpl: QuizControllerDelegate {
    func submissionDidCorrect() {
        step.state = .successful
        delegate?.stepPresenterSubmissionDidCorrect(self)
    }

    func submissionDidWrong() {
        step.state = .wrong
        delegate?.stepPresenterSubmissionDidWrong(self)
    }

    func submissionDidRetry() {
        step.state = .unsolved
        delegate?.stepPresenterSubmissionDidRetry(self)
    }
}

// MARK: - StepPresenterImpl: Logoutable -

extension StepPresenterImpl: Logoutable {
    func logout(completion: (() -> Void)?) {
        checkToken().done { _ in
            completion?()
        }.catch { [weak self] error in
            self?.showError(message: error.localizedDescription)
        }
    }
}
