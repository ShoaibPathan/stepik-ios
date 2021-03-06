//
//  LessonViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 18.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import SnapKit

@available(*, deprecated, message: "Class to initialize lesson w/o storyboards logic")
final class LessonLegacyAssembly: Assembly {
    private let initObjects: LessonInitObjects?
    private let initIDs: LessonInitIds?

    init(
        initObjects: LessonInitObjects?,
        initIDs: LessonInitIds?
    ) {
        self.initObjects = initObjects
        self.initIDs = initIDs
    }

    func makeModule() -> UIViewController {
        guard let lessonVC = ControllerHelper.instantiateViewController(identifier: "LessonViewController") as? LessonViewController else {
            fatalError()
        }

        lessonVC.hidesBottomBarWhenPushed = true
        lessonVC.initObjects = self.initObjects
        lessonVC.initIds = self.initIDs

        return lessonVC
    }
}

typealias LessonNavigationRules = (prev: Bool, next: Bool)

class LessonViewController: PagerController, ShareableController, LessonView {

    var parentShareBlock: ((UIActivityViewController) -> Void)?

    fileprivate var presenter: LessonPresenter?

    lazy var activityView: UIView = self.initActivityView()

    lazy var warningView: UIView = self.initWarningView()

    fileprivate let warningViewTitle = NSLocalizedString("ConnectionErrorText", comment: "")

    fileprivate func initWarningView() -> UIView {
        let v = WarningView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), delegate: self, text: warningViewTitle, image: Images.noWifiImage.size250x250, width: UIScreen.main.bounds.width - 16, contentMode: DeviceInfo.current.isPad ? UIView.ContentMode.bottom : UIView.ContentMode.scaleAspectFit)
        self.view.insertSubview(v, aboveSubview: self.view)
        v.snp.makeConstraints { make -> Void in
            make.top.equalTo(self.view).offset(50)
            make.leading.bottom.trailing.equalTo(self.view)
        }
        return v
    }

    fileprivate func initActivityView() -> UIView {
        let v = UIView()
        let ai = UIActivityIndicatorView()
        ai.style = UIActivityIndicatorView.Style.whiteLarge
        ai.color = UIColor.mainDark
        v.backgroundColor = UIColor.white
        v.addSubview(ai)
        ai.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(50)
            make.center.equalTo(v)
        }
        ai.startAnimating()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.snp.makeConstraints { make -> Void in
            make.top.equalTo(self.view).offset(50)
            make.leading.bottom.trailing.equalTo(self.view)
        }
        v.isHidden = false
        return v
    }

    var doesPresentActivityIndicatorView: Bool = false {
        didSet {
            if doesPresentActivityIndicatorView {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.activityView.isHidden = false
                }
            } else {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.activityView.isHidden = true
                }
            }
        }
    }

    var doesPresentWarningView: Bool = false {
        didSet {
            if doesPresentWarningView {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.warningView.isHidden = false
                }
            } else {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.warningView.isHidden = true
                }
            }
        }
    }

    func updateTitle(title: String) {
        self.navigationItem.title = title
    }

    var initObjects: LessonInitObjects?
    var initIds: LessonInitIds?

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        initTabs()

        edgesForExtendedLayout = []

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
//        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.backBarButtonItem?.title = " "

        presenter = LessonPresenter(objects: initObjects, ids: initIds, stepsAPI: ApiDataDownloader.steps, lessonsAPI: ApiDataDownloader.lessons)
        presenter?.view = self
        presenter?.refreshSteps()
    }

    fileprivate func initTabs() {
        tabWidth = 44.0
        tabHeight = 44.0
        indicatorHeight = 2.0
        tabOffset = 8.0
        centerCurrentTab = true
        indicatorColor = UIColor.mainDark
        tabsViewBackgroundColor = UIColor.mainLight
    }

    func setRefreshing(refreshing: Bool) {
        if refreshing {
            self.view.isUserInteractionEnabled = false
            self.doesPresentWarningView = false
            self.doesPresentActivityIndicatorView = true
        } else {
            self.view.isUserInteractionEnabled = true
            self.doesPresentActivityIndicatorView = false
            if presenter?.pagesCount == 0 {
                self.doesPresentWarningView = true
            }
        }
    }

    func reload() {
        self.reloadData()
    }

    func selectTab(index: Int, updatePage: Bool) {
        self.selectTabAtIndex(index, swipe: true)
    }

    var nItem: UINavigationItem {
        return self.navigationItem
    }

    var nController: UINavigationController? {
        return self.navigationController
    }

    var pagerGestureRecognizer: UIPanGestureRecognizer? {
        return (self.pageViewController.view.subviews.first as? UIScrollView)?.panGestureRecognizer
    }

    deinit {
        print("deinit LessonViewController")
    }

    func share(popoverSourceItem: UIBarButtonItem?, popoverView: UIView?, fromParent: Bool) {

        guard let url = presenter?.url else {
            return
        }

        let shareBlock: ((UIActivityViewController) -> Void)? = parentShareBlock

        DispatchQueue.global(qos: .background).async {
            [weak self] in
            let shareVC = SharingHelper.getSharingController(url)
            shareVC.popoverPresentationController?.barButtonItem = popoverSourceItem
            shareVC.popoverPresentationController?.sourceView = popoverView
            DispatchQueue.main.async {
                [weak self] in
                if !fromParent {
                    self?.present(shareVC, animated: true, completion: nil)
                } else {
                    shareBlock?(shareVC)
                }
            }
        }
    }

    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        let shareItem = UIPreviewAction(title: NSLocalizedString("Share", comment: ""), style: .default, handler: {
            [weak self]
            _, _ in
            self?.share(popoverSourceItem: nil, popoverView: nil, fromParent: true)
        })
        return [shareItem]
    }
}

extension LessonViewController: PagerDataSource {
    func numberOfTabs(_ pager: PagerController) -> Int {
        guard let presenter = presenter else { return 0 }
        return presenter.pagesCount
    }

    func tabViewForIndex(_ index: Int, pager: PagerController) -> UIView {
        guard let presenter = presenter else { return UIView() }
        return presenter.tabView(index: index)
    }

    func controllerForTabAtIndex(_ index: Int, pager: PagerController) -> UIViewController {
        guard let presenter = presenter else { return UIViewController() }
        return presenter.controller(index: index) ?? UIViewController()
    }
}

extension LessonViewController: WarningViewDelegate {
    func didPressButton() {
        presenter?.refreshSteps()
    }
}

extension LessonViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        return .init(shadowViewAlpha: 0.0)
    }
}
