import 'dart:ui';
import 'package:sifra/screens/util/color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_parsing/path_parsing.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';
extension StringExtensions on String {
  bool isValidColor()=>startsWith('#');

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
    int.parse(color.substring(5, 6), radix: 16),
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




// ... (existing code)



void convertSvgToVectorXml(String svgFilePath, String outputDir) {
  // Read the SVG file
  final svgFile = File(svgFilePath);
  final svgContent = svgFile.readAsStringSync();

  // Parse the SVG content
  final svgDocument = XmlDocument.parse(svgContent);
  final svgElement = svgDocument.rootElement;

  // Create a new XML builder for the vector drawable
  final builder = XmlBuilder();

  // Extract width and height values
  final widthStr = svgElement.getAttribute('width');
  final heightStr = svgElement.getAttribute('height');

  // Remove non-numeric characters and append 'dp' unit
  final width = '${widthStr?.replaceAll(RegExp(r'[^0-9.]'), '')}dp';
  final height = '${heightStr?.replaceAll(RegExp(r'[^0-9.]'), '')}dp';

  // Start building the vector drawable
  builder.processing('xml', 'version="1.0" encoding="utf-8"');
  builder.element('vector', nest: () {
    builder.attribute('xmlns:android', 'http://schemas.android.com/apk/res/android');
    builder.attribute('android:width', width);
    builder.attribute('android:height', height);
    builder.attribute('android:viewportWidth', '${svgElement.getAttribute('viewBox')?.split(' ')[2]}');
    builder.attribute('android:viewportHeight', '${svgElement.getAttribute('viewBox')?.split(' ')[3]}');

    // Convert SVG elements to vector drawable paths
    for (final element in svgElement.children) {
      if (element is XmlElement && element.name.local == 'path') {
        builder.element('path', nest: () {
          final opacity = element.getAttribute('opacity');
          if (opacity != null) {
            builder.attribute('android:fillAlpha', opacity);
          }

          final fillRule = element.getAttribute('fill-rule');
          if (fillRule != null) {
            builder.attribute('android:fillType', fillRule == 'evenodd' ? 'evenOdd' : 'nonZero');
          }

          final clipRule = element.getAttribute('clip-rule');
          if (clipRule != null) {
            builder.attribute('android:clipToOutline', clipRule == 'evenodd' ? 'true' : 'false');
          }

          final fillColor = element.getAttribute('fill');
          if (fillColor != null && fillColor != 'none') {
            builder.attribute('android:fillColor', fillColor.startsWith('#') ? fillColor : '#$fillColor');
          } else {
            builder.attribute('android:fillColor', '#00000000');
          }

          builder.attribute('android:pathData', '${element.getAttribute('d')}');
        });
      }
    }
  });


  // Generate the vector drawable XML
  final vectorXml = builder.buildDocument();

  // Create the output directory if it doesn't exist
 /* final outputDirectory = Directory(outputDir);
  if (!outputDirectory.existsSync()) {
    outputDirectory.createSync(recursive: true);
  }*/

  // Write the vector drawable XML to a file
  final outputFile = File(outputDir);
  outputFile.writeAsStringSync(vectorXml.toXmlString(pretty: true));

  print('Vector drawable generated successfully: ${outputFile.path}');
}

// ... (existing code)