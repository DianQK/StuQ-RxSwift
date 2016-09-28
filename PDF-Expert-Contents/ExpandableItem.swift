//
//  ExpandableItem.swift
//  PDF-Expert-Contents
//
//  Created by DianQK on 17/09/2016.
//  Copyright © 2016 DianQK. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import SwiftyJSON

protocol IDHashable: Hashable {
    associatedtype ID: Hashable
    var id: ID { get }
}

extension IDHashable {
    var hashValue: Int {
        return id.hashValue
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Hashable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension IdentifiableType where Self: IDHashable {
    var identity: Self.ID {
        return id
    }
}

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import SwiftyJSON

struct ExpandableItem: IDHashable, IdentifiableType {

    let id: Int64
    let title: String
    let level: Int
    let url: URL?

    let isExpanded: Variable<Bool>
    private let _subItems: Variable<[ExpandableItem]> = Variable([])
    let canExpanded: Bool
    private let disposeBag = DisposeBag()

    var subItems: Observable<[ExpandableItem]> {
        return self._subItems.asObservable()
    }

    init(id: Int64, title: String, level: Int, url: URL?, isExpanded: Bool, subItems: [ExpandableItem]) {
        self.id = id
        self.title = title
        self.level = level
        self.url = url

        self.canExpanded = !subItems.isEmpty
        if self.canExpanded {

            self.isExpanded = Variable(isExpanded)

            self.isExpanded.asObservable()
                .map { isExpanded in
                    isExpanded ? subItems : []
                }
                .flatMap(combineSubItems)
                .bindTo(_subItems)
                .addDisposableTo(disposeBag)

        } else {
            self.isExpanded = Variable(false)
        }

    }

    let combineSubItems: (_ subItems: [ExpandableItem]) -> Observable<[ExpandableItem]> = { subItems in
        return subItems.reduce(Observable<[ExpandableItem]>.just([])) { (acc, x) in
            Observable.combineLatest(acc, Observable.just([x]), x._subItems.asObservable(), resultSelector: { $0 + $1 + $2 })
        }
    }

    static func createExpandableItem(json: JSON, withPreLevel preLevel: Int) -> ExpandableItem {
        let title = json["title"].stringValue
        let id = json["id"].int64Value
        let url = URL(string: json["url"].stringValue)

        let level = preLevel + 1

        let subItems: [ExpandableItem]

        if let subJSON = json["subdirectory"].array, !subJSON.isEmpty {
            subItems = subJSON.map { createExpandableItem(json: $0, withPreLevel: level) }
        } else {
            subItems = []
        }
        return ExpandableItem(id: id, title: title, level: level, url: url, isExpanded: false, subItems: subItems)
    }

}
