/*
 * Copyright (C) 2018, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General  License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';

typedef LayoutCallback = FutureOr<List<int>> Function(PdfPageFormat format);

class Printing {
  static const MethodChannel _channel = MethodChannel('printing');
  static LayoutCallback _onLayout;

  static Future<dynamic> _handleMethod(MethodCall call) async {
    print(call.method);
    print(call.arguments);
    switch (call.method) {
      case "onLayout":
        final bytes = await _onLayout(
            PdfPageFormat(call.arguments['width'], call.arguments['height']));
        final Map<String, dynamic> params = <String, dynamic>{
          'doc': Uint8List.fromList(bytes),
        };
        await _channel.invokeMethod('writePdf', params);
        return Future.value("");
    }
  }

  static Future<Null> layoutPdf(
      {@required LayoutCallback onLayout, String name = "Document"}) async {
//    if (Platform.isIOS) {
//      final bytes = await onLayout(PDFPageFormat.a4);
//      final Map<String, dynamic> params = <String, dynamic>{
//        'doc': new Uint8List.fromList(bytes),
//      };
//      await _channel.invokeMethod('printPdf', params);
//      return;
//    }

    _onLayout = onLayout;

    _channel.setMethodCallHandler(_handleMethod);
    final Map<String, dynamic> params = <String, dynamic>{'name': name};
    await _channel.invokeMethod('printPdf', params);
    print('done');
  }

  @deprecated
  static Future<Null> printPdf({PdfDocument document, List<int> bytes}) async {
    assert(document != null || bytes != null);
    assert(!(document == null && bytes == null));

    layoutPdf(
        onLayout: (PdfPageFormat format) =>
            document != null ? document.save() : bytes);
  }

  static Future<Null> sharePdf(
      {PdfDocument document, List<int> bytes, Rect bounds}) async {
    assert(document != null || bytes != null);
    assert(!(document == null && bytes == null));

    if (document != null) bytes = document.save();

    if (bounds == null) {
      bounds = Rect.fromCircle(center: Offset.zero, radius: 10.0);
    }

    final Map<String, dynamic> params = <String, dynamic>{
      'doc': Uint8List.fromList(bytes),
      'x': bounds.left,
      'y': bounds.top,
      'w': bounds.width,
      'h': bounds.height,
    };
    await _channel.invokeMethod('sharePdf', params);
  }
}
