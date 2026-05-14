import '../../models/beat.dart';

abstract class BeatState {
  const BeatState();
}

class BeatInitial extends BeatState {
  const BeatInitial();
}

class BeatLoading extends BeatState {
  const BeatLoading();
}

class BeatLoaded extends BeatState {
  final List<Beat> beats;

  const BeatLoaded({required this.beats});

  BeatLoaded copyWith({List<Beat>? beats}) {
    return BeatLoaded(beats: beats ?? this.beats);
  }
}

class BeatError extends BeatState {
  final String message;

  const BeatError({required this.message});
}
