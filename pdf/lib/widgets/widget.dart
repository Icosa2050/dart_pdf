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

class Context {
  final PdfPage page;
  final PdfGraphics canvas;

  const Context(this.page, this.canvas);
}

abstract class Widget {
  PdfRect box;
  int flex = 0;
  FlexFit fit = FlexFit.loose;

  Widget();

  @protected
  void layout(BoxConstraints constraints, {parentUsesSize = false});

  @protected
  void paint(Context context) {
    assert(() {
      if (Document.debug) debugPaint(context);
      return true;
    }());
  }

  @protected
  void debugPaint(Context context) {
    context.canvas
      ..setColor(PdfColor.purple)
      ..drawRect(box.x, box.y, box.w, box.h)
      ..strokePath();
  }
}

abstract class StatelessWidget extends Widget {
  Widget _widget;

  Widget get child {
    if (_widget == null) _widget = build();
    return _widget;
  }

  StatelessWidget() : super();

  @override
  void layout(BoxConstraints constraints, {parentUsesSize = false}) {
    if (child != null) {
      child.layout(constraints, parentUsesSize: parentUsesSize);
      box = child.box;
    } else {
      box = PdfRect.zero;
    }
  }

  @override
  void paint(Context context) {
    super.paint(context);

    if (child != null) {
      child.paint(context);
    }
  }

  @protected
  Widget build();
}

abstract class SingleChildWidget extends Widget {
  SingleChildWidget({this.child}) : super();

  final Widget child;

  @override
  void paint(Context context) {
    super.paint(context);

    if (child != null) {
      child.paint(context);
    }
  }
}

abstract class MultiChildWidget extends Widget {
  MultiChildWidget({this.children = const <Widget>[]}) : super();

  final List<Widget> children;
}

class LimitedBox extends SingleChildWidget {
  LimitedBox({
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    Widget child,
  })  : assert(maxWidth != null && maxWidth >= 0.0),
        assert(maxHeight != null && maxHeight >= 0.0),
        super(child: child);

  final double maxWidth;

  final double maxHeight;

  BoxConstraints _limitConstraints(BoxConstraints constraints) {
    return BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.hasBoundedWidth
            ? constraints.maxWidth
            : constraints.constrainWidth(maxWidth),
        minHeight: constraints.minHeight,
        maxHeight: constraints.hasBoundedHeight
            ? constraints.maxHeight
            : constraints.constrainHeight(maxHeight));
  }

  @override
  void layout(BoxConstraints constraints, {parentUsesSize = false}) {
    PdfPoint size;
    if (child != null) {
      child.layout(_limitConstraints(constraints), parentUsesSize: true);
      size = constraints.constrain(child.box.size);
    } else {
      size = _limitConstraints(constraints).constrain(PdfPoint.zero);
    }
    box = PdfRect(box.x, box.y, size.x, size.y);
  }
}
