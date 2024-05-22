//
//  ViewController.swift
//  CombineUIkit
//
//  Created by Sonata Girl on 21.05.2024.
//

import UIKit
import Combine

final class ViewController: UIViewController {

    var viewModel = FirstPipelineViewModel()

    let label = UILabel()
    let textFieldName = UITextField()
    let textFieldSurname = UITextField()

    var anyCancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        label.frame = CGRect(x: 250, y: 100, width: 100, height: 50)
        textFieldName.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
        textFieldName.placeholder = "Ваше Имя"
        textFieldName.addTarget(self, action: #selector(textFieldValueChanged(_ :)), for: .editingChanged)
        textFieldSurname.frame = CGRect(x: 100, y: 200, width: 100, height: 50)
        textFieldSurname.placeholder = "Ваша Фамилия"
        textFieldSurname.addTarget(self, action: #selector(textFieldValueChanged(_ :)), for: .editingChanged)

        view.addSubview(label)
        view.addSubview(textFieldName)
        view.addSubview(textFieldSurname)

        // тут мы связываем свойство валидации во вью модели с
        // нашим вью контроллером
        // в assign говорим чтобы результат возвращался в лейбл.text
        anyCancellable = viewModel.$validationName
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: label)

    }

    @objc private func textFieldValueChanged(_ sender: UITextField) {
        if sender == textFieldName {
            viewModel.name = textFieldName.text ?? ""
        } else {
            viewModel.surname = textFieldSurname.text ?? ""
        }
    }

}

class FirstPipelineViewModel: ObservableObject {
    @Published var name = ""
    @Published var surname = ""
    @Published var validationName: String? = ""

    init() {
        $name
            .map { $0.isEmpty || self.surname.isEmpty ? "❌" : "✅"}
            .assign(to: &$validationName)

        $surname
            .map { $0.isEmpty || self.name.isEmpty ? "❌" : "✅"}
            .assign(to: &$validationName)
    }
}
