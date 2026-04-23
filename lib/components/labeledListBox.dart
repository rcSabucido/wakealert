import 'package:flutter/material.dart';
import 'package:wakealert/components/fullListEditModal.dart';

class LabeledListBox extends StatelessWidget {
  final String label;
  final List<String> items;
  final void Function(List<String>) onChanged;

  const LabeledListBox({
    Key? key,
    required this.label,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: InkWell(
        onTap: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => FullListEditModal(items: items),
          );

          if (result != null) {
            onChanged(result);
          }
        },
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                items.join(", "),
                maxLines: 1,
                overflow: TextOverflow.ellipsis
              ),
            ]
          ),
        ),
      ),
    );
  }
}