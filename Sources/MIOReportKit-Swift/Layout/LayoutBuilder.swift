//
//  LayoutStackBuilder.swift
//  
//
//  Created by Javier Segura Perez on 11/7/22.
//

import Foundation

class EmptyLayoutItem : LayoutItem {}

public class LayoutItemGroup : LayoutItem {
    var children:[LayoutItem] = []

    init ( components: LayoutItem... ) {
        for c in components {
            self.children.append( c )
        }
    }
    
    init ( components: [LayoutItem] ) {
        for c in components {
            self.children.append( c )
        }
    }
    
    init ( component: LayoutItem? = nil ) {
        if component != nil {
            self.children.append( component! )
        }
    }
    
    func flatChildren( _ array:inout [LayoutItem] ) {
        for c in children {
            if let g = c as? LayoutItemGroup {
                g.flatChildren( &array )
            }
            else {
                array.append( c )
            }
        }
    }
}

@resultBuilder
public struct LayoutStackBuilder {
    
    public static func buildBlock(_ components: LayoutItem...) -> LayoutItemGroup {
        return LayoutItemGroup( components: components )
    }
    
    public static func buildOptional(_ component: LayoutItem?) -> LayoutItemGroup {
        return LayoutItemGroup( component: component )
    }
    
    public static func buildEither(first component: LayoutItemGroup) -> LayoutItemGroup {
        return component
    }
    
    public static func buildEither(second component: LayoutItemGroup) -> LayoutItemGroup {
        return component
    }
}

extension HStack
{
    public convenience init (_ flex: Int, _ id:String? = nil, @LayoutStackBuilder _ content: ( ) -> LayoutItemGroup) {
        self.init( flex, id )
        let group = content()
        var array:[LayoutItem] = []
        group.flatChildren( &array )
        for c in array {
            add( c as! E )
        }
    }

    public func border( color:String ) -> HStack {
        self.style.borderColor = BorderColor(color, color, color, color)
        return self
    }

    public func border( topColor: String? = nil, rightColor: String? = nil, bottomColor: String? = nil, leftColor: String? = nil ) -> HStack {
        self.style.borderColor = BorderColor(topColor, rightColor, bottomColor, leftColor)
        return self
    }

    public func border( width: Int = 0 ) -> HStack {
        self.style.borderWidth = BorderWidth( width, width, width, width )
        return self
    }
    
    public func border( top: Int = 0, right:Int = 0, bottom:Int = 0, left:Int = 0 ) -> HStack {
        self.style.borderWidth = BorderWidth( top, right, bottom, left )
        return self
    }
    
    public func border( radius:Int ) -> HStack {
        self.style.borderRadius = radius
        return self
    }
}

extension VStack
{
    public convenience init (_ flex: Int, _ id:String? = nil,  @LayoutStackBuilder _ content: ( ) -> LayoutItemGroup) {
        self.init( flex, id )
        let group = content()
        var array:[LayoutItem] = []
        group.flatChildren( &array )
        for c in array {
            add( c as! E )
        }
    }
    
    public func border( color:String ) -> VStack {
        self.style.borderColor = BorderColor(color, color, color, color)
        return self
    }

    public func border( topColor: String? = nil, rightColor: String? = nil, bottomColor: String? = nil, leftColor: String? = nil ) -> VStack {
        self.style.borderColor = BorderColor(topColor, rightColor, bottomColor, leftColor)
        return self
    }

    public func border( width: Int = 0 ) -> VStack {
        self.style.borderWidth = BorderWidth( width, width, width, width )
        return self
    }
    
    public func border( top: Int = 0, right:Int = 0, bottom:Int = 0, left:Int = 0 ) -> VStack {
        self.style.borderWidth = BorderWidth( top, right, bottom, left )
        return self
    }
    
    public func border( radius:Int ) -> VStack {
        self.style.borderRadius = radius
        return self
    }
}

extension Text
{
    public func foregroundColor( _ hexColor:String ) -> Text {
        self.fgColor( hexColor )
        return self
    }

    public func backgroundColor( _ hexColor:String ) -> Text {
        self.bgColor( hexColor )
        return self
    }
    
    public func font( size:ItemSize ) -> Text {
        self.text_size = size
        return self
    }
    
    public func font( bold:Bool = false, italic:Bool = false ) -> Text {
        self.bold = bold
        self.italic = italic
        return self
    }

}

