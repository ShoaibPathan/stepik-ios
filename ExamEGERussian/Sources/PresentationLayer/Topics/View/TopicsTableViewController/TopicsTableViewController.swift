//
//  TopicsTableViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TopicsTableViewController: UITableViewController {

    // MARK: Instance Properties

    var presenter: TopicsPresenter!

    private var topics = [TopicsViewData]() {
        didSet {
            tableView.reloadData()
            topicsRefreshControl.endRefreshing()
        }
    }

    private lazy var topicsRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

        return refreshControl
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.addTarget(self, action: #selector(onSegmentedControlValueChanged(_:)), for: .valueChanged)

        return segmentedControl
    }()

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        presenter.refresh()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TopicTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.descriptionTitleLabel.text = topics[indexPath.row].title

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.selectTopic(with: topics[indexPath.row])
    }

    // MARK: - Private API

    private func setupView() {
        tableView.registerNib(for: TopicTableViewCell.self)
        title = NSLocalizedString("Topics", comment: "")

        if #available(iOS 10.0, *) {
            tableView.refreshControl = topicsRefreshControl
        } else {
            tableView.addSubview(topicsRefreshControl)
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Logout", comment: ""),
            style: .plain,
            target: self,
            action: #selector(onLogoutClick(_:))
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("SignIn", comment: ""),
            style: .plain,
            target: self,
            action: #selector(onSignInClick(_:))
        )

        navigationItem.titleView = segmentedControl
    }
}

// MARK: - TopicsTableViewController (Actions) -

extension TopicsTableViewController {
    @objc
    private func refreshData(_ sender: Any) {
        presenter.refresh()
    }

    @objc
    private func onLogoutClick(_ sender: Any) {
        presenter.logout()
    }

    @objc
    private func onSignInClick(_ sender: Any) {
        presenter.signIn()
    }

    @objc
    private func onSegmentedControlValueChanged(_ sender: Any) {
        presenter.selectSegment(at: segmentedControl.selectedSegmentIndex)
    }
}

// MARK: - TopicsTableViewController: TopicsView -

extension TopicsTableViewController: TopicsView {
    func setTopics(_ topics: [TopicsViewData]) {
        self.topics = topics
    }

    func setSegments(_ segments: [String]) {
        segmentedControl.removeAllSegments()
        segments.enumerated().forEach {
            segmentedControl.insertSegment(withTitle: $0.element, at: $0.offset, animated: false)
        }

        segmentedControl.sizeToFit()
    }

    func selectSegment(at index: Int) {
        segmentedControl.selectedSegmentIndex = index
    }

    func displayError(title: String, message: String) {
        presentAlert(withTitle: title, message: message)
    }
}
