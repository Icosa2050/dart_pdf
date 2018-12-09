/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
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

part of widget;

class Document {
  static var debug = false;

  final PdfDocument document;

  Document({PdfPageMode pageMode = PdfPageMode.none, DeflateCallback deflate})
      : document = PdfDocument(pageMode: pageMode, deflate: deflate);

  void addPage(Page page) {
    final pdfPage = PdfPage(document, pageFormat: page.pageFormat);
    final canvas = pdfPage.getGraphics();
    final constraints = BoxConstraints(
        maxWidth: page.pageFormat.width, maxHeight: page.pageFormat.height);
    page.layout(constraints);
    final context = Context(pdfPage, canvas);
    page.paint(context);
  }
}

class Page extends StatelessWidget {
  final PdfPageFormat pageFormat;
  final Widget child;

  Page({this.pageFormat = PdfPageFormat.a4, this.child}) : super() {
    box = PdfRect(0.0, 0.0, pageFormat.dimension.x, pageFormat.dimension.y);
  }

  @override
  Widget build() {
    return child;
  }
}
