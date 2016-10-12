//
//  RefreshTableViewController.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 05/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions
import SwiftyJSON
import SafariServices
import MBProgressHUD

class CommitTableViewCell: UITableViewCell {
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!

    var message: String? {
        get {
            return messageLabel.text
        }
        set(message) {
            messageLabel.text = message
        }
    }

    var author: String? {
        get {
            return authorLabel.text
        }
        set(author) {
            authorLabel.text = author
        }
    }
}

struct Commit {
    let author: String
    let message: String
    let url: URL
}

let praseJSON: (_ json: JSON) -> [Commit] = { json -> [Commit] in
    json.arrayValue.map { json in
        let message = json["commit"]["message"].stringValue
        let author = json["commit"]["author"]["name"].stringValue
        let url = URL(string: json["html_url"].stringValue)!
        let commit = Commit(author: author, message: message, url: url)
        return commit
    }
}

func isLoading(for view: UIView) -> AnyObserver<Bool> {
    return UIBindingObserver(UIElement: view, binding: { (hud, isLoading) in
        switch isLoading {
        case true:
            MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        case false:
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            break
        }

    }).asObserver()
}

typealias CommitSectionModel = SectionModel<String, Commit>

class RefreshTableViewController: UITableViewController {

    @IBOutlet private weak var typeSegmentedControl: UISegmentedControl!

    private let dataSource = RxTableViewSectionedReloadDataSource<CommitSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()

        do { // MARK: Self-Sizing
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 60
        }

        do { // MARK: Cell 样式
            dataSource.configureCell = { dataSource, tableView, indexPath, element in
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.commitTableViewCell, for: indexPath)!
                cell.message = element.message
                cell.author = element.author
                return cell
            }
        }

        do { // MARK: 点击 Cell
            tableView.rx.modelSelected(Commit.self)
                .map { $0.url }
                .subscribe(onNext: { [unowned self] url in
                    let safari = SFSafariViewController(url: url)
                    safari.preferredControlTintColor = UIColor.black
                    self.showDetailViewController(safari, sender: nil)
                })
                .addDisposableTo(rx.disposeBag)

            tableView.rx.itemSelected
                .map { (at: $0, animated: true) }
                .subscribe(onNext: deselectRow)
                .addDisposableTo(rx.disposeBag)
        }

//        do { // MARK: 刷新逻辑
//            let refreshControl = UIRefreshControl()
//            self.refreshControl = refreshControl
//            let refresh = refreshControl.rx.controlEvent(.valueChanged)
//                .startWith(())
//                .shareReplay(1)
//
//            let response = refresh
//                .flatMap { request("https://api.github.com/repos/ReactiveX/RxSwift/commits", parameters: ["per_page": 10]) }
//                .map(praseJSON)
//                .map { [CommitSectionModel(model: "", items: $0)] }
//                .shareReplay(1)
//
//            response
//                .bindTo(tableView.rx.items(dataSource: dataSource))
//                .addDisposableTo(rx.disposeBag)
//
//            Observable.from([refresh.skip(1).map { true }, response.skip(1).map { _ in false }])
//                .merge()
//                .bindTo(refreshControl.rx.refreshing)
//                .addDisposableTo(rx.disposeBag)
//
//            Observable.from([refresh.take(1).map { true }, response.take(1).map { _ in false }])
//                .merge()
//                .bindTo(isLoading(for: tableView))
//                .addDisposableTo(rx.disposeBag)
//        }

//        do { // MARK: 刷新逻辑 & Result
//            let refreshControl = UIRefreshControl()
//            self.refreshControl = refreshControl
//            let refresh = refreshControl.rx.controlEvent(.valueChanged)
//                .startWith(())
//                .shareReplay(1)
//
//            let response = refresh
//                .flatMap { request("https://api.github.com/repos/ReactiveX/RxSwift/commits", parameters: ["per_page": 10]) }
//                .map { $0.map(transform: praseJSON) }
//                .map { $0.map { [CommitSectionModel(model: "", items: $0)] } }
//                .shareReplay(1)
//
//            response
//                .flatMap { $0.unwarp() }
//                .bindTo(tableView.rx.items(dataSource: dataSource))
//                .addDisposableTo(rx.disposeBag)
//
//            response
//                .flatMap { $0.error }
//                .subscribe(onNext: { error in
//                    print(error)
//                })
//                .addDisposableTo(rx.disposeBag)
//
//            Observable.from([refresh.skip(1).map { true }, response.skip(1).map { _ in false }])
//                .merge()
//                .bindTo(refreshControl.rx.refreshing)
//                .addDisposableTo(rx.disposeBag)
//
//            Observable.from([refresh.take(1).map { true }, response.take(1).map { _ in false }])
//                .merge()
//                .bindTo(isLoading(for: tableView))
//                .addDisposableTo(rx.disposeBag)
//        }

        do { // MARK: 刷新逻辑
            let refreshControl = UIRefreshControl()
            self.refreshControl = refreshControl
            let refresh = refreshControl.rx.controlEvent(.valueChanged)
                .startWith(())
                .shareReplay(1)

//            let response = refresh
//                .flatMap { request("https://api.github.com/repos/ReactiveX/RxSwift/commits", parameters: ["per_page": 10]) }
//                .map(praseJSON)
//                .map { [CommitSectionModel(model: "", items: $0)] }
//                .catchError { (error) in
//                    // show error
//                    return Observable.just([]) // 不合理的用法，抓不到 error
//                }
//                .shareReplay(1)

            let response = refresh
                .flatMap { request("https://api.github.com/repos/ReactiveX/RxSwift/commits", parameters: ["per_page": 10])
                    .map(praseJSON)
                    .map { [CommitSectionModel(model: "", items: $0)] }
                    .catchError { (error) in
                        // show error
                        return Observable.just([])
                    }
                }
                .shareReplay(1)

            response
                .bindTo(tableView.rx.items(dataSource: dataSource))
                .addDisposableTo(rx.disposeBag)

            Observable.from([refresh.skip(1).map { true }, response.skip(1).map { _ in false }])
                .merge()
                .bindTo(refreshControl.rx.refreshing)
                .addDisposableTo(rx.disposeBag)

            Observable.from([refresh.take(1).map { true }, response.take(1).map { _ in false }])
                .merge()
                .bindTo(isLoading(for: tableView))
                .addDisposableTo(rx.disposeBag)
        }

    }

    func deselectRow(at indexPath: IndexPath, animated: Bool) {
//        tableView.deselectRow(at: indexPath, animated: animated)
    }

    deinit {
        print("Deinit")
    }

}

let manager: SessionManager = {
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = nil
    return SessionManager.init(configuration: configuration)
}()

func request(_ url: URLConvertible, method: Alamofire.HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders? = nil) -> Observable<JSON> {
    return Observable<JSON>.create { (observer) in
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let task = manager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
            .responseData { (response) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                switch response.result {
                case let .success(data):
                    let json = JSON(data: data)
                    observer.on(.next(json))
                    observer.on(.completed)
                case let .failure(error):
                    observer.on(.error(error))
                }
        }
        return Disposables.create(with: task.cancel)
    }
}

enum Result<T> {
    case success(T)
    case failure(Swift.Error)

    func map<V>(transform: (T) throws -> V) -> Result<V> {
        switch self {
        case let .success(value):
            do {
                return Result<V>.success(try transform(value))
            } catch {
                return Result<V>.failure(error)
            }
        case let .failure(error):
            return Result<V>.failure(error)
        }
    }

    func unwarp() -> Observable<T> {
        switch self {
        case let .success(value):
            return Observable.just(value)
        case .failure:
            return Observable.empty()
        }
    }

    var error: Observable<Swift.Error> {
        switch self {
        case .success:
            return Observable.empty()
        case let .failure(error):
            return Observable.just(error)
        }
    }
}

func request(_ url: URLConvertible, method: Alamofire.HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders? = nil) -> Observable<Result<JSON>> {
    return Observable<Result<JSON>>.create { (observer) in
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let task = manager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
            .responseData { (response) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                switch response.result {
                case let .success(data):
                    let json = JSON(data: data)
                    observer.on(.next(Result.success(json)))
                    observer.on(.completed)
                case let .failure(error):
                    observer.on(.next(Result.failure(error)))
                    observer.on(.completed) // 很重要
                }
        }
        return Disposables.create(with: task.cancel)
    }
}
