import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardGestureController extends GetxController {
  // Define reactive observables (using '.obs')
  final Rx<Offset> dragOffset = Offset.zero.obs;
  final RxBool isDragging = false.obs;

  void updateOffset(Offset delta) {
    dragOffset.value += delta;
  }

  void startDragging() {
    isDragging.value = true;
  }

  void stopDragging() {
    isDragging.value = false;
  }

  void reset() {
    dragOffset.value = Offset.zero;
    isDragging.value = false;
  }
}
