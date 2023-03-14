// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:config/config.dart';

import 'ios_sdk.dart';
import 'packaging_preference.dart';
import 'target.dart';

class NativeAssetsCliConfig {
  /// The folder in which all output and intermediate artifacts should be
  /// placed.
  Uri get outDir => _outDir;
  late final Uri _outDir;

  /// The target that is being compiled for.
  Target get target => _target;
  late final Target _target;

  /// When compiling for iOS, whether to target device or simulator.
  ///
  /// Required when [target.os] equals [OS.iOS].
  IOSSdk? get targetIOSSdk => _targetIOSSdk;
  late final IOSSdk? _targetIOSSdk;

  /// Path to a C compiler.
  Uri? get cc => _cc;
  late final Uri? _cc;

  /// Path to a native linker.
  Uri? get ld => _ld;
  late final Uri? _ld;

  /// Preferred packaging method for library.
  PackagingPreference get packaging => _packaging;
  late final PackagingPreference _packaging;

  factory NativeAssetsCliConfig({
    required Uri outDir,
    required Target target,
    IOSSdk? targetIOSSdk,
    Uri? cc,
    Uri? ld,
    required PackagingPreference packaging,
  }) {
    final nonValidated = NativeAssetsCliConfig._()
      .._outDir = outDir
      .._target = target
      .._targetIOSSdk = targetIOSSdk
      .._cc = cc
      .._ld = ld
      .._packaging = packaging;
    final parsedConfigFile = nonValidated.toYamlEncoding();
    final config = Config(fileParsed: parsedConfigFile);
    return NativeAssetsCliConfig.fromConfig(config);
  }

  NativeAssetsCliConfig._();

  factory NativeAssetsCliConfig.fromConfig(Config config) {
    final result = NativeAssetsCliConfig._();
    final configExceptions = <FormatException>[];
    for (final f in result._readFieldsFromConfig()) {
      try {
        f(config);
      } on FormatException catch (e) {
        configExceptions.add(e);
      }
    }

    if (configExceptions.isNotEmpty) {
      if (configExceptions.length == 1) {
        throw configExceptions.single;
      }
      throw FormatException(
          'Multiple FormatExceptions happened: $configExceptions');
    }

    return result;
  }

  static const outDirConfigKey = 'out_dir';
  static const ccConfigKey = 'cc';
  static const ldConfigKey = 'ld';

  List<void Function(Config)> _readFieldsFromConfig() => [
        (config) => _outDir = config.getPath(outDirConfigKey),
        (config) => _target = Target.fromString(
              config.getString(
                Target.configKey,
                validValues: Target.values.map((e) => '$e'),
              ),
            ),
        (config) => _targetIOSSdk = _target.os == OS.iOS
            ? IOSSdk.fromString(
                config.getString(
                  IOSSdk.configKey,
                  validValues: IOSSdk.values.map((e) => '$e'),
                ),
              )
            : null,
        (config) => _cc = config.getOptionalPath(ccConfigKey, mustExist: true),
        (config) => _ld = config.getOptionalPath(ldConfigKey, mustExist: true),
        (config) => _packaging = PackagingPreference.fromString(
              config.getString(
                PackagingPreference.configKey,
                validValues: PackagingPreference.values.map((e) => '$e'),
              ),
            ),
      ];

  Map<String, Object> toYamlEncoding() => {
        outDirConfigKey: _outDir.path,
        Target.configKey: _target.toString(),
        if (_targetIOSSdk != null) IOSSdk.configKey: _targetIOSSdk.toString(),
        if (_cc != null) ccConfigKey: _cc!.path,
        if (_ld != null) ldConfigKey: _ld!.path,
        PackagingPreference.configKey: _packaging.toString(),
      };

  @override
  bool operator ==(Object other) {
    if (other is! NativeAssetsCliConfig) {
      return false;
    }
    if (other._outDir != _outDir) return false;
    if (other._target != _target) return false;
    if (other._targetIOSSdk != _targetIOSSdk) return false;
    if (other._cc != _cc) return false;
    if (other._ld != _ld) return false;
    if (other._packaging != _packaging) return false;
    return true;
  }

  @override
  int get hashCode =>
      _outDir.path.hashCode ^
      _target.hashCode ^
      _targetIOSSdk.hashCode ^
      _cc.hashCode ^
      _ld.hashCode ^
      _packaging.hashCode;

  @override
  String toString() => 'NativeAssetsCliConfig(${toYamlEncoding()})';
}
