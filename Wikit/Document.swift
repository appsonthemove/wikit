//
//  Document.swift
//  Wikit
//
//  Created by Matthew Kennard on 10/08/2020.
//  Copyright © 2020 Apps On The Move Limited. All rights reserved.
//

import UIKit

class Document: UIDocument {
    var html: Data? = nil
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        if let html = html {
            return html
        } else {
            return Data()
        }
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let userContent = contents as? Data {
            html = userContent
        }
    }
}

