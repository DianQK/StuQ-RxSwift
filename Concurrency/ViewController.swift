//
//  ViewController.swift
//  Concurrency
//
//  Created by DianQK on 8/17/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON

let convertToRequest: (Int) -> NSURLRequest = {
    return NSURLRequest(URL: NSURL(string: "https://httpbin.org/get?foo=\($0)")!)
}

let prase: (NSData) -> JSON = {
    return JSON(data: $0)
}

class ViewController: UIViewController {

    @IBOutlet private weak var concurrencyButton: UIButton!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        concurrencyButton
            .rx_tap
            .flatMap {
            [1, 2, 3, 4, 5, 6, 7]
                .toObservable()
                .map(convertToRequest)
                .map(NSURLSession.sharedSession().rx_data)
                .concat()
                .map(prase)
                .map { $0["args"]["foo"].stringValue }
                .toArray()
                .reduce(Array<String>(), accumulator: +)
        }
            .subscribeNext {
            print($0)
        }
            .addDisposableTo(disposeBag)

        //        concurrencyButton
        //            .rx_tap
        //            .flatMap { [1, 2, 3, 4, 5, 6, 7].toObservable() }
        //            .map(convertToRequest)
        //            .map(NSURLSession.sharedSession().rx_data)
        //            .concat()
        //            .map(prase)
        //            .map { $0["args"]["foo"].stringValue }
        //            .toArray()
        //            .reduce(Array<String>(), accumulator: +)
        //            .subscribeNext {
        //                print($0)
        //            }
        //            .addDisposableTo(disposeBag)
    }

}
