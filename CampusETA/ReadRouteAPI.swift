//
//  ReadAPIData.swift
//  CampusETA
//
//  Created by Keshav Varadarajan on 3/30/24.
//

import Foundation



class ReadRouteAPI: ObservableObject {
    
    @Published var hub = [Hub]()
    
    init(stopId:String, routeId:String) {
        fetchAPIData(stopID: stopId, routeID:routeId)
    }
    
    func fetchAPIData(stopID:String, routeID:String) -> Void {
        let headers = [
            "X-RapidAPI-Key": "65629c31edmsh02d5f387dd070adp1f7446jsn27d7cb0cb7cc",
            "X-RapidAPI-Host": "transloc-api-1-2.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://transloc-api-1-2.p.rapidapi.com/arrival-estimates.json?agencies=176&routes=" + routeID + "&stops=" + stopID + "&callback=call")! as URL,
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
                
                
                var hubData:[Hub] = requestData!.data
                
                
                self.hub = hubData
                
                
                
            }
        })

        dataTask.resume()
    
        
    }
    
}

