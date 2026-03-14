import 'dart:io';

import 'trimmer2_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../appwrite_interface.dart';
import '../../custom_code/widgets/toast.dart';
import '../../platform/audio_recorder_platform.dart';

class FileSelectorWidget extends StatefulWidget {
  const FileSelectorWidget({super.key});

  @override
  State<FileSelectorWidget> createState() => _FileSelectorWidgetState();
}

class _FileSelectorWidgetState extends State<FileSelectorWidget>  with AudioRecorderMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Trimmer"),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              // FilePickerResult? result = await FilePicker.platform.pickFiles(
              //   type: FileType.audio,
              //   allowCompression: false,
              // );


              await setMaxVersionNumbersCurrentSessionStep();
              if (currentSessionStep!.maxAudioVersion! < 1) {
                toast(
                  context,
                  'No recording stored',
                  ToastKind.warning,
                );
              } else {
                String localPath = await getPath(
                    sessionStepId: currentSessionStep!.reference!.path!,
                    fileKind: FileKind.audio,
                    version: currentSessionStep!.maxAudioVersion!);

                bool ok = await copyStorageFiletoLocal(
                  bucketId: artTheopyAIRaudiosRef.path,
                  fileId: generateAudioStorageFilename(
                    currentSessionStep!,
                    currentSessionStep!.maxAudioVersion!,
                  ),
                  localPath: localPath,
                  fileKind: FileKind.audio,
                );


                File file = File(localPath);
                // ignore: use_build_context_synchronously
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return AudioTrimmerView(file);
                  }),
                );
              }
            },
            child: const Text("Select File")),
      ),
    );
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