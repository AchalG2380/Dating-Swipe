import 'dart:math';
import 'package:flutter/material.dart';
import '../models/dummy_user.dart';
import 'package:get/get.dart';
import '../../core/app_color.dart';
import 'package:task/core/app_strings.dart';
import '../controllers/card_gesture_controller.dart';

class SwipeCard extends StatefulWidget {
  final DummyUser user;
  final Function(bool isAccepted) onSwipe;
  final bool isFrontCard;

  const SwipeCard({
    super.key,
    required this.user,
    required this.onSwipe,
    this.isFrontCard = false,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _swipeAnimation;
  late final CardGestureController gesture;

  // Offset _dragOffset = Offset.zero;
  // bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    gesture = Get.put(CardGestureController(), tag: widget.user.id.toString());
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    Get.delete<CardGestureController>(tag: widget.user.id.toString());
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isFrontCard) return;
    gesture.startDragging();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isFrontCard) return;
    gesture.updateOffset(details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isFrontCard) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.35;

    if (gesture.dragOffset.value.dx > threshold) {
      // Swipe Right (Accept)
      _animateSwipe(const Offset(600, 0), true);
    } else if (gesture.dragOffset.value.dx < -threshold) {
      // Swipe Left (Reject)
      _animateSwipe(const Offset(-600, 0), false);
    } else {
      // Snap Back
      gesture.isDragging.value = false;
      _animController.forward(from: 0).then((_) {
        gesture.dragOffset.value = Offset.zero;
      });
      _swipeAnimation =
          Tween<Offset>(
              begin: gesture.dragOffset.value,
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animController,
                curve: Curves.easeOutBack,
              ),
            )
            ..addListener(() {
              if (!gesture.isDragging.value) {
                gesture.dragOffset.value = _swipeAnimation.value;
              }
            });
    }
  }

  void _animateSwipe(Offset targetOffset, bool isAccepted) {
    gesture.isDragging.value = false;
    _swipeAnimation =
        Tween<Offset>(
            begin: gesture.dragOffset.value,
            end: targetOffset,
          ).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut),
          )
          ..addListener(() {
            gesture.dragOffset.value = _swipeAnimation.value;
          });

    _animController.forward(from: 0).then((_) {
      widget.onSwipe(isAccepted);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Obx(() {
        final offset = gesture.dragOffset.value;
        double angle = widget.isFrontCard
            ? (offset.dx / size.width) * (pi / 12)
            : 0.0;
        double likeOpacity = (widget.isFrontCard && offset.dx > 0)
            ? min(offset.dx / (size.width * 0.25), 1.0)
            : 0.0;
        double nopeOpacity = (widget.isFrontCard && offset.dx < 0)
            ? min(-offset.dx / (size.width * 0.25), 1.0)
            : 0.0;
        return Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: angle,
            child: _buildCardContent(likeOpacity, nopeOpacity),
          ),
        );
      }),
    );
  }

  Widget _buildCardContent(double likeOpacity, double nopeOpacity) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              widget.user.image,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: AppColor.surface,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                          : null,
                      color: AppColor.primary,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColor.surface,
                  child: const Center(
                    child: Icon(Icons.person, size: 80, color: Colors.grey),
                  ),
                );
              },
            ),

            // Top gradient overlay for better lighting
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    AppColor.transparent,
                    AppColor.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // User Info
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.user.firstName}, ${widget.user.age}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Gender tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.user.gender == 'female'
                              ? Colors.pink.withValues(alpha: 0.8)
                              : Colors.blue.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.user.gender.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColor.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.user.city,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            shadows: const [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stamp overlay (LIKE)
            if (likeOpacity > 0)
              Positioned(
                top: 40,
                left: 30,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Opacity(
                    opacity: likeOpacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.likeGreen, width: 4),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black26,
                      ),
                      child: const Text(
                        AppStrings.likeLabel,
                        style: TextStyle(
                          color: AppColor.likeGreen,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Stamp overlay (NOPE)
            if (nopeOpacity > 0)
              Positioned(
                top: 40,
                right: 30,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Opacity(
                    opacity: nopeOpacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.nopeRed, width: 4),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black26,
                      ),
                      child: const Text(
                        AppStrings.nopeLabel,
                        style: TextStyle(
                          color: AppColor.nopeRed,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
