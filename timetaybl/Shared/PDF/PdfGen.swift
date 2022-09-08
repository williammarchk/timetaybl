//
//  PdfGen.swift
//  timetaybl (macOS)
//
//  Created by MACKE, Mats on 07.09.22.
//

import Foundation
import PDFKit
import SwiftUI

struct PDFViewer: NSViewRepresentable {
    let pdfView = PDFView()
    
    func makeNSView(context: NSViewRepresentableContext<PDFViewer>) -> PDFViewer.NSViewType {
        // Create a `PDFView` and set its `PDFDocument`.
        return pdfView
    }
    
    func displayTimeTable(timetable: TimeTable) {
        pdfView.document = PDFDocument(data: PDF(timetable: timetable))
    }

    func updateNSView(_ uiView: NSView, context: NSViewRepresentableContext<PDFViewer>) {
        // Nothing to update
    }
}

func PDF(timetable: TimeTable) -> Data {
    return drawOnPdf(emptyPdf: getEmptyPdf(), timetable: timetable)
}

func drawOnPdf(emptyPdf: Data, timetable: TimeTable) -> Data {
    let data = NSMutableData()
    let consumer = CGDataConsumer(data: data)!
    
    let pdfdoc = PDFDocument(data: emptyPdf)!
    let page: PDFPage = pdfdoc.page(at: 0)!
    var mediaBox: CGRect = page.bounds(for: .mediaBox)

    let gc = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)!
    let nsgc = NSGraphicsContext(cgContext: gc, flipped: false)
    NSGraphicsContext.current = nsgc
    gc.beginPDFPage(nil); do {
        page.draw(with: .mediaBox, to: gc)
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        for (index, subject) in timetable.enumerated() {
            let richText = NSAttributedString(string: subject.name, attributes: [
                NSAttributedString.Key.font: NSFont.systemFont(ofSize: 28),
                NSAttributedString.Key.foregroundColor: NSColor.blue,
                NSAttributedString.Key.paragraphStyle: style
            ])
            
            let i = CGFloat(index)

            let richTextBounds = richText.size()
            let point = CGPoint(x: mediaBox.midX - richTextBounds.width / 2, y: mediaBox.maxY - i * richTextBounds.height)
            
            gc.saveGState(); do {
                gc.translateBy(x: point.x, y: point.y)
                richText.draw(at: .zero)
            }; gc.restoreGState()
        }

    }; gc.endPDFPage()
    NSGraphicsContext.current = nil
    gc.closePDF()
    
    return data as Data
}

func getEmptyPdf() -> Data {
    if let fileURL = Bundle.main.url(forResource: "empty", withExtension: "pdf") {
        if let fileContents = try? Data(contentsOf: fileURL) {
            return fileContents
        }
    }
    return Data()
}
