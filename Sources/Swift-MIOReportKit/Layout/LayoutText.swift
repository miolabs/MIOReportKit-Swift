//
//  File.swift
//  
//
//  Created by David Trallero on 22/06/2021.
//

import Foundation

public class Text: LayoutItem {
    public var text: String
    
    public init ( _ text: String, flex: Int = 0, id: String? = nil ) {
        self.text = text
        super.init( flex, id )
    }
    
    override func setValue(_ value: Any) throws {
        if let new_text = value as? String {
            text = new_text
        }
    }
}

class TextBox: LayoutItem {
    
}
