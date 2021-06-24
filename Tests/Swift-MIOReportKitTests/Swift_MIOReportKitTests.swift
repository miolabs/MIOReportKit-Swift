    import XCTest
    @testable import Swift_MIOReportKit

    final class Swift_MIOReportKitTests: XCTestCase {
        func testText ( ) throws {
            let page = A4( )
            let text = Text( "Hello World", "ID1" )
            let layout = Layout( page )
            
            page.add( text )
            
            XCTAssertNotNil( layout.elementsByID[ "ID1" ] )
            
            let render = HTMLRender( )
            
            layout.render( render )
            
            XCTAssertEqual( String( data: render.output( ), encoding: .utf8 ), """
<div class="page a4">
<div>Hello World</div>
</div>
""" )
            
            render.reset( )
            try layout.setValue( forID: "ID1", value: "Bye bye World" )
            layout.render( render )

            XCTAssertEqual( String( data: render.output( ), encoding: .utf8 ), """
<div class="page a4">
<div>Bye bye World</div>
</div>
""" )
        }
        
        func testHstack ( ) throws {
            let render = HTMLRender( )
            let page   = A4( )
            let row    = HStack( )
            let layout = Layout( page )

            row.add( Text( "Hello ", "ID1" ) )
            row.add( Text( "Word", "ID2" ) )

            page.add( row )

            XCTAssertNotNil( layout.elementsByID[ "ID1" ] )
            XCTAssertNotNil( layout.elementsByID[ "ID2" ] )
            try layout.setValue( forID: "ID2", value: "World!!!" )
            
            layout.render( render )
            
            XCTAssertEqual( String( data: render.output( ), encoding: .utf8 ), """
<div class="page a4">
<div class="row">
<div>Hello </div>
<div>World!!!</div>
</div>
</div>
""" )
        }

        
        func testVstack ( ) throws {
            let render = HTMLRender( )
            let page   = A4( )
            let row    = VStack( )
            let layout = Layout( page )

            row.add( Text( "Hello ", "ID1" ) )
            row.add( Text( "World", "ID2" ) )

            page.add( row )
            
            layout.render( render )
            
            XCTAssertEqual( String( data: render.output( ), encoding: .utf8 ), """
<div class="page a4">
<div class="col">
<div>Hello </div>
<div>World</div>
</div>
</div>
""" )
        }

        
        func testImage ( ) throws {
            let render = HTMLRender( )
            let page   = A4( )
            let img    = Image( url: "dual-link.com/img.jpg", width: 200, height: 100 )
            let layout = Layout( page )
            
            page.add( img )
            
            layout.render( render )
            
            XCTAssertEqual( String( data: render.output( ), encoding: .utf8 ), """
<div class="page a4">
<img src="dual-link.com/img.jpg" width="200" height="100"/>
</div>
""" )            
        }
        
        func testText_TR ( ) throws {
            let page = Page( Size( width: 80, height: 0 ) )
            let text = Text( "Hello World" )
            let layout = Layout( page )
            
            page.add( text )
            
            let render = TextRender( )
            
            layout.render( render )
            
            XCTAssertEqual( String( data: render.output( ), encoding: .utf8 ), """
Hello World
""" )
        }

        func testHStack_TR ( ) throws {
            let render = TextRender( )
            let page   = Page( Size( width: 80, height: 0 ) )
            let row    = HStack( )
            let layout = Layout( page )

            row.add( Text( "Hello " ) )
            row.add( Text( "World" ) )
            page.add( row )
            
            layout.render( render )
            
            XCTAssertEqual( String( data: render.output( ), encoding: .utf8 ), """
Hello World
""" )
        }

        func testVStack_TR ( ) throws {
            let render = TextRender( )
            let page   = Page( Size( width: 80, height: 0 ) )
            let row    = VStack( )
            let layout = Layout( page )

            row.add( Text( "Hello" ) )
            row.add( Text( "World" ) )
            page.add( row )
            
            layout.render( render )
            
            XCTAssertEqual( String( data: render.output( ), encoding: .utf8 ), """
Hello
World
""" )
        }

        func testVStackFlex_TR ( ) throws {
            let render = TextRender( )
            let page   = Page( Size( width: 40, height: 0 ) )
            let row    = HStack( 1 )
            let layout = Layout( page )

            row.add( Text( "Hello" ) )
            row.add( LayoutItem( 1 ) )
            row.add( Text( "World" ) )
            page.add( row )
            
            layout.render( render )
            
            XCTAssertEqual( String( data: render.output( ), encoding: .utf8 ), """
Hello                              World
""" )
        }

        func testVStackFlex3_TR ( ) throws {
            let render = TextRender( )
            let page   = Page( Size( width: 40, height: 0 ) )
            let row    = HStack( 1 )
            let layout = Layout( page )

            row.add( LayoutItem( 1 ) )
            row.add( Text( "Hello" ) )
            row.add( LayoutItem( 2 ) )
            row.add( Text( "World" ) )
            row.add( LayoutItem( 1 ) )
            page.add( row )
            
            layout.render( render )
            
            XCTAssertEqual( String( data: render.output( ), encoding: .utf8 ), """
       Hello               World
""" )
        }

        
        func testImage_TR ( ) throws {
            let render = TextRender( )
            let page   = Page( Size( width: 40, height: 0 ) )
            let row    = HStack( 1 )
            let layout = Layout( page )

            row.add( LayoutItem( 1 ) )
            row.add( Image( url: "Hello", width: 20, height: 3 ) )
            row.add( LayoutItem( 1 ) )
            page.add( row )
            
            layout.render( render )
            
            XCTAssertEqual( String( data: render.output( ), encoding: .utf8 ), """
          IIIIIIIIIIIIIIIIIIII
          IIIIIIIIIIIIIIIIIIII
          IIIIIIIIIIIIIIIIIIII
""" )
        }
}
