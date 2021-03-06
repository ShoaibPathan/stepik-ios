import SnapKit
import UIKit

extension CourseWidgetView {
    struct Appearance {
        let coverViewWidthHeight: CGFloat = 80.0

        let secondaryActionButtonInsets = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 10)
        let secondaryActionButtonSize = CGSize(width: 80, height: 48)

        let mainActionButtonHeight: CGFloat = 48.0

        let statsViewHeight: CGFloat = 17
        let statsViewInsets = UIEdgeInsets(top: 8, left: 9, bottom: 12, right: 0)
    }
}

final class CourseWidgetView: UIView {
    let appearance: Appearance
    let colorMode: CourseListColorMode

    private lazy var coverView = CourseWidgetCoverView()

    private lazy var primaryActionButton: CourseWidgetButton = {
        let button = CourseWidgetButton(
            appearance: self.colorMode.courseWidgetButtonAppearance
        )
        button.addTarget(self, action: #selector(self.primaryActionButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var secondaryActionButton: CourseWidgetButton = {
        let button = CourseWidgetButton(
            appearance: self.colorMode.courseWidgetButtonAppearance
        )
        button.addTarget(self, action: #selector(self.secondaryActionButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel = CourseWidgetLabel(
        appearance: self.colorMode.courseWidgetLabelAppearance
    )
    private lazy var statsView = CourseWidgetStatsView(
        appearance: self.colorMode.courseWidgetStatsViewAppearance
    )

    var onPrimaryButtonClick: (() -> Void)?
    var onSecondaryButtonClick: (() -> Void)?

    init(
        frame: CGRect = .zero,
        colorMode: CourseListColorMode = .default,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.colorMode = colorMode
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: CourseWidgetViewModel) {
        self.titleLabel.text = viewModel.title
        self.coverView.coverImageURL = viewModel.coverImageURL
        self.coverView.shouldShowAdaptiveMark = viewModel.isAdaptive

        self.primaryActionButton.setTitle(
            viewModel.primaryButtonDescription.title,
            for: .normal
        )
        self.primaryActionButton.isCallToAction = viewModel
            .primaryButtonDescription
            .isCallToAction

        self.secondaryActionButton.setTitle(
            viewModel.secondaryButtonDescription.title,
            for: .normal
        )
        self.secondaryActionButton.isCallToAction = viewModel
            .secondaryButtonDescription
            .isCallToAction

        self.statsView.learnersLabelText = viewModel.learnersLabelText
        self.statsView.ratingLabelText = viewModel.ratingLabelText
        self.statsView.progress = viewModel.progress
    }

    func updateProgress(viewModel: CourseWidgetProgressViewModel) {
        self.statsView.progress = viewModel
    }

    // MARK: Button selectors

    @objc
    private func primaryActionButtonClicked() {
        self.onPrimaryButtonClick?()
    }

    @objc
    private func secondaryActionButtonClicked() {
        self.onSecondaryButtonClick?()
    }
}

extension CourseWidgetView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.coverView)
        self.addSubview(self.primaryActionButton)
        self.addSubview(self.secondaryActionButton)
        self.addSubview(self.titleLabel)
        self.addSubview(self.statsView)
    }

    func makeConstraints() {
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.coverView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.height.width.equalTo(self.appearance.coverViewWidthHeight)
        }

        self.primaryActionButton.translatesAutoresizingMaskIntoConstraints = false
        self.primaryActionButton.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.mainActionButtonHeight)
        }

        self.secondaryActionButton.translatesAutoresizingMaskIntoConstraints = false
        self.secondaryActionButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.secondaryActionButtonSize)
            make.leading.bottom.equalToSuperview()
            make.top
                .equalTo(self.coverView.snp.bottom)
                .offset(self.appearance.secondaryActionButtonInsets.top)
            make.trailing
                .equalTo(self.primaryActionButton.snp.leading)
                .offset(-self.appearance.secondaryActionButtonInsets.right)
        }

        self.statsView.translatesAutoresizingMaskIntoConstraints = false
        self.statsView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom
                .lessThanOrEqualTo(self.primaryActionButton.snp.top)
                .offset(-self.appearance.statsViewInsets.bottom)
            make.leading
                .equalTo(self.coverView.snp.trailing)
                .offset(self.appearance.statsViewInsets.left)
            make.height.equalTo(self.appearance.statsViewHeight)
            make.top
                .equalTo(self.titleLabel.snp.bottom)
                .offset(self.appearance.statsViewInsets.top)
                .priority(.low)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalTo(self.statsView.snp.leading)
        }
    }
}
