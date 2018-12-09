import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:test/test.dart';

void main() {
  test('Pdf', () {
    Document.debug = true;

    var pdf = Document(deflate: zlib.encode);

    final helvetica = PdfFont.helvetica(pdf.document);
    final symbol = PdfFont.zapfDingbats(pdf.document);

    final imData = zlib.decode(base64.decode(
        "eJz7//8/w388uOTCT6a4Ez96Q47++I+OI479mEVALyNU7z9seuNP/mAm196Ekz8YR+0dWHtBmJC9S+7/Zog89iMIKLYaHQPVJGLTD7MXpDfq+I9goNhPdPPDjv3YlnH6Jye6+2H21l/6yeB/4HsSDr1bQXrRwq8HqHcGyF6QXp9933N0tn/7Y7vn+/9gLPaih0PDlV9MIAzVm6ez7dsfzW3f/oMwzAx0e7FhoJutdbcj9MKw9frnL2J2POfBpxeEg478YLba/X0Wsl6lBXf+s0bP/s8ePXeWePJCvPEJNYMRZIYWSO/cq/9Z/Nv+M4bO+M8YDjFDJGkhzvSE7A6jRTdnsQR2wfXCMLHuMC5byyidvGgWE5JeZDOIcYdR+TpmkBno+mFmAAC+DGhl"));
    final im = PdfImage(pdf.document, image: imData, width: 16, height: 20);

    final shape =
        "M 2.424 26.712 L 2.424 26.712 C 2.076 26.712 1.742 26.599 1.457 26.386 C 0.416 25.605 0.276 24.736 0.342 24.144 C 0.524 22.516 2.537 20.812 6.327 19.076 C 7.831 15.78 9.262 11.719 10.115 8.326 C 9.117 6.154 8.147 3.336 8.854 1.683 C 9.102 1.104 9.411 0.66 9.988 0.468 C 10.216 0.392 10.792 0.296 11.004 0.296 C 11.508 0.296 11.951 0.945 12.265 1.345 C 12.56 1.721 13.229 2.518 11.892 8.147 C 13.24 10.931 15.15 13.767 16.98 15.709 C 18.291 15.472 19.419 15.351 20.338 15.351 C 21.904 15.351 22.853 15.716 23.24 16.468 C 23.56 17.09 23.429 17.817 22.85 18.628 C 22.293 19.407 21.525 19.819 20.63 19.819 C 19.414 19.819 17.998 19.051 16.419 17.534 C 13.582 18.127 10.269 19.185 7.591 20.356 C 6.755 22.13 5.954 23.559 5.208 24.607 C 4.183 26.042 3.299 26.712 2.424 26.712 Z M 5.086 21.586 C 2.949 22.787 2.078 23.774 2.015 24.33 C 2.005 24.422 1.978 24.664 2.446 25.022 C 2.595 24.975 3.465 24.578 5.086 21.586 Z M 18.723 17.144 C 19.538 17.771 19.737 18.088 20.27 18.088 C 20.504 18.088 21.171 18.078 21.48 17.647 C 21.629 17.438 21.687 17.304 21.71 17.232 C 21.587 17.167 21.424 17.035 20.535 17.035 C 20.03 17.036 19.395 17.058 18.723 17.144 Z M 11.253 10.562 C 10.538 13.036 9.594 15.707 8.579 18.126 C 10.669 17.315 12.941 16.607 15.075 16.106 C 13.725 14.538 12.376 12.58 11.253 10.562 Z M 10.646 2.1 C 10.548 2.133 9.316 3.857 10.742 5.316 C 11.691 3.201 10.689 2.086 10.646 2.1 Z";

    pdf.addPage(Page(
        pageFormat: PdfPageFormat(400.0, 400.0),
        child: Column(children: <Widget>[
          Text("Hello World", font: helvetica),
          Text("How are you?", font: helvetica, fontSize: 10.0),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Image(im),
            Shape(shape, width: 24.0, height: 27.0, fillColor: PdfColor.red),
            Column(children: <Widget>[
              Text("(", font: symbol),
              Text("4", font: symbol),
            ]),
          ]),
          Text("that's all Folks!", font: helvetica, fontSize: 10.0),
        ])));

    var file = File('widgets.pdf');
    file.writeAsBytesSync(pdf.document.save());
  });
}
