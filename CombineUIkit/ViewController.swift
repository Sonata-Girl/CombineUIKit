//
//  ViewController.swift
//  CombineUIkit
//
//  Created by Sonata Girl on 21.05.2024.
//

import UIKit
import Combine

final class ViewController: UIViewController {

    let resultLabel = UILabel()
    let fetchButton = UIButton()

    var viewModel = FuturePublisherViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        resultLabel.frame = CGRect(x: 150, y: 200, width: 70, height: 50)
        resultLabel.textColor = .green

        fetchButton.frame = CGRect(x: 150, y: 380, width: 70, height: 50)
        fetchButton.setTitle("Fetch", for: .normal)
        fetchButton.addTarget(self, action: #selector(fetchAction), for: .touchUpInside)
        fetchButton.setTitleColor(.blue, for: .normal)

        view.addSubview(resultLabel)
        view.addSubview(fetchButton)

        bind()
    }

    private func bind() {
        viewModel.$firstResult.subscribe(Subscribers.Assign(object: resultLabel, keyPath: \.text))
    }

    @objc func fetchAction() {
        viewModel.fetch()
    }
}

final class FuturePublisherViewModel: ObservableObject {
    @Published var firstResult: String? = ""
    var cancellable: AnyCancellable?

    let futurePublisher = Deferred {
        Future<String, Never> { promise in
            promise(.success("FuturePublisher сработал"))
            print("FuturePublisher сработал")
        }
    }

    init() {

    }

    func createFetch(url: URL) -> AnyPublisher<String?, Error> {
        Future { promise in
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                promise(.success(response?.url?.absoluteString ?? ""))
            }
            task.resume()
        }
        .eraseToAnyPublisher()
    }

    func fetch() {
        guard let url = URL(string: "https://google.com") else { return }
        cancellable = createFetch(url: url)
            .receive(on: RunLoop.main)
            .sink { completion in
                print(completion)
            } receiveValue: { [unowned self] value in
                firstResult = value ?? ""
            }
    }
}
