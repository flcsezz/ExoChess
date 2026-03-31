import 'package:flutter/material.dart';
import 'package:exochess_mobile/src/constants.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/widgets/cyberpunk/cyberpunk.dart';

const _customOpacity = 0.6;
const _defaultStatFontSize = 12.0;
const _defaultValueFontSize = 18.0;

class StatCard extends StatelessWidget {
  const StatCard(
    this.stat, {
    this.child,
    this.value,
    this.contentPadding,
    this.opacity,
    this.statFontSize,
    this.valueFontSize,
    this.backgroundColor,
    this.elevation = 0,
  });

  final String stat;
  final Widget? child;
  final String? value;
  final EdgeInsets? contentPadding;
  final double? opacity;
  final double? statFontSize;
  final double? valueFontSize;
  final Color? backgroundColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultStatStyle = TextStyle(
      color: isDark ? Colors.white38 : Colors.black54,
      fontSize: statFontSize ?? _defaultStatFontSize,
      fontFamily: 'SpaceMono',
      fontWeight: FontWeight.bold,
    );

    final defaultValueStyle = TextStyle(
      fontSize: valueFontSize ?? _defaultValueFontSize,
      fontFamily: 'SpaceMono',
      fontWeight: FontWeight.bold,
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      color: isDark ? null : Colors.white,
      child: Padding(
        padding: contentPadding ?? const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.scaleDown,
              child: Text(stat.toUpperCase(), style: defaultStatStyle, textAlign: TextAlign.center),
            ),
            if (value != null)
              Text(value!.toUpperCase(), style: defaultValueStyle, textAlign: TextAlign.center)
            else if (child != null)
              child!
            else
              Text('?', style: defaultValueStyle),
          ],
        ),
      ),
    );
  }
}

class StatCardRow extends StatelessWidget {
  final List<StatCard> cards;

  const StatCardRow(this.cards);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _divideRow(cards).map((e) => Expanded(child: e)).toList(growable: false),
      ),
    );
  }
}

@allowedWidgetReturn
Iterable<Widget> _divideRow(Iterable<Widget> elements) {
  final list = elements.toList();

  if (list.isEmpty || list.length == 1) {
    return list;
  }

  Widget wrapElement(Widget el) {
    return Container(margin: const EdgeInsets.only(right: 8), child: el);
  }

  return <Widget>[...list.take(list.length - 1).map(wrapElement), list.last];
}
