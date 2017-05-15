//
//  SerializeAPICallProcedure.swift
//  iOSApp
//
//  Created by Yannick Heinrich on 16.11.16.
//  Copyright © 2016 Vitactiv. All rights reserved.
//

import ProcedureKit

public final class SerializeAPICallProcedure<E: Endpoint>: Procedure, OutputProcedure {

    public var endpoint: E
    public var output: Pending<ProcedureResult<URLRequest>>

    public init(endpoint: E) {
        self.endpoint = endpoint
        output = .pending

        super.init()

        name = "Serialize URL for call: \(endpoint)"
    }

    public override func execute() {

        guard let token = API.Token else {
            self.finish(withError: ProcedureKitError.programmingError(reason: "Token needs to be setted"))
            return
        }

        let callURL = endpoint.baseURL.appendingPathComponent(endpoint.path)

        var request = URLRequest(url: callURL)
        request.httpMethod = endpoint.method
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        output = .ready(.success(request))
        finish()
    }
}
