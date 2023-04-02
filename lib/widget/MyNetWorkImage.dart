import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyNetWorkImage extends StatefulWidget {
  final String url;
  final Widget? placeholder;
  Function? loadingWidgetBuilder;
  Function? errorWidgetBuilder;
  BoxFit? fit;
  Function? onLoaded;
  double? height;
  double? width;
  BorderRadius? borderRadius;

  var errorWidget;

  MyNetWorkImage(
      {required this.url,
      this.placeholder,
      Function(Uint8List imageBytes)? this.onLoaded,
      Function(double progress)? this.loadingWidgetBuilder,
      Function(BuildContext context, String url, dynamic error)?
          this.errorWidgetBuilder,
      this.height,
      this.width,
      this.fit,
      this.borderRadius}) {}

  @override
  State<MyNetWorkImage> createState() => _MyNetWorkImageState();
}

class _MyNetWorkImageState extends State<MyNetWorkImage> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(

      fadeInDuration: Duration(milliseconds: 500),
      imageUrl: widget.url,
      imageBuilder: (context, imageProvider) {
        final format = widget.url.contains('png')
            ? ImageByteFormat.png
            : ImageByteFormat.png;
        if (widget.onLoaded != null)
          imageProvider.getBytes(context, format: format).then((imageBytes) {
            if (widget.onLoaded != null &&
                imageBytes != null &&
                imageBytes.isNotEmpty) {
              if (widget.onLoaded != null) widget.onLoaded!(imageBytes);
              // print("***image bytes:${imageBytes.length}");
            }
          });
        return ClipRRect(
          borderRadius:
              widget.borderRadius ?? BorderRadius.all(Radius.circular(0)),
          child: Image(
            image: imageProvider,
            fit: widget.fit,
          ),
        );
      },
      progressIndicatorBuilder: widget.loadingWidgetBuilder != null
          ? (context, url, downloadProgress) {
              if (downloadProgress.progress != null)
                return widget.loadingWidgetBuilder!(downloadProgress.progress);
              return Center();
            }
          : null,

      placeholder:
          widget.loadingWidgetBuilder == null && widget.placeholder != null
              ? (context, url) => widget.placeholder!
              : null,
      errorWidget: (context, url, dynamic error) => widget.errorWidget != null
          ? widget.errorWidget(context, url, error)
          : Center(),
      fit: widget.fit ?? BoxFit.contain,
      height: widget.height,
      width: widget.width,
    );
  }
}

extension ImageTool on ImageProvider {
  Future<Uint8List?> getBytes(BuildContext context,
      {ImageByteFormat format = ImageByteFormat.rawRgba}) async {
    final imageStream = resolve(createLocalImageConfiguration(context));
    final Completer<Uint8List?> completer = Completer<Uint8List?>();
    final ImageStreamListener listener = ImageStreamListener(
      (imageInfo, synchronousCall) async {
        final bytes = await imageInfo.image.toByteData(format: format);
        if (!completer.isCompleted) {
          completer.complete(bytes?.buffer.asUint8List());
        }
      },
    );
    imageStream.addListener(listener);
    final imageBytes = await completer.future;
    imageStream.removeListener(listener);
    return imageBytes;
  }
}
