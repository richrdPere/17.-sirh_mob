import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// Database Instance
import 'package:sirh_mob/src/data/datasource/local/db_sqlite/database_ssoma.dart';

// Modelos
import 'package:sirh_mob/src/domain/models/ssoma_models/PuestoTrabajo.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/Tarea.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/identificarPeligro/CasosDeUso/VerPeligros.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/Control.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/EvaluacionRiesgo.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/Peligro.dart';


// Widgets
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/widgets/CustomSelect.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/widgets/LabeledSelectNum.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/widgets/PhotoPicker.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/widgets/labeled_field.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/widgets/summary_card.dart';

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

  // 1.- Instancia a la DB Ssoma
  final db = DatabaseSsoma.instance;

  // 2.- Otras instancias
  // Variable - Formulario multipasos
  int _currentStep = 0;
  String? _fechaString;

  // Formularios por paso
  final _formDatosKey = GlobalKey<FormState>();
  final _formPeligrosKey = GlobalKey<FormState>();
  final _formEvaluacionkey = GlobalKey<FormState>();
  final _formControlesKey = GlobalKey<FormState>();

  // 3.- Controllers
  // (Step 1)
  int? _idPuestoTrabajo;
  int? _idTarea;

  // (Step 2)
  final _nombrePeligroCtrl = TextEditingController();
  final _gravedadCtrl = TextEditingController();
  final _imagenCtrl = TextEditingController();
  final _stdCtrl = TextEditingController();
  // final _fecha = TextEditingController();
  DateTime? _fecha;

  // (Step 3)
  int? _idPeligro;

  // final TextEditingController _nombreEvalRiesgoCtrl = TextEditingController();
  final _riesgoCustomCtrl = TextEditingController();
  final _tipoEvalRiesgo = TextEditingController();
  final _observacionesEvalRiesgo = TextEditingController();
  final _stdEvalRiesgo = TextEditingController();
  String _riesgosSeleccionadosString = "";

  // Riesgo
  int? _personaExpuestaIden;
  int? _procedimientoExistenteIden;
  int? _capacitacionIden;
  int? _exposicionRiesgoIden;

  int?
  _probabilidadIden; // _personaExpuestaIden + _procedimientoExistenteIden + _capacitacionIden + _exposicionRiesgoIden
  int? _severidadIden;

  num _countProbabilidadIden = 0;

  int? _fase; // _probabilidadIden * _severidadIden
  num _countFase = 0;

  // Control
  int? _personaExpuestaEval;
  int? _procedimientoExistenteEval;
  int? _capacitacionEval;
  int? _exposicionRiesgoEval;

  int?
  _probabilidadEval; // _personaExpuestaEval + _procedimientoExistenteEval + _capacitacionEval + _exposicionRiesgoEval
  int? _severidadEval;

  // Paso 2: Riesgos (chips multiselección + agregar propio)
  final List<String> _riesgoCatalogo = [
    'Caída a distinto nivel',
    'Atrapamiento',
    'Golpeado por objeto',
    'Exposición a ruido',
    'Exposición a sustancias químicas',
    'Corte / laceración',
    'Contacto eléctrico',
    'Posturas forzadas',
  ];
  final Set<String> _riesgosSeleccionados = {};

  // Paso 3: Controles (lista dinámica)
  final List<ControlEntry> _controles = [
    ControlEntry(type: ControlType.epp, description: ''),
  ];

  List<Control> _allControles = [];
  List<int> _riesgosSelec = []; // Solo almacenamos los IDs seleccionados

  @override
  void dispose() {
    _nombrePeligroCtrl.dispose();
    _gravedadCtrl.dispose();
    // _fechaCtrl.dispose();
    _imagenCtrl.dispose();
    _stdCtrl.dispose();
    //

    // STEP 3:
    _tipoEvalRiesgo.dispose();
    _riesgoCustomCtrl.dispose();
    // _nombreEvalRiesgoCtrl.dispose();
    super.dispose();
  }

  /// Carga los datos desde la base de datos SQLite
  void _cargarRiesgos() async {
    try {
      final data = await db.getControles();

      setState(() {
        _allControles = data;
      });
    } catch (e) {
      debugPrint("Error cargando riesgos: $e");
    }
  }

  // Puestos, tareas , peligros
  PuestoTrabajo? _selectedPuesto;
  dynamic _selectedTarea;
  Peligro? _selectedPeligro;

  // Listas (luego puedes traerlas desde SQLite)
  List<PuestoTrabajo> _allPuestos = [];
  List<Tarea> _allTareas = [];
  List<Peligro> _allPeligros = [];

  void _refreshPuestosTrabajo() async {
    final data = await db.getPuestosTrabajo();
    setState(() {
      _allPuestos = data;
    });
  }

  void _refreshPasosTarea() async {
    final tareasData = await db.getPasosTarea();
    setState(() {
      _allTareas = tareasData;
      // _isLoading = false;
      // PuestoTrabajo? _selectedPuesto;
      // dynamic _selectedTarea;
    });
  }

  void _refreshPeligro() async {
    final peligrosData = await db.getPeligros();
    setState(() {
      _allPeligros = peligrosData;
    });
  }

  void _refreshControles() async {
    final controlesData = await db.getControles();
    setState(() {
      _allControles = controlesData;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshPuestosTrabajo();
    _refreshPasosTarea();
    _refreshPeligro();
    _refreshControles();
    _cargarRiesgos();
  }

  /// FUNCIONES INSERT - PELIGRO
  Future<void> _insertarPeligro() async {
    if (_formPeligrosKey.currentState!.validate()) {
      final nuevoPeligro = Peligro(
        nombre: _nombrePeligroCtrl.text,
        gravedad: _gravedadCtrl.text,
        fechaCreacion: _fechaString,
        // fechaCreacion: _fecha,
        std: _stdCtrl.text,
        ruta: "",
        puestoTrabajoId: _idPuestoTrabajo,
        tareaId: _idTarea,
        fechaIdentificacion: null,
      );

      await db.insertPeligro(nuevoPeligro);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Peligro registrado correctamente")),
      );

      // Limpiar campos
      // _nombrePeligroCtrl.clear();
      // _gravedadCtrl.clear();
      // _stdCtrl.clear();
      // _imagenCtrl.clear();
      // setState(() {
      //   _fecha = null;
      // });
    }
  }

  /// FUNCIONES INSERT - EVALUACION RIESGO
  Future<void> _insertarEvaluacionRiesgo() async {
    if (_formEvaluacionkey.currentState!.validate()) {
      final nuevaEvaluacion = EvaluacionRiesgo(
        peligroId: _idPeligro,
        nombre: _riesgoCustomCtrl.text,
        tipo: _tipoEvalRiesgo.text,
        fechaEvaluacion: _fechaString,
        observaciones: _observacionesEvalRiesgo.text,
        std: _stdEvalRiesgo.text,
        usuarioCreacion: 'Admin',

        // Riesgo
        personaExpuestaIden: _personaExpuestaIden,
        procedimientoExistenteIden: _procedimientoExistenteIden,
        capacitacionIden: _capacitacionIden,
        exposicionRiesgoIden: _exposicionRiesgoIden,
        probabilidadIden: _countProbabilidadIden.toInt(),
        severidadIden: _severidadIden,
        fase: _countFase.toInt(),

        // Control
        personaExpuestaEval: _personaExpuestaEval,
        procedimientoExistenteEval: _procedimientoExistenteEval,
        capacitacionEval: _capacitacionEval,
        exposicionRiesgoEval: _exposicionRiesgoEval,
        probabilidadEval: _probabilidadEval,
        severidadEval: _severidadEval,
      );

      await db.insertEvaluacionRiesgo(nuevaEvaluacion);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Evaluación de Riesgo registrado correctamente"),
        ),
      );
    }
  }

  /// ---------- ACCIONES ----------
  void _next() async {
    if (_currentStep == 0) {
      // Validación Paso 1
      if (_formDatosKey.currentState?.validate() != true) return;

      // Validar que haya al menos un puesto seleccionado
      if (_selectedPuesto == null) {
        _showMsg('Selecciona un puesto de trabajo.');
        return;
      }

      // Validar que haya al menos una tarea seleccionada
      if (_selectedTarea == null) {
        _showMsg('Selecciona una tarea registrada.');
        return;
      }
    }

    if (_currentStep == 1) {
      // Validación Paso 2: al menos un riesgo

      if (_formPeligrosKey.currentState!.validate()) {
        // Guardamos en la base de datos
        await _insertarPeligro();
      }
    }

    if (_currentStep == 2) {
      // Validación Paso 3: al menos un control válido

      if (_riesgosSeleccionadosString == "") {
        _showMsg('Elige a al menos un riesgo.');
        return;
      }

      if (_formEvaluacionkey.currentState!.validate()) {
        await _insertarEvaluacionRiesgo();
      }
    } else if (_currentStep == 3) {
      // Validación Paso 4: al menos un control válido
      // y que todas las descripciones no estén vacías
      // if (_controles.isEmpty) {
      //   _showMsg('Agrega al menos un control.');
      //   return;
      // }
      // final vacios = _controles.any((c) => c.description.trim().isEmpty);
      // if (vacios) {
      //   _showMsg('Completa la descripción de todos los controles.');
      //   return;
      // }
    }

    if (_currentStep < 5) {
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
      setState(() {
        _fecha = picked;
        // Convertimos la fecha seleccionada a String en formato yyyy-MM-dd
        _fechaString = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _addCustomRisk() {
    final newRisk = _riesgoCustomCtrl.text.trim();
    if (newRisk.isNotEmpty && !_riesgoCatalogo.contains(newRisk)) {
      setState(() {
        _riesgoCatalogo.add(newRisk);
        _riesgosSeleccionados.add(newRisk);
        _riesgosSeleccionadosString = _riesgosSeleccionados.join(", ");
        _riesgoCustomCtrl.clear();
      });
    }
  }

  // void _addControl() {
  //   setState(() {
  //     _controles.add(ControlEntry(type: ControlType.epp, description: ''));
  //   });
  // }

  void _removeControl(int index) {
    setState(() {
      _controles.removeAt(index);
    });
  }

  void _submit() {
    final data = HazardReport(
      peligro: "",
      descripcion: "",
      area: "",
      ubicacion: "",
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
        steps: [
          _stepDatosTarea(),
          _stepIdentificarPeligro(),
          _stepEvaluarRiesgos(),
          _stepMedidasControles(),
          _stepResumen(),
        ],
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 4;
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

  Step _stepDatosTarea() {
    return Step(
      title: GestureDetector(
        onTap: toggleFirstStep,
        child: const Text('Datos de la Tarea'),
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formDatosKey,
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Select Puestos
            CustomSelect<PuestoTrabajo>(
              label: 'Puestos de trabajo',
              items: _allPuestos,
              // initialValue: _allPuestos.isNotEmpty ? _allPuestos[0] : null,
              initialValue: _selectedPuesto,
              onChanged: (value) {
                setState(() => _selectedPuesto = value);
                _idPuestoTrabajo = value!.id;
                // print("Seleccionado: ${value?.nombre}");
              },
              onAdd: () {
                // Aquí puedes abrir un diálogo para ingresar un nuevo valor
                context.go("/ssoma/seguridad_proteccion/add_puesto");

                setState(() {
                  _refreshPuestosTrabajo();
                });

                // print("Agregar nuevo elemento");
              },
              itemLabel: (puesto) => "${puesto.id}.- ${puesto.nombre}",
            ),
            const SizedBox(height: 20),
            // Select Tareas
            CustomSelect<Tarea>(
              label: 'Tareas registradas',
              items: _allTareas,
              // initialValue: _allTareas.isNotEmpty ? _allTareas[0] : null,
              initialValue: _selectedTarea,
              onChanged: (value) {
                setState(() => _selectedTarea = value);
                _idTarea = value!.id;

                // print("Seleccionado: ${value?.nombre} - ${value?.pasos}");
              },
              onAdd: () {
                // Aquí puedes abrir un diálogo para ingresar un nuevo valor
                // print("Agregar nuevo elemento");
                context.go("/ssoma/seguridad_proteccion/add_tareas");

                setState(() {
                  _refreshPasosTarea();
                });
              },
              itemLabel: (tarea) => "${tarea.id}.- ${tarea.pasos}",
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Step _stepIdentificarPeligro() {
    return Step(
      title: GestureDetector(
        onTap: toggleFirstStep,
        child: const Text('Identificar Peligro'),
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formPeligrosKey,
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            LabeledField(
              label: 'Peligro (obligatorio)',
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nombrePeligroCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Ej.: Trabajo en altura',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón de lista
                  Container(
                    height: 60,
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.list_alt,
                        color: Colors.blue,
                        size: 28,
                      ),
                      tooltip: 'Ver peligros',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VerPeligros(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            LabeledField(
              label: 'Gravedad',
              child: TextFormField(
                controller: _gravedadCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Describe la gravedad del peligro',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LabeledField(
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
                              ? 'Fecha'
                              // : _fecha!.toIso8601String(),
                              : '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LabeledField(
                    label: 'Estado/Std',
                    child: TextFormField(
                      controller: _stdCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PhotoPicker(
              label: "Foto del incidente",
              onImageSelected: (url) {
                print("URL de la imagen en S3: $url");
                _imagenCtrl.text = url ?? "";
                // if (file != null) {
                //   print("Imagen seleccionada: ${file.path}");
                // }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Step _stepEvaluarRiesgos() {
    return Step(
      title: const Text('Evaluación Riesgos'),
      isActive: _currentStep >= 2,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Form(
          key: _formEvaluacionkey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            const Text(
              'Peligro y Tipo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        
            const SizedBox(height: 15),
            // Select Peligro
            CustomSelect<Peligro>(
              label: 'Peligro y Tipo:',
              items: _allPeligros,
              // initialValue: _allPuestos.isNotEmpty ? _allPuestos[0] : null,
              initialValue: _selectedPeligro,
              onChanged: (value) {
                setState(() => _selectedPeligro = value);
                _idPeligro = value!.id;
                // print("Seleccionado: ${value?.nombre}");
              },
              itemLabel: (puesto) => "${puesto.id}.- ${puesto.nombre}",
            ),
        
            const SizedBox(height: 15),
            // Tipo de Riesgo
            TextField(
              controller: _tipoEvalRiesgo,
              decoration: const InputDecoration(
                labelText: "Tipo de riesgo",
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 15),
            const Text(
              'Asocia uno o varios riesgos:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _riesgoCustomCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Agregar riesgo nuevo',
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
            const SizedBox(height: 15),
            // Lista de Riesgos
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _riesgoCatalogo.map((r) {
                final selected = _riesgosSeleccionados.contains(r);
                return FilterChip(
                  //label: Text(r),
                  label: SizedBox(
                    //width: 100, //  Controla el ancho máximo del chip
                    // height: 50,
                    child: Text(
                      r,
                      style: const TextStyle(fontSize: 12), //  Texto más pequeño
                      // softWrap: false, //  Permite salto de línea
                      // overflow: TextOverflow.visible,
                    ),
                  ),
                  selected: selected,
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, //  Reduce altura
                  padding: const EdgeInsets.all(6), //  Chip más compacto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _riesgosSeleccionados.add(r);
                      } else {
                        _riesgosSeleccionados.remove(r);
                      }
                      // Aquí actualizamos la variable en cada cambio
                      _riesgosSeleccionadosString = _riesgosSeleccionados.join(
                        ", ",
                      );
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
        
            // Probabilidades
            const Text(
              'PROBABILIDAD:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                LabeledSelectNum(
                  label: "Índ. Personas Exp. (A)",
                  onChanged: (val) {
                    // debugPrint("A -> $val");
                    setState(() {
                      _personaExpuestaIden = val;
                      _countProbabilidadIden += val!;
                    });
                  },
                ),
                const SizedBox(width: 10),
                LabeledSelectNum(
                  label: "Índ. Procedimientos (B)",
                  onChanged: (val) {
                    // debugPrint("B -> $val");
                    setState(() {
                      _procedimientoExistenteIden = val;
                      _countProbabilidadIden += val!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                LabeledSelectNum(
                  label: "Índ. Capacitación (C)",
                  onChanged: (val) {
                    // debugPrint("C -> $val");
                    setState(() {
                      _capacitacionIden = val;
                      _countProbabilidadIden += val!;
                    });
                  },
                ),
                const SizedBox(width: 10),
                LabeledSelectNum(
                  label: "Índ. Exposición al Riesgo (D)",
                  onChanged: (val) {
                    // debugPrint("D -> $val");
                    setState(() {
                      _exposicionRiesgoIden = val;
                      _countProbabilidadIden += val!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                LabeledSelectNum(
                  label: "ÍNDICE DE SEVERIDAD",
                  onChanged: (val) {
                    setState(() {
                      _severidadIden = val;
                      _countFase = val! * _countProbabilidadIden;
                    });
                  },
                ),
                const Spacer(), // para alinear solo uno en esta fila
              ],
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Step _stepMedidasControles() {
    return Step(
      // title: const Text('Controles'),
      title: const Text('Medidas de Control'),
      isActive: _currentStep >= 3,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formControlesKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agrega y Seleciona uno o varios controles:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                // onPressed: _addControl,
                onPressed: () {
                  context.go("/ssoma/seguridad_proteccion/add_controles");
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar control'),
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _allControles.map((r) {
                final id = r.id as int;
                final nombre = r.nombre;
                final selected = _riesgosSelec.contains(id);
                return FilterChip(
                  label: SizedBox(
                    child: Text(
                      "$id - $nombre", // Mostramos el id y el nombre
                      style: const TextStyle(
                        fontSize: 12,
                      ), //  Texto más pequeño
                      // softWrap: false, //  Permite salto de línea
                      // overflow: TextOverflow.visible,
                    ),
                  ),
                  selected: selected,
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, //  Reduce altura
                  padding: const EdgeInsets.all(6), //  Chip más compacto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _riesgosSelec.add(id);
                        _cargarRiesgos();
                        // _refreshPuestos();
                      } else {
                        _riesgosSelec.remove(id);
                        _cargarRiesgos();
                        // _refreshPuestos();
                      }
                    });
                    // Aquí obtenemos el arreglo final de IDs seleccionados
                    // debugPrint("IDs seleccionados: $_riesgosSeleccionados");
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
            Text(
              'Datos del responsable:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                // Primer TextField
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        // _capacitacionIden = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),

                // Segundo TextField
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Eficacia",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        // _severidadIden = val;
                      });
                    },
                    keyboardType: TextInputType
                        .number, // Por si quieres que sea solo números
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Evidencia",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        // _capacitacionIden = val;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Estado/Sts",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        // _capacitacionIden = val;
                      });
                    },
                  ),
                ),
              ],
            ),
            // ListView.separated(
            //   separatorBuilder: (_, __) => const SizedBox(height: 12),
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   itemCount: _controles.length,
            //   itemBuilder: (context, index) {
            //     final c = _controles[index];
            //     return Container(
            //       padding: const EdgeInsets.all(12),
            //       decoration: BoxDecoration(
            //         color: Colors.grey.shade100,
            //         borderRadius: BorderRadius.circular(12),
            //         border: Border.all(color: Colors.grey.shade300),
            //       ),
            //       child: Column(
            //         children: [
            //           Row(
            //             children: [
            //               Expanded(
            //                 child: DropdownButtonFormField<ControlType>(
            //                   value: c.type,
            //                   decoration: const InputDecoration(
            //                     labelText: 'Tipo de control',
            //                     border: OutlineInputBorder(),
            //                   ),
            //                   items: ControlType.values.map((t) {
            //                     return DropdownMenuItem(
            //                       value: t,
            //                       child: Text(t.label),
            //                     );
            //                   }).toList(),
            //                   onChanged: (val) {
            //                     if (val == null) return;
            //                     setState(() => c.type = val);
            //                   },
            //                 ),
            //               ),
            //               const SizedBox(width: 8),
            //               IconButton(
            //                 tooltip: 'Eliminar',
            //                 onPressed: _controles.length > 1
            //                     ? () => _removeControl(index)
            //                     : null,
            //                 icon: const Icon(Icons.delete_outline),
            //               ),
            //             ],
            //           ),
            //           const SizedBox(height: 8),
            //           TextFormField(
            //             initialValue: c.description,
            //             onChanged: (val) => c.description = val,
            //             decoration: const InputDecoration(
            //               labelText: 'Descripción / medida',
            //               hintText:
            //                   'Ej.: Línea de vida, barandas, procedimiento, EPP específico…',
            //               border: OutlineInputBorder(),
            //             ),
            //             validator: (v) => (v == null || v.trim().isEmpty)
            //                 ? 'Requerido'
            //                 : null,
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            // ),
            const SizedBox(height: 12),

            PhotoPicker(label: "Imagen/Evidencia"),
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
          SummaryCard(
            title: 'Datos del peligro',
            children: [
              _kv('Peligro', _nombrePeligroCtrl.text),
              _kv('Descripción', _gravedadCtrl.text),
              // Row(
              //   children: [
              //     Expanded(child: _kv('Área/Proceso', _areaCtrl.text)),
              //     const SizedBox(width: 12),
              //     Expanded(child: _kv('Ubicación', _ubicacionCtrl.text)),
              //   ],
              // ),
              // _kv('Área/Proceso', _areaCtrl.text),
              _kv('Estado', _stdCtrl.text),
              _kv(
                'Fecha',
                _fecha == null
                    ? 'Sin fecha'
                    : '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          SummaryCard(
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
          SummaryCard(
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
