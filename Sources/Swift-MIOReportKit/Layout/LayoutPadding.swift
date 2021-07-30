//
//  File.swift
//  
//
//  Created by David Trallero on 30/7/21.
//

import Foundation


public class Padding: VStack {
    public init ( _ item: LayoutItem
                , _ top: ItemSize, _ right: ItemSize, _ bottom: ItemSize, _ left: ItemSize
                , flex: Int = 0, id: String? = nil
                ) {
        super.init( flex, id )
        
        let hstack = HStack( 1 )
        
        if left.rawValue > 0 { hstack.add( Space( left ) ) }
        hstack.add( item )
        if right.rawValue > 0 { hstack.add( Space( right ) ) }

        if top.rawValue > 0 { add( Space( top ) ) }

        add( hstack )
        
        if bottom.rawValue > 0 { add( Space( top ) ) }
    }
}
