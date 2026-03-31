import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:exochess_mobile/src/model/common/time_increment.dart';
import 'package:exochess_mobile/src/model/lobby/game_setup_preferences.dart';
import 'package:exochess_mobile/src/styles/exochess_icons.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/widgets/adaptive_bottom_sheet.dart';
import 'package:exochess_mobile/src/widgets/non_linear_slider.dart';
import 'package:exochess_mobile/src/widgets/settings.dart';
import 'package:exochess_mobile/src/widgets/cyberpunk/cyberpunk.dart';
import 'package:exochess_mobile/src/styles/exochess_colors.dart';

class TimeControlModal extends StatelessWidget {
  const TimeControlModal({
    required this.timeIncrement,
    required this.onSelected,
    this.excludeUltraBullet = false,
    super.key,
  });

  final TimeIncrement timeIncrement;
  final ValueSetter<TimeIncrement> onSelected;

  final bool excludeUltraBullet;

  static const _horizontalPadding = EdgeInsets.symmetric(horizontal: 16.0);
  static const _sectionSpacing = SizedBox(height: 16.0);

  @override
  Widget build(BuildContext context) {
    void onSelected(TimeIncrement choice) {
      Navigator.pop(context);
      this.onSelected(choice);
    }

    return BottomSheetScrollableContainer(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      children: [
        Padding(
          padding: _horizontalPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.timeControl.toUpperCase(),
                style: const TextStyle(fontFamily: 'NDot', fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                '${context.l10n.minutesPerSide} + ${context.l10n.incrementInSeconds}'.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 11,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24.0),
        Padding(
          padding: Styles.horizontalBodyPadding.add(Styles.sectionBottomPadding),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SectionChoices(
                    timeIncrement,
                    choices: [
                      if (!excludeUltraBullet) const TimeIncrement(0, 1),
                      const TimeIncrement(60, 0),
                      const TimeIncrement(60, 1),
                      const TimeIncrement(120, 1),
                    ],
                    title: const _SectionTitle(title: 'BULLET', icon: ExoChessIcons.bullet),
                    onSelected: onSelected,
                  ),
                  const SizedBox(height: 24),
                  _SectionChoices(
                    timeIncrement,
                    choices: const [
                      TimeIncrement(180, 0),
                      TimeIncrement(180, 2),
                      TimeIncrement(300, 0),
                      TimeIncrement(300, 3),
                    ],
                    title: const _SectionTitle(title: 'BLITZ', icon: ExoChessIcons.blitz),
                    onSelected: onSelected,
                  ),
                  const SizedBox(height: 24),
                  _SectionChoices(
                    timeIncrement,
                    choices: const [
                      TimeIncrement(600, 0),
                      TimeIncrement(600, 5),
                      TimeIncrement(900, 0),
                      TimeIncrement(900, 10),
                    ],
                    title: const _SectionTitle(title: 'RAPID', icon: ExoChessIcons.rapid),
                    onSelected: onSelected,
                  ),
                  const SizedBox(height: 24),
                  _SectionChoices(
                    timeIncrement,
                    choices: const [
                      TimeIncrement(1500, 0),
                      TimeIncrement(1800, 0),
                      TimeIncrement(1800, 20),
                      TimeIncrement(3600, 0),
                    ],
                    title: const _SectionTitle(title: 'CLASSICAL', icon: ExoChessIcons.classical),
                    onSelected: onSelected,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: _horizontalPadding,
          child: Card(
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: timeIncrement.isCustom,
                title: _SectionTitle(title: context.l10n.custom.toUpperCase(), icon: Icons.tune),
                tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                minTileHeight: 0,
                children: [
                  Builder(
                    builder: (context) {
                      TimeIncrement custom = timeIncrement;
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return Padding(
                            padding: const EdgeInsets.all(24.0).copyWith(top: 0),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text.rich(
                                    TextSpan(
                                      text: '${context.l10n.minutesPerSide.toUpperCase()}: ',
                                      style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 12),
                                      children: [
                                        TextSpan(
                                          style: const TextStyle(
                                            fontFamily: 'NDot',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                          text: clockLabelInMinutes(custom.time),
                                        ),
                                      ],
                                    ),
                                  ),
                                  subtitle: NonLinearSlider(
                                    value: custom.time,
                                    values: kAvailableTimesInSeconds,
                                    labelBuilder: clockLabelInMinutes,
                                    onChange: (num value) {
                                      setState(() {
                                        custom = TimeIncrement(value.toInt(), custom.increment);
                                      });
                                    },
                                    onChangeEnd: (num value) {
                                      setState(() {
                                        custom = TimeIncrement(value.toInt(), custom.increment);
                                      });
                                    },
                                  ),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text.rich(
                                    TextSpan(
                                      text: '${context.l10n.incrementInSeconds.toUpperCase()}: ',
                                      style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 12),
                                      children: [
                                        TextSpan(
                                          style: const TextStyle(
                                            fontFamily: 'NDot',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                          text: custom.increment.toString(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  subtitle: NonLinearSlider(
                                    value: custom.increment,
                                    values: kAvailableIncrementsInSeconds,
                                    onChange: (num value) {
                                      setState(() {
                                        custom = TimeIncrement(custom.time, value.toInt());
                                      });
                                    },
                                    onChangeEnd: (num value) {
                                      setState(() {
                                        custom = TimeIncrement(custom.time, value.toInt());
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: custom.isInfinite ? null : () => onSelected(custom),
                                  child: Text(context.l10n.mobileOkButton.toUpperCase(), style: const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionChoices extends StatelessWidget {
  const _SectionChoices(
    this.selected, {
    required this.title,
    required this.choices,
    required this.onSelected,
  });

  final TimeIncrement selected;
  final List<TimeIncrement> choices;
  final _SectionTitle title;
  final void Function(TimeIncrement choice) onSelected;

  static const spacing = SizedBox(width: 8.0);

  @override
  Widget build(BuildContext context) {
    final choiceWidgets = choices
        .mapIndexed((index, choice) {
          return [
            Expanded(
              child: _ChoiceChip(
                key: ValueKey(choice),
                label: Text(choice.display, style: Styles.bold),
                selected: selected == choice,
                onSelected: (bool selected) {
                  if (selected) onSelected(choice);
                },
              ),
            ),
            if (index < choices.length - 1) spacing,
          ];
        })
        .flattened
        .toList();

    if (choices.length < 4) {
      final placeHolders = [
        const [SizedBox(width: 10)],
        for (int i = choices.length; i < 4; i++)
          [const Expanded(child: spacing), if (i < 3) spacing],
      ];
      choiceWidgets.addAll(placeHolders.flattened);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: 4),
        Row(children: choiceWidgets),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final Widget label;
  final bool selected;
  final void Function(bool selected) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected 
          ? (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))
          : Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        border: Border.all(
          color: selected ? accentColor : theme.colorScheme.outline,
          width: selected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        onTap: () => onSelected(true),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Center(
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: selected 
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.white38 : Colors.black38),
              ),
              child: label,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.0, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title, 
          style: const TextStyle(
            fontFamily: 'SpaceMono', 
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
