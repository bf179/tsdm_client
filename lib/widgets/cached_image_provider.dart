import 'dart:async';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/image_cache_provider.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';

// https://github.com/Baseflow/flutter_cached_network_image/blob/develop/cached_network_image/lib/src/image_provider/cached_network_image_provider.dart
// ${flutter_sdk}/lib/src/painting/_network_image_io.dart
@immutable
class CachedImageProvider extends ImageProvider<CachedImageProvider> {
  const CachedImageProvider(
    this.imageUrl,
    this.context,
    this.ref, {
    this.scale = 1.0,
    this.maxWidth,
    this.maxHeight,
    this.headers = const <String, String>{
      'Accept': 'image/avif,image/webp,*/*',
    },
    this.fallbackImageUrl,
  });

  final String imageUrl;

  /// Use check widget mounted.
  ///
  /// Workaround to fix "ref used after widget dispose" exception.
  final BuildContext context;
  final WidgetRef ref;
  final double? maxWidth;
  final double? maxHeight;

  final double scale;

  /// Use this image if [imageUrl] is unavailable.
  final String? fallbackImageUrl;

  String get url => imageUrl;

  final Map<String, String>? headers;

  @override
  Future<CachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
      CachedImageProvider key, ImageDecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode: decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<CachedImageProvider>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    CachedImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents, {
    required ImageDecoderCallback decode,
  }) async {
    try {
      assert(key == this);

      final bytes = await ref
          .read(imageCacheProvider.notifier)
          .getCache(imageUrl)
          .onError((e, st) async {
        if (!context.mounted) {
          return Uint8List(0);
        }
        // When error occurred in `getCache`, it means the image is not
        // correctly cached, fetch from network.
        final resp = await ref
            .read(netClientProvider())
            .get(
              imageUrl,
              options: Options(
                responseType: ResponseType.bytes,
                headers: headers,
              ),
            )
            .onError((e, st) async {
          // Error occurred when fetching this image.
          // If we have [fallbackImageUrl], use it.
          if (fallbackImageUrl == null) {
            // Rethrow if can not fallback.
            throw Exception(e);
          }
          if (!context.mounted) {
            return Future.value(Response(requestOptions: RequestOptions()));
          }
          return ref.read(netClientProvider()).get(
                fallbackImageUrl!,
                options: Options(
                  responseType: ResponseType.bytes,
                  headers: headers,
                ),
              );
        });
        if (!context.mounted) {
          return Uint8List(0);
        }
        final imageData = resp.data as List<int>;

        // Make cache.
        await ref
            .read(imageCacheProvider.notifier)
            .updateCache(imageUrl, imageData);
        return Uint8List.fromList(imageData);
      });

      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkImage is an empty file: $imageUrl');
      }
      return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (e) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      await chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CachedImageProvider &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CachedImageProvider')}("$url", scale: $scale)';
}
