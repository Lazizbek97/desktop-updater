import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('build hook accepts an invocation without code assets', () async {
    final temp = await Directory.systemTemp.createTemp('updater-hook-test-');
    addTearDown(() => temp.delete(recursive: true));
    final root = Directory.current.path;
    final input = File('${temp.path}/input.json');
    await input.writeAsString(jsonEncode({
      'assets': <String, Object>{},
      'config': {'build_asset_types': <String>[], 'linking_enabled': false},
      'out_dir_shared': '${temp.path}/',
      'out_file': '${temp.path}/output.json',
      'package_name': 'velopack_flutter',
      'package_root': '$root/packages/velopack_flutter/',
      'user_defines': <String, Object>{},
    }));
    final result = await Process.run('dart', [
      '--packages=$root/.dart_tool/package_config.json',
      '$root/packages/velopack_flutter/hook/build.dart',
      '--config=${input.path}',
    ]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });
}
