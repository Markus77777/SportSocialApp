import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onTab;
  final String text;
  const MyButton({
    super.key,
    required this.onTab,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTab,
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              decoration: BoxDecoration(
                 color: Colors.white, 
                 border: Border.all(color: const Color.fromARGB(255, 68, 67, 67), width: 1.5), 
                 borderRadius: BorderRadius.zero, ),
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Colors.black,
                ),
              ),
            )
          )
        );
  }
}
