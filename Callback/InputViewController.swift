//
//  InputViewController.swift
//  Callback
//
//  Created by DianQK on 11/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InputViewController: UIViewController {
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var saveBarButtonItem: UIBarButtonItem!

    let disposeBag = DisposeBag()

    let saved = PublishSubject<String>()

    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.from([saveBarButtonItem.rx.tap.asObservable(),
                         textField.rx.controlEvent(UIControlEvents.editingDidEnd).asObservable()
                         ])
            .merge()
            .withLatestFrom(textField.rx.text)
            .bindTo(saved)
            .addDisposableTo(disposeBag)

    }
}
