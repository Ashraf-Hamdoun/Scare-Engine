import 'dart:convert';
import 'dart:io';
import '../models/scare_question.dart';

/// Custom exception for QuestionLoader errors.
class QuestionLoaderException implements Exception {
  final String message;
  final dynamic originalError;

  QuestionLoaderException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError == null) return 'QuestionLoaderException: $message';
    return 'QuestionLoaderException: $message\nOriginal Error: $originalError';
  }
}

class QuestionLoader {
  static List<ScareQuestion> _questions = [];
  static bool _isLoaded = false;

  static Future<void> loadQuestions(String path) async {
    if (_isLoaded) {
      return; // Already loaded
    }
    try {
      final String response = await File(path).readAsString();
      final List<dynamic> data = json.decode(response);
      _questions = data.map((json) => ScareQuestion.fromJson(json)).toList();
      _isLoaded = true;
    } on Exception catch (e) {
      _questions = []; // Ensure it's empty on error
      _isLoaded = true; // Mark as loaded to prevent repeated attempts on error
      throw QuestionLoaderException(
          "Failed to load or parse questions from $path", e);
    }
  }

  static List<ScareQuestion> get questions {
    if (!_isLoaded) {
      // Potentially throw an error or log a warning if questions are accessed before being loaded
      // This scenario should ideally be prevented by ensuring loadQuestions() is called upfront.
    }
    return _questions;
  }

  // For testing purposes, to reset the loaded state
  static void reset() {
    _questions = [];
    _isLoaded = false;
  }
}
