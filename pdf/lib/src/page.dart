/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

part of pdf;

class PdfPage extends PdfObject {
  /// This is this page format, ie the size of the page, margins, and rotation
  final PdfPageFormat pageFormat;

  /// This holds the contents of the page.
  List<PdfObjectStream> contents = [];

  /// Object ID that contains a thumbnail sketch of the page.
  /// -1 indicates no thumbnail.
  PdfObject thumbnail;

  /// This holds any Annotations contained within this page.
  List<PdfAnnot> annotations = [];

  /// The fonts associated with this page
  final fonts = Map<String, PdfFont>();

  /// The xobjects or other images in the pdf
  final xObjects = Map<String, PdfXObject>();

  /// This constructs a Page object, which will hold any contents for this
  /// page.
  ///
  /// Once created, it is added to the document via the [PdfDocument.add()] method.
  ///
  /// @param pdfDocument Document
  /// @param pageFormat [PdfPageFormat] describing the page size
  PdfPage(PdfDocument pdfDocument, {this.pageFormat = PdfPageFormat.a4})
      : super(pdfDocument, "/Page") {
    pdfDocument.pdfPageList.pages.add(this);
  }

  /// This returns a [PdfGraphics] object, which can then be used to render
  /// on to this page. If a previous [PdfGraphics] object was used, this object
  /// is appended to the page, and will be drawn over the top of any previous
  /// objects.
  ///
  /// @return a new [PdfGraphics] object to be used to draw this page.
  PdfGraphics getGraphics() {
    var stream = PdfObjectStream(pdfDocument);
    var g = PdfGraphics(this, stream.buf);
    contents.add(stream);
    return g;
  }

  /// This adds an Annotation to the page.
  ///
  /// As with other objects, the annotation must be added to the pdf
  /// document using [PdfDocument.add()] before adding to the page.
  ///
  /// @param ob Annotation to add.
  void addAnnotation(PdfObject ob) {
    annotations.add(ob);
  }

  /// @param os OutputStream to send the object to
  @override
  void _prepare() {
    super._prepare();

    // the /Parent pages object
    params["/Parent"] = pdfDocument.pdfPageList.ref();

    // the /MediaBox for the page size
    params["/MediaBox"] = PdfStream()
      ..putStringArray([0, 0, pageFormat.width, pageFormat.height]);

    // Rotation (if not zero)
//        if(rotate!=0) {
//            os.write("/Rotate ");
//            os.write(Integer.toString(rotate).getBytes());
//            os.write("\n");
//        }

    // the /Contents pages object
    if (contents.length > 0) {
      if (contents.length == 1) {
        params["/Contents"] = contents[0].ref();
      } else {
        params["/Contents"] = PdfStream()..putObjectArray(contents);
      }
    }

    // Now the resources
    /// This holds any resources for this page
    final resources = Map<String, PdfStream>();

    // fonts
    if (fonts.length > 0) {
      resources["/Font"] = PdfStream()..putObjectDictionary(fonts);
    }

    // Now the XObjects
    if (xObjects.length > 0) {
      resources["/XObject"] = PdfStream()..putObjectDictionary(xObjects);
    }

    params["/Resources"] = PdfStream.dictionary(resources);

    // The thumbnail
    if (thumbnail != null) {
      params["/Thumb"] = thumbnail.ref();
    }

    // The /Annots object
    if (annotations.length > 0) {
      params["/Annots"] = PdfStream()..putObjectArray(annotations);
    }
  }
}
