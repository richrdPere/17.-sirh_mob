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
  void didUpdateWidget(covariant CustomSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si la lista de items cambia, actualizamos la selección
    if (oldWidget.items != widget.items) {
      setState(() {
        // Si el valor actual sigue existiendo en la nueva lista, lo mantenemos.
        // Si no, lo limpiamos.
        if (widget.items.contains(selectedValue)) {
          selectedValue = selectedValue;
        } else {
          selectedValue = null;
        }
      });
    }
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
            isExpanded:
                true, //  Permite que el dropdown use todo el ancho disponible
            items: widget.items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 250, //  Ajustamos un ancho máximo
                      ),
                      child: Text(
                        widget.itemLabel(item),
                        style: TextStyle(fontSize: 14),
                        softWrap: true, //  Permite el salto de línea automático
                        overflow:
                            TextOverflow.fade, //  Evita cortar el texto
                      ),
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
