//
//  ObservableExt.swift
//  GCBetFinder
//
//  Created by Logan on 6/12/20.
//  Copyright © 2020 GeoComply. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType where Element == Bool {
    /// Boolean not operator
    public func not() -> Observable<Bool> {
        return self.map(!)
    }
}

extension ObservableType {
    func notNil<T>() -> Observable<T> where Element == T? {
        return self.filter { (item) -> Bool in
            return item != nil
        }
        .map { (item) -> T in
            return item!
        }
    }
    
    func defaultThrottle() -> Observable<Element> {
        return self.throttle(.milliseconds(400), scheduler: MainScheduler.instance)
    }
}

extension SharedSequenceConvertibleType {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}

extension ObservableType {
    
    func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}
