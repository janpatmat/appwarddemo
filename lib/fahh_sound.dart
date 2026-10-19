import 'package:audioplayers/audioplayers.dart';

/// Plays the FAHH meme sound bundled at `assets/sounds/fahh.mp3`.
class FahhSound {
  FahhSound() {
    // Keep the clip loaded after it finishes so replays start straight away.
    _player.setReleaseMode(ReleaseMode.stop);
    // Load the clip now so the first tap doesn't wait for it. If this fails,
    // play() loads it again and reports the error there.
    _player.setSource(_source).ignore();
  }

  static final _source = AssetSource('sounds/fahh.mp3');

  final _player = AudioPlayer();

  /// Plays the sound from the start, cutting off any playback in progress.
  Future<void> play() async {
    await _player.stop();
    await _player.play(_source);
  }

  Future<void> dispose() => _player.dispose();
}
