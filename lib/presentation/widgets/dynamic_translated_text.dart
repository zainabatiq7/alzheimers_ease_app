import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class DynamicTranslatedText extends StatefulWidget {
  final String text;
  final String targetLanguageCode; // e.g., 'ur' or 'en'
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const DynamicTranslatedText({
    super.key,
    required this.text,
    required this.targetLanguageCode,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  @override
  State<DynamicTranslatedText> createState() => _DynamicTranslatedTextState();
}

class _DynamicTranslatedTextState extends State<DynamicTranslatedText> {
  String _translatedText = '';
  bool _isLoading = false;
  OnDeviceTranslator? _translator;

  @override
  void initState() {
    super.initState();
    _handleTranslation();
  }

  @override
  void didUpdateWidget(covariant DynamicTranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.targetLanguageCode != widget.targetLanguageCode) {
      _handleTranslation();
    }
  }

  TranslateLanguage _getLanguageEnum(String code) {
    switch (code.toLowerCase()) {
      case 'ur':
        return TranslateLanguage.urdu;
      case 'en':
      default:
        return TranslateLanguage.english;
    }
  }

  Future<void> _handleTranslation() async {
    // If text is empty or target language is English, display raw text directly
    if (widget.text.trim().isEmpty || widget.targetLanguageCode == 'en') {
      if (mounted) {
        setState(() {
          _translatedText = widget.text;
          _isLoading = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final targetLang = _getLanguageEnum(widget.targetLanguageCode);
      final modelManager = OnDeviceTranslatorModelManager();

      // Check and download Urdu model pack on first run if missing (~30MB)
      final isDownloaded = await modelManager.isModelDownloaded(targetLang.bcpCode);
      if (!isDownloaded) {
        await modelManager.downloadModel(targetLang.bcpCode);
      }

      // Initialize translator and process string on-device
      _translator?.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: targetLang,
      );

      final result = await _translator!.translateText(widget.text);

      if (mounted) {
        setState(() {
          _translatedText = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to original text if translation fails or loses connectivity on first download
      if (mounted) {
        setState(() {
          _translatedText = widget.text;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _translator?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Text(
        widget.text,
        style: widget.style?.copyWith(
          color: widget.style?.color?.withValues(alpha: 0.6),
        ),
        textAlign: widget.textAlign,
        overflow: widget.overflow,
        maxLines: widget.maxLines,
      );
    }

    return Text(
      _translatedText.isNotEmpty ? _translatedText : widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
      overflow: widget.overflow,
      maxLines: widget.maxLines,
    );
  }
}