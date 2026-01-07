import '../models/fear_type.dart';
import 'dart:math';

final Map<FearType, List<String>> defaultDoctorNoteTemplates = {
  FearType.paranoia: [
    "You looked behind you before choosing that, didn't you?",
    "Interesting. Always good to be aware of your surroundings, or perhaps, what isn't there.",
    "A subtle shift, yet your vigilance remains. Tell me, what do you fear is watching?",
    "The shadows lengthen, and with them, the eyes unseen. Your choice reflects a keen, if troubled, awareness.",
    "Such caution, a testament to the whispers of unseen observers. Does your vigilance bring comfort, or merely sharpen the edges of your dread?",
  ],
  FearType.isolation: [
    "A lonely path, indeed. Do you prefer the quiet, or is it a burden?",
    "The echo of silence speaks volumes about your choice.",
    "You chose to stand apart. Is that strength, or a deeper yearning?",
    "To be truly alone is to confront oneself without distraction. Your selection hints at a profound, or perhaps isolating, journey.",
    "The world recedes, leaving only the self. Does this solitude offer peace, or merely amplify the silence you seek to fill?",
  ],
  FearType.lossOfControl: [
    "The reins slip. Do you resist, or embrace the inevitable?",
    "A subtle surrender, or a calculated maneuver? The lines blur.",
    "You chose to let go. Was it freedom, or fear of what you might hold?",
    "Power, once grasped, is difficult to relinquish. Your decision suggests a nuanced understanding of its ebb and flow.",
    "To cede control is to invite the unknown. Do you find liberation in the surrender, or a chilling premonition of what may take its place?",
  ],
  FearType.existential: [
    "The void beckons. Do you gaze back, or avert your eyes?",
    "A ponderous choice, for the questions of existence linger.",
    "You chose to acknowledge the unknown. A brave, or perhaps, a foolish endeavor?",
    "The fabric of reality is thin, and your choice brushes against its edges. What truths do you seek in the abyss?",
    "The great questions weigh heavily, and your response reveals a mind grappling with the impermanence of all things. Is it fear, or curiosity, that guides you?",
  ],
  FearType.unknown: [
    "A perplexing response. The path ahead remains shrouded in mist.",
    "Your choice, much like the nature of the unknown, defies easy categorization.",
    "The currents of your psyche are subtle. This choice reveals little, yet suggests much.",
    "The enigma persists. Your decision casts a faint, yet indecipherable, shadow upon the canvas of your fears."
  ],
};

String getRandomDoctorNote(
  FearType fearType,
  Map<FearType, List<String>> templates, {
  String? previousNote,
}) {
  final notes = templates[fearType];
  if (notes == null || notes.isEmpty) {
    return "A silence falls as your choice resonates... (No specific note for this fear type)";
  }

  if (notes.length == 1) {
    return notes.first; // Only one note, repetition is unavoidable
  }

  final _random = Random();
  String selectedNote;
  do {
    selectedNote = notes[_random.nextInt(notes.length)];
  } while (
      selectedNote == previousNote); // Loop until a different note is found

  return selectedNote;
}
