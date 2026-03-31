import 'package:flutter/material.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/widgets/buttons.dart';
import 'package:exochess_mobile/src/widgets/cyberpunk/cyberpunk.dart';

/// A platform agnostic list section.
///
/// Use to show a limited number of items.
class ListSection extends StatelessWidget {
  const ListSection({
    super.key,
    required this.children,
    this.header,
    this.onHeaderTap,
    this.headerTrailing,
    this.footer,
    this.margin,
    this.hasLeading = false,
    this.leadingIndent,
    this.dense = false,
    this.materialFilledCard = false,
    this.clipBehavior = Clip.hardEdge,
    this.backgroundColor,
  }) : _isLoading = false;

  ListSection.loading({
    required int itemsNumber,
    bool header = false,
    this.margin,
    this.hasLeading = false,
  }) : children = [for (int i = 0; i < itemsNumber; i++) const SizedBox.shrink()],
       onHeaderTap = null,
       headerTrailing = null,
       header = header ? const SizedBox.shrink() : null,
       footer = null,
       dense = false,
       leadingIndent = null,
       materialFilledCard = false,
       clipBehavior = Clip.hardEdge,
       backgroundColor = null,
       _isLoading = true;

  /// Usually a list of [ListTile] widgets
  final List<Widget> children;

  /// Whether the iOS tiles have a leading widget.
  final bool hasLeading;

  /// Cupertino leading indent.
  final double? leadingIndent;

  /// Show a header above the children rows. Typically a [Text] widget.
  final Widget? header;

  /// A callback to be called when the header is tapped.
  final VoidCallback? onHeaderTap;

  /// A widget to show at the end of the header (only if [onHeaderTap] is null).
  final Widget? headerTrailing;

  /// A widget to show at the end of the section.
  final Widget? footer;

  final EdgeInsetsGeometry? margin;

  /// Whether the card should have a filled background.
  final bool materialFilledCard;

  final Clip clipBehavior;

  /// Use it to set [ListTileTheme.dense] property.
  final bool dense;

  final Color? backgroundColor;

  final bool _isLoading;

  static const double materialVerticalPadding = 8.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.64,
      child: _isLoading
          ? Column(
              children: [
                Padding(
                  padding: margin ?? Styles.bodySectionPadding,
                  child: Card(
                    child: Column(
                      children: [
                        const SizedBox(height: materialVerticalPadding),
                        if (header != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                            child: Container(
                              width: double.infinity,
                              height: 25,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : Colors.black12,
                                borderRadius: const BorderRadius.all(Radius.circular(16)),
                              ),
                            ),
                          ),
                      for (int i = 0; i < children.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                          child: Container(
                            width: double.infinity,
                            height: 25,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black12,
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                      const SizedBox(height: materialVerticalPadding),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Padding(
              padding: margin ?? Styles.bodySectionPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (header != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: ListSectionHeader(title: header!, onTap: onHeaderTap, trailing: headerTrailing),
                    ),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (theme.platform == TargetPlatform.iOS)
                          ..._divideTiles(
                            context: context,
                            tiles: children,
                            cupertinoHasLeading: hasLeading,
                            cupertinoLeadingIndent: leadingIndent,
                          )
                        else
                          ...children,
                      ],
                    ),
                  ),
                  if (footer != null) footer!,
                ],
              ),
            ),
    );
  }

  static Iterable<Widget> _divideTiles({
    required BuildContext context,
    required Iterable<Widget> tiles,
    bool cupertinoHasLeading = false,
    double? cupertinoLeadingIndent,
  }) {
    final tilesList = tiles.toList();

    if (tilesList.isEmpty || tilesList.length == 1) {
      return tiles;
    }

    final List<Widget> result = [];
    final theme = Theme.of(context);
    for (int i = 0; i < tilesList.length; i++) {
      result.add(tilesList.elementAt(i));
      if (i != tilesList.length - 1) {
        result.add(
          Divider(
            height: 1,
            indent: cupertinoHasLeading ? 56 : 16,
            endIndent: 16,
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
        );
      }
    }
    return result;
  }
}

/// A header for a [ListSection].
class ListSectionHeader extends StatelessWidget {
  const ListSectionHeader({super.key, required this.title, this.onTap, this.trailing});

  final Widget title;

  /// A callback to be called when the header is tapped.
  final VoidCallback? onTap;

  /// A widget to show at the end of the header (only if [onTap] is null).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return OpacityButton(
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: DefaultTextStyle.merge(
              style: Styles.sectionTitle.copyWith(
                letterSpacing: 1.2,
              ),
              child: title is Text 
                ? Text((title as Text).data?.toUpperCase() ?? '', style: Styles.sectionTitle.copyWith(letterSpacing: 1.2))
                : title,
            ),
          ),
          if (onTap != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.more.toUpperCase(), 
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontFamily: 'SpaceMono',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.primary),
              ],
            )
          else if (trailing != null)
            trailing!,
        ],
      ),
    );
  }
}

/// Platform agnostic divider widget.
///
/// Useful to show a divider between [ListTile] widgets when using the
/// [ListView.separated] constructor.
class PlatformDivider extends StatelessWidget {
  const PlatformDivider({
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
    this.cupertinoHasLeading = false,
    this.cupertinoLeadingIndent,
  });

  final double? height;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;

  /// Set to true if the cupertino tiles have a leading widget, to adapt the
  /// divider margin.
  final bool cupertinoHasLeading;
  final double? cupertinoLeadingIndent;

  static const _defaultListTileLeadingWidth = 40.0;

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.android
        ? Divider(
            height: height,
            thickness: thickness,
            indent: indent,
            endIndent: endIndent,
            color: color,
          )
        : Divider(
            height: height,
            thickness: thickness ?? 0.0,
            indent:
                indent ??
                (cupertinoHasLeading
                    ? 16.0 + (cupertinoLeadingIndent ?? _defaultListTileLeadingWidth)
                    : 16.0),
            endIndent: endIndent,
            color: color,
          );
  }
}

typedef RemovedItemBuilder<T> =
    Widget Function(T item, BuildContext context, Animation<double> animation);

/// Keeps a Dart [List] in sync with an [AnimatedList].
///
/// The [insert] and [removeAt] methods apply to both the internal list and
/// the animated list that belongs to [listKey].
class AnimatedListModel<E> {
  AnimatedListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
    int? itemsOffset,
  }) : _items = List<E>.from(initialItems ?? <E>[]),
       itemsOffset = itemsOffset ?? 0;

  final GlobalKey<AnimatedListState> listKey;
  final RemovedItemBuilder<E> removedItemBuilder;
  final List<E> _items;
  final int itemsOffset;

  AnimatedListState? get _animatedList => listKey.currentState;

  void prepend(E item) {
    _items.insert(0, item);
    _animatedList!.insertItem(itemsOffset);
  }

  void insert(int index, E item) {
    _items.insert(index - itemsOffset, item);
    _animatedList!.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index - itemsOffset);
    if (removedItem != null) {
      _animatedList!.removeItem(index, (BuildContext context, Animation<double> animation) {
        return removedItemBuilder(removedItem, context, animation);
      });
    }
    return removedItem;
  }

  int get length => _items.length + itemsOffset;

  E operator [](int index) => _items[index - itemsOffset];

  int indexOf(E item) => _items.indexOf(item) + itemsOffset;
}

/// Keeps a Dart [List] in sync with a [SliverAnimatedList].
///
/// The [insert] and [removeAt] methods apply to both the internal list and
/// the animated list that belongs to [listKey].
class SliverAnimatedListModel<E> {
  SliverAnimatedListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
    int? itemsOffset,
  }) : _items = List<E>.from(initialItems ?? <E>[]),
       itemsOffset = itemsOffset ?? 0;

  final GlobalKey<SliverAnimatedListState> listKey;
  final RemovedItemBuilder<E> removedItemBuilder;
  final List<E> _items;
  final int itemsOffset;

  SliverAnimatedListState? get _animatedList => listKey.currentState;

  void prepend(E item) {
    _items.insert(0, item);
    _animatedList!.insertItem(itemsOffset);
  }

  void insert(int index, E item) {
    _items.insert(index - itemsOffset, item);
    _animatedList!.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index - itemsOffset);
    if (removedItem != null) {
      _animatedList!.removeItem(index, (BuildContext context, Animation<double> animation) {
        return removedItemBuilder(removedItem, context, animation);
      });
    }
    return removedItem;
  }

  int get length => _items.length + itemsOffset;

  E operator [](int index) => _items[index - itemsOffset];

  int indexOf(E item) => _items.indexOf(item) + itemsOffset;
}
