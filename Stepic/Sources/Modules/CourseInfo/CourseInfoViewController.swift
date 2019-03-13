import Pageboy
import Presentr
import SVProgressHUD
import UIKit

protocol CourseInfoScrollablePageViewProtocol: class {
    var scrollViewDelegate: UIScrollViewDelegate? { get set }
    var contentInsets: UIEdgeInsets { get set }
    var contentOffset: CGPoint { get set }

    @available(iOS 11.0, *)
    var contentInsetAdjustmentBehavior: UIScrollViewContentInsetAdjustmentBehavior { get set }
}

protocol CourseInfoViewControllerProtocol: class {
    func displayCourse(viewModel: CourseInfo.CourseLoad.ViewModel)
    func displayLesson(viewModel: CourseInfo.LessonPresentation.ViewModel)
    func displayPersonalDeadlinesSettings(viewModel: CourseInfo.PersonalDeadlinesSettingsPresentation.ViewModel)
    func displayExamLesson(viewModel: CourseInfo.ExamLessonPresentation.ViewModel)
    func displayCourseSharing(viewModel: CourseInfo.CourseShareAction.ViewModel)
    func displayLastStep(viewModel: CourseInfo.LastStepPresentation.ViewModel)
    func displayAuthorization(viewModel: CourseInfo.AuthorizationPresentation.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: CourseInfo.BlockingWaitingIndicatorUpdate.ViewModel)
}

final class CourseInfoViewController: UIViewController {
    private static let topBarAlphaStatusBarThreshold = 0.85

    private let availableTabs: [CourseInfo.Tab]
    private let initialTabIndex: Int

    private let interactor: CourseInfoInteractorProtocol

    private lazy var pageViewController: PageboyViewController = {
        let viewController = PageboyViewController()
        viewController.dataSource = self
        viewController.delegate = self
        return viewController
    }()

    lazy var courseInfoView = self.view as? CourseInfoView
    lazy var styledNavigationController = self.navigationController as? StyledNavigationController

    private lazy var moreBarButton = UIBarButtonItem(
        image: UIImage(named: "horizontal-dots-icon")?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: self,
        action: #selector(self.actionButtonClicked)
    )

    private var submodulesControllers: [UIViewController] = []

    private var shouldShowDropCourseAction = false
    private let didJustSubscribe: Bool

    init(
        interactor: CourseInfoInteractorProtocol,
        availableTabs: [CourseInfo.Tab],
        initialTab: CourseInfo.Tab,
        didJustSubscribe: Bool = false
    ) {
        self.interactor = interactor
        self.availableTabs = availableTabs
        self.didJustSubscribe = didJustSubscribe

        if let initialTabIndex = self.availableTabs.firstIndex(of: initialTab) {
            self.initialTabIndex = initialTabIndex
        } else {
            self.initialTabIndex = 0
        }

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addChildViewController(self.pageViewController)
        self.pageViewController.reloadData()

        self.title = NSLocalizedString("CourseInfoTitle", comment: "")

        self.navigationItem.rightBarButtonItem = self.moreBarButton
        self.styledNavigationController?.removeBackButtonTitleForTopController()

        if #available(iOS 11.0, *) { } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        self.interactor.doCourseRefresh(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.interactor.doOnlineModeReset(request: .init())

        if self.didJustSubscribe {
            NotificationPermissionStatus.current.done { status in
                if status == .notDetermined {
                    self.interactor.doRegistrationForRemoteNotifications(request: .init())
                }
            }
        }
    }

    override func loadView() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0

        let appearance = CourseInfoView.Appearance(headerTopOffset: statusBarHeight + navigationBarHeight)

        let view = CourseInfoView(
            frame: UIScreen.main.bounds,
            pageControllerView: self.pageViewController.view,
            scrollDelegate: self,
            tabsTitles: self.availableTabs.map { $0.title },
            appearance: appearance
        )
        view.delegate = self

        self.view = view

        self.submodulesControllers = self.makeSubmodules()
    }

    private func updateTopBar(alpha: CGFloat) {
        self.styledNavigationController?.changeBackgroundColor(
            StyledNavigationController.Appearance.backgroundColor.withAlphaComponent(alpha),
            sender: self
        )

        let transitionColor = ColorTransitionHelper.makeTransitionColor(
            from: .white,
            to: StyledNavigationController.Appearance.tintColor,
            transitionProgress: alpha
        )
        self.styledNavigationController?.changeTintColor(transitionColor, sender: self)
        self.styledNavigationController?.changeTextColor(
            StyledNavigationController.Appearance.tintColor.withAlphaComponent(alpha),
            sender: self
        )

        let statusBarStyle = alpha > CGFloat(CourseInfoViewController.topBarAlphaStatusBarThreshold)
            ? UIStatusBarStyle.default
            : UIStatusBarStyle.lightContent
        self.styledNavigationController?.changeStatusBarStyle(statusBarStyle, sender: self)
    }

    private func makeSubmodules() -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        var submodules: [CourseInfoSubmoduleProtocol?] = []

        for tab in self.availableTabs {
            switch tab {
            case .info:
                let infoAssembly = CourseInfoTabInfoAssembly()
                viewControllers.append(infoAssembly.makeModule())
                submodules.append(infoAssembly.moduleInput)
            case .syllabus:
                let syllabusAssembly = CourseInfoTabSyllabusAssembly(
                    output: self.interactor as? CourseInfoTabSyllabusOutputProtocol
                )
                viewControllers.append(syllabusAssembly.makeModule())
                submodules.append(syllabusAssembly.moduleInput)
            case .reviews:
                let reviewsAssembly = CourseInfoTabReviewsAssembly()
                viewControllers.append(reviewsAssembly.makeModule())
                submodules.append(reviewsAssembly.moduleInput)
            }
        }

        self.interactor.doSubmodulesRegistration(request: .init(submodules: submodules.compactMap { $0 }))

        return viewControllers
    }

    @objc
    private func actionButtonClicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Share", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    self?.interactor.doCourseShareAction(request: .init())
                }
            )
        )

        if self.shouldShowDropCourseAction {
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("DropCourse", comment: ""),
                    style: .destructive,
                    handler: { [weak self] _ in
                        self?.interactor.doCourseUnenrollmentAction(request: .init())
                    }
                )
            )
        }

        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        )
        alert.popoverPresentationController?.barButtonItem = self.moreBarButton
        self.present(module: alert)
    }
}

extension CourseInfoViewController: PageboyViewControllerDataSource, PageboyViewControllerDelegate {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return self.submodulesControllers.count
    }

    func viewController(
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex
    ) -> UIViewController? {
        return self.submodulesControllers[safe: index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .at(index: self.initialTabIndex)
    }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollToPageAt index: PageboyViewController.PageIndex,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) {
        self.courseInfoView?.updateCurrentPageIndex(index)
        self.interactor.doSubmoduleControllerAppearanceUpdate(request: .init(submoduleIndex: index))
    }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        willScrollToPageAt index: PageboyViewController.PageIndex,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) { }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollTo position: CGPoint,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool
    ) { }

    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didReloadWith currentViewController: UIViewController,
        currentPageIndex: PageboyViewController.PageIndex
    ) { }
}

extension CourseInfoViewController: CourseInfoViewControllerProtocol {
    func displayExamLesson(viewModel: CourseInfo.ExamLessonPresentation.ViewModel) {
        let alert = UIAlertController(
            title: NSLocalizedString("ExamTitle", comment: ""),
            message: NSLocalizedString("ShowExamInWeb", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Open", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }
                    WebControllerManager.sharedManager.presentWebControllerWithURLString(
                        "\(viewModel.urlPath)?from_mobile_app=true",
                        inController: strongSelf,
                        withKey: "exam",
                        allowsSafari: true,
                        backButtonStyle: .close
                    )
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: nil
            )
        )
        self.present(module: alert)
    }

    func displayCourseSharing(viewModel: CourseInfo.CourseShareAction.ViewModel) {
        let sharingViewController = SharingHelper.getSharingController(viewModel.urlPath)
        sharingViewController.popoverPresentationController?.barButtonItem = self.moreBarButton
        self.present(module: sharingViewController)
    }

    func displayCourse(viewModel: CourseInfo.CourseLoad.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            self.courseInfoView?.configure(viewModel: data)
            self.shouldShowDropCourseAction = data.isEnrolled
        case .loading:
            break
        }
    }

    func displayLesson(viewModel: CourseInfo.LessonPresentation.ViewModel) {
        let assembly = LessonLegacyAssembly(
            initObjects: viewModel.initObjects,
            initIDs: viewModel.initIDs
        )

        self.push(module: assembly.makeModule())
    }

    func displayPersonalDeadlinesSettings(viewModel: CourseInfo.PersonalDeadlinesSettingsPresentation.ViewModel) {
        if viewModel.action == .create {
            // Show popup
            let presentr: Presentr = {
                let presenter = Presentr(presentationType: .dynamic(center: .center))
                presenter.roundCorners = true
                return presenter
            }()

            let viewController = PersonalDeadlinesModeSelectionLegacyAssembly(
                course: viewModel.course,
                updateCompletion: { [weak self] in
                    self?.interactor.doCourseRefresh(request: .init())
                }
            ).makeModule()
            self.customPresentViewController(
                presentr,
                viewController: viewController,
                animated: true
            )
        } else {
            // Show action sheet
            let viewController = PersonalDeadlineEditDeleteAlertLegacyAssembly(
                course: viewModel.course,
                presentingViewController: self,
                updateCompletion: { [weak self] in
                    self?.interactor.doCourseRefresh(request: .init())
                }
            ).makeModule()
            viewController.popoverPresentationController?.barButtonItem = self.moreBarButton
            self.present(module: viewController)
        }
    }

    func displayBlockingLoadingIndicator(viewModel: CourseInfo.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
        }
    }

    func displayLastStep(viewModel: CourseInfo.LastStepPresentation.ViewModel) {
        guard let navigationController = self.navigationController else {
            return
        }

        LastStepRouter.continueLearning(
            for: viewModel.course,
            isAdaptive: viewModel.isAdaptive,
            using: navigationController,
            skipSyllabus: true
        )
    }

    func displayAuthorization(viewModel: CourseInfo.AuthorizationPresentation.ViewModel) {
        RoutingManager.auth.routeFrom(controller: self, success: nil, cancel: nil)
    }
}

extension CourseInfoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let courseInfoView = self.courseInfoView else {
            return
        }

        let navigationBarHeight = self.navigationController?.navigationBar.bounds.height
        let statusBarHeight = min(
            UIApplication.shared.statusBarFrame.size.width,
            UIApplication.shared.statusBarFrame.size.height
        )
        let topPadding = (navigationBarHeight ?? 0) + statusBarHeight

        let offset = scrollView.contentOffset.y

        let offsetWithHeader = offset
            + courseInfoView.headerHeight
            + courseInfoView.appearance.segmentedControlHeight
        let headerHeight = courseInfoView.headerHeight - topPadding

        let scrollingProgress = max(0, min(1, offsetWithHeader / headerHeight))
        self.updateTopBar(alpha: scrollingProgress)

        // Pin segmented control
        let scrollViewOffset = min(offsetWithHeader, headerHeight)
        courseInfoView.updateScroll(offset: scrollViewOffset)

        // Arrange page views contentOffset
        let offsetWithHiddenHeader = -(topPadding + courseInfoView.appearance.segmentedControlHeight)
        self.arrangePagesScrollOffset(
            topOffsetOfCurrentTab: offset,
            maxTopOffset: offsetWithHiddenHeader
        )
    }

    private func arrangePagesScrollOffset(topOffsetOfCurrentTab: CGFloat, maxTopOffset: CGFloat) {
        for viewController in self.submodulesControllers {
            guard let view = viewController.view as? CourseInfoScrollablePageViewProtocol else {
                return
            }

            var topOffset = view.contentOffset.y

            // Scrolling down
            if topOffset != topOffsetOfCurrentTab && topOffset <= maxTopOffset {
                topOffset = min(topOffsetOfCurrentTab, maxTopOffset)
            }

            // Scrolling up
            if topOffset > maxTopOffset && topOffsetOfCurrentTab <= maxTopOffset {
                topOffset = min(topOffsetOfCurrentTab, maxTopOffset)
            }

            view.contentOffset = CGPoint(
                x: view.contentOffset.x,
                y: topOffset
            )
        }
    }
}

extension CourseInfoViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        return .init(
            shadowViewAlpha: 0.0,
            backgroundColor: StyledNavigationController.Appearance.backgroundColor.withAlphaComponent(0.0),
            textColor: StyledNavigationController.Appearance.tintColor.withAlphaComponent(0.0),
            tintColor: .white,
            statusBarStyle: .lightContent
        )
    }
}

extension CourseInfoViewController: CourseInfoViewDelegate {
    func numberOfPages(in courseInfoView: CourseInfoView) -> Int {
        return self.submodulesControllers.count
    }

    func courseInfoView(_ courseInfoView: CourseInfoView, reportNewHeaderHeight height: CGFloat) {
        // Update contentInset for each page
        for viewController in self.submodulesControllers {
            let view = viewController.view as? CourseInfoScrollablePageViewProtocol

            if let view = view {
                view.contentInsets = UIEdgeInsets(
                    top: height,
                    left: view.contentInsets.left,
                    bottom: view.contentInsets.bottom,
                    right: view.contentInsets.right
                )
                view.scrollViewDelegate = self
            }

            viewController.view.setNeedsLayout()
            viewController.view.layoutIfNeeded()

            if #available(iOS 11.0, *) {
                view?.contentInsetAdjustmentBehavior = .never
            } else {
                viewController.automaticallyAdjustsScrollViewInsets = false
            }
        }
    }

    func courseInfoView(_ courseInfoView: CourseInfoView, requestScrollToPage index: Int) {
        self.pageViewController.scrollToPage(.at(index: index), animated: true)
    }

    func courseInfoViewDidMainAction(_ courseInfoView: CourseInfoView) {
        self.interactor.doMainCourseAction(request: .init())
    }
}