//
//  NumericFunctions.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/31.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import Foundation

func gcd(_ a: Int, _ b: Int) -> Int {
    var a = a
    var b = b
    
    if a < b {
        let c = a
        a = b
        b = c
    }
    
    var rest: Int
    while true {
        rest = a % b
        
        if rest == 0 {
            return b
        } else {
            a = b
            b = rest
        }
    }
}

extension Array where Element == Int {
    func gcd() -> Int {
        if isEmpty {
            return 1
        }
        
        var gcdOfArray = self[0]
        
        for value in self {
            gcdOfArray = FavoriteGifs.gcd(value, gcdOfArray)
        }
                
        return gcdOfArray
    }
}
