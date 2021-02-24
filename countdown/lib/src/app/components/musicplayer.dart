import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jlpt_testdate_countdown/src/models/song/mediastate.model.dart';
import 'package:jlpt_testdate_countdown/src/models/song/queuestate.model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../../resources/data.dart';
import '../../utils/sizeconfig.dart';

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class MusicView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AudioServiceWidget(
        child: StreamBuilder<bool>(
            stream: AudioService.runningStream as Stream<bool>,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.active) {
                return SizedBox();
              }
              final running = snapshot.data ?? false;
              if (!running) {
                AudioService.start(
                  backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
                  androidNotificationChannelName: 'Audio Service Demo',
                  // Enable this if you want the Android service to exit the foreground state on pause.
                  //androidStopForegroundOnPause: true,
                  androidNotificationColor: 0xFF2196f3,
                  androidNotificationIcon: 'mipmap/ic_launcher',
                  androidEnableQueue: true,
                );
              }
              return StreamBuilder<QueueState>(
                  stream: _queueStateStream,
                  builder: (context, snapshot) {
                    final queueState = snapshot.data;
                    final queue = queueState?.queue ?? [];
                    final mediaItem = queueState?.mediaItem;
                    return Container(
                        height: SizeConfig.safeBlockHorizontal * 20,
                        width: SizeConfig.safeBlockHorizontal * 60,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.horizontal(left: Radius.circular(180), right: Radius.circular(30)),
                            color: Colors.black12),
                        alignment: Alignment.centerLeft,
                        child: Row(children: [
                          ClipRRect(
                            // ignore: null_aware_in_condition
                            child: mediaItem?.artUri != null
                                ? Image.network(
                                    mediaItem.artUri,
                                    height: SizeConfig.safeBlockHorizontal * 20,
                                  )
                                : Image.asset('assets/images/song.jpg', height: SizeConfig.safeBlockHorizontal * 20),
                            borderRadius: BorderRadius.circular(180),
                          ),
                          Container(
                              height: SizeConfig.safeBlockVertical * 20,
                              width: SizeConfig.safeBlockHorizontal * 40,
                              alignment: Alignment.center,
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                if (mediaItem?.title != null)
                                  Text(mediaItem.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: AppText.fontSize10,
                                          color: Colors.white)),
                                if (mediaItem?.artist != null)
                                  Text(mediaItem.artist,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: AppText.fontSize10,
                                          color: Colors.white)),
                                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  if (queue != null && queue.isNotEmpty)
                                    IconButton(
                                      icon: Icon(Icons.skip_previous, color: Colors.white),
                                      iconSize: SizeConfig.safeBlockHorizontal * 6,
                                      onPressed: mediaItem == queue.first ? null : AudioService.skipToPrevious,
                                    ),
                                  StreamBuilder<bool>(
                                    stream: AudioService.playbackStateStream.map((state) => state.playing).distinct(),
                                    builder: (context, snapshot) {
                                      final playing = snapshot.data ?? false;
                                      return (playing) ? pauseButton() : playButton();
                                    },
                                  ),
                                  if (queue != null && queue.isNotEmpty)
                                    IconButton(
                                      icon: Icon(Icons.skip_next, color: Colors.white),
                                      iconSize: SizeConfig.safeBlockHorizontal * 6,
                                      onPressed: mediaItem == queue.last ? null : AudioService.skipToNext,
                                    )
                                ])
                              ]))
                        ]));
                  });
            }));
  }

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream => Rx.combineLatest2<MediaItem, Duration, MediaState>(
      AudioService.currentMediaItemStream,
      AudioService.positionStream,
      (mediaItem, position) => MediaState(mediaItem, position));

  /// A stream reporting the combined state of the current queue and the current
  /// media item within that queue.
  Stream<QueueState> get _queueStateStream => Rx.combineLatest2<List<MediaItem>, MediaItem, QueueState>(
      AudioService.queueStream,
      AudioService.currentMediaItemStream,
      (queue, mediaItem) => QueueState(queue, mediaItem));

  RaisedButton startButton(String label, VoidCallback onPressed) => RaisedButton(
        child: Text(label),
        onPressed: onPressed,
      );

  IconButton playButton() => IconButton(
        icon: Icon(Icons.play_arrow, color: Colors.white),
        iconSize: SizeConfig.safeBlockHorizontal * 6,
        onPressed: AudioService.play,
      );

  IconButton pauseButton() => IconButton(
        icon: Icon(Icons.pause, color: Colors.white),
        iconSize: SizeConfig.safeBlockHorizontal * 6,
        onPressed: AudioService.pause,
      );
}

class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer _player = AudioPlayer();
  AudioProcessingState _skipState;
  StreamSubscription<PlaybackEvent> _eventSubscription;

  List<MediaItem> get queue => DataConfig.musicItems;

  int get index => _player.currentIndex;

  MediaItem get mediaItem => index == null ? null : queue[index];

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Broadcast media item changes.
    _player.currentIndexStream.listen((index) {
      if (index != null) AudioServiceBackground.setMediaItem(queue[index]);
    });
    // Propagate all events from the audio player to AudioService clients.
    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
    // Special processing for state transitions.
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          // In this example, the service stops when reaching the end.
          onStop();
          break;
        case ProcessingState.ready:
          // If we just came from skipping between tracks, clear the skip
          // state now that we're ready to play.
          _skipState = null;
          break;
        default:
          break;
      }
    });

    // Load and broadcast the queue
    AudioServiceBackground.setQueue(queue);
    try {
      await _player.setAudioSource(ConcatenatingAudioSource(
        children: queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
      ));
      // In this example, we automatically start playing on start.
      onPlay();
    } catch (e) {
      print("Error: $e");
      onStop();
    }
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    // Then default implementations of onSkipToNext and onSkipToPrevious will
    // delegate to this method.
    final newIndex = queue.indexWhere((item) => item.id == mediaId);
    if (newIndex == -1) return queue.length - 1;
    // During a skip, the player may enter the buffering state. We could just
    // propagate that state directly to AudioService clients but AudioService
    // has some more specific states we could use for skipping to next and
    // previous. This variable holds the preferred state to send instead of
    // buffering during a skip, and it is cleared as soon as the player exits
    // buffering (see the listener in onStart).
    _skipState = newIndex > index ? AudioProcessingState.skippingToNext : AudioProcessingState.skippingToPrevious;
    // This jumps to the beginning of the queue item at newIndex.
    _player.seek(Duration.zero, index: newIndex);
    // Demonstrate custom events.
    AudioServiceBackground.sendCustomEvent('skip to $newIndex');
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onSeekTo(Duration position) => _player.seek(position);

  @override
  Future<void> onFastForward() => _seekRelative(fastForwardInterval);

  @override
  Future<void> onRewind() => _seekRelative(-rewindInterval);

  @override
  Future<void> onStop() async {
    await _player.dispose();
    _eventSubscription.cancel();
    // It is important to wait for this state to be broadcast before we shut
    // down the task. If we don't, the background task will be destroyed before
    // the message gets sent to the UI.
    await _broadcastState();
    // Shut down this task
    await super.onStop();
  }

  /// Jumps away from the current position by [offset].
  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _player.position + offset;
    // Make sure we don't jump out of bounds.
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > mediaItem.duration) newPosition = mediaItem.duration;
    // Perform the jump via a seek.
    await _player.seek(newPosition);
  }

  /// Broadcasts the current state to all clients.
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      androidCompactActions: [0, 1, 3],
      processingState: _getProcessingState(),
      playing: _player.playing,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  /// Maps just_audio's processing state into into audio_service's playing
  /// state. If we are in the middle of a skip, we use [_skipState] instead.
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState;
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_player.processingState}");
    }
  }
}
