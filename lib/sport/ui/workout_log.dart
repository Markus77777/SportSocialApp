// workout_log.dart

class WorkoutLog {
  final String exerciseName;
  final DateTime startTime;
  final DateTime endTime;
  final int sets;
  final int workoutSeconds;
  final int restSeconds;

  WorkoutLog({
    required this.exerciseName,
    required this.startTime,
    required this.endTime,
    required this.sets,
    required this.workoutSeconds,
    required this.restSeconds,
  });

  String get durationText {
    final duration = endTime.difference(startTime);
    return "${duration.inMinutes} 分 ${duration.inSeconds % 60} 秒";
  }
}

final List<WorkoutLog> workoutHistory = [];
