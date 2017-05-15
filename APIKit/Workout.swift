//
//  Workout.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 15.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import Foundation

public struct ParsedEditWorkout: JSONMarshable {

    public let title: String
    public let workoutDescription: String

    public init(title: String, workoutDescription: String) {
        self.title = title
        self.workoutDescription = workoutDescription
    }

    public var JSON: [String: Any] {
        return [
            ParsedWorkout.TitleKey: title,
            ParsedWorkout.DescriptionKey: workoutDescription
        ]
    }
}

public struct ParsedWorkout: JSONUnmarshable {

    fileprivate static let IDKey = "id"
    fileprivate static let TitleKey = "title"
    fileprivate static let TypeKey = "type"
    fileprivate static let DistanceKey = "distance"
    fileprivate static let LocationKey = "location"

    fileprivate static let StartKey = "start"
    fileprivate static let EndKey = "end"
    fileprivate static let CreatedKey = "created"

    fileprivate static let TargetDurationKey = "target_duration"
    fileprivate static let EffectiveDurationKey = "effective_duration"
    fileprivate static let DataKey = "data"
    fileprivate static let DescriptionKey = "description"

    public let ID: String
    public let title: String
    public let type: String
    public let distance: Double
    public let location: String
    public let workoutDescription: String
    public let start: Date
    public let end: Date

    public let targetDuration: TimeInterval?
    public let effectiveDuration: TimeInterval?

    public let created: Date

    public let data: [[String: Any]]?

    public init?(JSON: [String: Any]) {

        guard
        let IDJSON = JSON[ParsedWorkout.IDKey] as? String,
        let descriptionJSON = JSON[ParsedWorkout.DescriptionKey] as? String,
        let titleJSON = JSON[ParsedWorkout.TitleKey] as? String,
        let typeJSON = JSON[ParsedWorkout.TypeKey] as? String,
        let distanceJSON = JSON[ParsedWorkout.DistanceKey] as? Double,
        let locationJSON = JSON[ParsedWorkout.LocationKey] as? String,
        let startJSON = JSON[ParsedWorkout.StartKey] as? String,
        let endJSON = JSON[ParsedWorkout.EndKey] as? String,
        let createdJSON = JSON[ParsedWorkout.CreatedKey] as? String
            else { return nil }

        

        guard
        let startDate = API.date(from: startJSON),
        let endDate = API.date(from: endJSON),
        let createdDate = API.date(from: createdJSON) else {
            print("Impossible to download Workout: \(IDJSON)")
            return nil }

        ID = IDJSON
        title = titleJSON
        workoutDescription = descriptionJSON
        type = typeJSON
        distance = distanceJSON
        location = locationJSON

        start = startDate
        end = endDate
        created = createdDate

        targetDuration = JSON[ParsedWorkout.TargetDurationKey] as? Double
        effectiveDuration = JSON[ParsedWorkout.EffectiveDurationKey] as? Double
        data = JSON[ParsedWorkout.DataKey] as? [[String: Any]]

    }
}
