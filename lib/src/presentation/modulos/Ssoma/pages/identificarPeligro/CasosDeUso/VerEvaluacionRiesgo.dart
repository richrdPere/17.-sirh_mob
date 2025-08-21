import 'package:flutter/material.dart';

// Database
import 'package:sirh_mob/src/data/datasource/local/db_sqlite/database_ssoma.dart';

// Modelo
import 'package:sirh_mob/src/domain/models/ssoma_models/EvaluacionRiesgo.dart';

class VerEvaluacionRiesgo extends StatefulWidget {
  const VerEvaluacionRiesgo({super.key});

  @override
  State<VerEvaluacionRiesgo> createState() => _VerEvaluacionRiesgoState();
}

class _VerEvaluacionRiesgoState extends State<VerEvaluacionRiesgo> {
  // 1.- Instancia a la DB Ssoma
  final db = DatabaseSsoma.instance;

  // 2.- Todas las evaluaciones de riesgo
  List<EvaluacionRiesgo> _allEvaluacionRiesgo = [];
  bool _isLoading = true;

  // 4.- Inicializar
  @override
  void initState() {
    super.initState();
    _refreshPeligros();
  }

  // 5.- Funciones
  // Obtener
  void _refreshPeligros() async {
    final data = await db.getEvaluacionRiesgo();

    setState(() {
      _allEvaluacionRiesgo = data;
      _isLoading = false;
    });
  }

  // Actualizar
  // Future<void> _updatePeligro(int id) async {
  //   await db.updatePeligro(
  //     Peligro(
  //       id: id,
  //       nombre: "",
  //       gravedad: '',
  //       ruta: '',
  //       std: '',
  //       fechaCreacion: DateTime.now().toString(),
  //       puestoTrabajoId: null,
  //       tareaId: null,
  //       fechaIdentificacion: null,
  //     ),
  //   );
  //   _refreshPeligros();
  // }

  // Eliminar
  void _deletePeligro(int id) async {
    await db.deletePeligro(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Peligro eliminado."),
      ),
    );
    _refreshPeligros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Evaluaciones de Riesgo")),
      body: _allEvaluacionRiesgo.isEmpty
          ? const Center(child: Text("No hay Evaluaciones registrados"))
          : ListView.builder(
              itemCount: _allEvaluacionRiesgo.length,
              itemBuilder: (context, index) {
                final p = _allEvaluacionRiesgo[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 4,
                  child: ListTile(
                    // leading: p.ruta!.isNotEmpty
                    //     ? Image.network(
                    //         p.ruta!,
                    //         width: 50,
                    //         height: 50,
                    //         fit: BoxFit.cover,
                    //       )
                    //     : const Icon(Icons.warning_amber, color: Colors.orange),
                    title: Text(
                      p.nombre!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Tipo: ${p.tipo}\nPers. Expuesta: ${p.personaExpuestaIden}\nPers. Existente: ${p.procedimientoExistenteIden}\nFecha: ${p.fechaCreacion}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Aquí podrías abrir un formulario para actualizar
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePeligro(p.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
