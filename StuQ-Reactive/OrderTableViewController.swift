//
//  OrderTableViewController.swift
//  StuQ-Reactive
//
//  Created by DianQK on 8/30/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

let unitPrice = 118
let coupon = 20

class OrderTableViewController: UITableViewController {

    @IBOutlet private weak var minusButton: UIButton!
    @IBOutlet private weak var countTextField: UITextField!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet private weak var subtotalLabel: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enum Count {
            case add
            case subtract
            case custom(Int)
        }
        
        let count = [
            // 减
            minusButton.rx_tap.map { Count.subtract },
            // 加
            plusButton.rx_tap.map { Count.add },
            // 手动调整
            countTextField.rx_text.flatMap { text -> Observable<Int> in
                if let count = Int(text) {
                    return Observable.just(count)
                } else {
                    return Observable.empty()
                }
                }.map(Count.custom)
            ]
            .toObservable()
            .merge()
            .scan(1) { (acc, x) -> Int in
//                print("scan")
                switch x {
                case .add: return acc + 1
                case .subtract: return acc - 1
                case .custom(let count): return count
                }
            }
            .startWith(1)
            .shareReplay(1)

        // 商品数量绑定到 countTextField
        count.map(String.init).bindTo(countTextField.rx_text).addDisposableTo(disposeBag)

        count.map { $0 > 1 }.distinctUntilChanged().bindTo(minusButton.rx_enabled).addDisposableTo(disposeBag)
        count.map { $0 <= 99 }.distinctUntilChanged().bindTo(plusButton.rx_enabled).addDisposableTo(disposeBag)
        
        let price = count
            .map { $0 * unitPrice }
            .shareReplay(1)

        price
            .map(String.init)
            .bindTo(subtotalLabel.rx_text)
            .addDisposableTo(disposeBag)

        price.map { $0 - coupon }
            .debug("coupon")
            .map(String.init)
            .bindTo(totalLabel.rx_text)
            .addDisposableTo(disposeBag)

    }
}
