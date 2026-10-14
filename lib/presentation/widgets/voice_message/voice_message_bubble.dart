import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class VoiceMessageBubble extends StatefulWidget {
  final String audioUrl;
  final bool isMe;
  final int duration;

  const VoiceMessageBubble({
    super.key,
    required this.audioUrl,
    required this.isMe,
    required this.duration,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _duration = Duration(seconds: widget.duration);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = false;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_position > Duration.zero && _position < _duration) {
        await _audioPlayer.resume();
      } else {
        setState(() {
          _isLoading = true;
        });
        try {
          await _audioPlayer.play(UrlSource(widget.audioUrl));
        } catch (e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          debugPrint("Error playing audio: $e");
        }
      }
    }
  }

  String _formatTimer(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final maxDurationSeconds =
    _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0;
    final currentPositionSeconds =
    _position.inSeconds.toDouble().clamp(0.0, maxDurationSeconds);

    final bubbleBgColor =
    widget.isMe ? colorScheme.primary : colorScheme.surfaceContainerHighest;
    final contentColor =
    widget.isMe ? colorScheme.onPrimary : colorScheme.onSurface;
    final subTextColor =
    widget.isMe ? colorScheme.onPrimary.withValues(alpha: 0.7) : colorScheme.onSurfaceVariant;

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: bubbleBgColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16.0),
          topRight: const Radius.circular(16.0),
          bottomLeft: widget.isMe ? const Radius.circular(16.0) : const Radius.circular(4.0),
          bottomRight: widget.isMe ? const Radius.circular(4.0) : const Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isLoading
                  ? SizedBox(
                width: 40,
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: contentColor,
                  ),
                ),
              )
                  : IconButton(
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_filled_rounded,
                  size: 36.0,
                  color: contentColor,
                ),
                onPressed: _toggleAudio,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
                    trackHeight: 3.0,
                  ),
                  child: Slider(
                    activeColor: contentColor,
                    inactiveColor: contentColor.withValues(alpha: 0.3),
                    min: 0.0,
                    max: maxDurationSeconds,
                    value: currentPositionSeconds,
                    onChanged: (value) async {
                      if (_duration.inSeconds > 0) {
                        await _audioPlayer.seek(Duration(seconds: value.toInt()));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 48.0, bottom: 2.0),
            child: Text(
              _isPlaying ? _formatTimer(_position) : _formatTimer(_duration),
              style: TextStyle(
                fontSize: 11,
                color: subTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}