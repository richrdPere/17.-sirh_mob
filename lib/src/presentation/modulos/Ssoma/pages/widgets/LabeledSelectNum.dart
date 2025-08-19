import 'package:flutter/material.dart';

class LabeledSelectNum extends StatefulWidget {
  final String label;
  final Function(int?) onChanged;
  final int? initialValue;

  const LabeledSelectNum({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<LabeledSelectNum> createState() => _LabeledSelectNumState();
}

class _LabeledSelectNumState extends State<LabeledSelectNum> {
  int? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 5),
          DropdownButtonFormField<int>(
            value: selectedValue,
            items: List.generate(
              6,
              (i) => DropdownMenuItem(
                value: i + 1,
                child: Text((i + 1).toString()),
              ),
            ),
            onChanged: (val) {
              setState(() => selectedValue = val);
              widget.onChanged(val);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
