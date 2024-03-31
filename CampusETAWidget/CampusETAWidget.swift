//
//  CampusETAWidget.swift
//  CampusETAWidget
//
//  Created by Keshav Varadarajan on 3/31/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let placeholderDestinations = [
            DestData(dest: "east", bus1_id: "4007836", bus2_id: "4014045", wait_time1: 12.3232, wait_time2: 20.2342, eta1: "12:43", eta2: "NA"),
            DestData(dest: "swift", bus1_id: "4007836", bus2_id: "4014045", wait_time1: 12.3232, wait_time2: 20.2342, eta1: "12:43", eta2: "NA")
        ]
        
        return SimpleEntry(date: Date(), emoji: "😀", destinations: placeholderDestinations)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let destinations = [
            DestData(dest: "east", bus1_id: "4007836", bus2_id: "4014045", wait_time1: 12.3232, wait_time2: 20.2342, eta1: "12:43", eta2: "NA"),
            DestData(dest: "swift", bus1_id: "4007836", bus2_id: "4014045", wait_time1: 12.3232, wait_time2: 20.2342, eta1: "12:43", eta2: "NA")
        ]
        let entry = SimpleEntry(date: Date(), emoji: "😀", destinations: destinations)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        Task {
            var entries: [SimpleEntry] = []

            
            let currentDate = Date()
            let currentDestinations = try? await updateState()
            
            let entry = SimpleEntry(date: currentDate, emoji: "", destinations: currentDestinations!)
            
            entries.append(entry)

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    
    
    func fetchStopCluster() -> [Stop] {
        @ObservedObject var stopData = ReadData()
        
        
        let isWeekend = Calendar.current.isDateInWeekend(Date.now)

//        let curLat = Float((locationManager.userLocation?.coordinate.latitude)!)
//        let curLng = Float((locationManager.userLocation?.coordinate.longitude)!)
        
        let curLat = Float(36.0006142)
        let curLng = Float(-78.9403102)
        
        
        var stopCluster:[Stop] = []
        
        var minDist = Float(0.1)
        let distThresh = Float(0.000000497)
        var closestStop:Stop? = nil
        
        var stops = stopData.weekday_stops
        
        if (isWeekend)
        {
            stops = stopData.weekend_stops
        }
        
        for stop in stops {
            let stopLat = stop.location.lat
            let stopLng = stop.location.lng
            
            let dist = pow((curLat - stopLat), 2) + pow((curLng - stopLng), 2)
            
            
            if (dist <= minDist)
            {
                closestStop = stop
                minDist = dist
            }
            
        }
        
        stopCluster.append(closestStop!)
        
        var tempStopArr = stops
        
        tempStopArr = tempStopArr.sorted(by: { stop1, stop2 in
            (pow((closestStop!.location.lat - stop1.location.lat), 2) + pow((closestStop!.location.lng - stop1.location.lng), 2)) < (pow((closestStop!.location.lat - stop2.location.lat), 2) + pow((closestStop!.location.lng - stop2.location.lng), 2))
            
        })
        
        
        for stop in tempStopArr {
            if (stop.stop_id == closestStop!.stop_id)
            {
                continue
            }
            
            if (stopCluster.count == 3)
            {
                break
            }
            
            let dist = pow((closestStop!.location.lat - stop.location.lat), 2) + pow((closestStop!.location.lng - stop.location.lng), 2)
            
            if (dist < distThresh)
            {
                stopCluster.append(stop)
            }
            
        }
            
        
        
        return stopCluster
    }
    
    func fetchDestinations() -> [String] {
        
        let isWeekend = Calendar.current.isDateInWeekend(Date.now)
        
        var destinations:[String] = []
        
        let stopCluster = fetchStopCluster()
        
        
        for stop in stopCluster {
            for dir in stop.direction {
                if (!destinations.contains(dir)) {
                    destinations.append(dir)
                }
            }
        }
        
        return destinations
    }
    
    
    func ReadStops(stop_id:String) async->[Hub]{
        let headers = [
            "X-RapidAPI-Key": "65629c31edmsh02d5f387dd070adp1f7446jsn27d7cb0cb7cc",
            "X-RapidAPI-Host": "transloc-api-1-2.p.rapidapi.com"
        ]

        var request = NSMutableURLRequest(url: NSURL(string: "https://transloc-api-1-2.p.rapidapi.com/arrival-estimates.json?agencies=176&stops=" + stop_id + "&callback=call")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        
        var decodedData : [Hub]? = nil
        
        do {
            let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                
                if (error != nil) {
                    print(error as Any)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    
//                    print(httpResponse)
                    DispatchQueue.main.async {
                        let responseData = try? JSONDecoder().decode(Request.self, from:data!)
                        
                        decodedData = responseData!.data
                    }
                    
                    
                    
                }
            })
            

            dataTask.resume()
            
            try await Task.sleep(nanoseconds: 1500_000_000)
        } catch {
            
        }
        
        
        
        return decodedData!
        
        
    }
    
    
    
    
    func fetchDestData(destination:String, stops:[Stop]) async -> DestData {
        
        var C1_ID = "4008330"
        var Swift_ID = "4016862"
        var C1_Swift_ID = "4017244"
        var East = "4117202"
        var West = "4267588"
        var Swift_weekday = "4258580"
        var Swift_west = "4258580"
        var Swift_east = "4276800"
        
        let isWeekend = Calendar.current.isDateInWeekend(Date.now)
        
        
        var tempStops = stops
        
        for (ind, stop) in tempStops.enumerated() {
            if (!stop.direction.contains(destination))
            {
                tempStops.remove(at:ind)
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        var buses : [Bus] = []
        
        if (destination == "west" || isWeekend)
        {
            for stop in tempStops {
                
                let hubData = await ReadStops(stop_id: stop.stop_id)
                
                var stopBuses = hubData[0].arrivals
                
                for bus in stopBuses {
                    buses.append(bus)
                }
            }
        }
        else
        {
            var routeID : String = ""
            
            if (destination == "east")
            {
                routeID = C1_ID
            }
            else
            {
                routeID = Swift_ID
            }
            
            for stop in tempStops {
                
                let apiData = ReadRouteAPI(stopId: stop.stop_id, routeId: routeID).hub
                
                if (apiData.count > 0)
                {
                    let stopBuses = apiData[0].arrivals
                    
                    for bus in stopBuses {
                        buses.append(bus)
                    }
                }
            }
        }
        
        
        
        buses = buses.sorted(by: { bus1, bus2 in
            dateFormatter.date(from:bus1.arrival_at)! < dateFormatter.date(from:bus2.arrival_at)!
        })
        
        
        let bus1 = buses[0]
        let bus2 = buses[1]
        
        
        
        var arrivals : [Bus] = []
        
        if (destination == "west")
        {
            
            arrivals = await ReadStops(stop_id: West)[0].arrivals
        }
        
        if (destination == "east")
        {
            
            arrivals = await ReadStops(stop_id: East)[0].arrivals
        }
        
        if (destination == "swift" && !isWeekend)
        {
            
            arrivals = await ReadStops(stop_id: Swift_weekday)[0].arrivals
        }
        
        if (destination == "swift" && isWeekend)
        {
            
            let westArrivals = await ReadStops(stop_id: Swift_west)[0].arrivals
            
            let eastArrivals = await ReadStops(stop_id: Swift_east)[0].arrivals
            
            arrivals = westArrivals + eastArrivals
        }
        
        var bus1Eta:String? = nil
        var bus1EtaDate:Date? = nil
        
        var bus2Eta:String? = nil
        var bus2EtaDate:Date? = nil
        
        var dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "hh:mm"
        
        
        for arrival in arrivals {
            
            if (arrival.vehicle_id == bus1.vehicle_id)
            {
                if (bus1EtaDate == nil || bus1EtaDate! > dateFormatter.date(from:arrival.arrival_at)!) {
                    bus1EtaDate = dateFormatter.date(from:arrival.arrival_at)!
                    bus1Eta = dateFormatter1.string(from:bus1EtaDate!)
                }
                
            }
            
            if (arrival.vehicle_id == bus2.vehicle_id)
            {
                if (bus2EtaDate == nil || bus2EtaDate! > dateFormatter.date(from:arrival.arrival_at)!) {
                    bus2EtaDate = dateFormatter.date(from:arrival.arrival_at)!
                    bus2Eta = dateFormatter1.string(from:bus2EtaDate!)
                }
            }
        }
        
        let curTime = Date.now
        
        let bus1WaitTime = curTime.distance(to:dateFormatter.date(from:bus1.arrival_at)!) / 60
        let bus2WaitTime = curTime.distance(to:dateFormatter.date(from:bus2.arrival_at)!) / 60
        
        
        var bus1EtaVal : String = "NA"
        var bus2EtaVal : String = "NA"
        
        if bus1Eta != nil {
            bus1EtaVal = bus1Eta!
        }
        if bus2Eta != nil {
            bus2EtaVal = bus2Eta!
        }
        
        if (bus1EtaDate != nil && bus1EtaDate! < dateFormatter.date(from:bus1.arrival_at)!) {
            bus1EtaVal = "NA"
        }
        
        if (bus2EtaDate != nil && bus2EtaDate! < dateFormatter.date(from:bus2.arrival_at)!) {
            bus2EtaVal = "NA"
        }
        
        let destData = DestData(dest:destination,bus1_id: bus1.vehicle_id, bus2_id: bus2.vehicle_id, wait_time1: bus1WaitTime, wait_time2: bus2WaitTime, eta1: bus1EtaVal, eta2: bus2EtaVal)
        
        return destData
    }
    
    func updateState() async -> [DestData]{
        
        
        var tempDestData : [DestData] = []
        
        let stopCluster = fetchStopCluster()
        let destinations = fetchDestinations()
        
        
        for dest in destinations {
            let curDestData = await fetchDestData(destination: dest, stops: stopCluster)
            tempDestData.append(curDestData)
        }
        
        
        return tempDestData
    }
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
    var destinations: [DestData]
}

struct CampusETAWidgetMedium : View {
    var entry: Provider.Entry
    
    
    var body: some View {
        ZStack {
            Color(.offWhite)
            HStack {
                ForEach(entry.destinations) { destData in
                    HStack {
                        VStack {
                            Text(destData.dest.capitalized)
                                .font(.system(size: 18, weight:.medium))
                                .frame(width: 75, height: 15)
                                .foregroundStyle(.black)
                                .padding(5)
                                .background(Rectangle().fill(Color(.lightGrey)))
                                .cornerRadius(7)
                            
                            Spacer()
                            
                            Text(String(Int(destData.wait_time1)))
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(Color(.dangerRed))
                            + Text("MIN")
                                .font(.system(size: 8.0))
                            
                            Spacer()
                            
                            Text("ETA " + destData.dest + ": ")
                                .font(.system(size: 8.0))
                                .baselineOffset(2)
                            + Text(destData.eta1)
                        }
                    }
                }
            }
        }
        
    }
}

struct CampusETAWidgetLarge : View {
    var entry: Provider.Entry
    
    
    var body: some View {
        HStack {
            
        }
    }
}

struct CampusETAWidgetNone : View {
    var entry: Provider.Entry
    
    
    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Emoji:")
            Text(entry.emoji)
        }
    }
}

struct CampusETAWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium:
            CampusETAWidgetMedium(entry: entry)
        case .systemLarge:
            CampusETAWidgetLarge(entry: entry)
        default:
            CampusETAWidgetNone(entry: entry)
        }
    
    }
}



struct CampusETAWidget: Widget {
    let kind: String = "CampusETAWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CampusETAWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CampusETAWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    CampusETAWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀", destinations: [
        DestData(dest: "east", bus1_id: "4007836", bus2_id: "4014045", wait_time1: 12.3232, wait_time2: 20.2342, eta1: "12:43", eta2: "NA"),
        DestData(dest: "swift", bus1_id: "4007836", bus2_id: "4014045", wait_time1: 12.3232, wait_time2: 20.2342, eta1: "12:43", eta2: "NA")
    ])
}
