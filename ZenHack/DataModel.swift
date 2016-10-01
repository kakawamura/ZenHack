//
//  DataModel.swift
//  ZenHack
//
//  Created by KazushiKawamura on 10/2/16.
//  Copyright © 2016 KazushiKawamura. All rights reserved.
//


import Alamofire
import AlamofireObjectMapper
import RxSwift

class DataModel {
    
    
    init() {
        
    }
    
    static func fetchDatas()  -> Observable<[Data]> {
        return Observable.create({ (observer) -> Disposable in
            let URL = "https://raw.githubusercontent.com/kakawamura/ZenHack/master/sample2.json"
            
            Alamofire.request(.GET, URL).responseArray { (response: Response<[Data], NSError>) in
                switch response.result {
                case .Success(let datas):
                    observer.on(.Next(datas))
                    observer.on(.Completed)
                case .Failure(let error):
                    observer.on(.Error(error))
                }
            }
            
            return AnonymousDisposable { }
        })
    
    }
    
}

