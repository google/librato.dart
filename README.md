# librato

[![Build Status](https://travis-ci.org/google/librato.dart.svg)](https://travis-ci.org/google/librato.dart)

A [Dart][dart] library to upload metrics data to
[librato.com](https://metrics.librato.com).

## Usage

To use this library, instantiate an instance of the `Librato` class and call its
`postStats` method to post a set of statistics.

You need to provide a Librato username and access token, either explicitly in
the constructor, or implicitly via environment variables (`LIBRATO_USER` and
`LIBRATO_TOKEN`).

```dart
Librato librato = new Librato.fromEnvVars();
List<LibratoStat> stats = [
  new LibratoStat('benchmarkTime', 130);
  new LibratoStat('compiledAppSize', 230000);
];
librato.postStats(stats);
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/google/librato.dart/issues
[dart]: https://www.dartlang.org

## Notes

This is not an official Google project.
