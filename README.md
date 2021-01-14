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

Please refer to this article for a detailed review of code in this package – ["Introduction to structured concurrency in Swift: continuations, tasks, and cancellation"](https://desiatov.com/swift-structured-concurrency-introduction/).