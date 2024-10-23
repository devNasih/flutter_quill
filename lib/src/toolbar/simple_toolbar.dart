import 'package:flutter/material.dart';

import '../controller/quill_controller.dart';
import '../document/attribute.dart';
import '../document/document.dart';
import 'base_toolbar.dart';
import 'buttons/arrow_indicated_list_button.dart';
import 'config/toolbar_configurations.dart';
import 'simple_toolbar_provider.dart';

class QuillSimpleToolbar extends StatelessWidget
    implements PreferredSizeWidget {
  factory QuillSimpleToolbar({
    required QuillSimpleToolbarConfigurations? configurations,
    QuillController? controller,
    Key? key,
  }) {
    // ignore: deprecated_member_use_from_same_package
    controller ??= configurations?.controller;
    assert(controller != null,
        'controller required. Provide controller directly (preferred) or indirectly through configurations (not recommended - will be removed in future versions).');
    controller ??= QuillController(
        document: Document(),
        selection: const TextSelection.collapsed(offset: 0));
    //
    controller.toolbarConfigurations = configurations;
    //
    return QuillSimpleToolbar._(
      controller: controller,
      key: key,
    );
  }

  const QuillSimpleToolbar._({
    required this.controller,
    super.key,
  });

  final QuillController controller;

  /// The configurations for the toolbar widget of flutter quill
  QuillSimpleToolbarConfigurations get configurations =>
      controller.toolbarConfigurations;

  double get _toolbarSize => configurations.toolbarSize * 1.4;

  @override
  Widget build(BuildContext context) {
    List<Widget> childrenBuilder(BuildContext context) {
      final toolbarConfigurations =
          context.requireQuillSimpleToolbarConfigurations;


      final groups = [
        [
          if (configurations.showListNumbers)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.ol,
              options: toolbarConfigurations.buttonOptions.listNumbers,
              controller: controller,
            ),
          if (configurations.showListBullets)
            QuillToolbarToggleStyleButton(
              attribute: Attribute.ul,
              options: toolbarConfigurations.buttonOptions.listBullets,
              controller: controller,
            ),
          if (configurations.showListCheck)
            QuillToolbarToggleCheckListButton(
              options: toolbarConfigurations.buttonOptions.toggleCheckList,
              controller: controller,
            ),
        ],
      ];

      final buttonsAll = <Widget>[];

      for (var i = 0; i < groups.length; i++) {
        final buttons = groups[i];

        if (buttons.isNotEmpty) {
          buttonsAll.addAll(buttons);
        }
      }

      return buttonsAll;
    }

    return QuillSimpleToolbarProvider(
      toolbarConfigurations: configurations,
      child: QuillToolbar(
        configurations: QuillToolbarConfigurations(
          buttonOptions: configurations.buttonOptions,
        ),
        child: Builder(
          builder: (context) {
            if (configurations.multiRowsDisplay) {
              return Wrap(
                direction: configurations.axis,
                alignment: configurations.toolbarIconAlignment,
                crossAxisAlignment: configurations.toolbarIconCrossAlignment,
                runSpacing: configurations.toolbarRunSpacing,
                spacing: configurations.toolbarSectionSpacing,
                children: childrenBuilder(context),
              );
            }
            return Container(
              decoration: configurations.decoration ??
                  BoxDecoration(
                    color:
                        configurations.color ?? Theme.of(context).canvasColor,
                  ),
              constraints: BoxConstraints.tightFor(
                height: configurations.axis == Axis.horizontal
                    ? _toolbarSize
                    : null,
                width:
                    configurations.axis == Axis.vertical ? _toolbarSize : null,
              ),
              child: QuillToolbarArrowIndicatedButtonList(
                axis: configurations.axis,
                buttons: childrenBuilder(context),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize => configurations.axis == Axis.horizontal
      ? const Size.fromHeight(kDefaultToolbarSize)
      : const Size.fromWidth(kDefaultToolbarSize);
}

/// The divider which is used for separation of buttons in the toolbar.
///
/// It can be used outside of this package, for example when user does not use
/// [QuillToolbar.basic] and compose toolbar's children on its own.
class QuillToolbarDivider extends StatelessWidget {
  const QuillToolbarDivider(
    this.axis, {
    super.key,
    this.color,
    this.space,
  });

  /// Provides a horizontal divider for vertical toolbar.
  const QuillToolbarDivider.horizontal({Key? key, Color? color, double? space})
      : this(Axis.horizontal, color: color, space: space, key: key);

  /// Provides a horizontal divider for horizontal toolbar.
  const QuillToolbarDivider.vertical({Key? key, Color? color, double? space})
      : this(Axis.vertical, color: color, space: space, key: key);

  /// The axis along which the toolbar is.
  final Axis axis;

  /// The color to use when painting this divider's line.
  final Color? color;

  /// The divider's space (width or height) depending of [axis].
  final double? space;

  @override
  Widget build(BuildContext context) {
    // Vertical toolbar requires horizontal divider, and vice versa
    return axis == Axis.vertical
        ? Divider(
            height: space,
            color: color,
            indent: 12,
            endIndent: 12,
          )
        : VerticalDivider(
            width: space,
            color: color,
            indent: 12,
            endIndent: 12,
          );
  }
}
