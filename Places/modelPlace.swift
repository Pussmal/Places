//
//  modelPlace.swift
//  Places
//
//  Created by Алексей Моторин on 04.04.2022.
//

import RealmSwift

class Places: Object {
    
    @objc dynamic var namePlace: String = ""
    @objc dynamic var locationPlace: String?
    @objc dynamic var typePlace: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    @objc dynamic var raiting = 0.0
 
    convenience init(name: String, location: String?, type: String?, image: Data?, raiting: Double) {
        self.init()
        namePlace = name
        locationPlace = location
        typePlace = type
        imageData = image
        self.raiting = raiting
    }
        
}




