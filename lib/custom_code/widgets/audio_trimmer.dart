import 'dart:async';
import 'dart:io';
import 'dart:convert';

import '../../audio_trimmer_plus/audio_trimmer_plus.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../appwrite_interface.dart';
import '/../custom_code/widgets/toast.dart';
import '../../platform/audio_recorder_platform.dart';

class AudioTrimmerPopup extends StatefulWidget {
  const AudioTrimmerPopup({super.key});

  @override
  State<AudioTrimmerPopup> createState() => _AudioTrimmerPopupState();
}

class _AudioTrimmerPopupState extends State<AudioTrimmerPopup>
    with TickerProviderStateMixin, AudioRecorderMixin {
  String? _audioPath;
  bool _isLoadingAudio = false;
  bool _isTrimming = false;
  int? _startMs;
  int? _endMs;
  bool _isPlaying = false;

  final _trimmerController = AudioTrimmerController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _trimmerController.dispose();
    super.dispose();
  }

  Future<void> _pickAudio() async {
    try {
      setState(() => _isLoadingAudio = true);

/*
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: const ['mp3', 'wav', 'm4a', 'flac', 'aac'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
*/

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
         print(
           '(AT1)${localPath}....${generateAudioStorageFilename(currentSessionStep!, currentSessionStep!.maxAudioVersion!)}',
         );


        // Use the controller's importFile method
        await _trimmerController.importFile(localPath);

        setState(() {
          _audioPath = localPath;
          _startMs = null;
          _endMs = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing audio: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingAudio = false);
    }
  }

  void _handleTrimRangeChanged(int startMs, int endMs) {
    setState(() {
      _startMs = startMs;
      _endMs = endMs;
    });
    debugPrint('Trim range: ${startMs}ms - ${endMs}ms');
  }

  Future<void> _trimAudio() async {
    if (_startMs == null || _endMs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No trim range selected')),
      );
      return;
    }

    try {
      setState(() => _isTrimming = true);

      // Call the controller's trim function
      final trimmedFilePath = await _trimmerController.trim();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio trimmed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Load the trimmed file back into the controller
        await _trimmerController.importFile(trimmedFilePath);

        setState(() {
          _audioPath = trimmedFilePath;
          _startMs = null;
          _endMs = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error trimming audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTrimming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoadingAudio
                ? const Center(child: CircularProgressIndicator())
                : AudioTrimWidget(
                    trimWindowMs: 5000,
                    containerWidthFraction: 0.5,
                    onTap: _pickAudio,
                    trimmerController: _trimmerController,
                    onPlayerStateChanged: (state) {
                      setState(() {
                        _isPlaying = state == PlayerState.playing;
                      });
                    },
                    config: AudioTrimmerConfig(
                      borderColor: Colors.blue,
                      handleColor: Colors.blue,
                      progressColor:
                          Colors.blueAccent.withValues(alpha: 0.7),
                    ),
                    scaleFactor: 75.0,
                    fixedWaveColor: Colors.blue.withOpacity(0.2),
                    waveSpacing: 4.0,
                    onTrimRangeChanged: _handleTrimRangeChanged,
                  ),

            // Trim range info
            if (_startMs != null && _endMs != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Trim Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Start',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(_startMs! / 1000).toStringAsFixed(2)}s',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'End',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(_endMs! / 1000).toStringAsFixed(2)}s',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'Duration',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${((_endMs! - _startMs!) / 1000).toStringAsFixed(2)}s',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Play button
            if (_audioPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_isPlaying) {
                        _trimmerController.pause();
                      } else {
                        // print('(AT2)${_trimmerController.currentFilePath}....${_trimmerController.endMs}');
                        _trimmerController.play();
                      }
                    },
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(_isPlaying ? 'Pause' : 'Play'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),

            // Trim button
            if (_audioPath != null && _startMs != null && _endMs != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _isTrimming ? null : _trimAudio,
                    icon: _isTrimming
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.content_cut),
                    label: Text(_isTrimming ? 'Trimming...' : 'Trim Audio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
