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

enum FlexFit {
  tight,
  loose,
}

enum Axis {
  horizontal,
  vertical,
}

enum MainAxisSize {
  min,
  max,
}

enum MainAxisAlignment {
  start,
  end,
  center,
  spaceBetween,
  spaceAround,
  spaceEvenly,
}

enum CrossAxisAlignment {
  start,
  end,
  center,
  stretch,
}

enum VerticalDirection {
  up,
  down,
}

typedef _ChildSizingFunction = double Function(Widget child, double extent);

class Flex extends MultiChildWidget {
  Flex({
    @required this.direction,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.verticalDirection = VerticalDirection.down,
    List<Widget> children = const <Widget>[],
  })  : assert(direction != null),
        assert(mainAxisAlignment != null),
        assert(mainAxisSize != null),
        assert(crossAxisAlignment != null),
        super(children: children);

  final Axis direction;

  final MainAxisAlignment mainAxisAlignment;

  final MainAxisSize mainAxisSize;

  final CrossAxisAlignment crossAxisAlignment;

  final VerticalDirection verticalDirection;

  double _getIntrinsicSize(
      {Axis sizingDirection,
      double
          extent, // the extent in the direction that isn't the sizing direction
      _ChildSizingFunction
          childSize // a method to find the size in the sizing direction
      }) {
    if (direction == sizingDirection) {
      // INTRINSIC MAIN SIZE
      // Intrinsic main size is the smallest size the flex container can take
      // while maintaining the min/max-content contributions of its flex items.
      double totalFlex = 0.0;
      double inflexibleSpace = 0.0;
      double maxFlexFractionSoFar = 0.0;

      for (var child in children) {
        final int flex = child.flex;
        totalFlex += flex;
        if (flex > 0) {
          final double flexFraction = childSize(child, extent) / child.flex;
          maxFlexFractionSoFar = math.max(maxFlexFractionSoFar, flexFraction);
        } else {
          inflexibleSpace += childSize(child, extent);
        }
      }
      return maxFlexFractionSoFar * totalFlex + inflexibleSpace;
    } else {
      // INTRINSIC CROSS SIZE
      // Intrinsic cross size is the max of the intrinsic cross sizes of the
      // children, after the flexible children are fit into the available space,
      // with the children sized using their max intrinsic dimensions.
      // TODO(ianh): Support baseline alignment.

      // Get inflexible space using the max intrinsic dimensions of fixed children in the main direction.
      final double availableMainSpace = extent;
      int totalFlex = 0;
      double inflexibleSpace = 0.0;
      double maxCrossSize = 0.0;
      for (var child in children) {
        final int flex = child.flex;
        totalFlex += flex;
        double mainSize;
        double crossSize;
        if (flex == 0) {
          switch (direction) {
            case Axis.horizontal:
              mainSize = child.box.w;
              crossSize = childSize(child, mainSize);
              break;
            case Axis.vertical:
              mainSize = child.box.h;
              crossSize = childSize(child, mainSize);
              break;
          }
          inflexibleSpace += mainSize;
          maxCrossSize = math.max(maxCrossSize, crossSize);
        }
      }

      // Determine the spacePerFlex by allocating the remaining available space.
      // When you're overconstrained spacePerFlex can be negative.
      final double spacePerFlex =
          math.max(0.0, (availableMainSpace - inflexibleSpace) / totalFlex);

      // Size remaining (flexible) items, find the maximum cross size.
      for (var child in children) {
        final int flex = child.flex;
        if (flex > 0)
          maxCrossSize =
              math.max(maxCrossSize, childSize(child, spacePerFlex * flex));
      }

      return maxCrossSize;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _getIntrinsicSize(
        sizingDirection: Axis.horizontal,
        extent: height,
        childSize: (Widget child, double extent) => child.box.w);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _getIntrinsicSize(
        sizingDirection: Axis.horizontal,
        extent: height,
        childSize: (Widget child, double extent) => child.box.w);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _getIntrinsicSize(
        sizingDirection: Axis.vertical,
        extent: width,
        childSize: (Widget child, double extent) => child.box.h);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _getIntrinsicSize(
        sizingDirection: Axis.vertical,
        extent: width,
        childSize: (Widget child, double extent) => child.box.h);
  }

  double _getCrossSize(Widget child) {
    switch (direction) {
      case Axis.horizontal:
        return child.box.h;
      case Axis.vertical:
        return child.box.w;
    }
    return null;
  }

  double _getMainSize(Widget child) {
    switch (direction) {
      case Axis.horizontal:
        return child.box.w;
      case Axis.vertical:
        return child.box.h;
    }
    return null;
  }

  @override
  void layout(BoxConstraints constraints, {parentUsesSize = false}) {
    // Determine used flex factor, size inflexible items, calculate free space.
    int totalFlex = 0;
    final totalChildren = children.length;
    Widget lastFlexChild;
    assert(constraints != null);
    final double maxMainSize = direction == Axis.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
    final bool canFlex = maxMainSize < double.infinity;

    double crossSize = 0.0;
    double allocatedSize =
        0.0; // Sum of the sizes of the non-flexible children.

    for (var child in children) {
      final int flex = child.flex;
      if (flex > 0) {
        assert(() {
          final String dimension =
              direction == Axis.horizontal ? 'width' : 'height';
          if (!canFlex &&
              (mainAxisSize == MainAxisSize.max ||
                  child.fit == FlexFit.tight)) {
            throw Exception(
                'Flex children have non-zero flex but incoming $dimension constraints are unbounded.');
          } else {
            return true;
          }
        }());
        totalFlex += child.flex;
      } else {
        BoxConstraints innerConstraints;
        if (crossAxisAlignment == CrossAxisAlignment.stretch) {
          switch (direction) {
            case Axis.horizontal:
              innerConstraints = BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxHeight: constraints.maxHeight);
              break;
            case Axis.vertical:
              innerConstraints = BoxConstraints(
                  minWidth: constraints.maxWidth,
                  maxWidth: constraints.maxWidth);
              break;
          }
        } else {
          switch (direction) {
            case Axis.horizontal:
              innerConstraints =
                  BoxConstraints(maxHeight: constraints.maxHeight);
              break;
            case Axis.vertical:
              innerConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
              break;
          }
        }
        child.layout(innerConstraints, parentUsesSize: true);
        allocatedSize += _getMainSize(child);
        crossSize = math.max(crossSize, _getCrossSize(child));
      }
      lastFlexChild = child;
    }

    // Distribute free space to flexible children, and determine baseline.
    final double freeSpace =
        math.max(0.0, (canFlex ? maxMainSize : 0.0) - allocatedSize);
    double allocatedFlexSpace = 0.0;
    if (totalFlex > 0) {
      final double spacePerFlex =
          canFlex && totalFlex > 0 ? (freeSpace / totalFlex) : double.nan;

      for (var child in children) {
        final int flex = child.flex;
        if (flex > 0) {
          final double maxChildExtent = canFlex
              ? (child == lastFlexChild
                  ? (freeSpace - allocatedFlexSpace)
                  : spacePerFlex * flex)
              : double.infinity;
          double minChildExtent;
          switch (child.fit) {
            case FlexFit.tight:
              assert(maxChildExtent < double.infinity);
              minChildExtent = maxChildExtent;
              break;
            case FlexFit.loose:
              minChildExtent = 0.0;
              break;
          }
          assert(minChildExtent != null);
          BoxConstraints innerConstraints;
          if (crossAxisAlignment == CrossAxisAlignment.stretch) {
            switch (direction) {
              case Axis.horizontal:
                innerConstraints = BoxConstraints(
                    minWidth: minChildExtent,
                    maxWidth: maxChildExtent,
                    minHeight: constraints.maxHeight,
                    maxHeight: constraints.maxHeight);
                break;
              case Axis.vertical:
                innerConstraints = BoxConstraints(
                    minWidth: constraints.maxWidth,
                    maxWidth: constraints.maxWidth,
                    minHeight: minChildExtent,
                    maxHeight: maxChildExtent);
                break;
            }
          } else {
            switch (direction) {
              case Axis.horizontal:
                innerConstraints = BoxConstraints(
                    minWidth: minChildExtent,
                    maxWidth: maxChildExtent,
                    maxHeight: constraints.maxHeight);
                break;
              case Axis.vertical:
                innerConstraints = BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    minHeight: minChildExtent,
                    maxHeight: maxChildExtent);
                break;
            }
          }
          child.layout(innerConstraints, parentUsesSize: true);
          final double childSize = _getMainSize(child);
          assert(childSize <= maxChildExtent);
          allocatedSize += childSize;
          allocatedFlexSpace += maxChildExtent;
          crossSize = math.max(crossSize, _getCrossSize(child));
        }
      }
    }

    // Align items along the main axis.
    final double idealSize = canFlex && mainAxisSize == MainAxisSize.max
        ? maxMainSize
        : allocatedSize;
    double actualSize;
    double actualSizeDelta;
    PdfPoint size;
    switch (direction) {
      case Axis.horizontal:
        size = constraints.constrain(PdfPoint(idealSize, crossSize));
        actualSize = size.x;
        crossSize = size.y;

        break;
      case Axis.vertical:
        size = constraints.constrain(PdfPoint(crossSize, idealSize));
        actualSize = size.y;
        crossSize = size.x;
        break;
    }

    box = PdfRect.fromPoints(PdfPoint.zero, size);
    actualSizeDelta = actualSize - allocatedSize;

    final double remainingSpace = math.max(0.0, actualSizeDelta);
    double leadingSpace;
    double betweenSpace;
    final bool flipMainAxis = (verticalDirection == VerticalDirection.down &&
            direction == Axis.vertical) ||
        (verticalDirection == VerticalDirection.up &&
            direction == Axis.horizontal);
    switch (mainAxisAlignment) {
      case MainAxisAlignment.start:
        leadingSpace = 0.0;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.end:
        leadingSpace = remainingSpace;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.center:
        leadingSpace = remainingSpace / 2.0;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.spaceBetween:
        leadingSpace = 0.0;
        betweenSpace =
            totalChildren > 1 ? remainingSpace / (totalChildren - 1) : 0.0;
        break;
      case MainAxisAlignment.spaceAround:
        betweenSpace = totalChildren > 0 ? remainingSpace / totalChildren : 0.0;
        leadingSpace = betweenSpace / 2.0;
        break;
      case MainAxisAlignment.spaceEvenly:
        betweenSpace =
            totalChildren > 0 ? remainingSpace / (totalChildren + 1) : 0.0;
        leadingSpace = betweenSpace;
        break;
    }

    // Position elements
    double childMainPosition =
        flipMainAxis ? actualSize - leadingSpace : leadingSpace;
    for (var child in children) {
      double childCrossPosition;
      switch (crossAxisAlignment) {
        case CrossAxisAlignment.start:
        case CrossAxisAlignment.end:
          childCrossPosition = 0.0;
          break;
        case CrossAxisAlignment.center:
          childCrossPosition = crossSize / 2.0 - _getCrossSize(child) / 2.0;
          break;
        case CrossAxisAlignment.stretch:
          childCrossPosition = 0.0;
          break;
      }

      if (flipMainAxis) childMainPosition -= _getMainSize(child);
      switch (direction) {
        case Axis.horizontal:
          child.box = PdfRect(box.x + childMainPosition,
              box.y + childCrossPosition, child.box.w, child.box.h);
          break;
        case Axis.vertical:
          child.box = PdfRect(
              childCrossPosition, childMainPosition, child.box.w, child.box.h);
          break;
      }
      if (flipMainAxis) {
        childMainPosition -= betweenSpace;
      } else {
        childMainPosition += _getMainSize(child) + betweenSpace;
      }
    }
  }

  @override
  void paint(Context context) {
    super.paint(context);

    for (var child in children) {
      final mat = Matrix4.identity();
      mat.translate(box.x, box.y);
      context.canvas
        ..saveContext()
        ..setTransform(mat);
      child.paint(context);
      context.canvas.restoreContext();
    }
  }
}

class Row extends Flex {
  Row({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    VerticalDirection verticalDirection = VerticalDirection.down,
    List<Widget> children = const <Widget>[],
  }) : super(
          children: children,
          direction: Axis.horizontal,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          verticalDirection: verticalDirection,
        );
}

class Column extends Flex {
  Column({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    VerticalDirection verticalDirection = VerticalDirection.down,
    List<Widget> children = const <Widget>[],
  }) : super(
          children: children,
          direction: Axis.vertical,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          verticalDirection: verticalDirection,
        );
}

class Expanded extends SingleChildWidget {
  Expanded({
    int flex = 1,
    @required Widget child,
  }) : super(child: child) {
    this.flex = flex;
    this.fit = FlexFit.tight;
  }

  @override
  void layout(BoxConstraints constraints, {parentUsesSize = false}) {
    child.layout(constraints, parentUsesSize: parentUsesSize);
    box = child.box;
  }
}
