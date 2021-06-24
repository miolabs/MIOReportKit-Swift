//
//  File.swift
//  
//
//  Created by David Trallero on 23/06/2021.
//

import Foundation

public class TextRender: RenderContext {
    var lines: [String] = []
        
    override func renderItem ( _ item: LayoutItem ) {
        if let text = item as? Text {
            write( text.x, text.y, text.text )
        } else if let img = item as? Image {
            let line = String( repeating: "I", count: Int( img.dimensions.width ) )
            for y in 0..<Int(img.dimensions.height) {
                write( img.x, img.y + Float( y ), line )
            }
        }
    }

    func write ( _ decX: Float, _ decY: Float, _ str: String ) {
        let x = Int( decX )
        let y = Int( decY )
        
        while lines.count <= y { lines.append( "" ) }
        
        while lines[ y ].count < x {
            lines[ y ] += " "
        }

        let num_char_to_delete = min( str.count, lines[ y ].count - x )
        let insert_index = lines[ y ].index( lines[ y ].startIndex, offsetBy: x )

        lines[ y ].insert( contentsOf: str, at: insert_index )

        let endIndex = lines[ y ].index( insert_index, offsetBy: str.count )

        for _ in 0..<num_char_to_delete {
            lines[ y ].remove( at: endIndex )
        }
    }
    
    func reset ( ) {
        x = 0
        y = 0
        lines = [ "" ]
    }
    
    override func beginRender ( _ root: Container ) {
        reset()
        super.beginRender( root )
    }
    
    
    override func meassure ( _ item: LayoutItem ) -> Size {
        if let text = item as? Text {
            return Size( width: Float( text.text.count ), height: 1 )
        }
        
        return Size( width: 0, height: 0 )
    }
    
    override func output ( ) -> Data {
        return lines.joined( separator: "\n" ).data( using: .utf8 )!
    }
}
