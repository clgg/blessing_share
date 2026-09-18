import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_common/ui_common.dart';

void main() {
  test('AppDimens exposes stable page paddings', () {
    expect(AppDimens.pagePadding.left, AppDimens.spaceLg);
    expect(AppDimens.buttonHeight, 56);
  });
}
