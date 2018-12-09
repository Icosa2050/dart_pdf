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

class Text extends Widget {
  final String text;
  final PdfFont font;
  final double fontSize;
  final PdfColor color;
  PdfPoint _origin;

  Text(this.text,
      {@required this.font, this.fontSize = 20.0, this.color = PdfColor.black});

  @override
  void layout(BoxConstraints constraints, {parentUsesSize = false}) {
    box = font.stringBounds(text) * fontSize;
    _origin = box.offset;
    box = PdfRect.fromPoints(PdfPoint.zero, box.size);
  }

  @override
  void paint(Context context) {
    super.paint(context);

    context.canvas
      ..setColor(color)
      ..drawString(font, fontSize, text, box.x + _origin.x, box.y - _origin.y);
  }
}
