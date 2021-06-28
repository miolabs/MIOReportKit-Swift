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
            write( Int( text.x ), Int( text.y ), text.text )
        } else if let img = item as? Image {
            let line = String( repeating: "I", count: Int( img.dimensions.width ) )
            for y in 0..<Int(img.dimensions.height) {
                write( Int( img.x ), Int( img.y ) + y, line )
            }
        }
    }

    
    override func beginContainer ( _ container: Container ) {
        if let table = container as? Table {
            var local_y: Int = 0
            var local_x: Int = 0

            func local_write ( _ str: String ) {
                write( Int(table.x) + local_x, Int(table.y) + local_y, str )
                local_x += str.count
            }
            
            func pad ( _ str: String, _ length: Int ) {
                local_write( String( repeating: " ", count: max( 0, length - str.count ) ) )
            }
            
            func draw_border ( ) {
                local_x = 0
                local_write( "+" )
                for col in table.tableHeader().children {
                    local_write( "-" )
                    local_write( String( repeating: "-", count: Int( col.dimensions.width ) ) )
                    local_write( "-+" )
                }
                local_x = 0
                local_y += 1
            }
            
            draw_border( )
            local_write( "|" )
            
            for i in table.cols_key.indices {
                let col = table.tableHeaderCols()[ i ]
                local_write( " " )
                pad( col.text, Int( col.dimensions.width ) )
                local_write( col.text )
                local_write( " |" )
            }
            
            for i in table.body.children.indices {
                let row = table.body.children[ i ]
                local_y += Int( row.dimensions.height )
                draw_border( )
                local_write( "|" )
                for j in (row as! HStack).children.indices {
                    let col = (row as! HStack).children[ j ] as! Text
                    local_write( " " )
                    pad( col.text, Int( col.dimensions.width ) )
                    local_write( col.text )
                    local_write( " |" )
                }
            }
            
            local_y += Int( table.body.children.last?.dimensions.height ?? 0 )
            draw_border( )
        }
    }


    func write ( _ x: Int, _ y: Int, _ str: String ) {
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
