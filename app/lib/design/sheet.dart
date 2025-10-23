import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import 'button.dart';

class FlySheet extends StatelessWidget {
  const FlySheet({
    super.key,
    required this.title,
    required this.child,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.3,
    this.maxChildSize = 0.95,
    this.showCloseButton = false,
    this.showBackButton = true,
    this.showDragHandle = true,
    this.onClose,
  });

  final String title;
  final Widget child;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool showCloseButton;
  final bool showBackButton;
  final bool showDragHandle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return FlyBox(
          children: [
            // Top bar with centered drag handle and close button
            FlyBox(
              children: [
                // Centered drag handle
                if (showDragHandle)
                  Center(
                    child: FlyBox(
                      children: [],
                    ).w('s20').h('s1').bg('gray400').rounded('sm'),
                  ),
                // Close button positioned on the right
                if (showCloseButton)
                  FlyButton(
                    onTap: () {
                      if (onClose != null) {
                        onClose!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    buttonColor: ButtonColor.secondary,
                    child:
                        FlyBox(
                              children: [FlyIcon(Icons.close).color('gray600')],
                            )
                            .w('s8')
                            .h('s8')
                            .bg('gray200')
                            .rounded('999px')
                            .items('center')
                            .justify('center'),
                  ).top('s2').right('s2'),
              ],
            ).stack().px('s4').py('s2'),
            // Content area
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: child,
              ),
            ),
          ],
        ).col().bg('white').rounded('lg').items('start').justify('start');
      },
    );
  }
}
