@TestOn('linux')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Linux native library configures with its CUPS dependency', () async {
    final fixture = await Directory.systemTemp.createTemp(
      'printing-ffi-cmake-test-',
    );
    addTearDown(() async {
      if (fixture.existsSync()) {
        await fixture.delete(recursive: true);
      }
    });

    final sourceDirectory = Directory.current.uri.resolve('src').toFilePath();
    final pkgConfigDirectory = await Directory(
      '${fixture.path}/pkgconfig',
    ).create();
    await Directory('${fixture.path}/cups/include').create(recursive: true);
    await Directory('${fixture.path}/cups/lib').create(recursive: true);
    await File('${pkgConfigDirectory.path}/cups.pc').writeAsString('''
prefix=${fixture.path}/cups
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: CUPS
Description: Test fixture for the CUPS imported target
Version: 2.4.7
Libs: -L\${libdir} -lcups
Cflags: -I\${includedir}
''');
    await File('${fixture.path}/CMakeLists.txt').writeAsString('''
cmake_minimum_required(VERSION 3.10)
project(printing_ffi_linux_configure_test LANGUAGES C)
add_subdirectory("$sourceDirectory" printing_ffi)
''');

    final buildDirectory = '${fixture.path}/build';
    final result = await Process.run(
      'cmake',
      [
        '-S',
        fixture.path,
        '-B',
        buildDirectory,
      ],
      environment: {
        ...Platform.environment,
        'PKG_CONFIG_LIBDIR': pkgConfigDirectory.path,
        'PKG_CONFIG_PATH': pkgConfigDirectory.path,
      },
    );

    expect(
      result.exitCode,
      0,
      reason: 'CMake configuration failed:\n${result.stdout}\n${result.stderr}',
    );
  });
}
