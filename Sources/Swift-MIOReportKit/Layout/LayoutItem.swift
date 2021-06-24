//
//  File.swift
//  
//
//  Created by David Trallero on 22/06/2021.
//

import Foundation


public protocol AddProtocol {
    func onItemAdded ( _ idem: LayoutItem )
}

public class LayoutItem {
    var id: String?
    var flex: Int
    var x: Float
    var y: Float
    var dimensions: Size
    
    public init ( _ flex: Int = 0, _ id: String? = nil ) {
        self.id = id
        self.flex = flex
        self.x = 0
        self.y = 0
        self.dimensions = Size( )
    }
    
    func setDimension ( _ dim: Size ) {
        dimensions = dim
    }
    
    func setValue ( _ value: Any ) throws { }
    
    func meassure ( _ context: RenderContext ) {
        self.dimensions = context.meassure( self )
    }
    
    func setCoordinates ( ) { }
    func render ( _ context: RenderContext ) {
        context.renderItem( self )
    }
    
    func notifyAdded ( _ delegate: AddProtocol ) {
        delegate.onItemAdded( self )
    }
    // constraint ( width: Decimal? = nil, height: Decimal? = nil )
}


