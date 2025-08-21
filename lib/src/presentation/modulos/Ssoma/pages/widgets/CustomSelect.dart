import 'package:flutter/material.dart';

/// Widget reutilizable para un Select
class CustomSelect<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final String Function(T) itemLabel; // cómo mostrar el texto
  final void Function(T?)? onChanged;
  final T? initialValue;
  final VoidCallback? onAdd; // Acción cuando se presiona el botón +

  const CustomSelect({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.initialValue,
    this.onAdd,
  });

  @override
  State<CustomSelect<T>> createState() => _CustomSelectState<T>();
}

class _CustomSelectState<T> extends State<CustomSelect<T>> {
  T? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // El Dropdown ocupa el espacio disponible
        Expanded(
          child: DropdownButtonFormField<T>(
            decoration: InputDecoration(
              labelText: widget.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
            ),
            value: selectedValue,
            items: widget.items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      widget.itemLabel(item),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        // Solo mostramos el botón si onAdd no es null
        if (widget.onAdd != null)
          IconButton(
            onPressed: widget.onAdd,
            icon: const Icon(Icons.add_circle, color: Colors.blue, size: 35),
            tooltip: "Agregar nuevo",
          ),
      ],
    );
  }
}
