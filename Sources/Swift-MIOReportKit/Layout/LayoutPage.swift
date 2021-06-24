//
//  File.swift
//  
//
//  Created by David Trallero on 22/06/2021.
//

import Foundation

public class Page: FooterHeaderContainer
{
    public init ( _ size: Size ) {
        super.init()
        self.dimensions = size
    }
} // even / odd header
// render => is first child of page


public class A4: Page {
    init ( ) { super.init( Size( width: 210, height: 297 ) ) }
}
