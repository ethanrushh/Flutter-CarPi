import 'package:intl/intl.dart';

final nf = NumberFormat('00');

String formatDurationMmSs(Duration d) {
  final minutes = nf.format(d.inMinutes.remainder(60));
  final seconds = nf.format(d.inSeconds.remainder(60));
  return '$minutes:$seconds';
}
