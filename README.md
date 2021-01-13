# Swift Concurrency Example

A SwiftPM CLI package experimenting with Swift `async`/`await` and structured concurrency.
Requires [the latest development snapshot](https://swift.org/download/#snapshots) to run.
Note that 5.4 snapshots currently aren't fully compatible with this sample code, as they are a bit
out of date with the accepted `async`/`await` proposal, requiring the use of `await try` instead of `try await`.
It should work though if you adjust the code here manually to account for that.

After installing the toolchain, you can build the executable with

```shell
/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2021-01-12-a.xctoolchain/usr/bin/swift build
```

Before running anything in the project, you have to point it to the
new concurrency runtime by modifying the `DYLD_LIBRARY_PATH` environment variable.

```shell
export DYLD_LIBRARY_PATH=/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2021-01-12-a.xctoolchain/usr/lib/swift/macosx/
```

Then run the executable directly:

```shell
.build/debug/ConcurrencyExample
```

(You can't use `swift run` to run the executable on macOS because Sytem Integrity Protection [doesn't pass the `DYLD_LIBRARY-PATH` variable to SIP-protected processes](https://developer.apple.com/library/archive/documentation/Security/Conceptual/System_Integrity_Protection_Guide/RuntimeProtections/RuntimeProtections.html).)

## Reviewing the code

### Compiler flags

Notice how the target is declared in `Package.swift`:

```swift
.target(
    name: "ConcurrencyExample",
    dependencies: [],
    swiftSettings: [
        .unsafeFlags(["-Xfrontend", "-enable-experimental-concurrency"]),
    ]
)
```

Until Swift concurrency features become stable and enabled by default you have to pass these flags
when building. They are declared in the package manifest here so that you don't have to pass them
each time manually when building the project.

### Imports

When using [structured concurrency](https://forums.swift.org/t/pitch-2-structured-concurrency/43452)
to expose legacy callback-based APIs as `async` functions, you currently have to import the
`_Concurrency` module supplied with the latest Swift dev snapshots. The name of it starts with an
underscore to highlight that the module is experimental and its API may change.

### Legacy API conversion

While most of Apple's APIs will be converted to `async`/`await` [automatically](https://github.com/apple/swift-evolution/blob/main/proposals/0297-concurrency-objc.md), your own callback-based code can be converted using a few
helper functions.

In this example we convert `URLSession.shared.dataTask` to a throwing `async` function:

```swift
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
```

Here the continuation argument of the closure passed to `withUnsafeThrowingContinuation` becomes
your "callback". You have to call `resume` on it exactly once with either a success value or an
`Error` value. Multiple calls to `resume` on the same continuation are invalid, since
`async` functions can't throw or return more than once. If you don't ever call `resume` on the
continuation you'll get a function that never returns or throws, which would be clearly a bug too.

### The entry point

Currently, the `runAsyncAndBlock` function is an entry point you would use to interact with an
`async` function from your blocking synchronous code. 

```swift
runAsyncAndBlock {
    print("task started")
    let data = try! await download(url: URL(string: "https://httpbin.org/uuid")!)
    print(String(data: data, encoding: .utf8)!)
}
print("end of main")
```

Note that in the current toolchain (`DEVELOPMENT-SNAPSHOT-2021-01-12-a` at the moment of writing)
`runAsyncAndBlock` does not take throwing closures as arguments, thus `try!` or `do`/`catch` blocks
are required to call a throwing `async` function such as `download`.

The `print` statements here are added so that you can observe the execution sequence and to make sure
that your `async` code is actually called.
