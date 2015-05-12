// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:grinder/grinder.dart';

main(List<String> args) => grind(args);

@Task()
analyze() => new PubApp.global('tuneup').run(['check']);

@Task()
test() => new PubApp.local('test').run([]);

@DefaultTask()
@Depends(analyze, test)
all() => null;
