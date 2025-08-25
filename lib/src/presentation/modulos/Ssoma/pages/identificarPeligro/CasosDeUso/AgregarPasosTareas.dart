import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Database
import 'package:sirh_mob/src/data/datasource/local/db_sqlite/database_ssoma.dart';

// Modelo
import 'package:sirh_mob/src/domain/models/ssoma_models/Tarea.dart';

class TipoTareaOption {
  final int id;
  final String label;
  const TipoTareaOption(this.id, this.label);
}

class AgregarPasosTareas extends StatefulWidget {
  const AgregarPasosTareas({super.key});

  @override
  State<AgregarPasosTareas> createState() => _AgregarPasosTareasState();
}

class _AgregarPasosTareasState extends State<AgregarPasosTareas> {
  // 1.- Instancia a la DB Ssoma
  final db = DatabaseSsoma.instance;

  // 2.- Todos los puestos
  List<Tarea> _allTareas = [];
  bool _isLoading = true;
  bool _switchValue = false; // Estado inicial del switch

  final List<TipoTareaOption> _tipoTareas = const [
    TipoTareaOption(1, 'R'),
    TipoTareaOption(2, 'NR'),
    TipoTareaOption(3, 'E'),
  ];

  // 3.- Campos
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  int? _selectedTipoTareaId;

  final TextEditingController _pasosController = TextEditingController();
  final TextEditingController _frecuenciaController = TextEditingController();
  final List<TipoTareaOption> _frecuenciasTareas = const [
    TipoTareaOption(1, 'A veces'),
    TipoTareaOption(2, 'Con frecuencia'),
    TipoTareaOption(3, 'Siempre'),
    TipoTareaOption(4, 'Casi nunca'),
    TipoTareaOption(5, 'Usualmente'),
  ];
  int? _selectedTipoFrecuenciaId;

  String _stdController = "desactivado"; // Valor por defecto

  // 4.- Inicializar
  @override
  void initState() {
    super.initState();
    _nombreController.addListener(() {
      // Forzar a mayúsculas
      _nombreController.value = _nombreController.value.copyWith(
        text: _nombreController.text.toUpperCase(),
        selection: _nombreController.selection,
      );
    });

    _refreshPasosTarea();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _pasosController.dispose();
    _frecuenciaController.dispose();
    super.dispose();
  }

  // =============================
  // 5.- FUNCIONES PRINCIPALES
  // =============================
  // Obtener lista de pasos
  void _refreshPasosTarea() async {
    final data = await db.getPasosTarea();

    setState(() {
      _allTareas = data;
      _isLoading = false;
    });
  }

  // Insertar nueva tarea
  Future<void> _addPasosTarea() async {
    await db.insertPasosTarea(
      Tarea(
        nombre: _nombreController.text,
        // tipo: _tipoController.text,
        tipo: _tipoTareas[_selectedTipoTareaId!].label.toString(),
        pasos: _pasosController.text,
        // frecuencia: _frecuenciaController.text,
        frecuencia: _frecuenciasTareas[_selectedTipoFrecuenciaId!].label
            .toString(),
        std: _stdController,
        usuarioCreacion: 'admin',
        fechaCreacion: DateTime.now(),
        usuarioModificacion: '',
        fechaModificacion: DateTime.now(),
      ),
    );
    _refreshPasosTarea();
  }

  // Actualizar tarea existente
  Future<void> _updatePasosTarea(int id) async {
    await db.updatePasosTarea(
      Tarea(
        id: id,
        nombre: _nombreController.text,
        // tipo: _tipoController.text,
        tipo: _tipoTareas[_selectedTipoTareaId! - 1].label.toString(),
        pasos: _pasosController.text,
        // frecuencia: _frecuenciaController.text,
        frecuencia: _frecuenciasTareas[_selectedTipoFrecuenciaId! - 1].label
            .toString(),
        std: _stdController,
        usuarioCreacion: 'system', //  ficticio
        fechaCreacion: DateTime(2025, 01, 01), //  ficticio
        usuarioModificacion: 'admin_update', //  ficticio para update
        fechaModificacion: DateTime.now(),
      ),
    );
    _refreshPasosTarea();
  }

  // Eliminar tarea
  void _deletePasosTarea(int id) async {
    await db.deletePasosTarea(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Tarea Eliminado."),
      ),
    );
    _refreshPasosTarea();
  }

  // =============================
  // 6.- FUNCIONES AUXILIARES
  // =============================

  // Formatear Fecha: Si es string
  String formatFechaHoraString(String fecha) {
    try {
      // 1. Limpiar la cadena y eliminar la parte extra de microsegundos
      final cleanDate = fecha.split('-').first; // "2025-08-19 17:03:18"

      // 2. Parsear la fecha original
      final dateTime = DateTime.parse(cleanDate);

      // 3. Formatear al formato deseado
      final formato = DateFormat('dd/MM/yyyy HH:mm');
      return formato.format(dateTime);
    } catch (e) {
      return "Fecha inválida";
    }
  }

  // Formatear Fecha: Si es datetime
  String formatFechaHoraDate(DateTime fecha) {
    try {
      final formato = DateFormat('dd/MM/yyyy - HH:mm');
      return formato.format(fecha);
    } catch (e) {
      return "Fecha inválida";
    }
  }

  // Convertir a mayuscula
  String toUpperCaseText(String value) {
    return value.toUpperCase();
  }

  // =============================
  // 7.- MODAL PARA AGREGAR / EDITAR
  // =============================

  void showBottomSheet(int? id, bool isActive) async {
    if (id != null) {
      final existingData = _allTareas.firstWhere((e) => e.id == id);

      // Cargamos los valores
      _nombreController.text = existingData.nombre;
      _tipoController.text = existingData.tipo;
      _pasosController.text = existingData.pasos;
      _stdController = existingData.std;

      // 1 
      // Buscar el ID correcto segun el label guardado en la DB PARA FRECUENCIAS
      final frecuenciaEncontrado = _frecuenciasTareas.firstWhere(
        (e) => e.label == existingData.frecuencia,
        orElse: () =>
            _tipoTareas.first, // Evita crash si no encuentra coincidencia
      );
      // Guardamos el ID encontrado
      _selectedTipoFrecuenciaId = frecuenciaEncontrado.id;

      // 2
      // Buscar el ID correcto segun el label guardado en la DB PARA TIPO
      final tipoEncontrado = _tipoTareas.firstWhere(
        (e) => e.label == existingData.tipo,
        orElse: () =>
            _tipoTareas.first, // Evita crash si no encuentra coincidencia
      );

      // Guardamos el ID encontrado
      _selectedTipoTareaId = tipoEncontrado.id;
    } else {
      // Nuevo registro: limpiar selección
      _selectedTipoTareaId = null;
      _nombreController.clear();
      _pasosController.clear();
      _frecuenciaController.clear();
      _stdController = "";
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              top: 30,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 50,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    // Campo Nombre - Flexible para adaptarse
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: "Nombre",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Campo Meta - Select responsivo
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        value: _selectedTipoTareaId,
                        items: _tipoTareas
                            .map(
                              (tipo) => DropdownMenuItem<int>(
                                value: tipo.id,
                                child: Text(tipo.label),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setModalState(() {
                            _selectedTipoTareaId = val;
                          });
                          // opcional: sync con el controller si lo usas en otra parte
                          _tipoController.text = val?.toString() ?? '';
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Tipo",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _pasosController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Pasos de la Tarea",
                  ),
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    // Campo Meta - Select responsivo
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        value: _selectedTipoFrecuenciaId,
                        items: _frecuenciasTareas
                            .map(
                              (tipo) => DropdownMenuItem<int>(
                                value: tipo.id,
                                child: Text(tipo.label),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setModalState(() {
                            _selectedTipoFrecuenciaId = val;
                          });
                          // opcional: sync con el controller si lo usas en otra parte
                          _tipoController.text = val?.toString() ?? '';
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Frecuencia",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Campo Meta - Select responsivo
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("STD: "),
                          Switch(
                            //value: isActive,
                            value: _stdController == 'activado' ? true : false,
                            onChanged: (value) {
                              setModalState(() {
                                isActive = value;
                                _stdController = value
                                    ? "activado"
                                    : "desactivado";
                              });
                            },
                            activeColor: Colors
                                .white, // Color del círculo cuando está activado
                            activeTrackColor: Colors
                                .green, // Color de la pista cuando está activado
                            inactiveThumbColor: Colors
                                .white, // Color del círculo cuando está desactivado
                            inactiveTrackColor: Colors
                                .grey, // Color de la pista cuando está desactivado
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addPasosTarea();
                      }

                      if (id != null) {
                        await _updatePasosTarea(id);
                      }

                      _nombreController.text = "";
                      _tipoController.text = "";
                      _frecuenciaController.text = "";
                      _pasosController.text = "";
                      _stdController = "";

                      // Actualizar Lista de Puestos
                      _refreshPasosTarea();

                      // Ocultar Bottom sheet
                      Navigator.of(context).pop(true);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        id == null ? "Agregar Tarea" : "Actualizar Tarea",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEAF4),
      appBar: AppBar(title: const Text("Agregar Puestos")),
      body: _allTareas.isEmpty
          ? const Center(child: Text("No hay Tareas registradas"))
          : ListView.builder(
              itemCount: _allTareas.length,
              itemBuilder: (context, index) {
                final tarea = _allTareas[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // margin: EdgeInsets.all(15),
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título principal (nombre del puesto)
                        Text(
                          "${tarea.id}.- Puesto: ${tarea.nombre}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            // color: Color(0xFF1E88E5),
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Meta y STD en una fila
                        Row(
                          children: [
                            Icon(
                              Icons.apartment,
                              color: Colors.blueGrey.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Tipo: ${tarea.tipo}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.fact_check,
                              color: Colors.green.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "STD: ${tarea.std}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Pasos
                        Text(
                          tarea.pasos.isNotEmpty
                              ? "Pasos: ${tarea.pasos}"
                              : "Sin descripción",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          tarea.frecuencia.isNotEmpty
                              ? "Frecuencia: ${tarea.frecuencia}"
                              : "Sin info",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Información adicional de usuario y fecha
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Creado por: ${tarea.usuarioCreacion ?? "N/A"}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              tarea.fechaCreacion != null
                                  // ? " ${puesto.fechaCreacion}"
                                  ? formatFechaHoraDate(tarea.fechaCreacion!)
                                  : "",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        if (tarea.fechaModificacion != null ||
                            tarea.fechaModificacion != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Modificado por: ${tarea.usuarioModificacion ?? "N/A"}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                tarea.fechaModificacion != null
                                    ? formatFechaHoraDate(
                                        tarea.fechaModificacion!,
                                      )
                                    : "",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),

                        // Botones de acción
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Editar",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () =>
                                  showBottomSheet(tarea.id, _switchValue),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Eliminar",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => _deletePasosTarea(tarea.id!),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null, _switchValue),
        child: Icon(Icons.add),
      ),
    );
  }
}
