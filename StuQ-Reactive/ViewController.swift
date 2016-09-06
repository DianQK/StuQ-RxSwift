//
//  ViewController.swift
//  StuQ-Reactive
//
//  Created by DianQK on 8/28/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!

    var retrySubject = PublishSubject<Void>()
    var disposeBag: DisposeBag! = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil) -> Observable<JSON> {
            return Observable.create { (observer) -> Disposable in
                let task = Alamofire
                    .request(method, URLString, parameters: parameters)
                    .responseData { (response) in
                        switch response.result {
                        case let .Success(data):
                            let json = JSON(data: data)
                            print("Next JSON: \(json)")
                            observer.onNext(json)
                            observer.onCompleted()
                        case let .Failure(error):
                            print("Next Error: \(error)")
                            observer.onError(error)
                        }
                }

                return AnonymousDisposable {
                    print("task cancel")
                    task.cancel()
                }
            }
        }
        
        request(.GET, "https://httpbin.org/get", parameters: ["foo": "bar"])
//            .takeUntil(rx_deallocated)
            .subscribeNext { (json) in
                print("subscribe json: \(json)")
            }
            .addDisposableTo(disposeBag)
        
        let requestBar1 = request(.GET, "https://httpbin.org/get", parameters: ["foo":"bar1"])
        let requestBar2 = request(.GET, "https://httpbin.org/get", parameters: ["foo":"bar2"])
        
        Observable
            .combineLatest(requestBar1, requestBar2) {
                $0["args"]["foo"].stringValue + $1["args"]["foo"].stringValue
            }
            .subscribeNext { (bar) in
                print("----------------")
                print(bar)
                print("----------------")
            }
            .addDisposableTo(disposeBag)
        
        
        // 异步变化的正确用法
        requestBar1
            .flatMap {
                request(.GET, "https://httpbin.org/get", parameters: ["foo2": $0["args"]["foo"].stringValue])
            }
            .flatMap {
                request(.GET, "https://httpbin.org/get", parameters: ["foo3": $0["args"]["foo2"].stringValue])
            }
            .flatMap {
                request(.GET, "https://httpbin.org/get", parameters: ["foo4": $0["args"]["foo3"].stringValue])
            }
            .subscribeNext { (json) in
                print(json["args"])
            }
            .addDisposableTo(disposeBag)
        
        // 异步变换的错误用法
        
        request(.GET, "https://httpbin.org/get", parameters: ["foo": "bar"]).subscribeNext { (json) in
            
            request(.GET, "https://httpbin.org/get", parameters: ["foo2": json["args"]["foo"].stringValue])
                .subscribeNext { (json) in
                    print(json)
            }.addDisposableTo(self.disposeBag)
            
        }.addDisposableTo(self.disposeBag)
    }
    
}
