//
//  File.swift
//  
//
//  Created by David Trallero on 29/7/21.
//

import Foundation


public class Space: LayoutItem {
    public var a: ItemSize
    public var b: ItemSize
    
    public init ( _ a: ItemSize, _ b: ItemSize = .none ) {
        self.a = a
        self.b = b
        super.init( 0 )
    }
}
