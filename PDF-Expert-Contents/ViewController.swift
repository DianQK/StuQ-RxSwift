//
//  ViewController.swift
//  PDF-Expert-Contents
//
//  Created by DianQK on 17/09/2016.
//  Copyright © 2016 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SwiftyJSON
import SafariServices
import RxExtensions

typealias ContentsSectionModel = AnimatableSectionModel<String, ContentItem>

class ViewController: UIViewController {

    @IBOutlet private weak var contentsTableView: UITableView!

    private let dataSource = RxTableViewSectionedAnimatedDataSource<ContentsSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let fetch = Observable
            .just(R.file.contentsJson, scheduler: SerialDispatchQueueScheduler(globalConcurrentQueueQOS: DispatchQueueSchedulerQOS.background))
            .shareReplay(1)

        let expandableItems = fetch
            .map { try! Data(resource: $0) }
            .map { JSON(data: $0) }
            .map { json -> [ExpandableItem] in
                json.arrayValue.map(ExpandableItem.init)
            }

        let result = expandableItems
            .map { (items: [ExpandableItem]) in
                items.map { item in
                    Observable.combineLatest(Observable.just([ContentItem.expand(item)]), item.subItems.map { $0.map(ContentItem.index) }, resultSelector: +)
                }
            }
            .flatMap { (items: [Observable<[ContentItem]>]) -> Observable<[ContentItem]> in
                guard let first = items.first else { return Observable.empty() }
                return items.dropFirst().reduce(first) { acc, x in
                    Observable.combineLatest(acc, x, resultSelector: +)
                }
            }
            .map { [ContentsSectionModel(model: "", items: $0)] }

        result
            .observeOn(MainScheduler.instance)
            .bindTo(contentsTableView.rx.items(dataSource: dataSource))
            .addDisposableTo(rx.disposeBag)


        do {
            contentsTableView.rowHeight = UITableViewAutomaticDimension
            contentsTableView.estimatedRowHeight = 48
        }

        do {
            dataSource.animationConfiguration = RxDataSources.AnimationConfiguration(
                insertAnimation: .automatic,
                reloadAnimation: .automatic,
                deleteAnimation: .automatic)

            dataSource.configureCell = { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.expandedCell, for: indexPath)!

                switch item {
                case let .expand(item):
                    let font = UIFont.boldSystemFont(ofSize: 17)
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.firstLineHeadIndent = 0
                    paragraphStyle.headIndent = 0
                    let attributeString = NSAttributedString(string: item.title, attributes: [
                        NSParagraphStyleAttributeName: paragraphStyle,
                        NSFontAttributeName: font
                        ])
                    cell.attributedText = attributeString
                    cell.canExpanded = true
                    item.isExpanded.asObservable()
                        .bindTo(cell.rx.isExpanded)
                        .addDisposableTo(cell.disposeBag)
                case let .index(item):
                    let font = UIFont.systemFont(ofSize: 17)
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.firstLineHeadIndent = 15
                    paragraphStyle.headIndent = 15
                    let attributeString = NSAttributedString(string: item.title, attributes: [
                        NSParagraphStyleAttributeName: paragraphStyle,
                        NSFontAttributeName: font
                        ])
                    cell.attributedText = attributeString
                    cell.canExpanded = false
                }
                return cell
            }
        }

        do {
            contentsTableView.rx.modelSelected(ContentItem.self)
                .subscribe(onNext: { [unowned self] item in
                    switch item {
                    case let .expand(item):
                        item.isExpanded.value = !item.isExpanded.value
                    case let .index(item):
                        let sf = SFSafariViewController(url: item.url)
                        sf.preferredControlTintColor = UIColor.black
                        self.present(sf, animated: true, completion: nil)
                    }

                })
                .addDisposableTo(rx.disposeBag)

            contentsTableView.rx.itemSelected.map { (at: $0, animated: true) }
                .subscribe(onNext: contentsTableView.deselectRow)
                .addDisposableTo(rx.disposeBag)
        }

    }

}
