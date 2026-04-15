import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_audio_trimmer/native_audio_trimmer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../appwrite_interface.dart';
import '/../custom_code/widgets/toast.dart';
import '../../app_state.dart';
import '../../localDB.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class Trimmer3 extends StatefulWidget {
  Trimmer3({
    Key? key,
    required this.sessionStepId,
    required this.duration,
  }) : super(key: key);
  final String? sessionStepId;
  final double? duration;

  @override
  State<Trimmer3> createState() => _Trimmer3State();
}

class _Trimmer3State extends State<Trimmer3> {
  String _trimStatus = 'Idle';
  String? _selectedFilePath;
  String? _outputFilePath;
  bool _isLoading = false;
  double _startTime = 0.0;
  double _endTime = 5.0;
  late AudioPlayer player = AudioPlayer();
  // aplayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _selectedFilePath = appDirPath! + '/aac' + widget.sessionStepId! + '.aac';
    _endTime = widget.duration!;
    print("(EP0)${_selectedFilePath}....${widget.duration}");
  }

  Future<void> _pickAudioFile() async {
    try {
      // FilePickerResult? result = await FilePicker/*.platform*/.pickFiles(
      //   type: FileType.audio,
      // );

      if (widget.sessionStepId != null) {
        setState(() {
          _selectedFilePath = appDirPath! + '/aac' + widget.sessionStepId! + '.aac';
          /*result.files.single.path*/;
          print('(EP2)${_selectedFilePath}');
          _trimStatus = 'File selected: ${_selectedFilePath!.split('/').last}';
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _trimStatus = 'Failed to pick file: ${e.message}';
      });
    }
  }

  Future<void> _trimAudio() async {
    setState(() {
      _isLoading = true;
      _trimStatus = 'Trimming...';
    });
    try {
      // Get temp directory to save the trimmed file
      final directory = await getTemporaryDirectory();
      final outputPath = '${directory.path}/m4a${widget.sessionStepId}.m4a';
      _outputFilePath = outputPath;
      // Trim audio
      final result = await NativeAudioTrimmer.trimAudio(
        inputPath: _selectedFilePath!,
        outputPath: outputPath,
        startTimeInSeconds: _startTime,
        endTimeInSeconds: _endTime,
      );
      setState(() {
        _trimStatus = 'Trim result: $result\nOutput: $outputPath';
      });
    } on PlatformException catch (e) {
      setState(() {
        _trimStatus = 'Failed to trim: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playTrimmedAudio() async {
    await player.setSourceDeviceFile(_outputFilePath!);
    await player.resume();
  }

  Future<void> _saveTrimmedAudio() async {
    final directory = await getTemporaryDirectory();
    final tempPath = '${directory.path}/m4a${widget.sessionStepId}.m4a';
    String command = '-y -i ${tempPath} -codec:a aac ${appDirPath}/aac${widget.sessionStepId}.aac';
    await executeFFmpeg(command);
  }

  @override
  Widget build(BuildContext context) {
    _selectedFilePath = appDirPath! + '/aac' + widget.sessionStepId! + '.aac';
    print("(EP1)${widget.sessionStepId}....${_selectedFilePath},,,,${widget.duration}");
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FlutterFlowIconButton(
              showLoadingIndicator: true,
              caption: 'Restore original',
              // captionFontSize: basicFontSize,
              tooltipMessage: 'Restore original recording',
              borderColor: Colors.transparent,
              borderRadius: 0.0,
              borderWidth: 1.0,
              buttonSize: 40.0,
              buttonWidth: kIconButtonWidth,
              icon: Icon(Icons.backup),
              onPressed:
              //(_progressVisibility ? null : () => _saveAudio),
                  () async {
                debugPrint("(AC40)${widget.duration}");
                final String backupPath = appDirPath! + '/BACKUPaac' + widget.sessionStepId! + '.aac';
                File backupFile = File(backupPath);
                if(await backupFile.exists()) {
                  File trimmedFile = await File(backupPath!).copy(
                      appDirPath! + '/aac' + widget.sessionStepId! + '.aac');
                  debugPrint("(AC41)${backupPath}");
                  toast(context, 'Backup audio file restored', ToastKind.success);
                } else {
                  toast(context, 'Backup audio file does not exist', ToastKind.error);
                }
                Navigator.pop(context);
              }),
          SizedBox(height: kIconButtonGap),
          if (_selectedFilePath != null) ...[
            Text(
              'Recording length: ${widget.duration!.toStringAsFixed(2)} seconds',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 20),
            Text('Start Time:', style: FlutterFlowTheme.of(context).bodyMedium),
            Slider(
              value: _startTime,
              min: 0,
              max: widget.duration!,
              divisions: 60,
              label: _startTime.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _startTime = value;
                });
              },
            ),
            Text('End Time:', style: FlutterFlowTheme.of(context).bodyMedium),
            Slider(
              value: _endTime,
              min: 0,
              max: widget.duration!,
              divisions: 60,
              label: _endTime.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _endTime = value;
                });
              },
            ),
            const SizedBox(height: 20),
            FlutterFlowIconButton(
              showLoadingIndicator: true,
              caption: 'Play selection',
              tooltipMessage: 'Play trimmed audio',
              borderColor: Colors.transparent,
              borderRadius: 0.0,
              borderWidth: 1.0,
              buttonSize: 40.0,
              buttonWidth: kSessionIconButtonWidth,
              icon: Icon(Icons.play_arrow),
              onPressed: _isLoading
                  ? null
                  : () async {
                      await _trimAudio();
                      await _playTrimmedAudio();
                    },
            ),
            const SizedBox(height: 20),
            FlutterFlowIconButton(
              showLoadingIndicator: true,
              caption: 'Save selection',
              tooltipMessage: 'Save trimmed audio',
              borderColor: Colors.transparent,
              borderRadius: 0.0,
              borderWidth: 1.0,
              buttonSize: 40.0,
              buttonWidth: kSessionIconButtonWidth,
              icon: Icon(Icons.save),
              onPressed: _isLoading
                  ? null
                  : () async {
                      await _trimAudio;
                      await _saveTrimmedAudio();
                      toast(context, 'Selected audio saved', ToastKind.success);
                    },
            ),
          ],
        ],
      ),
    );
  }
}
