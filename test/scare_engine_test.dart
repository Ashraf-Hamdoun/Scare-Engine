import 'dart:io';
import 'package:test/test.dart';

import 'package:scare_engine/src/models/fear_type.dart';
import 'package:scare_engine/src/models/psych_profile.dart';
import 'package:scare_engine/scare_engine.dart';
import 'package:scare_engine/src/models/scare_question.dart';
import 'package:scare_engine/src/data/doctor_notes.dart';
import 'package:scare_engine/src/data/question_loader.dart';

void main() {
  group('PsychProfile', () {
    test('PsychProfile initializes with zero scores for all fear types', () {
      final profile = PsychProfile();
      expect(profile.scores.length, FearType.values.length - 1); // -1 for unknown
      expect(profile.scores[FearType.paranoia], 0);
      expect(profile.scores[FearType.isolation], 0);
      expect(profile.scores[FearType.lossOfControl], 0);
      expect(profile.scores[FearType.existential], 0);
      expect(profile.scores.containsKey(FearType.unknown), isFalse);
    });

    test('copyWithAddedScore increases the score for a specific fear type', () {
      final initialProfile = PsychProfile();
      final updatedProfile =
          initialProfile.copyWithAddedScore(FearType.paranoia);

      expect(updatedProfile.scores[FearType.paranoia], 1);
      expect(initialProfile.scores[FearType.paranoia],
          0); // Ensure initial profile is immutable
    });

    test('dominantFear returns the fear type with the highest score', () {
      final profile = PsychProfile(scores: {
        FearType.paranoia: 5,
        FearType.isolation: 2,
        FearType.lossOfControl: 8,
        FearType.existential: 1,
      });
      expect(profile.dominantFear, FearType.lossOfControl);
    });

    test('dominantFear returns paranoia if scores are tied', () {
      final profile = PsychProfile(scores: {
        FearType.paranoia: 5,
        FearType.isolation: 5,
        FearType.lossOfControl: 2,
        FearType.existential: 1,
      });
      // Implementation returns the first in enum order on tie
      expect(profile.dominantFear, FearType.paranoia);
    });

    test(
        'dominantFear returns a valid fear even if all scores are zero initially',
        () {
      final profile = PsychProfile(); // All scores are 0
      expect(profile.dominantFear, FearType.paranoia);
    });

    test(
        'toJson and fromJson correctly serialize and deserialize PsychProfile',
        () {
      final originalProfile = PsychProfile(scores: {
        FearType.paranoia: 3,
        FearType.isolation: 0,
        FearType.lossOfControl: 5,
        FearType.existential: 1,
      });

      final json = originalProfile.toJson();
      final deserializedProfile = PsychProfile.fromJson(json);

      expect(deserializedProfile.scores[FearType.paranoia], 3);
      expect(deserializedProfile.scores[FearType.isolation], 0);
      expect(deserializedProfile.scores[FearType.lossOfControl], 5);
      expect(deserializedProfile.scores[FearType.existential], 1);
      expect(deserializedProfile.dominantFear, FearType.lossOfControl);
    });

    test(
        'fromJson handles unknown fear types gracefully',
        () {
      final jsonWithUnknown = {
        'scores': {
          'paranoia': 1,
          'unidentified': 5, // This should be ignored
        }
      };
      final profile = PsychProfile.fromJson(jsonWithUnknown);
      expect(profile.scores.containsKey(FearType.unknown),
          isFalse); 
      expect(profile.scores[FearType.paranoia], 1);
      expect(profile.scores[FearType.isolation], 0);
    });
  });

  group('ScareEngine', () {
    // Mock questions for testing ScareEngine
    final mockQuestions = [
      ScareQuestion(
        id: "q1",
        questionText: {"en": "Paranoia question (both options paranoia)"},
        optionA:
            ScareOption(text: {"en": "Option A"}, impact: FearType.paranoia),
        optionB:
            ScareOption(text: {"en": "Option B"}, impact: FearType.paranoia),
      ),
      ScareQuestion(
        id: "q2",
        questionText: {"en": "Paranoia question (one option paranoia)"},
        optionA:
            ScareOption(text: {"en": "Option A"}, impact: FearType.paranoia),
        optionB:
            ScareOption(text: {"en": "Option B"}, impact: FearType.isolation),
      ),
      ScareQuestion(
        id: "q3",
        questionText: {"en": "Isolation question (both options isolation)"},
        optionA:
            ScareOption(text: {"en": "Option A"}, impact: FearType.isolation),
        optionB:
            ScareOption(text: {"en": "Option B"}, impact: FearType.isolation),
      ),
    ];

    test('getNextQuestion throws StateError if question pool is empty', () {
      final engine = ScareEngine(questionPool: []);
      expect(() => engine.getNextQuestion(locale: 'en'),
          throwsA(isA<StateError>()));
    });

    test(
        'getNextQuestion returns a random question if all scores are 0',
        () {
      final engine = ScareEngine(questionPool: mockQuestions);
      final question = engine.getNextQuestion(locale: 'en');
      expect(mockQuestions.contains(question), isTrue);
    });

    test(
        'getNextQuestion returns a highly relevant question based on dominant fear (score 2)',
        () {
      final profile = PsychProfile(scores: {FearType.paranoia: 1});
      final engine =
          ScareEngine(profile: profile, questionPool: mockQuestions);

      final question = engine.getNextQuestion(locale: 'en');
      expect(question.id, "q1");
    });
    
    test('processUserChoice updates PsychProfile correctly', () {
      final initialProfile = PsychProfile();
      final engine =
          ScareEngine(profile: initialProfile, questionPool: mockQuestions);

      final choice = mockQuestions[0].optionA; // Impact: Paranoia
      engine.processUserChoice(choice);

      expect(engine.profile.scores[FearType.paranoia], 1);
      expect(engine.profile.dominantFear, FearType.paranoia);
    });

    test('processUserChoice returns a doctor note', () {
      final engine = ScareEngine(questionPool: mockQuestions);
      final choice = mockQuestions[0].optionA; // Impact: Paranoia
      final note = engine.processUserChoice(choice);

      expect(note, isA<String>());
      expect(note, isNotEmpty);
    });

    test(
        'processUserChoice avoids immediate repetition of doctor notes if multiple available',
        () {
      final engine = ScareEngine(questionPool: mockQuestions);
      final choice = mockQuestions[0].optionA; // Impact: Paranoia

      expect(defaultDoctorNoteTemplates[FearType.paranoia]!.length, greaterThan(1));

      final firstNote = engine.processUserChoice(choice);
      final secondNote = engine.processUserChoice(choice);

      expect(firstNote, isNot(secondNote));
    });

    test('processUserChoice uses custom doctor notes when provided', () {
      final customNotes = {
        FearType.paranoia: ["This is a custom paranoia note."]
      };
      
      final engine = ScareEngine(
        questionPool: mockQuestions,
        customDoctorNotes: customNotes,
      );
      
      final choice = mockQuestions[0].optionA; // Impact: Paranoia
      final note = engine.processUserChoice(choice);

      expect(note, "This is a custom paranoia note.");
    });
  });

  group('QuestionLoader', () {
    late Directory tempDir;
    late File tempFile;

    setUp(() async {
      QuestionLoader.reset();
      tempDir = await Directory.systemTemp.createTemp('scare_engine_test_');
      tempFile = File('${tempDir.path}/questions.json');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('loadQuestions loads and parses valid JSON from file path', () async {
      final jsonContent = r'''
        [
          {
            "id": "test_q1",
            "questionText": {"en": "Test Question 1"},
            "optionA": {"text": {"en": "Option A1"}, "impact": "paranoia"},
            "optionB": {"text": {"en": "Option B1"}, "impact": "isolation"}
          }
        ]
      ''';
      await tempFile.writeAsString(jsonContent);

      await QuestionLoader.loadQuestions(tempFile.path);
      expect(QuestionLoader.questions.length, 1);
      expect(QuestionLoader.questions.first.id, "test_q1");
      expect(QuestionLoader.questions.first.getLocalizedQuestionText('en'),
          "Test Question 1");
    });

    test('loadQuestions throws QuestionLoaderException for file not found', () async {
      await expectLater(
        () => QuestionLoader.loadQuestions('non_existent_file.json'),
        throwsA(isA<QuestionLoaderException>()),
      );
    });

    test('loadQuestions throws QuestionLoaderException for invalid JSON', () async {
      await tempFile.writeAsString('this is not valid json');
      await expectLater(
        () => QuestionLoader.loadQuestions(tempFile.path),
        throwsA(isA<QuestionLoaderException>()),
      );
    });
  });
}
