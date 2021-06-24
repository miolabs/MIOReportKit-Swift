//
//  File.swift
//  
//
//  Created by David Trallero on 22/06/2021.
//

import Foundation


public class Container: LayoutItem {
    var children: [LayoutItem]
    public var delegate: AddProtocol?
    var growDirection: SizeGrowDirection
    
    public override init ( _ flex: Int = 0, _ id: String? = nil ) {
        children = []
        self.delegate = nil
        self.growDirection = .both
        
        super.init( flex, id )
    }
    
    public func add ( _ item: LayoutItem ) {
        children.append( item )
        
        if delegate != nil {
            item.notifyAdded( delegate! )
        }
    }

    override func notifyAdded ( _ delegate: AddProtocol ) {
        self.delegate = delegate

        for child in children {
            child.notifyAdded( delegate )
        }
    }
    
    override func meassure ( _ context: RenderContext )
    {
        var dim = Size( )
        
        for c in children {
            c.meassure( context )
            dim = dim.join( c.dimensions, growDirection )
        }

        if flex == 0 {
            dimensions = dim
        }
    }
    
    override func setDimension(_ dim: Size) {
        super.setDimension( dim )
        
        for c in children { c.setDimension( c.dimensions ) }
    }
    
    override func setCoordinates ( ) {
        for c in children { c.setCoordinates( ) }
    }
    
    override func render ( _ context: RenderContext ) {
        context.beginContainer( self )
          for c in children { c.render( context ) }
        context.endContainer( )
    }
}

public class FooterHeaderContainer : VStack {
    var header: LayoutItem?
    var footer: LayoutItem?
    
    init ( header: LayoutItem? = nil, footer: LayoutItem? = nil ) {
        self.header = header ;
        self.footer = footer ;
    }
}

