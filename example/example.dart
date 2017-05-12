// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library librato.example;

import 'dart:math' as math;

import 'package:librato/librato.dart';

void main(List<String> args) {
  if (args.length == 3) {
    Librato librato = new Librato(args[0], args[1]);

    // Post a stat.
    LibratoStat stat = new LibratoStat('startupTime', num.parse(args[2]));
    librato.postStats([stat]).then((_) {
      print('Sent ${stat}');
    });

    // Post an annotation.
    String commit = new math.Random().nextInt(0x7fffffff).toRadixString(16);
    LibratoLink link = new LibratoLink(
        'github', 'https://github.com/foo/bar/commit/${commit}');
    LibratoAnnotation annotation = new LibratoAnnotation(commit,
        description: 'Build triggered from commit ${commit}', links: [link]);
    librato.createAnnotation('builds', annotation).then((_) {
      print('Sent ${annotation}');
    });
  } else {
    print('usage: librato <username> <token> <stat-to-record>');
  }
}
