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

enum ContentItem: IDHashable, IdentifiableType {
    case index(IndexItem)
    case expand(ExpandableItem)

    var id: Int64 {
        switch self {
        case let .index(item):
            return item.id
        case let .expand(item):
            return item.id
        }
    }
}

struct IndexItem: IDHashable, IdentifiableType {
    let id: Int64
    let title: String
    let url: URL

    init(id: Int64, title: String, url: URL) {
        self.id = id
        self.title = title
        self.url = url
    }

    init(json: JSON) {
        self.id = json["id"].int64Value
        self.title = json["title"].stringValue
        self.url = json["url"].URL!
    }
}

struct ExpandableItem: IDHashable, IdentifiableType {

    let id: Int64
    let title: String

    let isExpanded: Variable<Bool>
    let _subItems: Variable<[IndexItem]> = Variable([])
    private let disposeBag = DisposeBag()

    var subItems: Observable<[IndexItem]> {
        return self._subItems.asObservable()
    }
    
    init(id: Int64, title: String, isExpanded: Bool, subItems: [IndexItem]) {
        self.id = id
        self.title = title

        self.isExpanded = Variable(isExpanded)

        self.isExpanded.asObservable()
            .map { isExpanded in
                isExpanded ? subItems : []
            }
            .bindTo(_subItems)
            .addDisposableTo(disposeBag)
    }

    init(json: JSON) {
        let id = json["id"].int64Value
        let title = json["title"].stringValue
        let isExpanded = false
        let subItems = json["subdirectory"].arrayValue.map(IndexItem.init)

        self.init(id: id, title: title, isExpanded: isExpanded, subItems: subItems)
    }

}
