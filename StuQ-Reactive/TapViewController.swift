//
//  TapViewController.swift
//  StuQ-Reactive
//
//  Created by DianQK on 8/28/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TapViewController: UIViewController {

    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var rxButton: UIButton!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var rxLabel: UILabel!

    @IBOutlet weak var reset: UIButton!
    @IBOutlet weak var rxReset: UIButton!

    private var tapCount: Int = 0
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        button.addTarget(self, action: #selector(TapViewController.buttonTap), forControlEvents: .TouchUpInside)

        // 使用 button reset 两个空间完整对 button 点击次数的计算，reset 会将次数归零
        // 使用 RxSwift 再次完成上述需求

    }

    dynamic func buttonTap() {
        addCount()
    }
    
    private func addCount() {
        tapCount += 1
        print("Tap: \(tapCount).")
        self.label.text = "\(tapCount)"
    }

}
