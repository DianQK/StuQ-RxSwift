//
//  Meizi.swift
//  Refresh
//
//  Created by 宋宋 on 8/30/16.
//  Copyright © 2016 T. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Meizi {
    let _id: String
    let url: NSURL
    
    init(_ json: JSON) {
        _id = json["_id"].stringValue
        url = NSURL(string: json["url"].stringValue)!
    }
}
