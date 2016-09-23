//
//  SelectPaymentViewController.swift
//  RxDealCell
//
//  Created by DianQK on 8/5/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct SelectPayment: Hashable, Equatable, IdentifiableType {
    let select: Variable<Payment>

    var hashValue: Int {
        return select.value.hashValue
    }

    var identity: Int {
        return select.value.hashValue
    }

    init(defaultSelected: Payment) {
        select = Variable(defaultSelected)
    }
}

func ==(lhs: SelectPayment, rhs: SelectPayment) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

typealias PaymentSectionModel = AnimatableSectionModel<SelectPayment, Payment>

class SelectPaymentViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    private let dataSource = RxTableViewSectionedReloadDataSource<PaymentSectionModel>()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSingleSelect()

//        setupMultipleSelect()

    }

    // 单选
    func setupSingleSelect() {
        struct SelectPayment {
            let type: Payment
            let isSelected: Variable<Bool>
        }

        Observable.just([
            SelectPayment(type: Payment.alipay, isSelected: Variable(false)),
            SelectPayment(type: Payment.wechat, isSelected: Variable(false)),
            SelectPayment(type: Payment.unionpay, isSelected: Variable(false))
            ])

            .bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.paymentTableViewCell.identifier, cellType: PaymentTableViewCell.self)) { index, item, cell in

                cell.setPayment(item.type)

                item.isSelected.asObservable()
                    .bindTo(cell.rx.isSelectedPayment)
                    .addDisposableTo(cell.rx.prepareForReuseBag)

            }
            .addDisposableTo(disposeBag)

        tableView.rx.modelSelected(SelectPayment.self)
            .subscribe(onNext: { selectPayment in
                selectPayment.isSelected.value = !selectPayment.isSelected.value
            })
            .addDisposableTo(disposeBag)
    }

    // 多选
    func setupMultipleSelect() {
        dataSource.configureCell = { ds, tb, indexPath, payment in
            let cell = tb.dequeueReusableCell(withIdentifier: R.reuseIdentifier.paymentTableViewCell, for: indexPath)!
            cell.setPayment(payment)
            let selectedPayment = ds.sectionAtIndex(indexPath.section).model.select.asObservable()
            selectedPayment
                .map { $0 == payment }
                .bindTo(cell.rx.isSelectedPayment)
                .addDisposableTo(cell.rx.prepareForReuseBag)
            return cell
        }

        let selectPayment = SelectPayment(defaultSelected: Payment.alipay)

        tableView
            .rx.modelSelected(Payment.self)
            .bindTo(selectPayment.select)
            .addDisposableTo(disposeBag)

        let paymentSection = PaymentSectionModel(
            model: selectPayment, items: [
                Payment.alipay,
                Payment.wechat,
                Payment.unionpay,
                ])

        Observable.just([paymentSection])
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

        tableView.rx.itemSelected
            .map { ($0, animated: true) }
            .subscribe(onNext: tableView.deselectRow)
            .addDisposableTo(disposeBag)
    }
}
