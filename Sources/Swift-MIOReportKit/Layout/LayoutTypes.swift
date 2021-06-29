//
//  File.swift
//  
//
//  Created by David Trallero on 22/06/2021.
//

import Foundation

public enum SizeGrowDirection: Int16 {
    case horizontal = 0
    case vertical   = 1
    case both       = 2
}


public struct Size {
    var width : Float = 0
    var height: Float = 0
    
    public init( width: Float = 0, height: Float = 0 ) {
        self.width  = width
        self.height = height
    }
        
    public func join ( _ s: Size, _ dir: SizeGrowDirection ) -> Size {
        return Size( width:  dir == .horizontal ? width  + s.width        : max( width , s.width )
                   , height: dir == .horizontal ? max( height, s.height ) : height + s.height )
    }
}

public class FontStyle {
    var color: String?
    var family: String?
    var size: Int?
    var weight: Int?
}

public class Constraint {
    var width: Decimal?
    var height: Decimal?
    
    init ( width: Decimal? = nil, height: Decimal? = nil ) {
        self.width  = width
        self.height = height
    }
}

open class RenderContext {
    var fgColor: String
    var bgColor: String
    var font: FontStyle
    var x: Float
    var y: Float
    var contraintStack: [Constraint]
    var containerStack: [Container]
    
    public init ( ) {
        fgColor = "#000000"
        bgColor = "#FFFFFF"
        font = FontStyle( )
        x = 0
        y = 0
        contraintStack = []
        containerStack = []
    }
    
    open func beginRender ( _ root: Container ) { containerStack = [root] }
    open func endRender ( ) { }
    
    open func meassure ( _ item: LayoutItem ) -> Size { return Size( width: 0, height: 0 ) }
    
    open func renderItem ( _ item: LayoutItem ) { }
    
    open func beginContainer ( _ container: Container ) {
        containerStack.append( container )
    }
    
    open func endContainer ( ) {
        _ = containerStack.popLast()
    }
    
    open func output ( ) -> Data { return Data( ) }
}
