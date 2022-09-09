//
//  ContentView.swift
//  Shared
//
//  Created by MARCH-KRAMER, William on 26.08.22.
//

import SwiftUI
import CoreData
import PDFKit
import GoogleApi


//struct ContentView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
//
//    var body: some View {
//        List {
//            ForEach(items) { item in
//                Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//            }
//            .onDelete(perform: deleteItems)
//        }
//        .toolbar {
//            #if os(iOS)
//            EditButton()
//            #endif
//
//            Button(action: addItem) {
//                Label("Add Item", systemImage: "plus")
//            }
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//}
//





struct ContentView: View {
    var googleLoader = GoogleapiNewDataLoader("{\"installed\":{\"client_id\":\"184149248061-u0pqmh6q7gkheoffs3pelf111qhdaaqk.apps.googleusercontent.com\",\"project_id\":\"timetable-361614\",\"auth_uri\":\"https://accounts.google.com/o/oauth2/auth\",\"token_uri\":\"https://oauth2.googleapis.com/token\",\"auth_provider_x509_cert_url\":\"https://www.googleapis.com/oauth2/v1/certs\",\"client_secret\":\"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\",\"redirect_uris\":[\"urn:ietf:wg:oauth:2.0:oob\"]}}")
    
    let authURL: String
    
    init() {
        let tmp = googleLoader?.getAuthURLstring()
        
        authURL = tmp!
    }
    
    @State private var timetable: TimeTable = []
    
    @State private var authCode: String = ""
    
    @State private var pdfViewer = PDFViewer()
    
    @State private var pdfRendered = false
    
    var body: some View {
        if !pdfRendered {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    ScrollView(.vertical) {
                        VStack {
                            Spacer()
                            Text("Format Your Own Timetable!").font(.system(size: 35))
                            Spacer()
                            
                            Button(action: {
                                if let url = URL(string: authURL) {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                HStack() {
                                    
                                    Image("google")
                                        .renderingMode(.original)
                                        .resizable()
                                        //.aspectRatio(contentMode: .fit)
                                        .frame(width: 70, height: 70)
                                        //.padding([.leading], 5)
                                    
                                    Text("Sign in with Google")
                                        .font(.system(size: 36))
                                        .padding()
                                        .font(.system(.title, design: .rounded))
                                        //.padding([.leading], -5)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .background(LinearGradient(gradient: .init(colors: [Color("Color-2"), Color("Color-1")]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(20)
                            .frame(width: 500, height: 40, alignment: .center)
                            .padding(.bottom, 20)
                            .padding(.top, 50)

                            TextField(
                                "Enter Authorization Code",
                                text: $authCode,
                                onCommit: {
                                    googleLoader?.getClient(authCode)
                                    let events = googleLoader?.getEvents()
                                    // print(events!)
                                    timetable = parseJSON(json: events!)
                                    
                                    pdfViewer.displayTimeTable(timetable: timetable)
                                    pdfRendered = true
                                }
                            )
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                            Spacer()
                            ForEach(timetable, id: \.self) {subject in
                                Text(subject.name)
                            }
                        }
                    }
                }
            }
        
            if pdfRendered {
                pdfViewer
            }
        }
    }
                    
            

struct EditSubject: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .opacity(0.8)
                .border(Color.black)
            HStack {
                VStack {
                    Text("Subject Name")
                }
                VStack {
                    Text("Subject Color ")
                }
                VStack {
                    Text("Room")
                }
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
