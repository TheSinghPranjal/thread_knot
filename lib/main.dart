import 'package:flutter/material.dart';

import 'app.dart';
import 'persist/progress.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await ProgressStore.load();
  runApp(ThreadKnotApp(progress: progress));
}
