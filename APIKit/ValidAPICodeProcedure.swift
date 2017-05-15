//
//  ValidAPICodeProcedure.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 18.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import ProcedureKit
import ProcedureKitNetwork

class ValidAPICodeProcedure<T: Equatable>: Procedure, InputProcedure, OutputProcedure {

    var input: Pending<HTTPPayloadResponse<T>> = .pending
    var output: Pending<ProcedureResult<HTTPPayloadResponse<T>>> = .pending

    override func execute() {

        guard !isCancelled else { return }

        guard let input = input.value else {
            self.finish(withError: ProcedureKitError.requirementNotSatisfied())
            return
        }
        
        switch input.response.statusCode {
        case 200..<299:
            print("OK - URL: \(input.response.url) - Status: \(input.response.statusCode)")
            self.output = .ready(.success(input))
            self.finish()
        default:
            print("ERROR - URL: \(input.response.url) - Status: \(input.response.statusCode)")
            print("ERROR - Content: \(input.payload)")
            self.output = .ready(.failure(APIError.apiErrorCode))
            finish(withError: APIError.apiErrorCode)
        }

    }
}
