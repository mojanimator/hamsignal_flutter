import 'dart:io';
import 'dart:io' as io;

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class ChewiePlayer extends StatefulWidget {
  String? src;
  final String placeHolder;
  final MaterialColor colors;

  final Function(String src)? onLoaded;
  late final Function()? onRefresh;

  String mode;

  ChewiePlayer({
    Key? key,
    this.title = '',
    required String? this.src,
    required String this.placeHolder,
    required this.colors,
    Function(String src)? this.onLoaded,
    String this.mode = 'view',
    Function()? this.onRefresh,
  }) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ChewiePlayerState();
  }
}

class _ChewiePlayerState extends State<ChewiePlayer> {
  TargetPlatform? _platform;
  VideoPlayerController? _videoPlayerController1;
  ChewieController? _chewieController;
  late String src;
  late final placeHolder;
  late final colors;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    colors = widget.colors;
    src = widget.src != '' && widget.src != ' ' && widget.src != null
        ? "${widget.src}"
        : ' ';

    placeHolder = widget.placeHolder;

    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1?.dispose();
    // _videoPlayerController2.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    try {
      if (widget.mode == 'create') {
        if (io.File(src).existsSync()) {
          File f = File(src);
          _videoPlayerController1 = VideoPlayerController.file(f);
        }
        // else
        //   _videoPlayerController1 = VideoPlayerController.network(src);
      } else {
        _videoPlayerController1 = VideoPlayerController.network(src);
      }

      widget.onLoaded!(src);

      await _videoPlayerController1?.initialize();

      // await Future.wait([
      //   _videoPlayerController1.initialize(),
      //
      //   // _videoPlayerController2.initialize()
      // ]);

      _videoPlayerController1?.addListener(() {
        // setState(() {});
      });
    } catch (e) {
      // print(e);
    }
    // _videoPlayerController2 = VideoPlayerController.network(src);
    if (src != ' ') _createChewieController();

    setState(() {});
  }

  void _createChewieController() {
    // final subtitles = [
    //     Subtitle(
    //       index: 0,
    //       start: Duration.zero,
    //       end: const Duration(seconds: 10),
    //       text: 'Hello from subtitles',
    //     ),
    //     Subtitle(
    //       index: 0,
    //       start: const Duration(seconds: 10),
    //       end: const Duration(seconds: 20),
    //       text: 'Whats up? :)',
    //     ),
    //   ];

    final subtitles = [
      Subtitle(
        index: 0,
        start: Duration.zero,
        end: const Duration(seconds: 10),
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Hello',
              style: TextStyle(color: Colors.red, fontSize: 22),
            ),
            TextSpan(
              text: ' from ',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
            TextSpan(
              text: 'subtitles',
              style: TextStyle(color: Colors.blue, fontSize: 18),
            )
          ],
        ),
      ),
      Subtitle(
        index: 0,
        start: const Duration(seconds: 10),
        end: const Duration(seconds: 20),
        text: 'Whats up? :)',
        // text: const TextSpan(
        //   text: 'Whats up? :)',
        //   style: TextStyle(color: Colors.amber, fontSize: 22, fontStyle: FontStyle.italic),
        // ),
      ),
    ];

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1!,
      autoPlay: false,
      looping: false,
      showOptions: false,

      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: () => toggleVideo(),
            iconData: Icons.live_tv_sharp,
            title: 'بارگذاری مجدد',
          ),
        ];
      },
      // subtitle: Subtitles(subtitles),
      // subtitleBuilder: (context, dynamic subtitle) => Container(
      //   padding: const EdgeInsets.all(10.0),
      //   child: subtitle is InlineSpan
      //       ? RichText(
      //           text: subtitle,
      //         )
      //       : Text(
      //           subtitle.toString(),
      //           style: const TextStyle(color: Colors.black),
      //         ),
      // ),

      hideControlsTimer: const Duration(seconds: 1),

      // Try playing around with some of these other options:

      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: colors[900],
        handleColor: colors[500],
        backgroundColor: colors[900],
        bufferedColor: colors[50],
      ),
      placeholder: Container(
        // child:
        // Image.asset('assets/images/icon-light.png'),
        color: colors[500],
        // child: CachedNetworkImage(imageUrl: placeHolder, ),
      ),
      // autoInitialize: true,
    );
  }

  int currPlayIndex = 0;

  Future<void> toggleVideo() async {
    await _videoPlayerController1?.pause();
    currPlayIndex = currPlayIndex == 0 ? 1 : 0;
    XFile? videoFile = await _picker.pickVideo(source: ImageSource.gallery);
    src = videoFile?.path != null && videoFile?.path != ''
        ? "${videoFile?.path}"
        : ' ';
    await initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
                child: src == ' '
                    ? TextButton.icon(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(colors[500]),
                            textStyle: MaterialStateProperty.all(TextStyle(
                              color: Colors.white,
                              fontFamily: 'Shabnam',
                            ))),
                        onPressed: () => toggleVideo(),
                        icon: Icon(
                          widget.mode == 'create'
                              ? Icons.videocam_outlined
                              : Icons.videocam_off_outlined,
                          color: Colors.white,
                        ),
                        label: Text(
                          widget.mode == 'create'
                              ? 'select_video'.tr
                              : 'no_video'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Shabnam',
                          ),
                        ))
                    : (_videoPlayerController1 != null &&
                            _videoPlayerController1?.value != null &&
                            !_videoPlayerController1!.value.isInitialized &&
                            !_videoPlayerController1!.value.hasError)
                        ? CircularProgressIndicator()
                        : _chewieController != null &&
                                _chewieController!
                                    .videoPlayerController.value.isInitialized
                            ? Column(
                                children: [
                                  Expanded(
                                    child: Chewie(
                                      controller: _chewieController!,
                                    ),
                                  ),
                                  if (widget.mode == 'create' || widget.mode == 'edit')
                                    TextButton.icon(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    colors[700]),
                                            textStyle:
                                                MaterialStateProperty.all(
                                                    TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Shabnam',
                                            ))),
                                        onPressed: () {
                                          src = ' ';
                                          toggleVideo();
                                          if (widget.onRefresh != null)
                                            widget.onRefresh;
                                        },
                                        icon: Icon(
                                          Icons.videocam_off_outlined,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          'edit_video'.tr,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Shabnam',
                                          ),
                                        ))
                                ],
                              )
                            : _chewieController!
                                    .videoPlayerController.value.hasError
                                ? Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.refresh),
                                        onPressed: () => toggleVideo(),
                                      ),
                                      Text('check_network'.tr)
                                    ],
                                  )
                                : Center()),
          ),
        ],
      ),
    );
  }
}

// ignore: avoid_classes_with_only_static_members
class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(secondary: Colors.red),
    disabledColor: Colors.grey.shade400,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(secondary: Colors.red),
    disabledColor: Colors.grey.shade400,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
