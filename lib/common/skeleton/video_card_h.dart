import 'dart:math' as math;

import 'package:pilipala/common/constants.dart';
import 'package:flutter/material.dart';
import 'skeleton.dart';

class VideoCardHSkeleton extends StatelessWidget {
  const VideoCardHSkeleton({super.key, this.thumbnailWidth});

  final double? thumbnailWidth;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: StyleString.safeSpace,
          vertical: thumbnailWidth == null ? 7 : 8,
        ),
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            final double width = thumbnailWidth
                    ?.clamp(0.0, boxConstraints.maxWidth * 0.4)
                    .toDouble() ??
                (boxConstraints.maxWidth - StyleString.cardSpace * 6) / 2;
            return SizedBox(
              height: thumbnailWidth == null
                  ? width / StyleString.aspectRatio
                  : math.max(width / StyleString.aspectRatio,
                      MediaQuery.textScalerOf(context).scale(112)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: thumbnailWidth == null ? null : width,
                    child: AspectRatio(
                      aspectRatio: StyleString.aspectRatio,
                      child: LayoutBuilder(
                        builder: (context, boxConstraints) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              borderRadius: BorderRadius.circular(
                                  StyleString.imgRadius.x),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // VideoContent(videoItem: videoItem)
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          width: 200,
                          height: 11,
                          margin: const EdgeInsets.only(bottom: 5),
                        ),
                        Container(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          width: 150,
                          height: 13,
                        ),
                        const Spacer(),
                        Container(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          width: 100,
                          height: 13,
                          margin: const EdgeInsets.only(bottom: 5),
                        ),
                        Row(
                          children: [
                            Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              width: 40,
                              height: 13,
                              margin: const EdgeInsets.only(right: 8),
                            ),
                            Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              width: 40,
                              height: 13,
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
