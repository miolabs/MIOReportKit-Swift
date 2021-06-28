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
        } else {
            m_output.append( "<div class=\"d-flex\" style=\"flex:\(item.flex)\"></div>")
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
        } else if let table = container as? Table {
            let header = (table.header as! HStack).children as! [Text]
            let COLS = header.map{ "<col style=\"width: \($0.dimensions.width);\">" }.joined(separator: "\n")
            
            let HEADER = header.map{ "<th class=\"table-cell\">\( $0.text)</th>" }.joined(separator: "\n")
            
            let HIDDEN_ROW = header.map{ _ in "<td style=\"padding: 0px; border: 0px; height: 0px;\"><div style=\"height: 0px; overflow: hidden;\">&nbsp;</div></td>" }.joined(separator: "\n")
            
            let DATA = table.body.children.map{ row in
                let cols = (row as! HStack).children.map{ "<td class=\"table-cell\"><span class=\"table-row-indent\" style=\"padding-left: 0px;\"></span>\(($0 as! Text).text)</td>" }
                
                return "<tr data-row-key=\"0\" class=\"table-row\">" + cols.joined( separator: "\n" ) + "</tr>"
            }.joined(separator: "\n")
            
            let table = """
<div class="table-fixed-header">
  <div class="table-container">
    <div class="table-header">
        <table>
            <colgroup>
{{COLS}}
            </colgroup>
            <thead class="table-thead">
                <tr>
{{HEADER}}
                </tr>
            </thead>
        </table>
    </div>
    <div class="table-body" style="overflow-y: scroll; max-height: 240px;">
        <table>
            <colgroup>
{{COLS}}
            </colgroup>
            <tbody class="table-tbody">
                <tr aria-hidden="true" class="table-measure-row" style="height: 0px; font-size: 0px;">
{{HIDDEN_ROW}}
                </tr>
{{DATA}}
            </tbody>
        </table>
    </div>
  </div>
"""
            m_output.append(
                table.replacingOccurrences(of: "{{COLS}}", with: COLS )
                     .replacingOccurrences(of: "{{HEADER}}", with: HEADER )
                     .replacingOccurrences(of: "{{HIDDEN_ROW}}", with: HIDDEN_ROW )
                     .replacingOccurrences(of: "{{DATA}}", with: DATA )
                )
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
