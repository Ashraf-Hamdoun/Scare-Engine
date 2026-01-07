import 'fear_type.dart';
import 'package:collection/collection.dart';

class PsychProfile {
  final Map<FearType, int> scores;

  PsychProfile({Map<FearType, int>? scores})
    : this.scores =
          scores ??
          {
            FearType.paranoia: 0,
            FearType.isolation: 0,
            FearType.lossOfControl: 0,
            FearType.existential: 0,
          };

  // Logic to find the user's greatest fear
  FearType get dominantFear {
    if (scores.values.every((score) => score == 0)) {
      return FearType.paranoia; // Consistent default for tied zero scores
    }
    // Find the max score
    final maxScore = scores.values.reduce((a, b) => a > b ? a : b);
    // Return the first FearType in definition order that matches the max score
    return FearType.values.firstWhere((fearType) => scores[fearType] == maxScore);
  }

  // Create a new profile with updated scores (Immutable for Redux)
  PsychProfile copyWithAddedScore(FearType type) {
    if (type == FearType.unknown) return this; // Do not score unknown fears

    final newScores = Map<FearType, int>.from(scores);
    newScores[type] = (newScores[type] ?? 0) + 1;
    return PsychProfile(scores: newScores);
  }

  // For persistence with shared_preferences/Redux Persist
  Map<String, dynamic> toJson() => {
    'scores': scores.map((key, value) => MapEntry(key.name, value)),
  };

  factory PsychProfile.fromJson(Map<String, dynamic> json) {
    final scoresJson = json['scores'] as Map<String, dynamic>;
    final Map<FearType, int> newScores = {
      FearType.paranoia: 0,
      FearType.isolation: 0,
      FearType.lossOfControl: 0,
      FearType.existential: 0,
    };

    scoresJson.forEach((keyString, value) {
      final fearType = FearType.values.firstWhereOrNull((e) => e.name == keyString);
      if (fearType != null && fearType != FearType.unknown) {
        newScores[fearType] = value as int;
      }
    });
    return PsychProfile(scores: newScores);
  }
}
