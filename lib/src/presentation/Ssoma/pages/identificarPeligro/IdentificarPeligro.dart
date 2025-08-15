import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';

/// ---------- MODELOS ----------
enum ControlType { eliminacion, sustitucion, ingenieria, administrativo, epp }

extension ControlTypeText on ControlType {
  String get label {
    switch (this) {
      case ControlType.eliminacion:
        return 'Eliminación';
      case ControlType.sustitucion:
        return 'Sustitución';
      case ControlType.ingenieria:
        return 'Ingeniería';
      case ControlType.administrativo:
        return 'Administrativo';
      case ControlType.epp:
        return 'EPP';
    }
  }
}

class ControlEntry {
  ControlType type;
  String description;

  ControlEntry({required this.type, required this.description});

  Map<String, dynamic> toJson() => {
    'type': type.label,
    'description': description,
  };
}

class HazardReport {
  String peligro;
  String descripcion;
  String area;
  String ubicacion;
  DateTime? fecha;
  List<String> riesgos;
  List<ControlEntry> controles;

  HazardReport({
    required this.peligro,
    required this.descripcion,
    required this.area,
    required this.ubicacion,
    required this.fecha,
    required this.riesgos,
    required this.controles,
  });

  Map<String, dynamic> toJson() => {
    'peligro': peligro,
    'descripcion': descripcion,
    'area': area,
    'ubicacion': ubicacion,
    'fecha': fecha?.toIso8601String(),
    'riesgos': riesgos,
    'controles': controles.map((e) => e.toJson()).toList(),
  };
}

/// ---------- PÁGINA PRINCIPAL ----------
class IdentificarPeligro extends StatefulWidget {
  const IdentificarPeligro({super.key});

  @override
  State<IdentificarPeligro> createState() => _IdentificarPeligroState();
}

class _IdentificarPeligroState extends State<IdentificarPeligro> {
  // Variable - Drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Variable - Formulario multipasos
  int _currentStep = -1;

  // Formularios por paso
  final _formDatosKey = GlobalKey<FormState>();
  final _formControlesKey = GlobalKey<FormState>();

  // Controllers (Paso 1)
  final _peligroCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  DateTime? _fecha;

  // Paso 2: Riesgos (chips multiselección + agregar propio)
  final List<String> _riesgoCatalogo = [
    'Caída a distinto nivel',
    'Golpeado por objeto',
    'Atrapamiento',
    'Exposición a ruido',
    'Exposición a sustancias químicas',
    'Corte / laceración',
    'Contacto eléctrico',
    'Posturas forzadas',
  ];
  final Set<String> _riesgosSeleccionados = {};
  final _riesgoCustomCtrl = TextEditingController();

  // Paso 3: Controles (lista dinámica)
  final List<ControlEntry> _controles = [
    ControlEntry(type: ControlType.epp, description: ''),
  ];

  @override
  void dispose() {
    _peligroCtrl.dispose();
    _descripcionCtrl.dispose();
    _areaCtrl.dispose();
    _ubicacionCtrl.dispose();
    _riesgoCustomCtrl.dispose();
    super.dispose();
  }

  /// ---------- ACCIONES ----------
  void _next() {
    if (_currentStep == 0) {
      // Validación Paso 1
      if (_formDatosKey.currentState?.validate() != true) return;
    } else if (_currentStep == 1) {
      // Validación Paso 2: al menos un riesgo
      if (_riesgosSeleccionados.isEmpty) {
        _showMsg('Selecciona al menos un riesgo.');
        return;
      }
    } else if (_currentStep == 2) {
      // Validación Paso 3: al menos un control válido
      // y que todas las descripciones no estén vacías
      if (_controles.isEmpty) {
        _showMsg('Agrega al menos un control.');
        return;
      }
      final vacios = _controles.any((c) => c.description.trim().isEmpty);
      if (vacios) {
        _showMsg('Completa la descripción de todos los controles.');
        return;
      }
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _fecha = picked);
    }
  }

  void _addCustomRisk() {
    final text = _riesgoCustomCtrl.text.trim();
    if (text.isEmpty) return;
    if (!_riesgoCatalogo.contains(text)) {
      _riesgoCatalogo.add(text);
    }
    _riesgosSeleccionados.add(text);
    _riesgoCustomCtrl.clear();
    setState(() {});
  }

  void _addControl() {
    setState(() {
      _controles.add(ControlEntry(type: ControlType.epp, description: ''));
    });
  }

  void _removeControl(int index) {
    setState(() {
      _controles.removeAt(index);
    });
  }

  void _submit() {
    final data = HazardReport(
      peligro: _peligroCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      ubicacion: _ubicacionCtrl.text.trim(),
      fecha: _fecha,
      riesgos: _riesgosSeleccionados.toList(),
      controles: _controles,
    );

    // TODO: aquí puedes llamar a tu backend.
    debugPrint('HAZARD REPORT JSON: ${data.toJson()}');

    _showMsg('Registro guardado correctamente.');
    Navigator.of(
      context,
    ).maybePop(); // o context.go('/ssoma') si usas go_router
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void toggleFirstStep() {
    setState(() {
      _currentStep = _currentStep == 0 ? -1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // clave para abrir el drawer
      endDrawer: Drawer(child: _drawerHeader(context)),
      backgroundColor: Colors.white,
      // appBar: AppBar(title: Text("Seguridad/Protección")),
      appBar: AppBar(
        title: const Text('Seguridad/Protección'),
        actions: const [SizedBox(width: 8)],
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep >= 0 ? _currentStep : 0,
        // onStepTapped: (step) {
        //   if (step == 0) {
        //     toggleFirstStep();
        //   } else {
        //     setState(() {
        //       _currentStep = step;
        //     });
        //   }
        // },
        onStepContinue: _next,
        onStepCancel: _back,
        steps: [_stepDatos(), _stepRiesgos(), _stepControles(), _stepResumen()],
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 3;
          return Row(
            children: [
              if (_currentStep > 0)
                OutlinedButton.icon(
                  onPressed: details.onStepCancel,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Anterior'),
                ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: details.onStepContinue,
                icon: Icon(isLast ? Icons.save : Icons.arrow_forward),
                label: Text(isLast ? 'Registrar' : 'Continuar'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ---------- UI DE PASOS ----------
  Step _stepDatos() {
    return Step(
      title: GestureDetector(
        onTap: toggleFirstStep,
        child: const Text('Identificar Peligro'),
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formDatosKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LabeledField(
              label: 'Peligro (obligatorio)',
              child: TextFormField(
                controller: _peligroCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ej.: Trabajo en altura',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Descripción',
              child: TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Describe el peligro y el contexto',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Área/Proceso',
                    child: TextFormField(
                      controller: _areaCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LabeledField(
                    label: 'Ubicación',
                    child: TextFormField(
                      controller: _ubicacionCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Fecha',
              child: InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _fecha == null
                        ? 'Selecciona fecha'
                        : '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Step _stepRiesgos() {
    return Step(
      // title: const Text('Riesgos'),
      title: const Text('Evaluación Riesgos'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Asocia uno o varios riesgos:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _riesgoCatalogo.map((r) {
              final selected = _riesgosSeleccionados.contains(r);
              return FilterChip(
                label: Text(r),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _riesgosSeleccionados.add(r);
                    } else {
                      _riesgosSeleccionados.remove(r);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _riesgoCustomCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Agregar riesgo personalizado',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addCustomRisk(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addCustomRisk,
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Step _stepControles() {
    return Step(
      // title: const Text('Controles'),
      title: const Text('Medidas de Control'),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formControlesKey,
        child: Column(
          children: [
            ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controles.length,
              itemBuilder: (context, index) {
                final c = _controles[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<ControlType>(
                              value: c.type,
                              decoration: const InputDecoration(
                                labelText: 'Tipo de control',
                                border: OutlineInputBorder(),
                              ),
                              items: ControlType.values.map((t) {
                                return DropdownMenuItem(
                                  value: t,
                                  child: Text(t.label),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() => c.type = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Eliminar',
                            onPressed: _controles.length > 1
                                ? () => _removeControl(index)
                                : null,
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: c.description,
                        onChanged: (val) => c.description = val,
                        decoration: const InputDecoration(
                          labelText: 'Descripción / medida',
                          hintText:
                              'Ej.: Línea de vida, barandas, procedimiento, EPP específico…',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _addControl,
                icon: const Icon(Icons.add),
                label: const Text('Agregar control'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Step _stepResumen() {
    return Step(
      title: const Text('Revisión'),
      isActive: _currentStep >= 3,
      state: _currentStep == 3 ? StepState.editing : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryCard(
            title: 'Datos del peligro',
            children: [
              _kv('Peligro', _peligroCtrl.text),
              _kv('Descripción', _descripcionCtrl.text),
              // Row(
              //   children: [
              //     Expanded(child: _kv('Área/Proceso', _areaCtrl.text)),
              //     const SizedBox(width: 12),
              //     Expanded(child: _kv('Ubicación', _ubicacionCtrl.text)),
              //   ],
              // ),
              _kv('Área/Proceso', _areaCtrl.text),
              _kv('Ubicación', _ubicacionCtrl.text),
              _kv(
                'Fecha',
                _fecha == null
                    ? 'Sin fecha'
                    : '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'Riesgos asociados',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _riesgosSeleccionados
                    .map((r) => Chip(label: Text(r)))
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'Controles',
            children: _controles.isEmpty
                ? [const Text('Sin controles')]
                : _controles
                      .map(
                        (c) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.shield_moon),
                          title: Text(c.description),
                          subtitle: Text(c.type.label),
                        ),
                      )
                      .toList(),
          ),
          const SizedBox(height: 8),
          const Text('Si todo es correcto, presiona "Registrar".'),
        ],
      ),
    );
  }

  // ===============================
  // Widgets
  // ===============================
  Widget _drawerHeader(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Color.fromRGBO(189, 155, 36, 1)),
          margin: EdgeInsets.only(bottom: 5.0),
          child: Text(
            'SSOMA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.person, color: Color.fromRGBO(5, 5, 5, 1)),
          title: Text("Perfil"),
          onTap: () {
            Navigator.pop(context);
            print("Ir a perfil");
          },
        ),
        ListTile(
          leading: Icon(Icons.work, color: Color.fromRGBO(5, 5, 5, 1)),
          title: Text("Otro Rol"),
          onTap: () {
            // Navigator.pop(context);
            context.go('/roles');
            print("Ir a configuración");
          },
        ),
        ListTile(
          leading: Icon(Icons.settings, color: Color.fromRGBO(5, 5, 5, 1)),
          title: Text("Configuración"),
          onTap: () {
            Navigator.pop(context);
            print("Ir a configuración");
          },
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app, color: Color.fromRGBO(5, 5, 5, 1)),
          title: Text("Cerrar sesión"),
          onTap: () {
            Navigator.pop(context);
            print("Cerrar sesión");
          },
        ),
      ],
    );
  }

  Widget _titulo() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            context.go("/muni");
          },
          child: Icon(Icons.arrow_back, color: Colors.black, size: 30),
        ),
        const SizedBox(width: 20),
        Text(
          "Seguridad/Protección",
          style: TextStyle(
            color: const Color.fromRGBO(75, 86, 117, 1),
            fontSize: 20, // Escalable
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _iconActions() {
    return Row(
      children: [
        Icon(Icons.mail, color: Color.fromRGBO(5, 5, 5, 1), size: 35),
        SizedBox(width: 19),
        GestureDetector(
          onTap: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
          child: Icon(Icons.menu, color: Colors.black, size: 43),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SummaryCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

Widget _kv(String k, String v) => Padding(
  padding: const EdgeInsets.only(bottom: 4),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 130,
        child: Text('$k:', style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      Expanded(child: Text(v.isEmpty ? '—' : v)),
    ],
  ),
);
