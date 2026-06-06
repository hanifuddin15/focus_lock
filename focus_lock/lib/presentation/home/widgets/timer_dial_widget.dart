import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:focus_lock/core/widgets/circular_timer.dart';
import 'package:focus_lock/presentation/home/home_controller.dart';

class TimerDialWidget extends GetView<HomeController> {
  const TimerDialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() => InteractiveTimerDial(
            currentMinutes: controller.selectedMinutes.value,
            onChanged: controller.setDuration,
            size: 260,
          )),
    );
  }
}
