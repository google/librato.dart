// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

/**
 * A Dart library to access the Librato hosted statistics service
 * ([metrics.librato.com](https://metrics.librato.com)).
 */
library librato;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/**
 * A class used to send statistical data to the
 * [Librato](https://metrics.librato.com) service.
 *
 * To use this class, instantiate an instance (with an optional url), and call
 * [postStats] to post a set of statistics.
 */
class Librato {
  static const String BASE_URL = "https://metrics-api.librato.com/v1";

  static String _env(String key) {
    if (Platform.environment[key] == null) throw 'Missing env var: ${key}';
    return Platform.environment[key];
  }

  final String baseUrl;
  final String _username;
  final String _password;

  Librato(this._username, this._password, [this.baseUrl = BASE_URL]);

  /**
   * Create a new `Librato` instance. This requires the `LIBRATO_USER` and
   * `LIBRATO_TOKEN` environment variables to be set (and will throw otherwise).
   */
  Librato.fromEnvVars() : baseUrl = BASE_URL,
      _username = _env('LIBRATO_USER'), _password = _env('LIBRATO_TOKEN');

  /**
   * Record a set of statistics.
   */
  Future postStats(List<LibratoStat> stats) {
    // { "gauges": [ {...}, {...} ] }
    var statsList = stats.map((stat) => stat._toMap()).toList();;
    Map m = { 'gauges': statsList };
    String data = JSON.encode(m);

    String url = '${baseUrl}/metrics';
    HttpClient client = new HttpClient();
    return client.postUrl(Uri.parse(url)).then((HttpClientRequest request) {
      request.headers.set('authorization', "Basic ${_authToken}");
      request.headers.contentType = ContentType.JSON;
      request.write(data);
      return request.close();
    }).then((HttpClientResponse response) {
      return _convertResponse(response);
    });
  }

  /**
   * Create an annotation event on the given annotation stream `name`. If the
   * annotation stream does not exist, it will be created automatically.
   */
  Future createAnnotation(String name, LibratoAnnotation annotation) {
    String data = JSON.encode(annotation._toMap());

    String url = '${baseUrl}/annotations/${name}';
    HttpClient client = new HttpClient();
    return client.postUrl(Uri.parse(url)).then((HttpClientRequest request) {
      request.headers.set('authorization', "Basic ${_authToken}");
      request.headers.contentType = ContentType.JSON;
      request.write(data);
      return request.close();
    }).then((HttpClientResponse response) {
      return _convertResponse(response);
    });
  }

  String get _authToken => CryptoUtils.bytesToBase64(
      UTF8.encode("${_username}:${_password}"));
}

/**
 * Fail if the reponse is not >= 200 <300.
 */
Future _convertResponse(HttpClientResponse response) {
  return response.toList().then((List<List<int>> data) {
    String str = data.isEmpty
        ? ''
        : UTF8.decode(data.reduce((a, b) => a.addAll(b)));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return str;
    } else {
      throw str;
    }
  });
}

class LibratoStat {
  final String name;
  final num value;
  final String source;

  LibratoStat(this.name, this.value, {this.source});

  String toString() => '[${name}: ${value}]';

  Map _toMap() {
    Map m = {'name': name, 'value': value};
    if (source != null) m['source'] = source;
    return m;
  }
}

// TODO: start_time, end_time

class LibratoAnnotation {
  /**
   * The title of an annotation is a string and may contain spaces. The title
   * should be a short, high-level summary of the annotation e.g.
   * `v45 Deployment`. The title is a required parameter to create an annotation.
   */
  final String title;

  /**
   * A string which describes the originating source of an annotation when that
   * annotation is tracked across multiple members of a population.
   *
   * Examples: foo3.bar.com, user-123, 77025.
   */
  final String source;

  /**
   * The description contains extra meta-data about a particular annotation. The
   * description should contain specifics on the individual annotation e.g.
   * `Deployed 9b562b2: shipped new feature foo!` A description is not required
   * to create an annotation.
   */
  final String description;

  /**
   * An optional list of references to resources associated with the particular
   * annotation. For example, these links could point to a build page in a CI
   * system or a changeset description of an SCM. Each link has a tag that
   * defines the link's relationship to the annotation.
   */
  List<LibratoLink> links;

  LibratoAnnotation(this.title, {this.source, this.description, this.links});

  Map _toMap() {
    Map m =  {'title': title};
    if (source != null) m['source'] = source;
    if (description != null) m['description'] = description;
    if (links != null) m['links'] = links.map((link) => link._toMap()).toList();
    return m;
  }

  String toString() => title;
}

class LibratoLink {
  /**
   * Defines the relationship of the link. A link's relationship must be unique
   * within a single annotation event.
   */
  final String rel;

  /**
   * The link URL.
   */
  final String href;

  /**
   * A display label for the link.
   */
  final String label;

  LibratoLink(this.rel, this.href, {this.label});

  Map _toMap() {
    Map m =  {'rel': rel, 'href': href};
    if (label != null) m['label'] = label;
    return m;
  }

  String toString() => href;
}
