//
//  ViewController.swift
//  Annotations
//
//  Created by 宋宋 on 18/09/2016.
//  Copyright © 2016 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    lazy var moveView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue
        view.frame = CGRect(x: 100, y: 100, width: 60, height: 60)
        return view
    }()
    
    let points: [CGPoint] = [
        CGPoint(x: 50, y: 120),
        CGPoint(x: 150, y: 200),
        CGPoint(x: 150, y: 350),
        CGPoint(x: 100, y: 450),
        CGPoint(x: 230, y: 500),
        CGPoint(x: 300, y: 200)
    ]
    
    var pointViews: [UIView] = []
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let views = points.enumerated()
            .map { index, point -> UIView in
                let view = UILabel()
                view.text = String(index)
                view.textAlignment = .center
                view.textColor = UIColor.white
                view.backgroundColor = UIColor.black
                view.frame = CGRect(origin: point, size: CGSize(width: 30, height: 30))
                return view
            }

        views.forEach(view.addSubview)
        pointViews = views

        view.isUserInteractionEnabled = true
        let ges = UIPanGestureRecognizer()
        view.addSubview(moveView)
        view.addGestureRecognizer(ges)
        let movedPoint = ges.rx.event
            .flatMap { ges -> Observable<CGPoint> in
                switch ges.state {
                case .changed:
                    return Observable.just(ges.location(in: ges.view))
                default:
                    return Observable.empty()
                }
            }
            .shareReplay(1)

        movedPoint
            .subscribe(onNext: { point in
                self.moveView.frame.origin = point
            })
            .addDisposableTo(disposeBag)


        let nextIndex = movedPoint
            .scan((nextIndex: 0, points: points)) { acc, x in
                if acc.nextIndex >= acc.points.count {
                    return (nextIndex: acc.nextIndex + 1, points: acc.points)
                }
                if x.distance(acc.points[acc.nextIndex]) < 20 {
                    return (nextIndex: acc.nextIndex + 1, points: acc.points)
                } else {
                    return acc
                }
            }
            .takeWhile { acc in
                acc.nextIndex <= acc.points.count
            }
            .map { $0.nextIndex }
            .startWith(0)
            .distinctUntilChanged()
            .shareReplay(1)
        
        nextIndex
            .map { $0 - 1 }
            .filter { $0 >= 0 }
            .subscribe(onNext: { nextIndex in
                let view = views[nextIndex]
                view.backgroundColor = UIColor.blue
                } , onCompleted: {
                    UIView.animate(withDuration: 0.6, animations: {
                        self.moveView.alpha = 0
                    })
            })
            .addDisposableTo(disposeBag)
//            .subscribe(onNext: { index in
//                print(index)
//                }, onCompleted: {
//                    print("Completed")
//            })
//            .addDisposableTo(disposeBag)
    }

}

extension CGPoint {
    func distance(_ point: CGPoint) -> CGFloat {
        let offsetX = point.x - x
        let offsetY = point.y - y
        return sqrt(offsetX * offsetX + offsetY * offsetY)
    }
}
