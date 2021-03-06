import SnapKit
import UIKit

final class CourseInfoTabSyllabusTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let separatorHeight: CGFloat = 0.5
        static let separatorColor = UIColor(hex: 0xe7e7e7)
    }

    private lazy var cellView = CourseInfoTabSyllabusCellView()
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.separatorColor
        return view
    }()

    var onDownloadButtonClick: (() -> Void)? {
        get {
            return self.cellView.onDownloadButtonClick
        }
        set {
            self.cellView.onDownloadButtonClick = newValue
        }
    }

    override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()

        if self.cellView.superview == nil {
            self.setupSubview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // Configure with nil to reset title and preserve correct dynamical cell height
        self.cellView.configure(viewModel: nil)

        self.cellView.hideLoading()
    }

    func configure(viewModel: CourseInfoTabSyllabusUnitViewModel) {
        self.cellView.configure(viewModel: viewModel)
    }

    func updateDownloadState(newState: CourseInfoTabSyllabus.DownloadState) {
        self.cellView.updateDownloadState(newState: newState)
    }

    func showLoading() {
        self.cellView.showLoading()
    }

    func hideLoading() {
        self.cellView.hideLoading()
    }

    private func setupSubview() {
        self.contentView.addSubview(self.cellView)
        self.contentView.addSubview(self.separatorView)

        self.clipsToBounds = true
        self.contentView.clipsToBounds = true

        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        self.cellView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.height.equalTo(Appearance.separatorHeight)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
            make.top.equalTo(self.cellView.snp.bottom)
        }
    }
}
