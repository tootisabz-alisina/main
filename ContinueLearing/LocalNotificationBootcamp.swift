//
//  LocalNotificationBootcamp.swift
//  ContinueLearing
//
//  Created by TOTI SABZ on 3/4/25.
//

import SwiftUI
import UserNotifications
import CoreLocation


class NotificationManager{
    
    static let instance = NotificationManager() // Single ton
     
    func requestPremission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }else if granted{
                debugPrint("PERMISSION GRANTED")
            }
        }
    }
    
    func scheduleNotification(){
       
        // CONTENT OF NOTIFICATION
        let content = UNMutableNotificationContent()
        content.title = "Alert"
        content.subtitle = "You left the office, come back"
        content.sound = .default
        content.badge = 1
        
        // NOTIFICATION TRIGGER [TIME, CALENDAR, LOCATION]
        
        // TIME
        let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // CALENDAR
        var dateComponents = DateComponents()
        dateComponents.hour = 11
        dateComponents.minute = 31
        let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // LOCATION
        let cood = CLLocationCoordinate2D(latitude: 34.5415506, longitude: 69.1614940)
        let region = CLCircularRegion(center: cood, radius: 10, identifier: "location")
        region.notifyOnEntry = true
        region.notifyOnExit = true
        let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: true)
        
        // NOTIFICATION REQUEST
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: locationTrigger)
        UNUserNotificationCenter.current().add(request)
    }

//    func cancelNotifications
    
    func clearBadgeNumber(){
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}


struct LocalNotificationBootcamp: View {
    var body: some View {
        VStack(spacing: 30){
            Button("Request permission"){
                NotificationManager.instance.requestPremission()
            }
            Button("schedule permission"){
                NotificationManager.instance.scheduleNotification()
            }
            Button("clear app icon badge number"){
                NotificationManager.instance.clearBadgeNumber()
            }
        }
    }
}

#Preview {
    LocalNotificationBootcamp()
}
