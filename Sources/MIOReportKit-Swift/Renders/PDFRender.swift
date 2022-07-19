//
//  PDFRender.swift
//  
//
//  Created by Javier Segura Perez on 27/1/22.
//

import Foundation
import PDFLib_Swift
import MIOCore

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif


public class PDFRender: RenderContext
{
    var pdf = PDF()
    var renderData:Data!
    
    var defaultFont:Int32 = -1
    var defaultFontBold:Int32 = -1
    var pageMargin: Margin = Margin( )
    
    var offsetY:Float = 0
    var pageOffsetY:Float = 0
    
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
        
//        defaultFont = (try? pdf.loadFont(name: "Arial", encoding: "winansi", options: "embedding") ) ?? -1
        defaultFont = (try? pdf.loadFont(name: "Helvetica", encoding: "winansi" ) ) ?? -1
        defaultFontBold = (try? pdf.loadFont(name: "Helvetica-Bold", encoding: "winansi") ) ?? -1
        
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
            pdf.setParameter(key: "stringformat", value: "utf8")
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
        defer {
            setColor( "#000000", "fillstroke")
        }
        
        let p = pos( item )
        let bg = item.style.bgColor
        let fg = item.style.fgColor
        let t = item.style.borderWidth.top
        let b = item.style.borderWidth.bottom
        let r = item.style.borderWidth.right
        let l = item.style.borderWidth.left
        
        if bg != nil {
            setColor( bg )
            pdf.rect( x: p.x
                    , y: p.y
                    , width:  Double( item.dimensions.width  )
                    , height: Double( item.dimensions.height ) )
            pdf.fill()
        }
                
        //TODO: Hack to render rounded rectangle only with all the border > 0
        if t > 0 && l > 0 && b > 0 && r > 0 && item.style.borderRadius > 0 {
            setColor( fg, "stroke" )
            let rdx = Double( item.style.borderRadius )
            pdf.moveTo( x: p.x + rdx, y: p.y)
            pdf.lineTo( x: p.x + Double( item.dimensions.width ) - rdx, y: p.y )
            pdf.arc   ( x: p.x + Double( item.dimensions.width ) - rdx, y: p.y + rdx, radius: rdx, alpha: 270, beta: 360 )
            pdf.lineTo( x: p.x + Double( item.dimensions.width ), y: p.y - rdx + Double( item.dimensions.height ) )
            pdf.arc   ( x: p.x + Double( item.dimensions.width ) - rdx , y: p.y - rdx + Double( item.dimensions.height ), radius: rdx, alpha: 0, beta: 90 )
            pdf.lineTo( x: p.x + rdx, y: p.y + Double( item.dimensions.height ) )
            pdf.arc   ( x: p.x + rdx, y: p.y - rdx + Double( item.dimensions.height ), radius: rdx, alpha: 90, beta: 180 )
            pdf.lineTo( x: p.x, y: p.y + rdx )
            pdf.arc   ( x: p.x + rdx, y: p.y + rdx, radius: rdx, alpha: 180, beta: 270 )
            
            pdf.stroke()
            return
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
        
    }
    
    func setColor ( _ color: String?, _ fstype: String = "fill" ) {
        if color == nil { return }
        
        let color = parse_color( color! )
        pdf.setColor(fstype: fstype, colorspace: "rgb", c1: color.r, c2: color.g, c3: color.b)
    }
    
    
    public func pos ( _ item: LayoutItem ) -> (x: Double, y: Double) {
        let abs_pos = item.absPosition( )
        
        return ( x: Double( abs_pos.x + pageMargin.left )
               , y: Double( offsetY - abs_pos.y - item.dimensions.height + pageMargin.top ) )
    }
    
    
    public override func endContainer(_ container: Container<LayoutItem>) {
        super.endContainer(container)
    }
    
    let _align:[String] = ["left", "center", "right"]
    func textAlignString( _ align: TextAlign ) -> String {
        return _align[ align.rawValue ]
    }
    func imageAlignString( _ align: ImageAlign ) -> String {
        return _align[ align.rawValue ]
    }

    
    override open func renderItem ( _ item: LayoutItem ) {
        rect( item )
        
        if clip( item ) {
            return
        }
        
        if let text = item as? Text {
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
            //opts.append( "margin=2" )
            let pos = self.pos( text )
            // Note => +4 = baseline?
            try? pdf.fitTextLine( text: text.text
                                , x: pos.x
                                , y: pos.y + 4
                                , options: opts.joined(separator: " "))
        }
        else if let img = item as? URLImage {
            let r = URLRequest( urlString: img.url )
            let data = try? MIOCoreURLDataRequest_sync( r )
            if data != nil {
                pdf.createPVF(filename: img.url, data: data!)
                if let image = try? pdf.loadImage(fileName: img.url) {
                    let pos = self.pos( img )
                    pdf.fitImage(image: image, x: pos.x, y: pos.y, options: "boxsize={\(item.dimensions.width) \(item.dimensions.height)} fitmethod=auto position={ \(imageAlignString ( img.align ) ) center }")
//                    pdf.fitImage(image: image, x: pos.x, y: pos.y, options: "boxsize={\(item.dimensions.width) \(item.dimensions.height)} fitmethod=auto")
                    pdf.closeImage( image: image )
                }
            }
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
    
    
    let fontSize:[Double] = [0, 2, 4, 6, 8, 10, 14, 18, 30]
    func fontSizeInPoints( _ size:ItemSize ) -> Double { return fontSize[ size.rawValue ] }
    var defaultFontSize:Double { get { return fontSizeInPoints (.s ) } }
    
    override open func meassure ( _ item: LayoutItem ) -> Size {
        if let text = item as? Text {
            let fs = fontSizeInPoints( text.text_size )
            let w = pdf.stringWidth("\(text.text)", font: text.bold ? defaultFontBold : defaultFont, size: fs )
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
