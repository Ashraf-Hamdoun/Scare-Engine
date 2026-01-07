# scare_engine

[![pub package](https://img.shields.io/pub/v/scare_engine.svg)](https://pub.dev/packages/scare_engine)

A pure Dart package for psychological vulnerability assessment through a guided, choice-based dialogue.

## Features

- **Psychological Profiling**: Categorizes user fears into Paranoia, Isolation, Loss of Control, and Existential.
- **Dynamic Question Generation**: Selects questions based on the user's dominant fear for targeted assessment.
- **AI Integration Ready**: Designed to work seamlessly with generative AI APIs for personalized interactions.
- **Redux Friendly**: Integrates well with Redux for state management, promoting immutability.
- **Local Fallback**: Provides a local `ScareEngine` implementation for continuity if AI integration fails.
- **Multilingual Support**: Questions provided in English and Arabic.

## Getting Started

To use this package, add `scare_engine` to your `pubspec.yaml` file:

```yaml
dependencies:
  scare_engine: ^0.0.1
```

Then, run `dart pub get` to install the package.

## Usage

The `ScareEngine` orchestrates the psychological assessment process.

### Basic Usage

First, import the necessary components:

```dart
import 'package:scare_engine/scare_engine.dart';
import 'package:scare_engine/src/models/psych_profile.dart';
import 'package:scare_engine/src/models/scare_question.dart';
import 'package:scare_engine/src/data/question_loader.dart';
```

Initialize the engine and get the first question:

```dart
Future<void> main() async {
  // Load questions from a file path.
  // In a real app, this path would point to your questions JSON file.
  // For example, in a Flutter app, you might first copy it from assets.
  await QuestionLoader.loadQuestions('assets/questions.json');
  final List<ScareQuestion> questions = QuestionLoader.questions;

  // Initialize with an optional existing profile
  final scareEngine = ScareEngine(
    questionPool: questions,
    doctorName: "Dr. Enigma", // Optional: Customize the doctor's name
  );

  // You can also provide custom doctor notes:
  final customNotes = {
    FearType.paranoia: ["A custom note for paranoia."]
  };
  final customScareEngine = ScareEngine(
    questionPool: questions,
    customDoctorNotes: customNotes, // Provide your custom notes here
  );

  print("--- ${scareEngine.doctorName} Begins ---");

  // Get the first question for the 'en' (English) locale
  ScareQuestion currentQuestion = scareEngine.getNextQuestion(locale: 'en');
  print("Question: ${currentQuestion.getLocalizedQuestionText('en')}");
  print("Option A: ${currentQuestion.optionA.getLocalizedText('en')} (Impact: ${currentQuestion.optionA.impact})");
  print("Option B: ${currentQuestion.optionB.getLocalizedText('en')} (Impact: ${currentQuestion.optionB.impact})");

  // Simulate a user choice (e.g., choosing Option A)
  ScareOption userChoice = currentQuestion.optionA;
  String doctorNote = scareEngine.processUserChoice(userChoice);

  print("\nUser chose: ${userChoice.getLocalizedText('en')}");
  print("Updated PsychProfile scores: ${scareEngine.profile.scores}");
  print("Dominant Fear: ${scareEngine.profile.dominantFear}");
  print("${scareEngine.doctorName}'s Observation: $doctorNote");

  // Get the next question, which might be targeted based on the new dominant fear
  currentQuestion = scareEngine.getNextQuestion(locale: 'en');
  print("\nNext Question: ${currentQuestion.getLocalizedQuestionText('en')}");
}
```

### AI Integration

This package is designed to integrate with a generative AI API (e.g., Google Generative AI). The AI should act as "Dr. Abdelmoati" and adhere to the "ScareEngine System Prompt" provided in the [docs/prompt.txt](docs/prompt.txt) file.

The AI is expected to return questions in a specific JSON format:

```json
{
  "question": "العربية (The Question Text)",
  "options": [
    {"text": "Option A", "impact": "fear_category"},
    {"text": "Option B", "impact": "fear_category"}
  ],
  "doctor_note": "A creepy observation about why they chose the previous answer."
}
```

Your app would send context (like user name/age) to the AI and parse its JSON response into a `ScareQuestion` object.

### Redux Integration

The `PsychProfile` class is designed with immutability in mind, making it suitable for Redux state management. When the AI returns an `impact` field or a local `ScareOption` is chosen, your Redux middleware should update the `PsychProfile` in your application's state.

The `PsychProfile.copyWithAddedScore(FearType type)` method returns a *new* `PsychProfile` instance with updated scores, facilitating immutable updates.

```dart
// Example of how Redux middleware might update the profile
// Assuming 'state.psychProfile' is the current profile in your Redux store
PsychProfile newProfile = state.psychProfile.copyWithAddedScore(chosenFearType);
// Dispatch an action to update the state with newProfile
```

### Fear Categories

The package categorizes psychological fears into:

-   **Paranoia**: Fear of being watched or followed.
-   **Isolation**: Fear of being alone or forgotten.
-   **Loss of Control**: Fear of an external entity (like an app or AI) taking over.
-   **Existential**: Fear of the unknown or death.

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.

## License

This package is distributed under the MIT License. See the `LICENSE` file for more information.
