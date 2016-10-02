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
    
    static func fetchDatas(param: String = "go", jap: Bool = true)  -> Observable<[Data]> {
        return Observable.create({ (observer) -> Disposable in
            var URL = ""
            
            if jap {
                URL = "http://54.191.66.113/img?lang=ja-jp&q=\(param)"
            } else {
                URL = "http://54.191.66.113/img?lang=en-us&q=\(param)"
            }
            URL = URL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
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

