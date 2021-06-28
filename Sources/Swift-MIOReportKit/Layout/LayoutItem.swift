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
    var size: Size
    var dimensions: Size
    
    public init ( _ flex: Int = 0, _ id: String? = nil ) {
        self.id = id
        self.flex = flex
        self.x = 0
        self.y = 0
        self.dimensions = Size( )
        self.size = Size( )
    }
        
    func setValue ( _ value: Any ) throws { }
    
    func meassure ( _ context: RenderContext ) {
        self.size = context.meassure( self )
    }

    func setDimension ( _ dim: Size ) {
        // TODO: Decide how to resize de image
        // - mantain aspect ratio:
        //   - cover
        //   - contain
        // - else:
        //   - resize
        dimensions = dim
    }
    
    func setCoordinates ( _ x: Float, _ y: Float ) {
        self.x = x
        self.y = y
    }
    
    func render ( _ context: RenderContext ) {
        context.renderItem( self )
    }
    
    func notifyAdded ( _ delegate: AddProtocol ) {
        delegate.onItemAdded( self )
    }
}


