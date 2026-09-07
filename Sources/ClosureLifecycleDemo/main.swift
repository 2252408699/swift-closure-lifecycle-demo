import Foundation

private func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else {
        fputs("FAIL: \(message)\n", stderr)
        exit(1)
    }
    print("PASS: \(message)")
}

private func transformNames(
    _ names: [String],
    using transform: (String) -> String
) -> [String] {
    names.map(transform)
}

private final class AvatarPipeline {
    typealias Completion = (Result<String, Error>) -> Void

    private var completions: [UUID: Completion] = [:]

    var pendingCount: Int { completions.count }

    func requestAvatar(completion: @escaping Completion) -> UUID {
        let id = UUID()
        completions[id] = completion
        return id
    }

    func finish(_ id: UUID, fileName: String) {
        let completion = completions.removeValue(forKey: id)
        completion?(.success(fileName))
    }

    func cancel(_ id: UUID) {
        completions.removeValue(forKey: id)
    }
}

private final class ProfileViewModel {
    let pipeline: AvatarPipeline
    var avatarFileName: String?
    var onDeinit: () -> Void

    init(pipeline: AvatarPipeline, onDeinit: @escaping () -> Void) {
        self.pipeline = pipeline
        self.onDeinit = onDeinit
    }

    func loadWithStrongCapture() -> UUID {
        pipeline.requestAvatar { result in
            if case let .success(fileName) = result {
                self.avatarFileName = fileName
            }
        }
    }

    func loadWithWeakCapture() -> UUID {
        pipeline.requestAvatar { [weak self] result in
            if case let .success(fileName) = result {
                self?.avatarFileName = fileName
            }
        }
    }

    deinit {
        onDeinit()
    }
}

let normalized = transformNames(["  Ana ", " BO "]) {
    $0.trimmingCharacters(in: .whitespaces).lowercased()
}
check(normalized == ["ana", "bo"], "non-escaping transformation finishes before return")

do {
    let pipeline = AvatarPipeline()
    var didDeinitialize = false
    weak var weakViewModel: ProfileViewModel?
    var requestID: UUID?

    do {
        let viewModel = ProfileViewModel(pipeline: pipeline) {
            didDeinitialize = true
        }
        weakViewModel = viewModel
        requestID = viewModel.loadWithStrongCapture()
        check(pipeline.pendingCount == 1, "escaping completion is stored for later")
    }

    check(weakViewModel != nil, "strong capture keeps the view model alive")
    check(!didDeinitialize, "deinit has not run while the cycle exists")

    pipeline.cancel(requestID!)
    check(weakViewModel == nil, "removing the stored closure breaks the cycle")
    check(didDeinitialize, "deinit runs after the strong closure is removed")
}

do {
    let pipeline = AvatarPipeline()
    var didDeinitialize = false
    weak var weakViewModel: ProfileViewModel?

    do {
        let viewModel = ProfileViewModel(pipeline: pipeline) {
            didDeinitialize = true
        }
        weakViewModel = viewModel
        _ = viewModel.loadWithWeakCapture()
    }

    check(weakViewModel == nil, "weak capture allows immediate deallocation")
    check(didDeinitialize, "weak-capture view model reaches deinit")
}

print("All closure lifecycle checks passed.")
