//
//  LayoutStackBuilder.swift
//  
//
//  Created by Javier Segura Perez on 11/7/22.
//

import Foundation

@resultBuilder
public struct LayoutStackBuilder {
    
    public static func buildBlock(_ components: LayoutItem...) -> [LayoutItem] {
        return components
    }
}

extension HStack
{
    public convenience init (_ flex: Int, _ id:String? = nil,  @LayoutStackBuilder _ content: ( ) -> [LayoutItem]) {
        self.init( flex, id )
        let children = content()
        for i in children {
            add( i as! E )
        }
    }
}

extension VStack
{
    public convenience init (_ flex: Int, _ id:String? = nil,  @LayoutStackBuilder _ content: ( ) -> [LayoutItem]) {
        self.init( flex, id )
        let children = content()
        for i in children {
            add( i as! E )
        }
    }
}

