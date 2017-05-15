//
//  API+Workout.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 15.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import Foundation

public extension API {

    public enum Workout {
        case GetWorkoutPage
        case UpdateWorkout(ID: String)
    }
}

extension API.Workout: Endpoint {

    public var path: String {
        switch self {
        case .GetWorkoutPage:
            return "/workouts/"
        case .UpdateWorkout(let resourceID):
            return "/workouts/\(resourceID)/"
        }
    }

    public var parameters: [String: Any] {
        return [:]
    }

    public var method: String {
        switch self {
        case .UpdateWorkout: return "PATCH"
        default: return "GET"
        }
    }
}
