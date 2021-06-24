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
    
    override func setDimension ( _ dim: Size ) {
        super.setDimension( dim )
        
        let num_flex: Int = children.reduce( 0 ) { total, child in total + child.flex }
        let fixed_size = children.reduce( 0 ) { total, child in total + (child.flex == 0 ? child.dimensions.width : 0) }
        let flex_size = max( 0, Float(dimensions.width - fixed_size) / Float(num_flex) )
        
        for c in children {
            c.setDimension( Size( width: c.flex > 0 ? Float(c.flex) * flex_size : c.dimensions.width
                                , height: c.dimensions.height))
        }
    }
    
    override func setCoordinates ( ) {
        if children.count == 0 { return }
        
        var posX: Float = 0
        
        for c in children {
            c.setCoordinates()
            c.x = posX
            c.y = 0
            posX += c.dimensions.width
        }
    }
}


public class VStack: Container {
    public override init ( _ flex: Int = 0, _ id: String? = nil ) {
        super.init( flex, id )
        growDirection = .vertical
    }

    override func setDimension ( _ dim: Size ) {
        super.setDimension( dim )
        
        let num_flex: Int = children.reduce( 0 ) { total, child in total + child.flex }
        let fixed_size = children.reduce( 0 ) { total, child in total + (child.flex == 0 ? child.dimensions.height : 0) }
        let flex_size = max( 0, Float(dimensions.width - fixed_size) / Float(num_flex) )
        
        for c in children {
            c.setDimension( Size( width: dim.width
                                , height: c.flex > 0 ? Float(c.flex) * flex_size : c.dimensions.height ))
        }
    }

    
    override func setCoordinates ( ) {
        if children.count == 0 { return }
        
        var posY: Float = 0
        
        for c in children {
            c.setCoordinates()
            c.x = 0
            c.y = posY
            posY += c.dimensions.height
        }
    }
}
