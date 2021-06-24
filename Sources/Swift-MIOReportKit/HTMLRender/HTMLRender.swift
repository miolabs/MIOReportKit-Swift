//
//  File.swift
//  
//
//  Created by David Trallero on 23/06/2021.
//

import Foundation

public class HTMLRender: RenderContext {
    var m_output: [String] = []
    
    override func renderItem ( _ item: LayoutItem ) {
        if let text = item as? Text {
            m_output.append( "<div>\(text.text)</div>")
        } else if let img = item as? Image {
            m_output.append( "<img src=\"\(img.url)\" width=\"\(Int(img.dimensions.width))\" height=\"\(Int(img.dimensions.height))\"/>")
        }
    }
    
    func reset ( ) {
        m_output = []
    }
    
    override func output() -> Data {
        return m_output.joined(separator: "\n").data( using: .utf8 )!
    }
    
    
    override func beginContainer ( _ container: Container ) {
        if container is A4 {
            m_output.append( "<div class=\"page a4\">" )
        } else if container is HStack {
            m_output.append( "<div class=\"row\">" )
        } else if container is VStack {
            m_output.append( "<div class=\"col\">" )
        } else {
            m_output.append( "<div>" )
        }
        super.beginContainer( container )
    }
    
    override func endContainer ( ) {
        m_output.append( "</div>" )
        super.endContainer()
    }
}
