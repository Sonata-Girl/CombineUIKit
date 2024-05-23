//
//  ViewController.swift
//  CombineUIkit
//
//  Created by Sonata Girl on 21.05.2024.
//

import UIKit
import Combine

class ViewController: UIViewController {

    private var stringTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16, weight: .black)
        textField.textColor = .label
        textField.placeholder = "Введите строку"
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        return textField
    }()

    let addButton = UIButton()
    let clearButton = UIButton()
    let tableView = UITableView()

    var viewModel = EmptyFailurePublishersViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        stringTextField.frame = CGRect(x: 20, y: 100, width: 250, height: 50)

        addButton.frame = CGRect(x: 50, y: 200, width: 150, height: 50)
        addButton.setTitle("Добавить", for: .normal)
        addButton.addTarget(self, action: #selector(addText), for: .touchUpInside)
        addButton.setTitleColor(.blue, for: .normal)

        clearButton.frame = CGRect(x: 200, y: 200, width: 100, height: 50)
        clearButton.setTitle("Очистить список", for: .normal)
        clearButton.addTarget(self, action: #selector(clearList), for: .touchUpInside)
        clearButton.setTitleColor(.blue, for: .normal)

        tableView.frame = CGRect(x: 50, y: 300, width: 300, height: 300)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.layer.borderColor = UIColor.gray.cgColor
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 20

        view.addSubview(stringTextField)
        view.addSubview(addButton)
        view.addSubview(clearButton)
        view.addSubview(tableView)

        bind()
    }

    @objc private func addText() {
        viewModel.selectionForAddWord.value = stringTextField.text ?? ""
        bind()
    }

    @objc private func clearList() {
        viewModel.clearList()
    }

    private func bind() {
        viewModel.$dataToView
            .sink(receiveValue: tableView.items { tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = item
                return cell
            })
            .store(in: &viewModel.cancellable)
    }
}

extension UITableView {
    func items<Element>(_ builder: @escaping (UITableView, IndexPath, Element) -> UITableViewCell) -> ([Element]) -> Void {
        let dataSource = CombineTableViewDataSource(builder: builder)
        return { items in
            dataSource.pushElements(items, to: self)
        }
    }
}

class CombineTableViewDataSource<Element>: NSObject, UITableViewDataSource {

    let build: (UITableView, IndexPath, Element) -> UITableViewCell
    var elements: [Element] = []

    init(builder: @escaping (UITableView, IndexPath, Element) -> UITableViewCell) {
        self.build = builder
        super.init()
    }

    func pushElements(_ elements: [Element], to tableView: UITableView) {
        tableView.dataSource = self
        self.elements = elements
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        build(tableView, indexPath, elements[indexPath.row])
    }
}

final class EmptyFailurePublishersViewModel: ObservableObject {
    @Published var dataToView: [String] = []
    @Published var isButtonVisible = false
    var selectionForAddWord = CurrentValueSubject<String, Never>("")
    var inputText = CurrentValueSubject<String, Never>("")

    var datas: [String?] = []
    var cancellable: Set<AnyCancellable> = []

    init() {
        inputText
            .map { newValue -> Bool in
                newValue.isEmpty ? false : true
            }
            .sink { [unowned self] value in
                self.isButtonVisible = value
            }
            .store(in: &cancellable)
        selectionForAddWord
            .filter {
                !$0.isEmpty
            }
            .sink { [unowned self] newValue in
                datas.append(newValue)
                dataToView.removeAll()
                fetch()
                inputText.value = ""
            }
            .store(in: &cancellable)
    }

    func fetch() {
        _ = datas.publisher
            .flatMap { item -> AnyPublisher<String, Never> in
                if let item = item {
                    return Just(item)
                        .eraseToAnyPublisher()
                } else {
                    return Empty(completeImmediately: true)
                        .eraseToAnyPublisher()
                }
            }
            .sink { [unowned self] item in
                dataToView.append(item)
            }
    }

    func clearList() {
        datas.removeAll()
        dataToView.removeAll()
        objectWillChange.send()
    }
}
