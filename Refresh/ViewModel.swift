//
//  ViewModel.swift
//  Refresh
//
//  Created by 宋宋 on 8/30/16.
//  Copyright © 2016 T. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import SwiftyJSON
import Alamofire

struct ViewModel {
    let isRefreshing = Variable(false)
    let items = Variable<[Meizi]>([])
    
    let disposeBag = DisposeBag()
    
    init(refreshTrigger: Observable<Void>) {
        
        let request = refreshTrigger
            .map { "http://gank.io/api/data/%E7%A6%8F%E5%88%A9/10/1" }    .doOnNext { _ in }
            .flatMap { rx_request(.GET, $0) }         .doOnNext { _ in }
//            .share()
//            .shareReplay(1)
        
        
        
//        response.subscribe().addDisposableTo(disposeBag)
        
//        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
//        dispatch_after(delay, dispatch_get_main_queue()) {
//            response
//                .bindTo(self.items)
//                .addDisposableTo(self.disposeBag)
//            [request.map { _ in true }, response.map { _ in false }]
//                .toObservable()
//                .merge()
//                .bindTo(self.isRefreshing)
//                .addDisposableTo(self.disposeBag)
//        }
        
        response
            .bindTo(items)
            .addDisposableTo(disposeBag)

        
        [request.map { _ in true }, response.map { _ in false }]
            .toObservable()
            .merge()
            .bindTo(isRefreshing)
            .addDisposableTo(disposeBag)
    }
}

public func rx_request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil) -> Observable<JSON> {
    
    return Observable<JSON>.create { (observer) -> Disposable in
        print("request")
        let task = request(method, URLString).responseData { (response) in
            print("response")
            switch response.result {
            case .Success(let value):
                let json = JSON(data: value)
                observer.onNext(json)
                observer.onCompleted()
            case .Failure(let error):
                observer.onError(error)
            }
        }
        
        return AnonymousDisposable(task.cancel)
    }
    
}

