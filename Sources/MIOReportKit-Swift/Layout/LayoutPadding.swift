//
//  File.swift
//  
//
//  Created by David Trallero on 30/7/21.
//

import Foundation


public class Padding: VStack<LayoutItem> {
    public init ( _ item: LayoutItem
                , top: ItemSize = .none, right: ItemSize = .none, bottom: ItemSize = .none, left: ItemSize = .none
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
