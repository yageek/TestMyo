//
//  UploadProcedure.swift
//  iOSApp
//
//  Created by Yannick Heinrich on 17.11.16.
//  Copyright © 2016 Vitactiv. All rights reserved.
//

import ProcedureKit
import ProcedureKitNetwork

internal final class UploadSerializationProcedure<E: Endpoint, T: JSONMarshable>: GroupProcedure, InputProcedure, OutputProcedure {
    public var input: Pending<Void> = .pending
    public var output: Pending<ProcedureResult<HTTPPayloadRequest<Data>>> = .pending

    internal var request: Pending<ProcedureResult<URLRequest>> = .pending
    internal var payload: Pending<ProcedureResult<Data>> = .pending

    init(urlProcedure: SerializeAPICallProcedure<E>, bodyProcedure: JSONSerializationProcedure<T>, object: Resource<T>) {
        bodyProcedure.input = .ready(object)
        super.init(operations: [urlProcedure, bodyProcedure])

        urlProcedure.addWillFinishBlockObserver { (serialize, errors) in

            if let error = errors.first {
                self.finish(withError: error)
            } else {
                self.request = serialize.output
            }
        }

        bodyProcedure.addWillFinishBlockObserver { (serialize, errors) in
            if let error = errors.first {
                self.finish(withError: error)
            } else {
                self.payload = serialize.output
            }
        }

        addWillFinishBlockObserver { [weak self] (_, errors) in
            guard errors.isEmpty, let strongSelf = self else { return }

            switch (strongSelf.request, strongSelf.payload) {
            case let (.ready(.success(request)), .ready(.success(object))):
                strongSelf.output = .ready(.success(HTTPPayloadRequest<Data>(payload: object, request: request)))

            default:
                strongSelf.finish(withError: nil)
            }
        }
    }
}

public final class UploadProcedure<E: Endpoint, T: JSONMarshable>: GroupProcedure, OutputProcedure {

    public var endpoint: E
    public var output: Pending<ProcedureResult<HTTPPayloadResponse<Data>>> = .pending

    public init(session: URLSession, endpoint: E, object: Resource<T>) {
        self.endpoint = endpoint

        // Serialize Both URL and Payload
        let serializeJSONProcedure = JSONSerializationProcedure<T>()
        let serializedURLProcedure = SerializeAPICallProcedure(endpoint: endpoint)
        // Merge everything
        let payloadProcedure = UploadSerializationProcedure(urlProcedure: serializedURLProcedure, bodyProcedure: serializeJSONProcedure, object: object)
        let uploadProcedure = NetworkUploadProcedure(session: session)
        let validCodeProcedure = ValidAPICodeProcedure<Data>()

        uploadProcedure.injectResult(from: payloadProcedure)
        validCodeProcedure.injectResult(from: uploadProcedure)

        super.init(operations: [uploadProcedure, payloadProcedure, validCodeProcedure])

        uploadProcedure.addWillFinishBlockObserver { [weak self] (procedure, errors) in
            guard errors.isEmpty, let strongSelf = self else { return }

            if let error = errors.first {
                strongSelf.output = .ready(.failure(error))
            } else {
                strongSelf.output = procedure.output
            }

        }
    }

}
