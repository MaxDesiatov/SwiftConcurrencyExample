//
//  main.swift
//  ConcurrencyPlayground
//
//  Created by Max Desiatov on 07/01/2021.
//

import _Concurrency
import Foundation

struct UnknownError: Error {}

func download(url: URL) async throws -> Data {
    try await withUnsafeThrowingContinuation { c in
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            switch (data, error) {
            case let (_, error?):
                return c.resume(throwing: error)
            case let (data?, _):
                return c.resume(returning: data)
            case (nil, nil):
                c.resume(throwing: UnknownError())
            }
        }
        task.resume()
    }
}

runAsyncAndBlock {
    print("task started")
    let data = try! await download(url: URL(string: "https://httpbin.org/uuid")!)
    print(String(data: data, encoding: .utf8)!)
}

print("end of main")
