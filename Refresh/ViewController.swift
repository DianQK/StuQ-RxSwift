//
//  ViewController.swift
//  Refresh
//
//  Created by 宋宋 on 8/30/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var viewModel: ViewModel!
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        let refreshTrigger = refreshControl.rx_controlEvent(.ValueChanged)
        
        viewModel = ViewModel(refreshTrigger: refreshTrigger.asObservable().startWith(()))
        
        viewModel.items.asObservable()
            .observeOn(MainScheduler.instance)
            .bindTo(tableView.rx_itemsWithCellIdentifier("ImageTableViewCell", cellType: ImageTableViewCell.self)) { index, meizi, cell in
                cell.meiziImageView.kf_setImageWithURL(meizi.url)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.isRefreshing.asObservable()
            .observeOn(MainScheduler.instance)
            .bindTo(refreshControl.rx_refreshing)
            .addDisposableTo(disposeBag)
    }

}

