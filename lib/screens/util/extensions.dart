import 'dart:ui';

import 'package:sifra/screens/util/color.dart';

extension StringExtensions on String {
  bool isValidColor() {
    if (startsWith('#')) {
      // Check if the color string is a valid hex color code
      String hexColor = substring(1);
      if (hexColor.length == 6 || hexColor.length == 8) {
        return RegExp(r'^[0-9a-fA-F]+$').hasMatch(hexColor);
      }
    } else {
      // Check if the color string is a valid color name
      try {
        Color color = Color(int.parse(this));
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  String getColorName() {
   var color = this.toUpperCase();
    if (color.length < 3 || color.length > 7) {
      return 'Invalid Color: $color';
    }
    if (color.length % 3 == 0) {
      color = '#$color';
    }
    if (color.length == 4) {
      color = '#${color[1]}${color[1]}${color[2]}${color[2]}${color[3]}${color[3]}';
    }

    final result = _name(color);
    return result[1];
  }
}




List<int> _rgb(String color) {
  return [
    int.parse(color.substring(1, 3), radix: 16),
    int.parse(color.substring(3, 5), radix: 16),
    int.parse(color.substring(5, 7), radix: 16),
  ];
}

List<int> _hsl(String color) {
  final rgb = _rgb(color);
  final r = rgb[0] / 255;
  final g = rgb[1] / 255;
  final b = rgb[2] / 255;

  final max = [r, g, b].reduce((a, b) => a > b ? a : b);
  final min = [r, g, b].reduce((a, b) => a < b ? a : b);
  final delta = max - min;

  var h = 0.0;
  var s = 0.0;
  final l = (min + max) / 2;

  if (l > 0 && l < 1) {
    s = delta / (l < 0.5 ? (2 * l) : (2 - 2 * l));
  }

  if (delta > 0) {
    if (max == r && max != g) h += (g - b) / delta;
    if (max == g && max != b) h += (2 + (b - r) / delta);
    if (max == b && max != r) h += (4 + (r - g) / delta);
    h /= 6;
  }

  return [
    (h * 255).round(),
    (s * 255).round(),
    (l * 255).round(),
  ];
}

List<dynamic> _name(String color) {
  final exactMatch = colors[color.toUpperCase()];

  if (exactMatch != null) {
    return [color, exactMatch, true];
  }

  final rgb = _rgb(color);
  final r = rgb[0];
  final g = rgb[1];
  final b = rgb[2];
  final hsl = _hsl(color);
  final h = hsl[0];
  final s = hsl[1];
  final l = hsl[2];

  var cl = '';
  var df = -1;

  for (final entry in colors.entries) {
    final colorCode = entry.key;
    final colorName = entry.value;

    final ndf1 = (r - int.parse(colorCode.substring(0, 2), radix: 16)).abs() +
        (g - int.parse(colorCode.substring(2, 4), radix: 16)).abs() +
        (b - int.parse(colorCode.substring(4, 6), radix: 16)).abs();
    final ndf2 = (h - _hsl(colorCode)[0]).abs() +
        (s - _hsl(colorCode)[1]).abs() +
        (l - _hsl(colorCode)[2]).abs();
    final ndf = ndf1 + ndf2 * 2;
    if (df < 0 || df > ndf) {
      df = ndf;
      cl = colorCode;
    }
  }

  if (cl.isEmpty) {
    return ['#000000', 'Invalid Color: $color', false];
  } else {
    return ['#$cl', colors[cl]!, false];
  }
}
