//
//  LayoutViewController.swift
//  StuQ-Reactive
//
//  Created by DianQK on 8/28/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class LayoutViewController: UIViewController {

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "输入文字"
        return textField
    }()

    private lazy var inputLabel: UILabel = {
        let label = UILabel()
        label.text = "输入的文本"
        label.font = UIFont.systemFontOfSize(30)
        label.numberOfLines = 0
        return label
    }()

    private lazy var footerLabel: UILabel = {
        let label = UILabel()
        label.text = "我是尾部"
        label.font = UIFont.systemFontOfSize(30)
        return label
    }()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(textField)
        view.addSubview(inputLabel)
        view.addSubview(footerLabel)

        textField.snp_makeConstraints { (make) in
            make.leading.equalTo(self.view).offset(30)
            make.top.equalTo(self.view).offset(120)
            make.trailing.equalTo(self.view).offset(-30)
            make.height.equalTo(60)
        }

        inputLabel.snp_makeConstraints { (make) in
            make.leading.equalTo(self.view).offset(120)
            make.trailing.equalTo(self.view).offset(-120)
            make.centerY.equalTo(self.view)
        }

        footerLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.inputLabel.snp_bottom).offset(30) // footer 的顶部距离 input 底部为 30
            make.centerX.equalTo(self.view)
        }

        textField.rx_text.bindTo(inputLabel.rx_text).addDisposableTo(disposeBag)

    }
}
