//
//  Document.swift
//  Twiki
//
//  Created by Matthew Kennard on 10/08/2020.
//  Copyright © 2020 Apps On The Move Limited. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

