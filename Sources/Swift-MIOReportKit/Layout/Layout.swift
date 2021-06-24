//
//  File.swift
//  
//
//  Created by David Trallero on 22/06/2021.
//

import Foundation

public class Layout: AddProtocol {
    var elementsByID: [String:LayoutItem]
    var rootItem: Container
    
    public init ( _ root: Container ) {
        elementsByID = [:]
        rootItem = root
        root.delegate = self
    }
    
    public func onItemAdded ( _ item: LayoutItem ) {
        if item.id != nil {
            elementsByID[ item.id! ] = item
        }
    }
    
    public func setValue( forID: String, value: Any ) throws { // Text, Image
        if let item = elementsByID[ forID ] {
            try item.setValue( value )
        }
    }

    
    public func render ( _ context: RenderContext ) {
        // Overwritten by meassure pass
        let initialSize = rootItem.dimensions
        
        context.beginRender( rootItem )
            rootItem.meassure( context )
            // This triggers resizing in children that has flex
            rootItem.setDimension( initialSize )
            rootItem.setCoordinates( )
            rootItem.render( context )
        context.endRender( )
    }
}
