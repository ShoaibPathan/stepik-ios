import Foundation
import PromiseKit

protocol CourseReviewSummariesNetworkServiceProtocol: class {
    func fetch(
        ids: [CourseReviewSummary.IdType],
        page: Int
    ) -> Promise<([CourseReviewSummary], Meta)>
    func fetch(id: CourseReviewSummary.IdType) -> Promise<CourseReviewSummary?>
}

final class CourseReviewSummariesNetworkService: CourseReviewSummariesNetworkServiceProtocol {
    private let courseReviewSummariesAPI: CourseReviewSummariesAPI

    init(courseReviewSummariesAPI: CourseReviewSummariesAPI) {
        self.courseReviewSummariesAPI = courseReviewSummariesAPI
    }

    func fetch(
        ids: [CourseReviewSummary.IdType],
        page: Int = 1
    ) -> Promise<([CourseReviewSummary], Meta)> {
        // FIXME: We have no pagination here but should support it
        return Promise { seal in
            self.courseReviewSummariesAPI.retrieve(ids: ids).done { summaries in
                let summaries = summaries.reordered(order: ids, transform: { $0.id })
                seal.fulfill((summaries, Meta.oneAndOnlyPage))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: CourseReviewSummary.IdType) -> Promise<CourseReviewSummary?> {
        return Promise { seal in
            self.courseReviewSummariesAPI.retrieve(ids: [id]).done { summaries in
                seal.fulfill(summaries.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
