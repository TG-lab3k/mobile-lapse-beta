//
//  CalendarPlugin.swift
//  Runner
//
//  Created by leigt on 2023/6/20.
//

import Foundation
import EventKit

class CalendarPlugin {
    public static func register(viewController : FlutterViewController){
        let channel = FlutterMethodChannel(name: "plugin.calendarAndAlarm",
                                           binaryMessenger: viewController.binaryMessenger)
        let helper = CalendarHelper()
        channel.setMethodCallHandler(helper.handleFlutterMessage)
    }
}

private struct CalendarEvent{
    var title:String
    var description: String?
    var location: String?
    var startAt: Int64
    var endAt: Int64?
    var aheadInMinutes: Double
    
    
}
private enum PermissionStatus : Int{
    case authorized = 0
    case restricted = 1
    case denied = 2
}

private typealias PermissionCallback = (_ status: PermissionStatus) -> Void
private class CalendarHelper{
    private let eventStore = EKEventStore()
    
    public func handleFlutterMessage(methodCall: FlutterMethodCall, result: @escaping FlutterResult){
        let methodName = methodCall.method
        if ("createCalendarEvent" == methodName) {
            let args = methodCall.arguments as? [String: Any]
            let title = args?["title"] as! String?
            if(title == nil){
                result(0)
                return
            }
            let startAtInMills = args?["startAt"] as! Int64?
            if(startAtInMills == nil){
                result(0)
                return
            }
            
            let endAtInMills = args?["endAt"] as! Int64?
            if(endAtInMills == nil){
                result(0)
                return
            }
            
            let aheadInMinutes = args?["aheadInMinutes"] as! Double?
            if(aheadInMinutes == nil){
                result(0)
                return
            }
            
            let description = args?["description"] as! String?
            let location = args?["location"] as! String?
            
            var calendarEvent = CalendarEvent(title: title!, startAt: startAtInMills!, endAt: endAtInMills!, aheadInMinutes: aheadInMinutes!)
            calendarEvent.description = description
            calendarEvent.location = location
            checkCalendarEventPermission(){ (eventStatus:PermissionStatus) -> Void in
                if(PermissionStatus.authorized == eventStatus){
                    let succeed = self.createEvent(calendarEvent:calendarEvent)
                    result(succeed ? 1 : 0)
                }else{
                    result(eventStatus.rawValue)
                }
            }
        } else if ("deleteCalendarEvent" == methodName){
            let args = methodCall.arguments as? [String: Any]
            let title = args?["title"] as! String?
            if(title == nil){
                result(0)
                return
            }
            
            let startAtInMills = args?["startAt"] as! Int64?
            if(startAtInMills == nil){
                result(0)
                return
            }
            
            let endAtInMills = args?["endAt"] as! Int64?
            if(endAtInMills == nil){
                result(0)
                return
            }
            
            let aheadInMinutes = args?["aheadInMinutes"] as! Double?
            if(aheadInMinutes == nil){
                result(0)
                return
            }
            
            let calendarEvent = CalendarEvent(title: title!,
                                              startAt: startAtInMills!,
                                              endAt: endAtInMills,
                                              aheadInMinutes: aheadInMinutes!)
            checkCalendarEventPermission(){ (eventStatus:PermissionStatus) -> Void in
                if(PermissionStatus.authorized == eventStatus){
                    let succeed = self.deleteEvent(calendarEvent: calendarEvent)
                    result(succeed ? 1 : 0)
                }else{
                    result(eventStatus.rawValue)
                }
            }
        } else if("checkAndRequestCalendarPermission" == methodName){
            checkCalendarEventPermission(){(eventStatus:PermissionStatus) -> Void in
                result(eventStatus.rawValue)
            }
        }
    }
    
    func checkCalendarEventPermission(permissionCallback: @escaping PermissionCallback){
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        switch(status){
        case EKAuthorizationStatus.notDetermined:
            print("_________ notDetermined")
            requestCalendarEventPermission(permissionCallback:permissionCallback)
            break
            
        case EKAuthorizationStatus.authorized:
            print("_________ authorized")
            permissionCallback(PermissionStatus.authorized)
            break
            
        case EKAuthorizationStatus.restricted:
            print("_________ restricted")
            permissionCallback(PermissionStatus.restricted)
            break
            
        case EKAuthorizationStatus.denied:
            print("_________ denied")
            permissionCallback(PermissionStatus.denied)
            break
        @unknown default:
            print("_________ default")
            break
        }
    }
    
    func requestCalendarEventPermission(permissionCallback: @escaping PermissionCallback){
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted, error) in
            if(accessGranted) && (error == nil){
                permissionCallback(PermissionStatus.authorized)
                print("_________ 日历授权成功")
            }else{
                print("_________ 日历授权失败!!!")
            }
        })
        
    }
    
    func checkCalendarReminderPermission(permissionCallback: @escaping PermissionCallback){
        let reminderStatus = EKEventStore.authorizationStatus(for: EKEntityType.reminder)
        switch(reminderStatus){
        case EKAuthorizationStatus.notDetermined:
            print("_________ notDetermined")
            requestCalendarReminderPermission(permissionCallback:permissionCallback)
            break
            
        case EKAuthorizationStatus.authorized:
            print("_________ authorized")
            permissionCallback(PermissionStatus.authorized)
            break
            
        case EKAuthorizationStatus.restricted:
            print("_________ restricted")
            permissionCallback(PermissionStatus.restricted)
            break
            
        case EKAuthorizationStatus.denied:
            print("_________ denied")
            permissionCallback(PermissionStatus.denied)
            break
        @unknown default:
            print("_________ default")
            break
        }
    }
    
    func requestCalendarReminderPermission(permissionCallback: @escaping PermissionCallback){
        eventStore.requestAccess(to: EKEntityType.reminder, completion: {
            (accessGranted, error) in
            if(accessGranted) && (error == nil){
                permissionCallback(PermissionStatus.authorized)
                print("_________ 提醒授权成功")
            }else{
                print("_________ 提醒授权失败!!!")
            }
        })
        
    }
    
    func createEvent(calendarEvent : CalendarEvent) -> Bool {
        let event:EKEvent = EKEvent(eventStore: eventStore)
        event.title = calendarEvent.title
        event.location = calendarEvent.location

        let eventStartAtInSeconds = calendarEvent.startAt / 1000
        let eventStartAt = Date(timeIntervalSince1970: TimeInterval(integerLiteral: Int64(integerLiteral: eventStartAtInSeconds)))
        event.startDate = eventStartAt
        let eventEndAt = Date(timeIntervalSince1970: TimeInterval(integerLiteral: Int64(integerLiteral: (calendarEvent.endAt! / 1000))))
        event.endDate = eventEndAt
        event.notes = calendarEvent.description
        
        
        let aheadInSeconds = -60 * calendarEvent.aheadInMinutes
        let alarm = EKAlarm(relativeOffset: aheadInSeconds)
        event.alarms = [alarm]
        event.timeZone = NSTimeZone.system
        event.calendar = self.eventStore.defaultCalendarForNewEvents
        do{
            try self.eventStore.save(event, span: EKSpan.thisEvent, commit: true)
            return true
        }catch{
            //ignore
        }
        return false
    }
    
    func deleteEvent(calendarEvent : CalendarEvent) -> Bool {
        print("#deleteEvent# \(calendarEvent.title)")
        let eventStartAt = Date(timeIntervalSince1970: TimeInterval(integerLiteral: Int64(integerLiteral: (calendarEvent.startAt / 1000))))
        let eventEndAt = Date(timeIntervalSince1970: TimeInterval(integerLiteral: Int64(integerLiteral: (calendarEvent.endAt! / 1000))))
        
        let predicate = self.eventStore.predicateForEvents(withStart: eventStartAt, end: eventEndAt,
                                           calendars: [self.eventStore.defaultCalendarForNewEvents!])
        let events:Array<EKEvent> = self.eventStore.events(matching: predicate)
        do{
            try events.forEach { event in
                if(event.title == calendarEvent.title){
                    try self.eventStore.remove(event, span: EKSpan.thisEvent, commit: true)
                }
            }
            return true
        }catch{
            //ignore
        }
        return false
    }
}



