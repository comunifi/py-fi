import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../design/avatar.dart';
import '../design/button.dart';
import '../design/card.dart';

class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Design System'),
        backgroundColor: CupertinoColors.systemBlue,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: FlyBox(
            children: [
              ..._buildButtonExamples(context),
              ..._buildAvatarExamples(),
              ..._buildCardExamples(),
            ],
          ).col().items('start').justify('start').gap('s6').bg('white').p('s8'),
        ),
      ),
    );
  }

  List<Widget> _buildButtonExamples(BuildContext context) {
    return [
      // Button Examples
      FlyText('Button Examples').text('xl').weight('bold').color('gray800'),

      // Colors
      FlyCard(
        variant: CardVariant.outlined,
        size: CardSize.medium,
        children: [
          FlyText('Colors').text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyButton(
                onTap: () => _showAlert(context),
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.solid,
                size: ButtonSize.medium,
                child: FlyText('Primary'),
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.secondary,
                variant: ButtonVariant.solid,
                size: ButtonSize.medium,
                child: FlyText('Secondary'),
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.success,
                variant: ButtonVariant.solid,
                size: ButtonSize.medium,
                child: FlyText('Success'),
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.error,
                variant: ButtonVariant.solid,
                size: ButtonSize.medium,
                child: FlyText('Danger'),
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.warning,
                variant: ButtonVariant.solid,
                size: ButtonSize.medium,
                child: FlyText('Warning'),
              ),
              FlyButton(
                onTap: () {},
                variant: ButtonVariant.none,
                buttonColor: ButtonColor.none,
                size: ButtonSize.medium,
                child: FlyText('Unstyled'),
              ),
            ],
          ).row().items('start').gap('s3').wrap(),
        ],
      ),

      // Variants
      FlyCard(
        variant: CardVariant.outlined,
        size: CardSize.medium,
        children: [
          FlyText('Variants').text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyButton(
                onTap: () => _showAlert(context),
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.solid,
                size: ButtonSize.medium,
                child: FlyText('Solid'),
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.soft,
                size: ButtonSize.medium,
                child: FlyText('Soft'),
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.outlined,
                size: ButtonSize.medium,
                child: FlyText('Outlined'),
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.dashed,
                size: ButtonSize.medium,
                child: FlyText('Dashed'),
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.ghost,
                size: ButtonSize.medium,
                child: FlyText('Ghost'),
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.none,
                size: ButtonSize.medium,
                child: FlyText('None'),
              ),
            ],
          ).row().items('start').gap('s3').wrap(),
        ],
      ),

      // Sizes
      FlyCard(
        variant: CardVariant.filled,
        size: CardSize.medium,
        children: [
          FlyText('Sizes').text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.solid,
                size: ButtonSize.small,
                child: FlyText('Small'),
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.solid,
                size: ButtonSize.medium,
                child: FlyText('Medium'),
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.solid,
                size: ButtonSize.large,
                child: FlyText('Large'),
              ),
            ],
          ).row().items('start').gap('s3'),
        ],
      ),

      // States
      FlyCard(
        variant: CardVariant.outlined,
        size: CardSize.medium,
        children: [
          FlyText('States').text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyButton(
                onTap: () => _showAlert(context),
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.solid,
                size: ButtonSize.medium,
                child: FlyText('Normal'),
              ),
              FlyButton(
                onTap: null,
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.solid,
                size: ButtonSize.medium,
                child: FlyText('Disabled'),
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.solid,
                size: ButtonSize.medium,
                isLoading: true,
                child: FlyText('Loading'),
              ),
            ],
          ).row().items('start').gap('s3'),
        ],
      ),

      // With Icons
      FlyCard(
        variant: CardVariant.filled,
        size: CardSize.medium,
        children: [
          FlyText('With Icons').text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyButton(
                onTap: () => _showAlert(context),
                buttonColor: ButtonColor.primary,
                variant: ButtonVariant.solid,
                size: ButtonSize.medium,
                children: [
                  FlyIcon(LucideIcons.star).color('white'),
                  FlyText(
                    'Star Button',
                  ).color('white').text('sm').weight('medium'),
                ],
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.secondary,
                variant: ButtonVariant.solid,
                size: ButtonSize.medium,
                children: [
                  FlyIcon(LucideIcons.download).color('white'),
                  FlyText(
                    'Download',
                  ).color('white').text('sm').weight('medium'),
                ],
              ),
              FlyButton(
                onTap: () {},
                buttonColor: ButtonColor.success,
                variant: ButtonVariant.solid,
                size: ButtonSize.medium,
                children: [
                  FlyIcon(LucideIcons.check).color('white'),
                  FlyText('Confirm').color('white').text('sm').weight('medium'),
                ],
              ),
            ],
          ).row().items('start').gap('s3').wrap(),
        ],
      ),
    ];
  }

  List<Widget> _buildCardExamples() {
    return [
      // Card Examples
      FlyText('Card Examples').text('xl').weight('bold').color('gray800'),

      // Variants
      FlyCard(
        variant: CardVariant.outlined,
        size: CardSize.medium,
        children: [
          FlyText('Variants').text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyCard(
                variant: CardVariant.outlined,
                size: CardSize.small,
                children: [
                  FlyText(
                    'Outlined',
                  ).text('base').weight('semibold').color('gray800'),
                  FlyText('With border').text('sm').color('gray600'),
                ],
              ),
              FlyCard(
                variant: CardVariant.filled,
                size: CardSize.small,
                children: [
                  FlyText(
                    'Filled',
                  ).text('base').weight('semibold').color('gray800'),
                  FlyText('With background').text('sm').color('gray600'),
                ],
              ),
              FlyCard(
                variant: CardVariant.unstyled,
                size: CardSize.small,
                children: [
                  FlyText(
                    'Unstyled',
                  ).text('base').weight('semibold').color('gray800'),
                  FlyText('No styling').text('sm').color('gray600'),
                ],
              ),
            ],
          ).row().items('start').gap('s4').wrap(),
        ],
      ),

      // Sizes
      FlyCard(
        variant: CardVariant.filled,
        size: CardSize.medium,
        children: [
          FlyText('Sizes').text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyCard(
                variant: CardVariant.outlined,
                size: CardSize.small,
                children: [
                  FlyText(
                    'Small',
                  ).text('sm').weight('semibold').color('gray800'),
                  FlyText('Compact padding').text('xs').color('gray600'),
                ],
              ),
              FlyCard(
                variant: CardVariant.outlined,
                size: CardSize.medium,
                children: [
                  FlyText(
                    'Medium',
                  ).text('base').weight('semibold').color('gray800'),
                  FlyText('Standard padding').text('sm').color('gray600'),
                ],
              ),
              FlyCard(
                variant: CardVariant.outlined,
                size: CardSize.large,
                children: [
                  FlyText(
                    'Large',
                  ).text('lg').weight('semibold').color('gray800'),
                  FlyText('Spacious padding').text('sm').color('gray600'),
                ],
              ),
            ],
          ).row().items('start').gap('s4'),
        ],
      ),

      // Card Components
      FlyCard(
        variant: CardVariant.outlined,
        size: CardSize.medium,
        children: [
          FlyText(
            'Card Components',
          ).text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              // Header example
              FlyCard(
                variant: CardVariant.outlined,
                size: CardSize.small,
                children: [
                  FlyBox(
                    children: [
                      FlyAvatar(
                        size: AvatarSize.sm,
                        shape: AvatarShape.circular,
                        children: [FlyAvatarFallback(fallbackText: 'JD')],
                      ),
                      FlyBox(
                        children: [
                          FlyText(
                            'John Doe',
                          ).text('base').weight('semibold').color('gray800'),
                          FlyText(
                            'Software Engineer',
                          ).text('sm').color('gray600'),
                        ],
                      ).col().items('start').gap('s1').flex(1),
                    ],
                  ).row().items('center').gap('s3'),
                ],
              ),
              // Content example
              FlyCard(
                variant: CardVariant.outlined,
                size: CardSize.small,
                children: [
                  FlyBox(
                    children: [
                      FlyText(
                        'Content Area',
                      ).text('sm').weight('semibold').color('gray800'),
                      FlyText('Main card content').text('xs').color('gray600'),
                    ],
                  ).col().items('start').gap('s1'),
                ],
              ),
              // Footer example
              FlyCard(
                variant: CardVariant.outlined,
                size: CardSize.small,
                children: [
                  FlyBox(
                    children: [
                      FlyText('Footer').text('xs').color('gray500'),
                      FlyButton(
                        onTap: () {},
                        buttonColor: ButtonColor.secondary,
                        variant: ButtonVariant.solid,
                        size: ButtonSize.small,
                        child: FlyText('Action'),
                      ),
                    ],
                  ).row().justify('between'),
                ],
              ),
            ],
          ).col().items('start').gap('s4'),
        ],
      ),

      // Complex Composition Example
      FlyCard(
        variant: CardVariant.outlined,
        size: CardSize.medium,
        children: [
          FlyText(
            'Complex Composition',
          ).text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              // Full-featured card
              FlyCard(
                variant: CardVariant.outlined,
                size: CardSize.large,
                children: [
                  FlyCardImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1586717791821-3f44a563fa4c?w=400&h=200&fit=crop',
                    aspectRatio: 2.0,
                    overlay: FlyBox(
                      children: [
                        FlyText(
                          'Typography',
                        ).text('xl').weight('bold').color('white'),
                        FlyText(
                          'The art of arranging type',
                        ).text('sm').color('white'),
                      ],
                    ).col().items('start').justify('end').p('s4'),
                  ),
                  FlyBox(
                    children: [
                      FlyBox(
                        children: [
                          FlyText(
                            'Design Principles',
                          ).text('lg').weight('semibold').color('gray800'),
                          FlyText(
                            'Typography Guide',
                          ).text('base').color('gray600'),
                        ],
                      ).col().items('start').gap('s1').flex(1),
                      FlyButton(
                        onTap: () {},
                        buttonColor: ButtonColor.secondary,
                        variant: ButtonVariant.solid,
                        size: ButtonSize.small,
                        child: FlyIcon(LucideIcons.moreVertical).color('gray500'),
                      ),
                    ],
                  ).row().items('center').gap('s3').p('s4'),
                  FlyBox(
                    children: [
                      FlyText(
                        'Typography is the art and technique of arranging type to make written language legible, readable and appealing when displayed.',
                      ).text('sm').color('gray600'),
                    ],
                  ).p('s2'),
                  FlyBox(
                    children: [
                      FlyText('2 min read').text('xs').color('gray500'),
                      FlyButton(
                        onTap: () {},
                        buttonColor: ButtonColor.secondary,
                        variant: ButtonVariant.solid,
                        size: ButtonSize.small,
                        child: FlyText('Read More'),
                      ),
                    ],
                  ).p('s2').row().justify('between'),
                ],
              ).p(0),
            ],
          ).col().items('start').gap('s4'),
        ],
      ),
    ];
  }

  List<Widget> _buildAvatarExamples() {
    return [
      // Size examples
      FlyText('Avatar Examples').text('xl').weight('bold').color('gray800'),

      // Different sizes
      FlyCard(
        variant: CardVariant.outlined,
        size: CardSize.medium,
        children: [
          FlyText('Sizes').text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyAvatar(
                size: AvatarSize.xs,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'XS')],
              ),
              FlyAvatar(
                size: AvatarSize.sm,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'SM')],
              ),
              FlyAvatar(
                size: AvatarSize.md,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'MD')],
              ),
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'LG')],
              ),
              FlyAvatar(
                size: AvatarSize.xl,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'XL')],
              ),
            ],
          ).row().items('start').gap('s4'),
        ],
      ),

      // Different shapes
      FlyCard(
        variant: CardVariant.filled,
        size: CardSize.medium,
        children: [
          FlyText('Shapes').text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'C')],
              ),
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.rounded,
                children: [FlyAvatarFallback(fallbackText: 'R')],
              ),
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.square,
                children: [FlyAvatarFallback(fallbackText: 'S')],
              ),
            ],
          ).row().items('start').gap('s4'),
        ],
      ),

      // Fallback types
      FlyCard(
        variant: CardVariant.outlined,
        size: CardSize.medium,
        children: [
          FlyText(
            'Fallback Types',
          ).text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'JD')],
              ),
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackIcon: Icons.person)],
              ),
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [
                  FlyAvatarFallback(
                    child: FlyIcon(Icons.star).color('yellow500'),
                  ),
                ],
              ),
            ],
          ).row().items('start').gap('s4'),
        ],
      ),

      // Loading state
      FlyCard(
        variant: CardVariant.filled,
        size: CardSize.medium,
        children: [
          FlyText(
            'Loading State',
          ).text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                isLoading: true,
              ),
            ],
          ).row().items('start').gap('s4'),
        ],
      ),

      // Image examples (with fallback)
      FlyCard(
        variant: CardVariant.outlined,
        size: CardSize.medium,
        children: [
          FlyText(
            'Image with Fallback',
          ).text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [
                  FlyAvatarImage(
                    imageUrl:
                        'https://avatars.githubusercontent.com/u/124599?v=4', // GitHub avatar
                    child: FlyAvatarFallback(fallbackText: 'FB'),
                  ),
                ],
              ),
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [
                  FlyAvatarImage(
                    imageUrl:
                        'https://invalid-url.com/image.jpg', // This will fail
                    child: FlyAvatarFallback(fallbackText: 'FB'),
                  ),
                ],
              ),
            ],
          ).row().items('start').gap('s4'),
        ],
      ),
    ];
  }

  void _showAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Alert!'),
          content: const Text('This is a Cupertino alert dialog.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
