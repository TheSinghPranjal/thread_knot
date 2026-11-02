// ignore_for_file: avoid_print
// Prints difficulty stats for every campaign level.
// Run: dart run tool/level_stats.dart
import 'package:thread_knot/data/level_generator.dart';
import 'package:thread_knot/data/levels.dart';

void main() {
  final sw = Stopwatch()..start();
  for (final level in campaignLevels) {
    final t0 = sw.elapsedMilliseconds;
    final s = measureLevel(level);
    print(
      '${level.id.toString().padLeft(3)} ${level.cols}x${level.rows} '
      '${level.difficulty.padRight(7)} threads=${level.threads.length.toString().padLeft(2)} '
      'free=${s.initialFree} maxFree=${s.maxFreeDuringPlay} depth=${s.depth.toString().padLeft(2)} '
      'fill=${(s.fill * 100).round()}% dirs=${s.directions.length} bent=${s.bentThreads} ${sw.elapsedMilliseconds - t0}ms',
    );
  }
  print('generated in ${sw.elapsedMilliseconds}ms');
}
