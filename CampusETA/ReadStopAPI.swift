//
//  ReadStopAPI.swift
//  CampusETA
//
//  Created by Keshav Varadarajan on 3/30/24.
//

import Foundation

struct Bus: Codable {
    var route_id:String
    var vehicle_id:String
    var arrival_at:String
    var type:String
}


struct Hub: Codable {
    var arrivals:[Bus]
}

struct Request: Codable {
    var rate_limit:Int
    var expires_in:Int
    var api_latest_version:String
    var generated_on:String
    var data:[Hub]
    var api_version:String
}


class ReadStopAPI: ObservableObject {
    
    @Published var hub = [Hub]()
    
    init(stopId:String) {
        fetchAPIData(stopID:stopId)
    }
    
    func fetchAPIData(stopID:String) -> Void {
        let headers = [
            "X-RapidAPI-Key": "65629c31edmsh02d5f387dd070adp1f7446jsn27d7cb0cb7cc",
            "X-RapidAPI-Host": "transloc-api-1-2.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://transloc-api-1-2.p.rapidapi.com/arrival-estimates.json?agencies=176&stops=" + stopID + "&callback=call")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error as Any)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    
                    
                    let requestData = try? JSONDecoder().decode(Request.self, from:data!)
                    
//                    print(requestData)
                    
                    var hubData = requestData!.data
                    
                    print(hubData)
                    
                    self.hub = hubData
                    
                    
                    
                }
        })

        dataTask.resume()
        

        
//        return dataTask
        
        
    }
    
}


