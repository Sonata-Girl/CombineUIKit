//
//  FailPublisherVIew.swift
//  CombineUIkit
//
//  Created by Sonata Girl on 23.05.2024.
//

import UIKit
import Combine

//final class ViewController: UIViewController {
//
//    private var ageTextField: UITextField = {
//        let textField = UITextField()
//        textField.font = UIFont.systemFont(ofSize: 16, weight: .black)
//        textField.textColor = .label
//        textField.placeholder = "Введите цифру"
//        textField.layer.borderWidth = 1
//        textField.layer.borderColor = UIColor.black.cgColor
//        return textField
//    }()
//
//    let ageLabel = UILabel()
//    let saveButton = UIButton()
//
//    var viewModel = FailPublisher2ViewModel()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        ageLabel.frame = CGRect(x: 150, y: 200, width: 70, height: 50)
//        ageLabel.textColor = .green
//
//        ageTextField.frame = CGRect(x: 20, y: 300, width: 300, height: 50)
//        ageTextField.layer.borderWidth = 1
//        ageTextField.layer.borderColor = UIColor.gray.cgColor
//        ageTextField.keyboardType = .numberPad
//
//        saveButton.frame = CGRect(x: 150, y: 380, width: 70, height: 50)
//        saveButton.setTitle("Save", for: .normal)
//        saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
//        saveButton.setTitleColor(.blue, for: .normal)
//
//        view.addSubview(ageLabel)
//        view.addSubview(ageTextField)
//        view.addSubview(saveButton)
//
//        bind()
//    }
//
//    private func bind() {
//        /// подписываемся и связывааем age и labelAge
//        let subscribe = Subscribers.Assign(object: ageLabel, keyPath: \.text)
//        viewModel.$age.subscribe(subscribe)
//
//        /// Ловим из textPublisher text
//        ageTextField.textPublisher
//            .sink { [unowned self] text in
//                viewModel.text = text
//            }
//            .store(in: &viewModel.subscriptions)
//
//        ///Ловим из error и показываем алерт
//        viewModel.$error
//            .sink { [unowned self] error in
//                let alert = UIAlertController(title: "Ошибка",
//                                              message: error?.rawValue,
//                                              preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Ok",
//                                              style: .default))
//                present(alert, animated: true, completion: nil)
//            }
//            .store(in: &viewModel.subscriptions)
//    }
//
//    @objc func saveAction() {
//        viewModel.save()
//    }
//}
//
//extension UITextField {
//    /// создаем паблишер для textField
//    var textPublisher: AnyPublisher<String, Never> {
//        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
//            .compactMap { ($0.object as? UITextField)?.text }
//            .eraseToAnyPublisher()
//    }
//}
//
//
//enum InvalidAgeError: String, Error, Identifiable {
//    var id: String { rawValue }
//    case lessZero = "Значение не может быть меньше нуля"
//    case moreHundred = "Значение не может быть больше 100"
//}
//
//final class FailPublisher2ViewModel: ObservableObject {
//    @Published var text = ""
//    @Published var age: String? = ""
//    @Published var error: InvalidAgeError?
//
//    var subscriptions = Set<AnyCancellable>()
//
//    init() {
//
//    }
//
//    func save() {
//        // подчеркивание это значит что мы не хотим использовать какую любо подписку
//        _ = validationPublisher(age: Int(text) ?? -1)
//            .sink { completion in
//                switch completion {
//                    case .failure(let error):
//                        self.error = error
//                    case .finished:
//                        break
//                }
//            } receiveValue: { [unowned self] value in
//                self.age = String(value)
//            }
//    }
//
//    func validationPublisher(age: Int) -> AnyPublisher<Int, InvalidAgeError> {
//        if age < 0 {
//            return Fail(error: InvalidAgeError.lessZero)
//                .eraseToAnyPublisher()
//        } else if age > 100 {
//            return Fail(error: InvalidAgeError.moreHundred)
//                .eraseToAnyPublisher()
//        }
//
//        return Just(age)
//        // из Never в Just делает определенный тип ошибки
//            .setFailureType(to: InvalidAgeError.self)
//            .eraseToAnyPublisher()
//    }
//}
//
