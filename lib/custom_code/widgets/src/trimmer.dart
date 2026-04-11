import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path/path.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../appwrite_interface.dart';
import 'utils/file_formats.dart';
import 'utils/storage_dir.dart';
import 'package:flutter_sound/flutter_sound.dart';

enum TrimmerEvent { initialized }

/// Helps in loading audio from file, saving trimmed audio to a file
/// and gives audio playback controls. Some of the helpful methods
/// are:
/// * [loadAudio()]
/// * [saveTrimmedAudio)]
/// * [audioPlaybackControl()]
class Trimmer {
  // final FlutterFFmpeg _flutterFFmpeg = FFmpegKit();

  final StreamController<TrimmerEvent> _controller = StreamController<TrimmerEvent>.broadcast();

  ap.AudioPlayer? _audioPlayer;

  ap.AudioPlayer? get audioPlayer => _audioPlayer;

  File? currentAudioFile;

  /// Listen to this stream to catch the events
  Stream<TrimmerEvent> get eventStream => _controller.stream;

  /// Loads a audio using the path provided.
  ///
  /// Returns the loaded audio file.
  Future<void> loadAudio({required File audioFile}) async {
    currentAudioFile = audioFile;
    if (audioFile.existsSync()) {
      _audioPlayer = ap.AudioPlayer();
      await _audioPlayer?.setSource(ap.DeviceFileSource(audioFile.path));

      _controller.add(TrimmerEvent.initialized);

      // await _audioPlayer!.).then((_) {
      //
      // });
    }
  }

  Future<String> _createFolderInAppDocDir(
    String folderName,
    StorageDir? storageDir,
  ) async {
    Directory? directory;

    if (storageDir == null) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      switch (storageDir.toString()) {
        case 'temporaryDirectory':
          directory = await getTemporaryDirectory();
          break;

        case 'applicationDocumentsDirectory':
          directory = await getApplicationDocumentsDirectory();
          break;

        case 'externalStorageDirectory':
          directory = await getExternalStorageDirectory();
          break;
      }
    }

    // Directory + folder name
    final Directory directoryFolder = Directory('${directory!.path}/$folderName/');

    if (await directoryFolder.exists()) {
      // If folder already exists return path
      debugPrint('Exists');
      return directoryFolder.path;
    } else {
      debugPrint('Creating');
      // If folder does not exists create folder and then return its path
      final Directory directoryNewFolder = await directoryFolder.create(recursive: true);
      return directoryNewFolder.path;
    }
  }

  /// Saves the trimmed audio to file system.
  ///
  ///
  /// The required parameters are [startValue], [endValue] & [onSave].
  ///
  /// The optional parameters are [audioFolderName], [audioFileName],
  /// [outputFormat], [fpsGIF], [scaleGIF], [applyAudioEncoding].
  ///
  /// The `@required` parameter [startValue] is for providing a starting point
  /// to the trimmed audio. To be specified in `milliseconds`.
  ///
  /// The `@required` parameter [endValue] is for providing an ending point
  /// to the trimmed audio. To be specified in `milliseconds`.
  ///
  /// The `@required` parameter [onSave] is a callback Function that helps to
  /// retrieve the output path as the FFmpeg processing is complete. Returns a
  /// `String`.
  ///
  /// The parameter [audioFolderName] is used to
  /// pass a folder name which will be used for creating a new
  /// folder in the selected directory. The default value for
  /// it is `Trimmer`.
  ///
  /// The parameter [audioFileName] is used for giving
  /// a new name to the trimmed audio file. By default the
  /// trimmed audio is named as `<original_file_name>_trimmed.mp4`.
  ///
  /// The parameter [outputFormat] is used for providing a
  /// file format to the trimmed audio. This only accepts value
  /// of [FileFormat] type. By default it is set to `FileFormat.mp4`,
  /// which is for `mp4` files.
  ///
  /// The parameter [storageDir] can be used for providing a storage
  /// location option. It accepts only [StorageDir] values. By default
  /// it is set to [applicationDocumentsDirectory]. Some of the
  /// storage types are:
  ///
  /// * [temporaryDirectory] (Only accessible from inside the app, can be
  /// cleared at anytime)
  ///
  /// * [applicationDocumentsDirectory] (Only accessible from inside the app)
  ///
  /// * [externalStorageDirectory] (Supports only `Android`, accessible externally)
  ///
  /// The parameters [fpsGIF] & [scaleGIF] are used only if the
  /// selected output format is `FileFormat.gif`.
  ///
  /// * [fpsGIF] for providing a FPS value (by default it is set
  /// to `10`)
  ///
  ///
  /// * [scaleGIF] for proving a width to output GIF, the height
  /// is selected by maintaining the aspect ratio automatically (by
  /// default it is set to `480`)
  ///
  ///
  /// * [applyAudioEncoding] for specifying whether to apply audio
  /// encoding (by default it is set to `false`).
  ///
  ///
  /// ADVANCED OPTION:
  ///
  /// If you want to give custom `FFmpeg` command, then define
  /// [ffmpegCommand] & [customAudioFormat] strings. The `input path`,
  /// `output path`, `start` and `end` position is already define.
  ///
  /// NOTE: The advanced option does not provide any safety check, so if wrong
  /// audio format is passed in [customAudioFormat], then the app may
  /// crash.
  ///
/*
  Future<void> saveTrimmedAudio({
    required double startValue,
    required double endValue,
    required Function(String? outputPath) onSave,
    bool applyAudioEncoding = false,
    FileFormat? outputFormat,
    String? ffmpegCommand,
    String? customAudioFormat,
    int? fpsGIF,
    int? scaleGIF,
    String? audioFolderName,
    String? audioFileName,
    StorageDir? storageDir,
  }) async {
    final String audioPath = currentAudioFile!.path;
    final String audioName = basename(audioPath).split('.')[0];

    String command;

    // Formatting Date and Time
    String dateTime = DateFormat.yMMMd()
        .addPattern('-')
        .add_Hms()
        .format(DateTime.now())
        .toString();

    // String _resultString;
    String outputPath;
    String? outputFormatString;
    String formattedDateTime = dateTime.replaceAll(' ', '');

    debugPrint("DateTime: $dateTime");
    debugPrint("Formatted: $formattedDateTime");

    audioFolderName ??= "Trimmer";

    audioFileName ??= "${audioName}_trimmed:$formattedDateTime";

    audioFileName = audioFileName.replaceAll(' ', '_');

    String path = await _createFolderInAppDocDir(
      audioFolderName,
      storageDir,
    ).whenComplete(
      () => debugPrint("Retrieved Trimmer folder"),
    );

    Duration startPoint = Duration(milliseconds: startValue.toInt());
    Duration endPoint = Duration(milliseconds: endValue.toInt());

    // Checking the start and end point strings
    debugPrint("Start: ${startPoint.toString()} & End: ${endPoint.toString()}");

    debugPrint(path);

    if (outputFormat == null) {
      outputFormat = FileFormat.mp3;
      outputFormatString = outputFormat.toString();
      debugPrint('OUTPUT: $outputFormatString');
    } else {
      outputFormatString = outputFormat.toString();
    }

    String trimLengthCommand =
        ' -ss $startPoint -i "$audioPath" -t ${endPoint - startPoint}';

    if (ffmpegCommand == null) {
      command = '$trimLengthCommand -c:a copy ';

      if (!applyAudioEncoding) {
        command += '-c:v copy ';
      }
    } else {
      command = '$trimLengthCommand $ffmpegCommand ';
      outputFormatString = customAudioFormat;
    }

    outputPath = '$path$audioFileName$outputFormatString';

    command += '"$outputPath"';


    FFmpegKit.executeAsync(command, (session) async {
      final state =
          FFmpegKitConfig.sessionStateToString(await session.getState());
      final returnCode = await session.getReturnCode();

      print('(AC2A)${command}');

      debugPrint("FFmpeg process exited with state $state and rc $returnCode");

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint("FFmpeg processing completed successfully.");
        debugPrint('Audio successfully saved');
        onSave(outputPath);
      } else {
        debugPrint("FFmpeg processing failed.");
        debugPrint('Couldn\'t save the audio');
        onSave(null);
      }
    });

    // return _outputPath;
  }
*/

  Future<FFmpegSession> extractAudio(
      {String? sourcePath, String? targetPath, Duration? startPoint, Duration? endPoint}) async {
    String command = '';
    if (endPoint == null) {
      command = '-y -ss $startPoint -i "$sourcePath"  -c copy ${targetPath}';
    } else {
      command = '-y -ss $startPoint -t ${endPoint} -i "$sourcePath"  -c copy ${targetPath}';
    }
    FFmpegSession ffmpegSession = await FFmpegKit.executeAsync(command, (session) async {
      final state = FFmpegKitConfig.sessionStateToString(await session.getState());
      final returnCode = await session.getReturnCode();
      final output = await session.getOutput();
      final duration = await session.getDuration();
      final logs = await session.getAllLogs();
      await printAppDirListing();
      print('(AC2A)${await File(sourcePath!).length()}....${command}');
      print(
          '(AC2B)${returnCode},,,,${output!.length}----${output.characters.length}>>>>${duration}<<<<${logs.length}');
      String logString = '';
      for (int i = 0; i < logs.length; i++) {
        print('(AC2C)${i}....${logs[i].getMessage()}');
        // logString = logString + logs[i].getMessage() + '££££';
      }
      // await printTempDirListing();
      debugPrint("(AC3)${state}....${returnCode}====${sourcePath}----${targetPath}");
      if (ReturnCode.isSuccess(returnCode)) {
        File trimmedFile = await File(targetPath!).copy(sourcePath);

        debugPrint("(AC4)${sourcePath}....${await File(sourcePath!).length()}");
      } else {
        debugPrint("(AC5)FFmpeg processing failed.");
      }
      //await copyFiletoAppDir(sourcePath: '${tempDirPath}/trimmed.aac', targetPath: audioPath);
    });
    return ffmpegSession;
  }

  Future<void> saveTrimmedAudio({
    required double startValue,
    required double endValue,
    required Function(String? outputPath) onSave,
    required String audioPath,
    bool saveNotCut = true,
  }) async {
    // final String audioPath = currentAudioFile!.path;
    // final String audioName = basename(audioPath).split('.')[0];

    // String _resultString;

    Duration startPoint = Duration(milliseconds: startValue.toInt());
    Duration endPoint = Duration(milliseconds: endValue.toInt());

    // Checking the start and end point strings
    debugPrint("(AC3)Start: ${startPoint.toString()} & End: ${endPoint.toString()}");

    String outputPath = '${tempDirPath}/trimmed.aac';

    String command = '';
    if (saveNotCut) {
      print('(EAT500)${audioPath}....${outputPath},,,,${startPoint}++++${endPoint}');
      await extractAudio(
          sourcePath: audioPath,
          targetPath: outputPath,
          startPoint: startPoint,
          endPoint: endPoint);
      var deleteResponse;
      File audioFile = File(audioPath);
      try {
        deleteResponse = await audioFile.delete();
      } on Exception catch (e){
        print('(EAT501)${e}....${deleteResponse}');
      }
      print('(EAT502)${deleteResponse}');
      File outputFile = File(outputPath);
      print('(EAT503)${outputFile.path}');
      File targetFile = await outputFile.copy(audioPath);
      print('(EAT504)${targetFile.path}');
    } else {
      String beforePath = '${tempDirPath}/before.aac';
      String afterPath = '${tempDirPath}/after.aac';
      await extractAudio(
          sourcePath: audioPath,
          targetPath: beforePath,
          startPoint: Duration(microseconds: 0),
          endPoint: startPoint);
      await extractAudio(
          sourcePath: audioPath, targetPath: afterPath, startPoint: endPoint, endPoint: null);
      String concatList = 'file ${beforePath}\nfile ${afterPath}';
      final File concatFile = await File("${tempDirPath}/concat.txt").writeAsString(concatList);
      final String concatCommand =
          "-y -f concat -safe 0 -i ${tempDirPath}/concat.txt -c copy ${audioPath}";
      print('(EV1)${audioPath}....${concatCommand}');
      FFmpegSession ffmpegSession2 = await FFmpegKit.execute(concatCommand);
      print('(EV2)${ffmpegSession2}');
    }
    // return _outputPath;
  }

  /// For getting the audio controller state, to know whether the
  /// audio is playing or paused currently.
  ///
  /// The two required parameters are [startValue] & [endValue]
  ///
  /// * [startValue] is the current starting point of the audio.
  /// * [endValue] is the current ending point of the audio.
  ///
  /// Returns a `Future<bool>`, if `true` then audio is playing
  /// otherwise paused.
  Future<bool> audioPlaybackControl({
    required double startValue,
    required double endValue,
  }) async {
    print('(EAT50)${audioPlayer?.state}');
    if (audioPlayer?.state == ap.PlayerState.playing) {
      print('(EAT51A)${audioPlayer?.state}');
      await audioPlayer?.pause();
      return false;
    } else {
      print('(EAT51B)${audioPlayer?.state}');
      // await audioPlayer!.seek(Duration(milliseconds: startValue.toInt()));
      print('(EAT51C)${audioPlayer?.state}....${Duration(milliseconds: startValue.toInt())}');
      var duration = await audioPlayer!.getCurrentPosition();
      print('(EAT52)${audioPlayer?.state}...${duration}');

      if ((duration?.inMilliseconds ?? 0) >= endValue.toInt()) {
        print('(EAT53)${duration?.inMilliseconds}');
        await audioPlayer!.seek(Duration(milliseconds: startValue.toInt()));
        await audioPlayer!.resume();
        return true;
      } else {
        print('(EAT54)${duration}');
        await audioPlayer!.play(ap.DeviceFileSource(currentAudioFile!.path));
        return true;
      }
    }
  }

  /*Source source, {
  double? volume,
      double? balance,
  AudioContext? ctx,
      Duration? position,
  PlayerMode? mode,*/

  /// Clean up
  void dispose() {
    _controller.close();
  }
}
