//
//  File.swift
//  
//
//  Created by David Trallero on 22/06/2021.
//

import Foundation

class Text: LayoutItem {
    var text: String
    
    init ( _ text: String, _ id: String? = nil ) {
        self.text = text
        super.init( 0, id )
    }
    
    override func setValue(_ value: Any) throws {
        if let new_text = value as? String {
            text = new_text
        }
    }
}

class TextBox: LayoutItem {
    
}
