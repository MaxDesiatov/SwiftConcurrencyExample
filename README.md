# SwiftConcurrencyPlayground

A SwiftPM CLI package experimenting with Swift `async`/`await` and structured concurrency.
Requires [the latest development snapshot](https://swift.org/download/#snapshots) to run.

After installing the toolchain, before running anything in project you have to point it to the
runtime parts by modifying the `DYLD_LIBRARY_PATH` environment variable.

```shell
export DYLD_LIBRARY_PATH=/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2021-01-07-a.xctoolchain/usr/lib/swift/macosx/
```

Then run it as

```shell
/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2021-01-07-a.xctoolchain/usr/bin/swift run
```
