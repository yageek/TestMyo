//
//  Workout.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 16.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import UIKit
import CoreData

class Workout: NSManagedObject {

    static let dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout");
    }

    @NSManaged public var workoutDescription: String
    @NSManaged public var created: NSDate
    @NSManaged public var data: NSObject?
    @NSManaged public var distance: NSDecimalNumber?
    @NSManaged public var effectiveDuration: NSDecimalNumber?
    @NSManaged public var end: NSDate
    @NSManaged public var identifier: String
    @NSManaged public var location: String
    @NSManaged public var start: NSDate
    @NSManaged public var targetDuration: NSDecimalNumber?
    @NSManaged public var title: String
    @NSManaged public var type: String

    @NSManaged private var primitiveSectionIdentifier: String?

    public var sectionIdentifier: String {
        get {

            willAccessValue(forKey: "sectionIdentifier")
            var tmp = primitiveSectionIdentifier
            didAccessValue(forKey: "sectionIdentifier")

            if let tmp = tmp {
                return tmp
            }

            tmp = Workout.dateFormatter.string(from: created as Date)
            primitiveSectionIdentifier = tmp
            return tmp ?? "Unknown"
        }
    }


    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if key == "sectionIdentifier" {
            return Set<String>(["created"])
        }
        else {
            return super.keyPathsForValuesAffectingValue(forKey:key)
        }
    }
}
