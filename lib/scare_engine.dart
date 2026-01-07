import 'src/models/scare_question.dart';
import 'src/models/psych_profile.dart';
import 'src/models/fear_type.dart';
import 'src/data/doctor_notes.dart';

class ScareEngine {
  PsychProfile profile;
  final List<ScareQuestion> _questionPool;
  String? _lastDoctorNote; // To prevent immediate repetition of notes
  final String doctorName; // New: Name of the principal character
  final Map<FearType, List<String>>? customDoctorNotes;

  // Initialize with a profile, which might be loaded from shared_preferences
  ScareEngine({
    PsychProfile? profile,
    required List<ScareQuestion> questionPool,
    this.doctorName = "Dr. Abdelmoati",
    this.customDoctorNotes,
  })  : this.profile = profile ?? PsychProfile(),
        _questionPool = questionPool;

  String? get lastDoctorNote => _lastDoctorNote;

  ScareQuestion getNextQuestion({required String locale}) {
    // 1. Determine what the user is most afraid of
    final dominantFear = profile.dominantFear;

    // Robust error handling: Check if the question pool is empty
    if (_questionPool.isEmpty) {
      throw StateError("The question pool is empty. Cannot retrieve next question.");
    }

    // If no dominant fear is identified yet (e.g., all scores are 0),
    // or if it's the fallback 'unknown' type, return a random question.
    if (dominantFear == FearType.unknown ||
        profile.scores.values.every((score) => score == 0)) {
      return (_questionPool..shuffle()).first;
    }

    // Calculate a score for each question based on its relevance to the dominant fear.
    // Score 2: Both options reinforce the dominant fear.
    // Score 1: One option reinforces the dominant fear.
    // Score 0: Neither option reinforces the dominant fear.
    final List<MapEntry<ScareQuestion, int>> scoredQuestions = _questionPool
        .map((q) {
          int score = 0;
          if (q.optionA.impact == dominantFear) {
            score++;
          }
          if (q.optionB.impact == dominantFear) {
            score++;
          }
          return MapEntry(q, score);
        })
        .toList();

    // Find the maximum score achieved by any question.
    final int maxScore =
        scoredQuestions.map((entry) => entry.value).fold(0, (prev, score) => score > prev ? score : prev);

    // Filter for questions that achieved the maximum score.
    final List<ScareQuestion> bestQuestions = scoredQuestions
        .where((entry) => entry.value == maxScore && maxScore > 0)
        .map((entry) => entry.key)
        .toList();

    // If there are best questions (maxScore > 0), return a random one from them.
    // Otherwise, if no questions directly target the dominant fear with a score > 0,
    // or if the list is empty (which should be caught by the initial check, but for safety),
    // return a random question from the entire pool as a fallback.
    if (bestQuestions.isNotEmpty) {
      return (bestQuestions..shuffle()).first;
    } else {
      return (_questionPool..shuffle()).first;
    }
  }

  String processUserChoice(ScareOption chosenOption) {
    // Update the profile based on the impact of the choice
    profile = profile.copyWithAddedScore(chosenOption.impact);
    // Generate and store the doctor's note
    _lastDoctorNote = getRandomDoctorNote(
      chosenOption.impact,
      customDoctorNotes ?? defaultDoctorNoteTemplates,
      previousNote: _lastDoctorNote,
    );
    return _lastDoctorNote!;
  }
}
