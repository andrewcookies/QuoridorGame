//
//  DictionaryConverter.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import Foundation

protocol DictionaryConverter {
    func toDictionary() -> [String : Any]
}

extension DictionaryConverter {
    
    func toDictionary() -> [String : Any] {
        let reflect = Mirror(reflecting: self)
        let children = reflect.children
        let dictionary = toAnyHashable(elements: children)
        return dictionary
    }
    
    func toAnyHashable(elements: AnyCollection<Mirror.Child>) -> [String : Any] {
        var dictionary: [String : Any] = [:]
        for element in elements {
            if let key = element.label {
                
                if let collectionValidHashable = element.value as? [AnyHashable] {
                    dictionary[key] = collectionValidHashable
                }
                
                if let validHashable = element.value as? String {
                    dictionary[key] = validHashable
                }
                if let validHashable = element.value as? Double {
                    dictionary[key] = validHashable
                }
                if let validHashable = element.value as? Int {
                    dictionary[key] = validHashable
                }
                
                if let convertor = element.value as? DictionaryConverter {
                    dictionary[key] = convertor.toDictionary()
                }
                
                if let convertorList = element.value as? [DictionaryConverter] {
                    dictionary[key] = convertorList.map({ e in
                        e.toDictionary()
                    })
                }
            }
        }
        return dictionary
    }
}
