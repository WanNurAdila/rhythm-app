import '../../models/beat.dart';

abstract class BeatEvent {
  const BeatEvent();
}

class BeatsLoadRequested extends BeatEvent {
  const BeatsLoadRequested();
}

class BeatAddRequested extends BeatEvent {
  final BeatType type;
  final String name;
  final String? startTime;
  final int? durationMinutes;
  final bool isActive;
  final int sortOrder;

  const BeatAddRequested({
    required this.type,
    required this.name,
    this.startTime,
    this.durationMinutes,
    this.isActive = true,
    required this.sortOrder,
  });
}

class BeatToggleRequested extends BeatEvent {
  final String id;
  final bool isActive;

  const BeatToggleRequested({required this.id, required this.isActive});
}

class BeatDeleteRequested extends BeatEvent {
  final String id;

  const BeatDeleteRequested(this.id);
}
