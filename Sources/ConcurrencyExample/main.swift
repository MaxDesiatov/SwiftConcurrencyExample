//
//  main.swift
//  ConcurrencyPlayground
//
//  Created by Max Desiatov on 07/01/2021.
//

import _Concurrency
import Foundation

struct UnknownError: Error {}

func download(_ url: String) async throws -> Data {
    try await withUnsafeThrowingContinuation { c in
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
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
    let data = try! await download("https://httpbin.org/uuid")
    print(String(data: data, encoding: .utf8)!)

    async let uuid1 = download("https://httpbin.org/uuid")
    async let uuid2 = download("https://httpbin.org/uuid")


    try! await print("""
    ids fetched conncurrently:
    \(String(data: uuid1, encoding: .utf8)!)\(String(data: uuid2, encoding: .utf8)!)
    """)
}

print("end of main")
