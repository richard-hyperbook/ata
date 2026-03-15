import 'dart:io';

import 'trimmer2_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../appwrite_interface.dart';
import '../../custom_code/widgets/toast.dart';
import '../../platform/audio_recorder_platform.dart';

class FileSelectorWidget extends StatefulWidget {
  String? filePath;
  String? dirPath;
  int? maxVersion;
  final String sessionStepId;

  FileSelectorWidget(
      {super.key,
      required this.filePath,
      required this.dirPath,
      required this.maxVersion,
      required this.sessionStepId});

  @override
  State<FileSelectorWidget> createState() => _FileSelectorWidgetState();
}

class _FileSelectorWidgetState extends State<FileSelectorWidget>
    with AudioRecorderMixin {
  @override
  Widget build(BuildContext context) {
    print('(EAT1)${widget.filePath}');
    File file = File(widget.filePath!);
    return AudioTrimmerView(
        file: file,
        dirPath: widget.dirPath!,
        maxVersion: widget.maxVersion!,
        sessionStepId: widget.sessionStepId);
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - (strength as num);
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
