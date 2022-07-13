//
//  File.swift
//  
//
//  Created by David Trallero on 22/06/2021.
//

import Foundation


public class Image: LayoutItem {
    public var data: Data
    public var imgSize: Size
    
    public init ( data: Data, width: Float, height: Float, flex: Int = 0, id: String? = nil ) {
        self.data = data
        self.imgSize = Size( width: width, height: height )
        super.init( flex, id)
    }
    
    override open func meassure ( _ context: RenderContext ) {
        size = self.imgSize
    }
    
    override func setValue ( _ value: Any ) throws {
        if let new_data = value as? Data {
            data = new_data
        }
        
        // TODO: throw xxx( "the url is not an string: \(value)" )
    }
    
    override open func shallowCopy ( ) -> LayoutItem {
        let ret = Image( data: data, width: imgSize.width, height: imgSize.height )
        ret.copyValues( self )
        
        return ret
    }
}


public class URLImage: LayoutItem {
    public var url: String
    public var imgSize: Size
    
    public init ( url: String, width: Float, height: Float, flex: Int = 0, id: String? = nil ) {
        self.url = url
        self.imgSize = Size( width: width, height: height )
        super.init( )
        self.flex = flex
        self.id = id
    }
    
    override open func meassure ( _ context: RenderContext ) {
        size = self.imgSize
    }
    
    override func setDimension ( _ dim: Size ) {
        dimensions = dim
    }
    
    override func setValue ( _ value: Any ) throws {
        if let new_url = value as? String {
            url = new_url
        }
        
        // TODO: throw xxx( "the url is not an string: \(value)" )
    }
    
    override open func shallowCopy ( ) -> LayoutItem {
        let ret = URLImage( url: url, width: imgSize.width, height: imgSize.height )
        ret.copyValues( self )
        
        return ret
    }
}
