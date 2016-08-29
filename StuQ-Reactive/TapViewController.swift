//
//  TapViewController.swift
//  StuQ-Reactive
//
//  Created by DianQK on 8/28/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TapViewController: UIViewController {

    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var rxButton: UIButton!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var rxLabel: UILabel!
    
    @IBOutlet weak var reset: UIButton!
    @IBOutlet weak var rxReset: UIButton!

    private var tapCount: Int = 0
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        button.addTarget(self, action: #selector(TapViewController.buttonTap), forControlEvents: .TouchUpInside)
        
        rxButton
            .rx_tap
            .map { return 1 }
            .scan(0, accumulator: +)
            .subscribeNext { (count) in
                print(count)
                self.rxLabel.text = "\(count)"
            }
            .addDisposableTo(disposeBag)
    }

    dynamic func buttonTap() {
        addCount()
    }
    
    private func addCount() {
        tapCount += 1
        print("Tap: \(tapCount).")
        self.label.text = "\(tapCount)"
    }

}

