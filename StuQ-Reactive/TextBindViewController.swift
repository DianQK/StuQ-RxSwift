//
//  TextBindViewController.swift
//  StuQ-Reactive
//
//  Created by DianQK on 8/29/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift

class TextBindViewController: UIViewController {

    @IBOutlet private weak var firstTextField: UITextField!
    @IBOutlet private weak var secondTextField: UITextField!
    @IBOutlet private weak var resultLabel: UILabel!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.combineLatest(
            firstTextField.rx_text.asObservable(),
            secondTextField.rx_text.asObservable(), resultSelector: +
            )
            .subscribeNext { [unowned self] (result) in
                self.resultLabel.text = result
            }
            .addDisposableTo(disposeBag)
    }
    
    
}
