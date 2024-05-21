//
//  ViewController.swift
//  CombineUIkit
//
//  Created by Sonata Girl on 21.05.2024.
//

import UIKit
import Combine

class ViewController: UIViewController {

    private var dataLabel: UILabel = {
        let label = UILabel()
        label.text = "data"
        label.font = UIFont.systemFont(ofSize: 20, weight: .black)
        label.textColor = .label
        return label
    }()

    private var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "status"
        label.font = UIFont.systemFont(ofSize: 20, weight: .black)
        label.textColor = .label
        return label
    }()

    let buttonCancel = UIButton()
    let buttonRefresh = UIButton()

    var viewModel = FirstCancelPipelineViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonCancel.frame = CGRect(x: 50, y: 100, width: 100, height: 50)
        buttonCancel.setTitle("Cancel", for: .normal)
        buttonCancel.backgroundColor = .green
        buttonCancel.addTarget(self, action: #selector(cancel), for: .touchUpInside)
       
        buttonRefresh.frame = CGRect(x: 50, y: 200, width: 100, height: 50)
        buttonRefresh.setTitle("Refresh", for: .normal)
        buttonRefresh.backgroundColor = .blue
        buttonRefresh.addTarget(self, action: #selector(refresh), for: .touchUpInside)

        dataLabel.frame = CGRect(x: 50, y: 300, width: 300, height: 50)
        statusLabel.frame = CGRect(x: 50, y: 400, width: 300, height: 50)

        view.addSubview(buttonCancel)
        view.addSubview(buttonRefresh)
        view.addSubview(dataLabel)
        view.addSubview(statusLabel)


        let subscribe1 = Subscribers.Assign(object: dataLabel, keyPath: \.text)
        viewModel.$data.subscribe(subscribe1)
       
        let subscribe2 = Subscribers.Assign(object: statusLabel, keyPath: \.text)
        viewModel.$status.subscribe(subscribe2)

    }

    @objc private func cancel() {
        viewModel.cancel()
    }

    @objc private func refresh() {
        viewModel.refresh()
    }
}

final class FirstCancelPipelineViewModel: ObservableObject {
    @Published var data: String? = ""
    @Published var status: String? = ""
    @Published var validation = ""

    private var cancellable: AnyCancellable?

    init() {
        cancellable = $data
            .map { [unowned self] value -> String in
                self.status = "Запрос в банк..."
                return value ?? ""
            }
            .delay(for: 5, scheduler: DispatchQueue.main)
            .sink { [unowned self] value in
                self.data = "Сумма всех счетов 1 млн."
                self.status = "Данные получены."

            }
    }

    func refresh() {
        data = "Перезапрос данных"
    }

    func cancel() {
        status = "Операция отменена"
        cancellable?.cancel()
        cancellable = nil
    }
}
