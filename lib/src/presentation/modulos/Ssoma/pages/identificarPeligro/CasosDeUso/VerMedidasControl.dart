import 'package:flutter/material.dart';

// Database
import 'package:sirh_mob/src/data/datasource/local/db_sqlite/database_ssoma.dart';

// Modelo
import 'package:sirh_mob/src/domain/models/ssoma_models/MedidasControl.dart';

class VerMedidasControl extends StatefulWidget {
  const VerMedidasControl({super.key});

  @override
  State<VerMedidasControl> createState() => _VerMedidasControlState();
}

class _VerMedidasControlState extends State<VerMedidasControl> {
  // 1.- Instancia a la DB Ssoma
  final db = DatabaseSsoma.instance;

  // 2.- Todas las evaluaciones de riesgo
  List<MedidaControl> _allMedidaControl = [];
  bool _isLoading = true;

  // 4.- Inicializar
  @override
  void initState() {
    super.initState();
    _refreshMedidasControl();
  }

  // 5.- Funciones
  // Obtener
  void _refreshMedidasControl() async {
    final data = await db.getMedidasControl();

    setState(() {
      _allMedidaControl = data;
      _isLoading = false;
    });
  }

  // Eliminar
  void _deleteMedidasControl(int id) async {
    await db
      ..deleteMedidaControl(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Medida de Control eliminado."),
      ),
    );
    _refreshMedidasControl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medidas de Control")),
      body: _allMedidaControl.isEmpty
          ? const Center(child: Text("No hay Evaluaciones registrados"))
          : ListView.builder(
              itemCount: _allMedidaControl.length,
              itemBuilder: (context, index) {
                final p = _allMedidaControl[index];
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
                      "${p.id}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "IdControl: ${p.controlId.toString()}\nResponsable: ${p.responsable}\nFecha Implementacion: ${p.fechaImplementacion}\nEficacia: ${p.eficacia}\nEvidencia: ${p.evidencia} \nFecha Creacion: ${p.fechaCreacion}",
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
                          onPressed: () => _deleteMedidasControl(p.id!),
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
