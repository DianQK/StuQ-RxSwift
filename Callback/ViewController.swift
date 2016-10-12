//
//  ViewController.swift
//  Callback
//
//  Created by DianQK on 11/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UITableViewController {

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        struct Info {
            let title: Variable<String>
            let detail: String
        }

        Observable.just([
            Info(title: Variable("靛青K"), detail: "姓名"),
            Info(title: Variable("iOS"), detail: "职业")
            ])
            .bindTo(tableView.rx.items(cellIdentifier: "Cell")) { index, element, cell in
                element.title.asObservable()
                    .map(Optional.init)
                    .bindTo(cell.textLabel!.rx.text)
                    .addDisposableTo(cell.rx.prepareForReuseBag)
                cell.detailTextLabel?.text = element.detail
            }
            .addDisposableTo(disposeBag)

        tableView.rx
            .modelSelected(Info.self)
//            .flatMap { [unowned self] info -> Observable<String> in
//                let inputViewController = R.storyboard.main.inputViewController()!
//            inputViewController.title = info.detail
//                self.show(inputViewController, sender: nil)
//                return inputViewController.saved
//            }
//            .do(onNext: { [unowned self]  _ in
//                self.navigationController?.popViewController(animated: true)
//            })
//            .subscribe(onNext: { value in
//                print(value)
//            })
//            .addDisposableTo(disposeBag)

            .subscribe(onNext: { [unowned self] info in
                let inputViewController = R.storyboard.main.inputViewController()!
                inputViewController.title = info.detail
                self.show(inputViewController, sender: nil)
                inputViewController.saved
                    .do(onNext: {   _ in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    .bindTo(info.title)
                    .addDisposableTo(inputViewController.disposeBag)
            })
            .addDisposableTo(disposeBag)
    }

}

