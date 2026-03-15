import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'easy_audio_trimmer.dart';
import 'package:flutter/material.dart';
import '../../appwrite_interface.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '../../localDB.dart';

class AudioTrimmerView extends StatefulWidget {
  final File file;
  final String dirPath;
  final int maxVersion;
  final String sessionStepId;

  const AudioTrimmerView(
      {super.key,
      required this.file,
      required this.dirPath,
      required this.maxVersion,
      required this.sessionStepId});
  @override
  State<AudioTrimmerView> createState() => _AudioTrimmerViewState();
}

class _AudioTrimmerViewState extends State<AudioTrimmerView> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAudio();
  }

  void _loadAudio() async {
    setState(() {
      isLoading = true;
    });
    await _trimmer.loadAudio(audioFile: widget.file);
    setState(() {
      isLoading = false;
    });
  }

  _saveAudio() {
    setState(() {
      _progressVisibility = true;
    });
    final String newFileName =
        'audio' +
        widget.sessionStepId +
        '_' +
        (widget.maxVersion + 1).toString();
    print('(EAT30)${widget.maxVersion}....${widget.dirPath}++++${newFileName}');
    _trimmer.saveTrimmedAudio(
      audioFolderName: 'x',
      audioFileName: newFileName,
      startValue: _startValue,
      endValue: _endValue,
      // outputFormat: ,
      onSave: (outputPath) async {
        setState(() {
          _progressVisibility = false;
        });
        debugPrint('(EAT31)${newFileName}....${outputPath}');
        return newFileName;
      },
    );
  }

  @override
  void dispose() {
    if (mounted) {
      _trimmer.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('(EAT44)${widget.dirPath}....${widget.maxVersion},,,,${widget.file}++++${widget.sessionStepId}');
    return isLoading
        ? const CircularProgressIndicator()
        : Container(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TrimViewer(
                    trimmer: _trimmer,
                    viewerHeight: 100,
                    maxAudioLength: const Duration(seconds: 50),
                    viewerWidth: MediaQuery.of(context).size.width,
                    durationStyle: DurationStyle.FORMAT_MM_SS,
                    backgroundColor: Theme.of(context).primaryColor,
                    barColor: Colors.white,
                    durationTextStyle:
                        TextStyle(color: Theme.of(context).primaryColor),
                    allowAudioSelection: true,
                    editorProperties: TrimEditorProperties(
                      circleSize: 10,
                      borderPaintColor: Colors.black,
                      borderWidth: 4,
                      borderRadius: 5,
                      circlePaintColor: Colors.black,
                    ),
                    areaProperties:
                        TrimAreaProperties.edgeBlur(blurEdges: true),
                    onChangeStart: (value) => _startValue = value,
                    onChangeEnd: (value) => _endValue = value,
                    onChangePlaybackState: (value) {
                      print('(EAT45)${value}');
                      if (mounted) {
                        setState(() => _isPlaying = value);
                      }
                    },
                  ),
                ),
                TextButton(
                  child: _isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Theme.of(context).primaryColor,
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Theme.of(context).primaryColor,
                        ),
                  onPressed: () async {
                    print('(EAT46)${_startValue}....${_endValue}');
                    bool playbackState = await _trimmer.audioPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    print('(EAT47)${playbackState}');
                    setState(() => _isPlaying = playbackState);
                  },
                ),
                FlutterFlowIconButton(
                    showLoadingIndicator: true,
                    caption: 'Save selection',
                    captionFontSize: basicFontSize,
                    tooltipMessage: 'Save selected audio',
                    borderColor: Colors.transparent,
                    borderRadius: 0.0,
                    borderWidth: 1.0,
                    buttonSize: 40.0,
                    buttonWidth: kIconButtonWidth,
                    icon: Icon(Icons.save),
                    onPressed:
                        //(_progressVisibility ? null : () => _saveAudio),
                        () {
                      _saveAudio();
                    }),
                FlutterFlowIconButton(
                    showLoadingIndicator: true,
                    caption: 'Dir',
                    captionFontSize: basicFontSize,
                    tooltipMessage: 'Save selected audio',
                    borderColor: Colors.transparent,
                    borderRadius: 0.0,
                    borderWidth: 1.0,
                    buttonSize: 40.0,
                    buttonWidth: kIconButtonWidth,
                    icon: Icon(Icons.save),
                    onPressed: () async {
                      final utf8Encoder = utf8.encoder;
                      var dir = Directory.fromRawPath(
                          utf8Encoder.convert(widget.dirPath));
                      await for (var entity
                          in dir.list(recursive: true, followLinks: false)) {
                        print('(EAT32)${entity.path}....${await entity.stat()}');
                      }
                    }),
              ],
            ),
          );
  }
}
