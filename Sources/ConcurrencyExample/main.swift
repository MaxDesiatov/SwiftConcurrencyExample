//
//  main.swift
//  ConcurrencyPlayground
//
//  Created by Max Desiatov on 07/01/2021.
//

import _Concurrency
import Dispatch
import Foundation

struct UnknownError: Error {}

func download(_ url: String) async throws -> Data {
    print("fetching \(url)")
    return try await withUnsafeThrowingContinuation { c in
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

func sleep(seconds: Int) async {
    await withUnsafeContinuation { c in
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(seconds)) {
            c.resume(returning: ())
        }
    }
}

func childTasks() async throws -> String {
    print("\(#function) started")

    async let uuid1 = download("https://httpbin.org/uuid")
    async let uuid2 = download("https://httpbin.org/uuid")
    try await Task.checkCancellation()
    print("\(#function) is not cancelled yet")

    return try await """
    ids fetched concurrently:
    \(String(data: uuid1, encoding: .utf8)!)\(String(data: uuid2, encoding: .utf8)!)
    """
}

runAsyncAndBlock {
    print("task started")
    let data = try! await download("https://httpbin.org/uuid")
    print(String(data: data, encoding: .utf8)!)

    try! await print(childTasks())

    // run this as a detached task and get a handle for it
    let handle = Task.runDetached {
        await sleep(seconds: 1)
        try await print(childTasks())
    }

    // cancel the task immediately through the handle
    handle.cancel()

    do {
        try await handle.get()
    } catch {
        if error is Task.CancellationError {
            print("task cancelled")
        } else {
            print(error)
        }
    }
}

print("end of main")
