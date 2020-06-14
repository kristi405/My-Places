//
//  StorageManager.swift
//  My Places
//
//  Created by kris on 28/05/2020.
//  Copyright © 2020 kris. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObjekt(place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
