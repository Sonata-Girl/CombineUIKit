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
    let inputNumberField = UITextField()

    var viewModel = FuturePublisherTask8ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        inputNumberField.frame = CGRect(x: 20, y: 400, width: 350, height: 30)
        inputNumberField.layer.borderColor = UIColor.gray.cgColor
        inputNumberField.layer.borderWidth = 1
        inputNumberField.layer.cornerRadius = 10
        inputNumberField.addTarget(self, action: #selector(textFieldValueChanged(_ :)), for: .editingChanged)

        resultLabel.frame = CGRect(x: 80, y: 520, width: 250, height: 30)
        resultLabel.textColor = .green

        fetchButton.frame = CGRect(x: 80, y: 450, width: 250, height: 50)
        fetchButton.setTitle("Проверить простоту числа", for: .normal)
        fetchButton.addTarget(self, action: #selector(fetchAction), for: .touchUpInside)
        fetchButton.setTitleColor(.blue, for: .normal)

        view.addSubview(inputNumberField)
        view.addSubview(resultLabel)
        view.addSubview(fetchButton)

        bind()
    }

    @objc private func textFieldValueChanged(_ sender: UITextField) {
        viewModel.inputText.value = inputNumberField.text ?? ""
    }

    private func bind() {
        viewModel.$result.subscribe(Subscribers.Assign(object: resultLabel, keyPath: \.text))
    }

    @objc func fetchAction() {
        viewModel.checkNumber()
    }
}

final class FuturePublisherTask8ViewModel: ObservableObject {
    @Published var firstResult: String? = ""
    @Published var result: String? = ""
    var cancellable: AnyCancellable?
    var inputText = CurrentValueSubject<String?, Never>("")

    func checkNumber() {
        cancellable = Future<String, Never> { promise in
            for number in 2...500 {
                if let intNumber = Int(self.inputText.value ?? ""), intNumber != Int(number),
                   intNumber % Int(number) == 0 {
                    print(number)
                    promise(.success("\(self.inputText.value ?? "") - Это не простое число."))
                }
            }
            promise(.success("\(self.inputText.value ?? "") - Это простое число."))
        }
        .sink { [unowned self] value in
           self.result = String(value)
        }
    }
}


//final class FuturePublisherViewModel: ObservableObject {
//    @Published var firstResult: String? = ""
//    var cancellable: AnyCancellable?
//
//    let futurePublisher = Deferred {
//        Future<String, Never> { promise in
//            promise(.success("FuturePublisher сработал"))
//            print("FuturePublisher сработал")
//        }
//    }
//
//    init() {
//
//    }
//
//    func createFetch(url: URL) -> AnyPublisher<String?, Error> {
//        Future { promise in
//            let task = URLSession.shared.dataTask(with: url) { data, response, error in
//                if let error = error {
//                    promise(.failure(error))
//                    return
//                }
//                promise(.success(response?.url?.absoluteString ?? ""))
//            }
//            task.resume()
//        }
//        .eraseToAnyPublisher()
//    }
//
//    func fetch() {
//        guard let url = URL(string: "https://google.com") else { return }
//        cancellable = createFetch(url: url)
//            .receive(on: RunLoop.main)
//            .sink { completion in
//                print(completion)
//            } receiveValue: { [unowned self] value in
//                firstResult = value ?? ""
//            }
//    }
//}
