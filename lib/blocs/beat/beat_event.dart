abstract class BeatEvent {
  const BeatEvent();
}

class BeatsLoadRequested extends BeatEvent {
  const BeatsLoadRequested();
}

class BeatAddRequested extends BeatEvent {
  final String name;
  final String color;
  final String startTime;
  final String endTime;
  final int sortOrder;

  const BeatAddRequested({
    required this.name,
    required this.color,
    required this.startTime,
    required this.endTime,
    required this.sortOrder,
  });
}

class BeatUpdateRequested extends BeatEvent {
  final String id;
  final String name;
  final String color;
  final String startTime;
  final String endTime;
  final bool isActive;

  const BeatUpdateRequested({
    required this.id,
    required this.name,
    required this.color,
    required this.startTime,
    required this.endTime,
    required this.isActive,
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
