//
//  PushSettingModel.swift
//  RxDealCell
//
//  Created by 宋宋 on 8/8/16.
//  Copyright © 2016 T. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum PushType {
    case confirm
    case willExpire
    case expired
    case refunded
    case getGift
    case couponInfo
    case favorite

    var name: String {
        switch self {
        case .confirm:
            return "消费确认"
        case .willExpire:
            return "订单即将过期"
        case .expired:
            return "订单已过期"
        case .refunded:
            return "退款成功"
        case .getGift:
            return "获得礼券"
        case .couponInfo:
            return "优惠信息"
        case .favorite:
            return "喜欢的礼遇有更新"
        }
    }
}

struct PushItemModel {
    let pushType: PushType
    let isSelected: Variable<Bool>
}

extension PushItemModel: Hashable, Equatable, IdentifiableType {
    var hashValue: Int {
        return pushType.hashValue
    }

    var identity: Int {
        return pushType.hashValue
    }
}

func ==(lhs: PushItemModel, rhs: PushItemModel) -> Bool {
    return lhs.pushType == rhs.pushType
}

struct PushSectionModel {
    let category: String
    let isSelectedAll: Variable<Bool>
}

extension PushSectionModel: Hashable, Equatable, IdentifiableType {
    var hashValue: Int {
        return category.hashValue
    }

    var identity: Int {
        return category.hashValue
    }
}

func ==(lhs: PushSectionModel, rhs: PushSectionModel) -> Bool {
    return lhs.category == rhs.category
}
