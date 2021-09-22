//
//  File.swift
//  
//
//  Created by David Trallero on 22/06/2021.
//

import Foundation

public struct TableCol {
    var key: String
    var name: Text
    
    public init ( _ key: String, _ name: Text ) {
        self.key  = key
        self.name = name
    }
}

// INDENTATION
// indentRow( X, level )
public class Table: FooterHeaderContainer {
    var cols_key: [String]
    var body: VStack
    var max_col: [Float]
    var max_row: [Float]
    public var border: Bool
    public var hideHeader: Bool

    public init ( flex: Int = 0, id: String? = nil ) {
        cols_key = []
        body     = VStack( )
        max_col  = []
        max_row  = []
        border   = true
        hideHeader = false
        
        super.init( header: HStack( ), footer: HStack( ) )
        self.flex = flex
        self.id = id
    }

    
    public func tableHeaderCols ( ) -> [Text] {
        return tableHeader().children as! [Text]
    }

    public func tableHeader ( ) -> HStack {
        return header as! HStack
    }
    

    public func addColumn ( _ key: String, _ name: String, flex: Int = 0, id: String? = nil, align: TextAlign = .left, wrap: TextWrap = .noWrap ) {
        cols_key.append( key )
        tableHeader( ).add( Text( name, flex: flex, id: id, align: align, wrap: wrap ) )
    }

    public func addRow ( _ dict: [String:Any], bold: Bool = false, italic: Bool = false ) {
        let table_row = HStack( )
        
        for i in cols_key.indices {
            let key = cols_key[ i ]
            let col = tableHeaderCols()[ i ]
            
            table_row.add( Text( "\(dict[ key ] ?? "")", bold: bold, italic: italic, align: col.align, wrap: col.wrap ) )
        }
        
        body.add( table_row )
    }
    
    public func addRow ( _ row: HStack ) {
        body.add( row )
    }
    
    override func meassure ( _ context: RenderContext ) {
        var sz = Size( )
        
        header!.meassure( context )
        footer!.meassure( context )
        body.meassure( context )

        var max_height: Float = 0

        for c in tableHeaderCols( ) {
            max_col.append( c.size.width )

            if max_height < c.size.height {
                max_height = c.size.height
            }
        }
        max_row.append( max_height )

        for row in body.children {
            max_height = 0
            for i in (row as! HStack).children.indices {
                let c = (row as! HStack).children[ i ]

                if max_col[ i ] < c.size.width {
                    max_col[ i ] = c.size.width
                }

                if max_height < c.size.height {
                    max_height = c.size.height
                }
            }

            max_row.append( max_height )
        }

        for i in tableHeaderCols().indices {
            tableHeaderCols()[ i ].size = Size( width: max_col[ i ], height: max_row[ 0 ] )
        }

        let hor_border_size = Float( cols_key.count + 1 )
        let ver_border_size = Float( body.children.count + 2 )

        sz = sz.join( header!.size, SizeGrowDirection.both)
        sz = sz.join( body.size, SizeGrowDirection.both)

        size = Size( width:  hor_border_size + max_col.reduce( 0 ){ sum,col in sum + col }
                   , height: ver_border_size + max_row.reduce( 0 ){ sum,row in sum + row }
                   )
    }
    
    override func setDimension(_ dim: Size) {
        // var header_dim = Size( )
        for i in tableHeaderCols().indices {
            let col = tableHeaderCols()[ i ]
            col.size = Size( width: max_col[ i ], height: max_row[ 0 ] )
            
            // tableFooterCols()[ i ].setDimension( Size( width: max_col[ i ], height: footer.size.height ) )
            
            // header_dim = header_dim.join( col.dimensions, .horizontal )
        }
        header!.setDimension( dim )
        // header!.dimensions = header_dim

        // footer!.setDimension(dim)
        
        var body_sz = Size( )
        for row in body.children {
            var sz = Size( )
            for index in cols_key.indices {
                let col = tableHeaderCols()[ index ]
                let c = (row as! HStack).children[ index ]
                c.setDimension( Size( width: col.dimensions.width, height: c.size.height))
                sz = sz.join( c.dimensions, .horizontal )
            }
            row.dimensions = sz
            body_sz = body_sz.join( row.dimensions, .vertical )
        }
        
        body.dimensions = body_sz
        
        dimensions = header!.dimensions
                        .join( body.dimensions, .vertical )
                        .join( footer!.dimensions, .vertical )
    }
    
    override func setCoordinates(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y

        var local_x: Float = x + 1 // 1 = border size
        var local_y: Float = y + 1
        
        for i in cols_key.indices {
            let col = tableHeaderCols()[ i ]
            col.setCoordinates( local_x, local_y )
            local_x += col.dimensions.width
            local_x += 1
        }

        local_y += header!.dimensions.height
        
        for i in body.children.indices {
            let row = body.children[ i ]
            local_y += 1 // border
            local_x = x
            local_x += 1 // border

            for j in (row as! HStack).children.indices {
                let col = (row as! HStack).children[ j ]
                col.setCoordinates( local_x, local_y )
                local_x += col.dimensions.width
                local_x += 1 // border
            }
            
            local_y += row.dimensions.height
        }
    }
}
