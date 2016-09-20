//: Please build the scheme 'RxSwiftPlayground' first
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

import RxSwift
import RxCocoa

extension ObservableType {
    func replaceWith<T>(_ value: T) -> Observable<T> {
        return asObservable().map { _ in value }
    }
}

public protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    /// Cast `Optional<Wrapped>` to `Wrapped?`
    public var value: Wrapped? {
        return self
    }
}

public protocol ReverseType {
    var reverse: Self { get }
}

extension Bool: ReverseType {
    public var reverse: Bool {
        return !self
    }
}

extension Int: ReverseType {
    public var reverse: Int {
        return -self
    }
}

extension ObservableType where E: OptionalType {
    func filterNil() -> Observable<E.Wrapped> {
//        return asObservable().filter { $0.value != nil }.map { $0.value! }
        return asObservable()
            .flatMap { optional -> Observable<E.Wrapped> in
                if let value = optional.value {
                    return Observable.just(value)
                } else {
                    return Observable.empty()
                }
        }
    }
}

extension ObservableType where E: ReverseType {
    func reverse() -> Observable<E> {
        return asObservable()
            .map { $0.reverse }
    }
}

let button = UIButton()

button.rx.tap.map { true }
button.rx.tap.map { _ in true }

button.rx.tap.replaceWith(true)

Observable.just(Optional.some(1)).filterNil()

//Observable.just(Optional.some(1)).fi

//let sequence: [Int?] = [1, 2, 3]

//sequence.flatMap { $0 }


