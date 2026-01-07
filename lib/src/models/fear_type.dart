enum FearType {
  paranoia, // Fear of being watched/followed.
  isolation, // Fear of being alone or abandoned.
  lossOfControl, // Fear of the device/AI taking over.
  existential, // Fear of death or the unknown.
  unknown; // Default/Fallback.

  /// Returns a clinical description in Arabic for Dr. Abdelmoati's analysis.
  String get clinicalDescription {
    switch (this) {
      case FearType.paranoia:
        return "حالة من الارتياب الرقمي والمراقبة المستمرة.";
      case FearType.isolation:
        return "خوف من الوحدة المطلقة والانفصال عن الواقع.";
      case FearType.lossOfControl:
        return "قلق ناتج عن فقدان السلطة أمام الذكاء الاصطناعي.";
      case FearType.existential:
        return "رهاب من المجهول وما وراء الوجود الرقمي.";
      case FearType.unknown:
        return "ملف نفسي غير مكتمل.";
    }
  }

  /// Suggests a visual 'glitch' effect intensity for the UI.
  double get glitchIntensity {
    switch (this) {
      case FearType.lossOfControl:
        return 0.8; // High intensity for control loss
      case FearType.paranoia:
        return 0.4;
      default:
        return 0.2;
    }
  }
}
