//
//  DownloadProcedure.swift
//  iOSApp
//
//  Created by Yannick Heinrich on 16.11.16.
//  Copyright © 2016 Vitactiv. All rights reserved.
//

import ProcedureKit
import ProcedureKitNetwork

public final class DownloadProcedure<E: Endpoint, T: JSONUnmarshable>: GroupProcedure, OutputProcedure {

    public var output: Pending<ProcedureResult<Resource<T>>> = .pending

    public init(session: URLSession, endpoint: E, object: Resource<T> = .none) {

        let serializedURLProcedure = SerializeAPICallProcedure(endpoint: endpoint)
        let downloadProcedure = NetworkDownloadProcedure(session: session)
        let unserializeProcedure = JSONDeserializationProcedure<T>()
        let validProcedure = ValidAPICodeProcedure<URL>()

        downloadProcedure.injectResult(from: serializedURLProcedure)
        validProcedure.injectResult(from: downloadProcedure)
        
        unserializeProcedure.injectResult(from: downloadProcedure)

        super.init(operations: [serializedURLProcedure, downloadProcedure, unserializeProcedure, validProcedure])

        unserializeProcedure.addWillFinishBlockObserver { (procedure, errors) in
            if let error = errors.first {
                self.output = .ready(.failure(error))
            } else {
                self.output = procedure.output
            }
        }
     }

}
