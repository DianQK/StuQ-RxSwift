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

class OrderTableViewController: UITableViewController {

    @IBOutlet private weak var minusButton: UIButton!
    @IBOutlet private weak var countTextField: UITextField!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet private weak var subtotalLabel: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
