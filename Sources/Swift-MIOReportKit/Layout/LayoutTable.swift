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
    var border: Bool

    public init ( _ flex: Int = 0, _ id: String? = nil ) {
        cols_key = []
        body     = VStack( )
        max_col  = []
        max_row  = []
        border   = true
        
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
    

    public func addColumn ( _ key: String, _ name: String, flex: Int = 0, id: String? = nil ) {
        cols_key.append( key )
        tableHeader( ).add( Text( name, flex: flex, id: id ) )
    }

    public func addRow ( _ dict: [String:Any] ) {
        let table_row = HStack( )
        
        for key in cols_key {
            table_row.add( Text( "\(dict[ key ] ?? "")" ) )
        }
        
        body.add( table_row )
    }
    
    public func addRow ( _ row: HStack ) {
        body.add( row )
    }
    
    override func meassure ( _ context: RenderContext ) {
        var sz = Size( )
        
        header!.meassure( context )
        sz = sz.join( header!.size, SizeGrowDirection.both)
//        var max_height: Float = 0
//
//        for c in cols {
//            c.name.meassure( context )
//            max_col.append( c.name.size.width )
//
//            if max_height < c.name.size.height {
//                max_height = c.name.size.height
//            }
//        }


        body.meassure( context )
        sz = sz.join( body.size, SizeGrowDirection.both)
        
//        for row in body.children {
//            row.meassure( context )
//            sz = sz.join( row.size, SizeGrowDirection.both)
//        }

//        for row in body {
//            max_height = 0
//            for i in row.indices {
//                let c = row[ i ]
//                c.meassure( context )
//
//                if max_col[ i ] < c.size.width {
//                    max_col[ i ] = c.size.width
//                }
//
//                if max_height < c.size.height {
//                    max_height = c.size.height
//                }
//            }
//
//            max_row.append( max_height )
//        }
        
        let hor_border_size = Float( cols_key.count + 1 )
        let ver_border_size = Float( body.children.count + 2 )

        size = Size( width:  hor_border_size + sz.width // max_col.reduce( 0 ){ sum,col in sum + col }
                   , height: ver_border_size + sz.height // max_row.reduce( 0 ){ sum,row in sum + row }
                   )
    }
    
    override func setDimension(_ dim: Size) {
        header!.setDimension(dim)
        footer?.setDimension(dim)
        
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
    }
}
