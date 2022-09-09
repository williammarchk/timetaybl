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
    
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    
    let textAttributes = [
        NSAttributedString.Key.font: NSFont.systemFont(ofSize: 6),
        NSAttributedString.Key.foregroundColor: NSColor.black,
        NSAttributedString.Key.paragraphStyle: style,
    ]
    
    let pageWidth = mediaBox.maxX - mediaBox.minX
    let pageHeight = mediaBox.maxY - mediaBox.minY

    let gc = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)!
    let nsgc = NSGraphicsContext(cgContext: gc, flipped: false)
    NSGraphicsContext.current = nsgc
    gc.beginPDFPage(nil); do {
        page.draw(with: .mediaBox, to: gc)
        
        for subject in timetable {
            for lesson in subject.lessons {
                let name = NSAttributedString(string: subject.name, attributes: textAttributes)
                let room = NSAttributedString(string: lesson.room, attributes: textAttributes)
                
                let minutesFromDayStart = (lesson.startTime.hour - 9) * 60 + lesson.startTime.minute
                
                let basePoint: CGPoint
                if lesson.day.week == 1 {
                    basePoint = CGPoint(
                        x: mediaBox.minX + 0.18 * pageWidth + 0.16 * CGFloat(lesson.day.day) * pageWidth,
                        y: mediaBox.maxY - pageHeight * 0.05 - CGFloat(minutesFromDayStart) * 0.000952 * pageHeight
                    )
                }
                else {
                    basePoint = CGPoint(
                        x: mediaBox.minX + 0.18 * pageWidth + 0.16 * CGFloat(lesson.day.day) * pageWidth,
                        y: mediaBox.midY - pageHeight * 0.05 - CGFloat(minutesFromDayStart) * 0.000952 * pageHeight
                    )
                }
                
                let nameBounds = name.size()
                let namePoint = CGPoint(x: basePoint.x - nameBounds.width / 2, y: basePoint.y - nameBounds.height)
                
                let roomBounds = room.size()
                let roomPoint = CGPoint(x: basePoint.x - roomBounds.width / 2, y: basePoint.y - nameBounds.height - roomBounds.height)
                
                gc.saveGState(); do {
                    gc.translateBy(x: namePoint.x, y: namePoint.y)
                    name.draw(at: .zero)
                }; gc.restoreGState()
                
                if subject.name != "Registration" {
                    gc.saveGState(); do {
                        gc.translateBy(x: roomPoint.x, y: roomPoint.y)
                        room.draw(at: .zero)
                    }; gc.restoreGState()
                }
            }
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
