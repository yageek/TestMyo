//
//  JSONSerializationProcedure.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 17.11.16.
//  Copyright © 2016 Vitactiv. All rights reserved.
//

import ProcedureKit
import ProcedureKitNetwork

public final class JSONSerializationProcedure<T: JSONMarshable>: Procedure, InputProcedure, OutputProcedure {

    public var input: Pending<Resource<T>> = .pending
    public var output: Pending<ProcedureResult<Data>> = .pending
    
    public override func execute() {
        guard let require = input.value else {
            finish(withError: ProcedureKitError.requirementNotSatisfied())
            return
        }

        var anyData: Any?

        switch require {
        case let .single(value):
            anyData = value.JSON
        case let .collection(objects):
            anyData = objects.flatMap{ $0.JSON }
        case .none:
            anyData = .none
        }

        guard let finalObject = anyData else {
            finish(withError: APIError.unmarshalError)
            return
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: finalObject, options: [])
            output = .ready(.success(data))
            finish()
        } catch let error {
            finish(withError: error)
        }

    }

}
