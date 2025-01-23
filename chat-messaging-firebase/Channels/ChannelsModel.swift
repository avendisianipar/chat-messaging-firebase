//
//  Channel.swift
//  chat-messaging-firebase
//
//  Created by Avendi Sianipar on 23/01/25.
//

import FirebaseFirestore

struct ChannelsModel {
    let id: String?
    let name: String
    
    init(name: String) {
        id = nil
        self.name = name
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let name = data["name"] as? String else {
            return nil
        }
        
        id = document.documentID
        self.name = name
    }
}

// MARK: - DatabaseRepresentation
extension ChannelsModel: DBRepresentation {
    var representation: [String: Any] {
        var rep = ["name": name]
        
        if let id = id {
            rep["id"] = id
        }
        
        return rep
    }
}

// MARK: - Comparable
extension ChannelsModel: Comparable {
    static func == (lhs: ChannelsModel, rhs: ChannelsModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: ChannelsModel, rhs: ChannelsModel) -> Bool {
        return lhs.name < rhs.name
    }
}
