//
//  PDFRender.swift
//  
//
//  Created by Javier Segura Perez on 27/1/22.
//

import Foundation
import PDFLib_Swift

public class PDFRender: RenderContext
{
    var pdf = PDF()
    var renderData:Data!
    
    var defaultFont:Int32 = -1
    var defaultFontBold:Int32 = -1
    var pageMargin: Margin = Margin( )
    
    var offsetY:Float = 0
    
    var resourcesPath:String?
    public override func setResourcesPath( _ path: String ) {
        resourcesPath = path
    }
    
    public override func beginRender(_ root: Page ) {
        super.beginRender(root)
                        
        try? pdf.beginDocument( )
        if resourcesPath != nil {
            pdf.setParameter(key: "SearchPath", value: resourcesPath!)
        }
        
        defaultFont = (try? pdf.loadFont(name: "SF-Compact-Text-Regular", encoding: "winansi", options: "embedding") ) ?? -1
        defaultFontBold = (try? pdf.loadFont(name: "SF-Compact-Text-Bold", encoding: "winansi", options: "embedding") ) ?? -1
        
        pageMargin = root.margins
        offsetY = PDF.A4.height - root.margins.top - root.margins.bottom
        
//        root.size = Size( width:  PDF.A4.width  - 2 * margin
//                        , height: PDF.A4.height - 2 * margin )
//
//        root.dimensions = root.size
    }
    
    public override func endRender() {
        super.endRender()
        
        pdf.endDocument()
        
        renderData = pdf.pdfData()
    }
    
    public override func output() -> Data {
        return renderData
    }
    
    public override func beginContainer(_ container: Container<LayoutItem>) {
        super.beginContainer(container)
        
        if container is A4 {
            pdf.setFont( defaultFont, size: defaultFontSize )
        }
        else if let table = container as? Table {
            
            if !table.hideHeader {
                let header = table.header!.children

                rect( table.header! )

                for h in header {
                    h.render( self )
                }
            }

            for row in table.body.children {
                for col in (row as! HStack).children {
                    col.render( self )
                }
            }
            
            if !table.hideFooter {
                rect( table.footer! )
                
                for col in table.footer!.children {
                    col.render( self )
                }
            }
        }
        else {
            rect( container )
        }

    }
    
    
    public func rect ( _ item: LayoutItem ) {
        
        let p = pos( item )
        let bg = item.style.bgColor
        let fg = item.style.fgColor
        let t = item.style.borderWidth.top
        let b = item.style.borderWidth.bottom
        let r = item.style.borderWidth.right
        let l = item.style.borderWidth.left
        
        if bg != nil {
            let bg_color = parse_color( bg! )

            pdf.setColor(fstype: "fill", colorspace: "rgb", c1: bg_color.r, c2: bg_color.g, c3: bg_color.b)
            pdf.rect( x: p.x
                    , y: p.y
                    , width:  Double( item.dimensions.width  )
                    , height: Double( item.dimensions.height ) )
            pdf.fill()
        }

        if t > 0 {
            setColor( item.style.borderColor.top ?? fg )
            pdf.rect( x: p.x
                    , y: p.y + Double( item.dimensions.height ) - Double( t )
                    , width:  Double( item.dimensions.width  )
                    , height: Double( t ) )
            pdf.fill()
        }

        if l > 0 {
            setColor( item.style.borderColor.left ?? fg )
            pdf.rect( x: p.x
                    , y: p.y
                    , width:  Double( l )
                    , height: Double( item.dimensions.height ) )
            pdf.fill()
        }
        
        if b > 0 {
            setColor( item.style.borderColor.bottom ?? fg )
            pdf.rect( x: p.x
                    , y: p.y
                    , width:  Double( item.dimensions.width  )
                    , height: Double( b ) )
            pdf.fill()
        }

        if r > 0 {
            setColor( item.style.borderColor.right ?? fg )
            pdf.rect( x: p.x + Double( item.dimensions.width ) - Double( r )
                    , y: p.y
                    , width:  Double( r )
                    , height: Double( item.dimensions.height ) )
            pdf.fill()
        }
        
        setColor( "#000000" )
    }
    
    func setColor ( _ fg: String?, _ fstype: String = "fill" ) {
        if fg == nil {
            return
        }
        
        let fg_color = parse_color( fg! )
        
        pdf.setColor(fstype: fstype, colorspace: "rgb", c1: fg_color.r, c2: fg_color.g, c3: fg_color.b)
    }
    
    
    public func pos ( _ item: LayoutItem ) -> (x: Double, y: Double) {
        let abs_pos = item.absPosition( )
        
        return ( x: Double( abs_pos.x + pageMargin.left )
               , y: Double( offsetY - abs_pos.y - item.dimensions.height + pageMargin.top ) )
    }
    
    
    public override func endContainer(_ container: Container<LayoutItem>) {
        super.endContainer(container)
    }
    
    let textAlign = ["left", "center", "right"]
    func textAlignString( _ align: TextAlign) -> String {
        return textAlign[ align.rawValue ]
    }
    
    override open func renderItem ( _ item: LayoutItem ) {
        rect( item )
        
        if clip( item ) {
            return
        }
        
        if let text = item as? Text {
//            func pad ( _ length: Int ) -> String {
//                return String( repeating: " ", count: max( 0, length ) )
//            }
//
//            let len   = Int( text.dimensions.width )
//            let space = len - text.text.count
//            var padded_text: String
//
//            switch text.align {
//                case .left:   padded_text = text.text + pad( space )
//                case .center: padded_text = pad( space/2 ) + text.text + pad( space - space/2 )
//                case .right:  padded_text = pad( space ) + text.text
//            }
//
//            x = text.x
//            y = text.y
//            local_write( padded_text )
//            pdf.setGraphicOptions( text.fg_color != nil ? "fillcolor={\(text.fg_color!)}" : "fillcolor=black")
            var opts:[String] = []
            opts.append("font=\( text.bold ? defaultFontBold : defaultFont)" )
            opts.append("fontsize=\(fontSizeInPoints(text.text_size))")
            if text.style.fgColor != nil {
                let (r,g,b,_) = parse_color(text.style.fgColor!)
                opts.append("fillcolor={rgb \(r) \(g) \(b)}")
//                opts.append("matchbox={fillcolor={rgb 0.8 0.8 0.87} boxheight={fontsize descender}}")
            }
            opts.append( "boxsize={\(text.dimensions.width) \(text.dimensions.height)}" )
            opts.append( "position={" + textAlignString ( text.align ) + " bottom }" )
            opts.append( "fitmethod=auto" )
            opts.append( "margin=1" )
            let pos = self.pos( text )
            // Note => +4 = baseline?
            try? pdf.fitTextLine( text: text.text
                                , x: pos.x + 4
                                , y: pos.y + 4 // 2 of air + 2 of descent?
                                , options: opts.joined(separator: " "))
        }
        else if let img = item as? Image {
//            let line = String( repeating: "I", count: Int( img.dimensions.width ) )
//            for y in 0..<Int(img.dimensions.height) {
//                write( Int( img.x ), Int( img.y ) + y, line )
//            }
        }
    }
        
    
    func clip ( _ item: LayoutItem ) -> Bool {
        if let text = item as? Text {
            if text.text.starts(with: "ICE TEA-") {
                print( text.text )
            }
        }
        return item.absPosition().y < 0 // >= offsetY
    }
    
    
    let fontSize:[Double] = [0, 8, 10, 12, 14, 16, 20, 30]
    func fontSizeInPoints( _ size:ItemSize ) -> Double { return fontSize[ size.rawValue ] }
    var defaultFontSize:Double { get { return fontSizeInPoints (.s ) } }
    
    override open func meassure ( _ item: LayoutItem ) -> Size {
        if let text = item as? Text {
            let fs = fontSizeInPoints( text.text_size )
            let w = pdf.stringWidth(text.text, font: defaultFont, size: fs )
            let descent: Double = 2
            // Text needs air
            return Size( width: Float( w ), height: Float (fs + descent + 4.0) )
        }
        else if let sp = item as? Space {
            return Size( width: Float (sp.a.rawValue) * 4, height: Float (sp.b.rawValue) * 4 )
        }
            
        return super.meassure( item )
    }
    
    
    func parse_color( _ hex:String) -> (r:Double, g:Double, b:Double, a:Double){
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor + "00")
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    let r = Double((hexNumber & 0xff000000) >> 24) / 255
                    let g = Double((hexNumber & 0x00ff0000) >> 16) / 255
                    let b = Double((hexNumber & 0x0000ff00) >> 8) / 255
                    let a = 1.0
                    //if hexColor.count == 8 { Double(hexNumber & 0x000000ff) / 255 }
                    
                    return (r, g, b, a)
                }
            }
        }
        
        return (0, 0, 0, 0)
    }
    
    open override func beginPage ( _ page: LayoutItem) {
        pdf.beginPage(options: "width=a4.width height=a4.height")
    }
    
    
    open override func endPage ( _ page: LayoutItem) {
        pdf.endPage()
    }

}
