import 'package:flutter/material.dart';
import '../../app/app.dart';

class VisualIndicator extends StatelessWidget {
  VisualIndicator({required this.amplitude, required this.startedAudio}) {
    ///limit amplitude to [decibleLimit]
    double db = amplitude ?? Constants.decibleLimit;
    if (db == double.infinity || db < Constants.decibleLimit) {
      db = Constants.decibleLimit;
    }
    if (db > 0) {
      db = 0;
    }

    ///this expression converts [db] to [0 to 1] double
    ///
    if (startedAudio) {
      range = 1 - (db * (1 / Constants.decibleLimit));
    } else {
      range = 0.0;
    }
    if (range > 0) print("range = $range");
  }

  final double? amplitude;
  final bool startedAudio;
  final double maxHeight = 100;

  late final double range;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildBar(0.15),
        buildBar(0.5),
        buildBar(0.25),
        buildBar(0.75),
        buildBar(0.5),
        buildBar(1),
        buildBar(0.75),
        buildBar(0.5),
        buildBar(0.25),
        buildBar(0.5),
        buildBar(0.15),
      ],
    );
  }

  buildBar(double intensity) {
    double barHeight = range * maxHeight * intensity;
    if (barHeight < 5) {
      barHeight = 5;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: Constants.amplitudeCaptureRateInMilliSeconds,
        ),
        height: barHeight,
        width: 5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              spreadRadius: 1,
              offset: Offset(1, 1),
            ),
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 1,
              offset: Offset(-1, -1),
            ),
          ],
        ),
      ),
    );
  }
}
