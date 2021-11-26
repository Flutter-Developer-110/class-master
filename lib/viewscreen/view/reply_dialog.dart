import 'package:flutter/material.dart';

class ReplyDialog extends StatelessWidget {
  final VoidCallback onDelete, onEdit;

  const ReplyDialog({
    Key? key,
    required this.onDelete,
    required this.onEdit,
  }) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: Colors.blueGrey),
            label: const Text(
              'Delete',
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: Colors.blueGrey),
            label: const Text(
              'Edit',
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}
