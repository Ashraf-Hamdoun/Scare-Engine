// packages/scare_engine/lib/src/models/scare_question.dart
import 'package:collection/collection.dart';
import 'fear_type.dart';

class ScareOption {
  final Map<String, String> text;
  final FearType impact; // The fear category this choice reinforces

  ScareOption({required this.text, required this.impact});

  factory ScareOption.fromJson(Map<String, dynamic> json) {
    return ScareOption(
      text: Map<String, String>.from(json['text'] as Map),
      impact: FearType.values.firstWhere(
        (e) => e.name == json['impact'] as String,
        orElse: () => FearType.unknown, // Fallback for unknown fear types
      ),
    );
  }

  Map<String, dynamic> toJson() => {'text': text, 'impact': impact.name};

  String getLocalizedText(String locale, {String fallbackLocale = 'ar'}) {
    return text[locale] ?? text[fallbackLocale] ?? text.values.firstOrNull ?? '';
  }
}

class ScareQuestion {
  final String id;
  final Map<String, String> questionText;
  final ScareOption optionA;
  final ScareOption optionB;

  ScareQuestion({
    required this.id,
    required this.questionText,
    required this.optionA,
    required this.optionB,
  });

  factory ScareQuestion.fromJson(Map<String, dynamic> json) {
    return ScareQuestion(
      id: json['id'] as String,
      questionText: Map<String, String>.from(json['questionText'] as Map),
      optionA: ScareOption.fromJson(json['optionA'] as Map<String, dynamic>),
      optionB: ScareOption.fromJson(json['optionB'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'questionText': questionText,
    'optionA': optionA.toJson(),
    'optionB': optionB.toJson(),
  };

  String getLocalizedQuestionText(String locale, {String fallbackLocale = 'ar'}) {
    return questionText[locale] ?? questionText[fallbackLocale] ?? questionText.values.firstOrNull ?? '';
  }
}
