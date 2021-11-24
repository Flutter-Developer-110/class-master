
import 'package:flutter/material.dart';

class MyCommentDialog extends StatelessWidget {
  final VoidCallback onDelete, onEdit;

  const MyCommentDialog({
    Key? key ,
    required this.onDelete,
    required this.onEdit,
  }):super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text(
              'Delete',
              style: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              'Edit',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
