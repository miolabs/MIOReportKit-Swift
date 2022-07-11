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


open class LayoutItem {
    var include_in_pages: IncludeInPage = .here
    var parent:LayoutItem?
    var id: String?
    var flex: Int
    var x: Float
    var y: Float
    var size: Size
    var dimensions: Size
    public var style: Style
    
    public init ( _ flex: Int = 0, _ id: String? = nil ) {
        self.id = id
        self.flex = flex
        self.x = 0
        self.y = 0
        self.dimensions = Size( )
        self.size = Size( )
        self.style = Style( )
    }
    
    open func shallowCopy ( ) -> LayoutItem {
        let ret = LayoutItem( flex, id )
        ret.copyValues( self )
        
        return ret
    }
    
    open func copyValues ( _ ret: LayoutItem ) {
        flex = ret.flex
        id = ret.id
        x = ret.x
        y = ret.y
        dimensions = ret.dimensions
        size = ret.size
        
        style.copyValues( ret.style )
    }
    
    @discardableResult
    public func bgColor ( _ bg: String ) -> LayoutItem {
        style.bgColor = bg
        return self
    }
        
    @discardableResult
    public func fgColor ( _ fg: String ) -> LayoutItem {
        style.fgColor = fg
        return self
    }
        
    func setValue ( _ value: Any ) throws { }
    
    open func meassure ( _ context: RenderContext ) {
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
    
    func absPosition() -> (x:Float, y:Float) {
        var abs_x = x
        var abs_y = y
        var p = parent
        
        while (p != nil) {
            abs_x += p!.x
            abs_y += p!.y
            p = p!.parent
        }
        
        return (x:abs_x, y: abs_y)
    }
}


