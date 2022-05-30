//
//  TodoItem.swift
//  core-data-realm
//
//  Created by Marcio Alico on 5/27/22.
//

import Foundation

struct TodoItem: Encodable, Decodable {
    let title: String
    var done: Bool = false
}
