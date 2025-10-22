import 'package:flutter/material.dart';

class MethodSelector extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodChanged;

  const MethodSelector({
    Key? key,
    required this.selectedMethod,
    required this.onMethodChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'];

    final methodColors = {
      'GET': Colors.blue,
      'POST': Colors.green,
      'PUT': Colors.orange,
      'DELETE': Colors.red,
      'PATCH': Colors.purple,
      'HEAD': Colors.grey,
      'OPTIONS': Colors.teal,
    };

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(128),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: methodColors[selectedMethod] ?? Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  selectedMethod,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Icon(Icons.expand_more),
            ],
          ),
        ),
        itemBuilder: (context) => methods.map((method) {
          return PopupMenuItem(
            value: method,
            onTap: () => onMethodChanged(method),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: methodColors[method] ?? Colors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    method,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}