//: Please build the scheme 'RxSwiftPlayground' first
import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

import RxSwift

func example1() {
    var createTimes = 0
    
    let intSequence = Observable<Int>
        .create { (observer) -> Disposable in
            createTimes += 1
            print("Create \(createTimes).")
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            observer.onCompleted()
            
            return NopDisposable.instance
        }

    intSequence
        .subscribeNext { (value) in
            print("Subscribe 1 Next \(value)")
    }
    
    intSequence
        .subscribeNext { (value) in
            print("Subscribe 2 Next \(value)")
    }
}

//example1()

func example2() {
    let intervalSequence = Observable<Int>
        .interval(1, scheduler: MainScheduler.instance)
        .take(5)
    intervalSequence
        .subscribeNext { value in
            print("Subscribe 1 Next \(value)")
        }
    delay(3) { // 暂停一秒，第二个订阅者比第一个订阅者晚一秒订阅
        intervalSequence
            .subscribeNext { value in
                print("Subscribe 2 Next \(value)")
            }
    }
}

//example2()

func example3() {
    let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .take(5)
        .publish()
    let s = intSequence.connect()
    intSequence.subscribeNext { value in
        print("Subscribe 1 Next \(value)")
    }
    delay(3) {
//        print("disconnect")
//        s.dispose()
//        print("reconnect")
//        intSequence.connect()
        intSequence.subscribeNext { value in
            print("Subscribe 2 Next \(value)")
        }
    }
    
    var datas = [1, 2, 3, 4]
    
    let indexPath = NSIndexPath(forRow: 1, inSection: 0)
    datas[indexPath.row]
    
    
    
    let tableView = UITableView()
    
    Observable.just([1]).subscribeNext { elements in
        datas = elements
        tableView.reloadData()
    }
    
    
    
}

//example3()

func example4() {
    let publishSubject = PublishSubject<Int>()
    publishSubject.onNext(0)
//    publishSubject.onNext(1)
//    publishSubject.onNext(2)
//    publishSubject.onNext(3)
//    publishSubject.onCompleted()
    
    publishSubject
        .subscribe { event in
            print("Event: \(event).")
    }

    publishSubject.onNext(1)
    publishSubject.onNext(2)
    publishSubject.onNext(3)
    publishSubject.onCompleted()
    
    publishSubject.onNext(1)
}

//example4()

func example5() {
    let replaySubject = ReplaySubject<Int>.create(bufferSize: 2)
//    replaySubject.onNext(1)
//    replaySubject.onNext(2)
//    replaySubject.onNext(3)
//    replaySubject.onNext(4)
//    replaySubject.onCompleted()
    replaySubject
        .subscribe { (event) in
            print(event)
    }
    replaySubject
        .subscribe { (event) in
            print(event)
    }
    
    
    
}

//example5()

func example6() {
    let behavior = BehaviorSubject(value: 1)
    behavior.onNext(2)
    behavior.subscribe { (event) in
        print(event)
    }
    behavior.onNext(3)
    
//    let variable = Variable(1)
//    variable.value = 2
//    print(variable.value)
//    variable.value = 3
//    variable.asObservable().subscribe {
//        print($0)
//    }
    
}

//example6()
