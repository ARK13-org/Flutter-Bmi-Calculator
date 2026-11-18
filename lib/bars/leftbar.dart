import 'package:flutter/material.dart';

class LeftContainer extends StatelessWidget {
  final double width;

  const LeftContainer({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: width,
          height: 25,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
