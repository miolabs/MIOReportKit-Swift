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
    var defaultFontSize: Double = 10
    
    var offsetY:Float = 0
    
    var resourcesPath:String?
    public override func setResourcesPath( _ path: String ) {
        resourcesPath = path
    }
    
    public override func beginRender(_ root: Container) {
        super.beginRender(root)
                        
        try? pdf.beginDocument( )
        if resourcesPath != nil {
            pdf.setParameter(key: "SearchPath", value: resourcesPath!)
        }
        
        defaultFont = (try? pdf.loadFont(name: "SF-Compact-Text-Regular", encoding: "winansi", options: "embedding") ) ?? -1
        defaultFontBold = (try? pdf.loadFont(name: "SF-Compact-Text-Bold", encoding: "winansi", options: "embedding") ) ?? -1
    }
    
    public override func endRender() {
        super.endRender()
        
        pdf.endDocument()
        
        renderData = pdf.pdfData()
    }
    
    public override func output() -> Data {
        return renderData
    }
    
    public override func beginContainer(_ container: Container) {
        super.beginContainer(container)
        
        if container is A4 {
            pdf.beginPage(options: "width=a4.width height=a4.height")
            pdf.setFont(defaultFont, size: defaultFontSize)
            offsetY = PDF.A4.height - 20
        }
        else if let table = container as? Table {
            let header = (table.header as! HStack).children as! [Text]
            
            let (r, g, b, _) = parse_color("#EAEAFD")
            for h in header {
                pdf.setColor(fstype: "fill", colorspace: "rgb", c1: r, c2: g, c3: b)
                pdf.rect(x: Double (h.absPosition().x), y: Double (offsetY - ( h.absPosition().y) - 3), width: Double( h.dimensions.width ), height: Double ( h.dimensions.height + 2) )
                pdf.fill()
                pdf.setColor(fstype: "fill", colorspace: "rgb", c1: 0.0)
                
                h.render( self )
            }
            
//            /* thick gray line */
//            pdf.setColor(fstype: "stroke", colorspace: "gray", c1: 0.5)
//            pdf.setLineWidth(width: 1)
//            let x = table.absPosition().x
//            let y = offsetY - ( table.absPosition().y + table.header!.dimensions.height ) + 6
//            pdf.moveTo(x: Double ( x ), y: Double ( y ) )
//            pdf.lineTo(x: Double ( x + table.dimensions.width ), y: Double ( y ) )
//            pdf.stroke()


            for row in table.body.children {
                for col in (row as! HStack).children {
                    col.render( self )
                }
            }
        }
        else {
            if container.bg_color != nil {
                let (r,g,b, _) = parse_color(container.bg_color!)
                pdf.setColor(fstype: "fill", colorspace: "rgb", c1: r, c2: g, c3: b)
                pdf.rect(x: Double (container.absPosition().x), y: Double (offsetY - ( container.absPosition().y) - 15 ), width: Double( container.dimensions.width ), height: Double ( container.dimensions.height) )
                pdf.fill()
                pdf.setColor(fstype: "fill", colorspace: "rgb", c1: 0.0)
            }
        }

    }
    
    public override func endContainer(_ container: Container) {
        super.endContainer(container)
        if container is Page {
            pdf.endPage()
        }
    }
    
    override open func renderItem ( _ item: LayoutItem ) {
                
        
        
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
            opts.append("fontsize=\(defaultFontSize)")
            if text.fg_color != nil {
                let (r,g,b,_) = parse_color(text.fg_color!)
                opts.append("fillcolor={rgb \(r) \(g) \(b)}")
//                opts.append("matchbox={fillcolor={rgb 0.8 0.8 0.87} boxheight={fontsize descender}}")
            }
            let pos = text.absPosition()            
            try? pdf.fitTextLine(text: text.text, x: Double(pos.x), y: Double( offsetY - pos.y), options: opts.joined(separator: " "))
//            y -= 24
        }
        else if let img = item as? Image {
//            let line = String( repeating: "I", count: Int( img.dimensions.width ) )
//            for y in 0..<Int(img.dimensions.height) {
//                write( Int( img.x ), Int( img.y ) + y, line )
//            }
        }
    }
    
    override open func meassure ( _ item: LayoutItem ) -> Size {
        if let text = item as? Text {
            let w = pdf.stringWidth(text.text, font: defaultFont, size: defaultFontSize)
            return Size( width: Float( w ), height: Float (defaultFontSize) )
        }
        else if let sp = item as? Space {
//            let w = pdf.stringWidth(" ", font: defaultFont, size: defaultFontSize)
            return Size( width: Float (sp.a.rawValue) * 2, height: Float (sp.b.rawValue) * 2 )
        }
        else if let _ = item as? A4 {
            return Size( width: Float( PDF.A4.width - 10), height: PDF.A4.height - 20 )
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
    
}
