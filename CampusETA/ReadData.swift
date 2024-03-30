//
//  ReadData.swift
//  CampusETA
//
//  Created by Keshav Varadarajan on 3/29/24.
//

import Foundation

struct Coordinates: Codable {
    var lat:Float
    var lng:Float
}

struct Stop: Codable {
    
    var stop_id:String
    var location:Coordinates
    var name:String
    var direction:[String]
}


//struct School : Codable {
//    
//    var agency_id:String
//    var C1_ID:String
//    var C1_stops:[Stop]
//    var Swift_ID:String
//    var Swift_stops:[Stop]
//    var C1_Swift_ID:String
//    var C1_Swift_stops:[Stop]
//    
//    var East:String
//    var West:String
//    var Swift_weekday:String
//    var Swift_west:String
//    var Swift_east:String
//    
//}

class ReadData: ObservableObject {
    
    @Published var weekday_stops = [Stop]()
    @Published var weekend_stops = [Stop]()
    
    init() {
        loadJsonData()
        
        
    }
    
    func loadJsonData() {
        guard let urlWeekday = Bundle.main.url(forResource:"weekday_stops", withExtension: "json")
            else {
                print("Json file not found")
                return
            }
        
        guard let urlWeekend = Bundle.main.url(forResource:"weekend_stops", withExtension: "json")
            else {
                print("Json file not found")
                return
            }
        
        let jsonDataWeekday = try? Data(contentsOf: urlWeekday)
        let jsonDataWeekend = try? Data(contentsOf: urlWeekend)
        
//        if let JSONString = String(data: jsonData!, encoding: String.Encoding.utf8) {
//           print(JSONString)
//        }
        
        let weekday_stops = try? JSONDecoder().decode([Stop].self, from: jsonDataWeekday!)
        let weekend_stops = try? JSONDecoder().decode([Stop].self, from: jsonDataWeekend!)
        
        self.weekday_stops = weekday_stops!
        self.weekend_stops = weekend_stops!
        
//        self.schools = schools!
    }
}


