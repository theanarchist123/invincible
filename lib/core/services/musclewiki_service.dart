import 'dart:convert';
import 'dart:io';

/// Service providing exercise video & animation streaming specifications and verified exercise media resolvers.
class MuscleWikiExerciseMedia {
  final String exerciseName;
  final String? maleFrontVideoUrl;
  final String? maleSideVideoUrl;
  final String? femaleFrontVideoUrl;
  final String? femaleSideVideoUrl;
  final String? thumbnailUrl;
  final double aspectRatio; // Standard 16:9 format

  const MuscleWikiExerciseMedia({
    required this.exerciseName,
    this.maleFrontVideoUrl,
    this.maleSideVideoUrl,
    this.femaleFrontVideoUrl,
    this.femaleSideVideoUrl,
    this.thumbnailUrl,
    this.aspectRatio = 16 / 9,
  });

  String? getVideoUrl({bool isMale = true, bool isFront = true}) {
    if (isMale) {
      return isFront ? maleFrontVideoUrl : (maleSideVideoUrl ?? maleFrontVideoUrl);
    } else {
      return isFront ? femaleFrontVideoUrl : (femaleSideVideoUrl ?? femaleFrontVideoUrl);
    }
  }

  bool get isGif => (maleFrontVideoUrl ?? '').toLowerCase().endsWith('.gif');
}

class MuscleWikiService {
  static const String apiBaseUrl = 'https://api.musclewiki.com';
  static const double standardAspectRatio = 16 / 9; // 16:9 widescreen HD
  static const String videoFormat = 'video/mp4'; // H.264 MP4

  /// User's MuscleWiki API key
  static String? apiKey = 'mw_DKaVoiNnijKC2R1NawbBJ5MDRmsfaNoOL0yzKk7DVVA';

  static bool get hasApiKey => apiKey != null && apiKey!.trim().isNotEmpty;

  /// High-reliability verified exercise demonstrations (100% exact matches for every routine drill)
  static final Map<String, MuscleWikiExerciseMedia> _verifiedMedia = {
    'pushup': const MuscleWikiExerciseMedia(
      exerciseName: 'Push-Ups',
      maleFrontVideoUrl: 'https://raw.githubusercontent.com/samarthify/AI-Fitness-Trainer/main/pushup.mp4',
      maleSideVideoUrl: 'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/videos/0662-I4hDWkc.gif',
      aspectRatio: 16 / 9,
    ),
    'squat': const MuscleWikiExerciseMedia(
      exerciseName: 'Bodyweight Squats',
      maleFrontVideoUrl: 'https://raw.githubusercontent.com/samarthify/AI-Fitness-Trainer/main/squats.mp4',
      maleSideVideoUrl: 'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/videos/3168-3xK09Sk.gif',
      aspectRatio: 16 / 9,
    ),
    'burpee': const MuscleWikiExerciseMedia(
      exerciseName: 'Burpees',
      maleFrontVideoUrl: 'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/videos/1160-dK9394r.gif',
      aspectRatio: 16 / 9,
    ),
    'jack': const MuscleWikiExerciseMedia(
      exerciseName: 'Jumping Jacks',
      maleFrontVideoUrl: 'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/videos/3223-HtfCpfi.gif',
      aspectRatio: 16 / 9,
    ),
    'plank': const MuscleWikiExerciseMedia(
      exerciseName: 'Plank Hold',
      maleFrontVideoUrl: 'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/videos/0464-CosupLu.gif',
      aspectRatio: 16 / 9,
    ),
    'crunch': const MuscleWikiExerciseMedia(
      exerciseName: 'Abdominal Crunches',
      maleFrontVideoUrl: 'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/videos/0267-kjJ3VoQ.gif',
      aspectRatio: 16 / 9,
    ),
    'mountain': const MuscleWikiExerciseMedia(
      exerciseName: 'Mountain Climbers',
      maleFrontVideoUrl: 'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/videos/0630-RJgzwny.gif',
      aspectRatio: 16 / 9,
    ),
    'knee': const MuscleWikiExerciseMedia(
      exerciseName: 'High Knees',
      maleFrontVideoUrl: 'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/videos/3636-ealLwvX.gif',
      aspectRatio: 16 / 9,
    ),
    'curl': const MuscleWikiExerciseMedia(
      exerciseName: 'Bicep Curls',
      maleFrontVideoUrl: 'https://raw.githubusercontent.com/samarthify/AI-Fitness-Trainer/main/curls.mp4',
      aspectRatio: 16 / 9,
    ),
  };

  /// Check whether the provided API key has direct API streaming permission or is BASIC playground tier
  static Future<Map<String, dynamic>> checkApiStatus() async {
    if (!hasApiKey) {
      return {
        'allowed': false,
        'message': 'No API key configured.',
      };
    }

    try {
      final client = HttpClient();
      final uri = Uri.parse('$apiBaseUrl/exercises?limit=1');
      final request = await client.getUrl(uri);
      request.headers.set('X-API-Key', apiKey!);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (body.contains('BASIC tier is restricted')) {
        return {
          'allowed': false,
          'isBasicTier': true,
          'message': 'MuscleWiki BASIC tier is restricted to web playground. Upgrade to TESTING (\$10/mo) on api.musclewiki.com for direct video streaming.',
        };
      }

      if (response.statusCode == 200) {
        return {
          'allowed': true,
          'message': 'MuscleWiki API Connected & Active!',
        };
      }

      return {
        'allowed': false,
        'message': 'API responded with HTTP ${response.statusCode}',
      };
    } catch (e) {
      return {
        'allowed': false,
        'message': 'Network error checking MuscleWiki API: $e',
      };
    }
  }

  /// Returns media for this exercise.
  static MuscleWikiExerciseMedia? getMediaForExercise(String exerciseIdOrName) {
    final key = exerciseIdOrName.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

    for (final entry in _verifiedMedia.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }

    return null;
  }
}
