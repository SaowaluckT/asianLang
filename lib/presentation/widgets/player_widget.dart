// import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayerWidget extends StatefulWidget {
  final String? voicePath;
  const PlayerWidget({super.key, required this.voicePath});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  final player = just_audio.AudioPlayer();
  String? _playerState;
  // late AudioPlayer player = AudioPlayer();
  // PlayerState? _playerState;
  Duration? _duration;
  // Duration? _position;

  @override
  void initState() {
    if (widget.voicePath != null) {
      player
          .setAudioSource(just_audio.AudioSource.file(widget.voicePath!))
          .then((value) => setState(() {
                _duration = value;
                print('setAudioSource file');
              }))
          .catchError((onError) => print("setAudioSource file (${player.playerState}/ ${player.processingState}) catchError: $onError"));
    }

    /* AudioPlayer */
    // player = AudioPlayer();
    // player.getDuration().then(
    //       (value) => setState(() {
    //     _duration = value;
    //   }),
    // );
    // // player.getCurrentPosition().then(
    // //       (value) => setState(() {
    // //     _position = value;
    // //   }),
    // // );
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  _buildStreamPlayer() {
    /// This StreamBuilder rebuilds whenever the player state changes, which
    /// includes the playing/paused state and also the
    /// loading/buffering/ready state. Depending on the state we show the
    /// appropriate button or loading indicator.
    return StreamBuilder<just_audio.PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        print("{$playerState // processingState: $processingState} // playing: $playing");

        if (processingState == just_audio.ProcessingState.loading ||
            processingState == just_audio.ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            width: 48.0,
            height: 48.0,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return IconButton(
            icon: const Icon(Icons.play_arrow),
            iconSize: 48.0,
            onPressed: player.play,
          );
        } else if (processingState != just_audio.ProcessingState.completed) {
          return IconButton(
            icon: const Icon(Icons.pause),
            iconSize: 48.0,
            onPressed: player.pause,
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.replay),
            iconSize: 48.0,
            onPressed: () => player.seek(Duration.zero),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStreamPlayer(),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
