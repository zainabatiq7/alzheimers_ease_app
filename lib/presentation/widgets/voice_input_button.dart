import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';
import 'package:alzhimers_ease/provider/settings_provider.dart';

class VoiceInputButton extends StatefulWidget {
  final TextEditingController controller;

  const VoiceInputButton({super.key, required this.controller});

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      // 1. Read provider state BEFORE the async gap
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final String localeId = settings.languageCode == 'ur' ? 'ur_PK' : 'en_US';

      bool available = await _speech.initialize();

      // 2. Guard against async context gaps before using widget state
      if (!mounted) return;

      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          // 3. Use SpeechListenOptions to pass localeId
          listenOptions: stt.SpeechListenOptions(
            localeId: localeId,
          ),
          onResult: (val) {
            if (mounted) {
              setState(() {
                widget.controller.text = val.recognizedWords;
              });
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return IconButton(
      icon: Icon(
        _isListening ? Icons.mic : Icons.mic_none_rounded,
        color: _isListening ? Colors.red : const Color(0xFF008080),
        size: 26,
      ),
      onPressed: _listen,
      tooltip: loc.speakToType,
    );
  }
}