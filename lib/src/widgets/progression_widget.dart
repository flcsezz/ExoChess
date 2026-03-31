import 'package:flutter/widgets.dart';
import 'package:exochess_mobile/src/styles/exochess_icons.dart';
import 'package:exochess_mobile/src/styles/styles.dart';

const _customOpacity = 0.6;

class ProgressionWidget extends StatelessWidget {
  final int progress;
  final double fontSize;

  const ProgressionWidget(this.progress, {this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (progress != 0) ...[
          Icon(
            progress > 0 ? ExoChessIcons.arrow_full_upperright : ExoChessIcons.arrow_full_lowerright,
            size: fontSize,
            color: progress > 0 ? context.exochessColors.good : context.exochessColors.error,
          ),
          Text(
            progress.abs().toString(),
            style: TextStyle(
              color: progress > 0 ? context.exochessColors.good : context.exochessColors.error,
              fontSize: fontSize,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ] else
          Text(
            '0',
            style: TextStyle(color: textShade(context, _customOpacity), fontSize: fontSize),
          ),
      ],
    );
  }
}
