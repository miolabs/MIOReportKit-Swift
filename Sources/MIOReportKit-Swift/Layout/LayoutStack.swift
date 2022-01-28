//
//  File.swift
//  
//
//  Created by David Trallero on 22/06/2021.
//

import Foundation

public class HStack: Container {
    public override init ( _ flex: Int = 0, _ id: String? = nil ) {
        super.init( flex, id )
        growDirection = .horizontal
    }
    
    
    override func meassure (_ context: RenderContext ) {
        super.meassure( context )

        for c in children {
            if let spc = c as? Space {
                spc.size = Size( width: spc.size.width, height: size.height )
            }
        }
    }
    
    override func setDimension ( _ dim: Size ) {
        let num_flex: Int = children.reduce( 0 ) { total, child in total + child.flex }
        let fixed_size = children.reduce( 0 ) { total, child in total + (child.flex == 0 ? child.size.width : 0) }
        let flex_size = max( 0, Float(dim.width - fixed_size) / Float(num_flex) )
        
        var sz = Size( width: 0, height: 0 )
        for c in children {
            c.setDimension( Size( width: c.flex > 0 ? Float(c.flex) * flex_size : c.size.width
                                , height: c.size.height))
            
            sz = sz.join( c.dimensions, .horizontal )
        }
        dimensions = sz
    }
    
    override func setCoordinates ( _ x: Float, _ y: Float ) {
        self.x = x
        self.y = y

        if children.count == 0 { return }
        
        var posX: Float = 0
        
        for c in children {
            c.setCoordinates( posX, 0 )
            posX += c.dimensions.width
        }
    }
}


public class VStack: Container {
    public override init ( _ flex: Int = 0, _ id: String? = nil ) {
        super.init( flex, id )
        growDirection = .vertical
    }
    
    override func meassure(_ context: RenderContext) {
        super.meassure( context )

        for c in children {
            if let spc = c as? Space {
                spc.size = Size( width: size.width, height: spc.size.width )
            }
        }
    }

    override func setDimension ( _ dim: Size ) {
        let num_flex: Int = children.reduce( 0 ) { total, child in total + child.flex }
        let fixed_size = children.reduce( 0 ) { total, child in total + (child.flex == 0 ? child.size.height : 0) }
        let flex_size = max( 0, Float(dim.width - fixed_size) / Float(num_flex) )
        
        var sz = Size( width: 0, height: 0 )
        for c in children {
            c.setDimension( Size( width: dim.width
                                , height: c.flex > 0 ? Float(c.flex) * flex_size : c.size.height ))

            sz = sz.join( c.dimensions, .vertical )
        }
        dimensions = sz
    }

    
    override func setCoordinates ( _ x: Float, _ y: Float ) {
        self.x = x
        self.y = y
        
        if children.count == 0 { return }
        
        var posY: Float = 0
        
        for c in children {
            c.setCoordinates( 0, posY )
            posY += c.dimensions.height
        }
    }
}
