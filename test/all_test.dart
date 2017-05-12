// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library librato.test;

import 'package:librato/librato.dart';
import 'package:test/test.dart';

main() {
  group('librato', () {
    test('authToken', () {
      final Librato librato = new Librato('foo', 'bar');
      expect(librato.authToken, 'Zm9vOmJhcg==');
    });
  });
}
