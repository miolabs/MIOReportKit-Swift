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
    var defaultFontSize: Double = 10
    
    var offsetY:Float = 0
            
    public override func beginRender(_ root: Container) {
        super.beginRender(root)
                        
        try? pdf.beginDocument( )
        
        defaultFont = (try? pdf.loadFont(name: "SF Compact Text Regular", encoding: "winansi", options: "embedding") ) ?? -1
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
            offsetY = PDF.A4.height - 20
            pdf.setFont(defaultFont, size: defaultFontSize)
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
            pdf.setGraphicOptions( text.fg_color != nil ? "fillcolor={\(text.fg_color!)}" : "fillcolor=black")
            pdf.fitTextLine(text: text.text, x: Double(text.x), y: Double(offsetY - text.y))
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
            return Size( width: Float( w ), height: 24 )
        }
        else if let _ = item as? Space {
            let w = pdf.stringWidth(" ", font: defaultFont, size: defaultFontSize)
            return Size( width: Float( w ), height: 24 )
        }
        else if let _ = item as? A4 {
            return Size( width: Float( PDF.A4.width ), height: PDF.A4.height )
        }
            
        return super.meassure( item )
    }
    
}
