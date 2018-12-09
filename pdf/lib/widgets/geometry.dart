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

class BoxConstraints {
  /// The minimum width that satisfies the constraints.
  final double minWidth;

  /// The maximum width that satisfies the constraints.
  ///
  /// Might be [double.infinity].
  final double maxWidth;

  /// The minimum height that satisfies the constraints.
  final double minHeight;

  /// The maximum height that satisfies the constraints.
  ///
  /// Might be [double.infinity].
  final double maxHeight;

  /// Creates box constraints with the given constraints.
  const BoxConstraints(
      {this.minWidth = 0.0,
      this.maxWidth = double.infinity,
      this.minHeight = 0.0,
      this.maxHeight = double.infinity});

  bool get hasBoundedWidth => maxWidth < double.infinity;

  bool get hasBoundedHeight => maxHeight < double.infinity;

  bool get hasInfiniteWidth => minWidth >= double.infinity;

  bool get hasInfiniteHeight => minHeight >= double.infinity;

  PdfPoint constrain(PdfPoint size) {
    final result = PdfPoint(constrainWidth(size.x), constrainHeight(size.y));
    return result;
  }

  double constrainWidth([double width = double.infinity]) {
    return width.clamp(minWidth, maxWidth);
  }

  double constrainHeight([double height = double.infinity]) {
    return height.clamp(minHeight, maxHeight);
  }
}
