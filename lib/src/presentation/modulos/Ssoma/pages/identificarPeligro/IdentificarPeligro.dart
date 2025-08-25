import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Database Instance
import 'package:sirh_mob/src/data/datasource/local/db_sqlite/database_ssoma.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/MedidasControl.dart';

// Modelos
import 'package:sirh_mob/src/domain/models/ssoma_models/PuestoTrabajo.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/Tarea.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/identificarPeligro/CasosDeUso/AgregarControl.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/identificarPeligro/CasosDeUso/AgregarPasosTareas.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/identificarPeligro/CasosDeUso/AgregarPuestoTrabajo.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/identificarPeligro/CasosDeUso/VerPeligros.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/Control.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/EvaluacionRiesgo.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/Peligro.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/widgets/CustomIconButton.dart';

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

class RiesgoTipoOption {
  final int id;
  final String label;
  const RiesgoTipoOption(this.id, this.label);
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
  final _formMedidasControlesKey = GlobalKey<FormState>();

  // 3.- Controllers

  // ====================================================
  // (Step 1) - DATOS DE LA TAREA
  // ====================================================
  int? _idPuestoTrabajo;
  int? _idTarea;

  String _nombrePuestoTrabajoResumen = "";
  String _nombreTareaResumen = "";
  String _pasosTareaResumen = "";

  // ====================================================
  // (Step 2) - IDENTIFICAR PELIGRO
  // ====================================================
  final _nombrePeligroCtrl = TextEditingController();
  final _gravedadPeligroCtrl = TextEditingController();
  final _imagenPeligroCtrl = TextEditingController();
  String _stdPeligroCtrl = "activado";
  DateTime? _fecha;

  bool _switchValuePeligro = false;

  // ====================================================
  // (Step 3) - EVALUACIÓN RIESGOS
  // ====================================================
  int? _idPeligro;

  final _nombresRiesgosCustomCtrl = TextEditingController();
  final _tipoEvalRiesgo = TextEditingController();
  final _observacionesEvalRiesgo = TextEditingController();
  final _stdEvalRiesgo = TextEditingController();
  String _riesgosSeleccionadosString = "";

  final List<RiesgoTipoOption> _tipoRiesgos = const [
    RiesgoTipoOption(1, 'Riesgos Físicos'),
    RiesgoTipoOption(2, 'Riesgos Químicos'),
    RiesgoTipoOption(3, 'Riesgos Biológicos'),
    RiesgoTipoOption(4, 'Riesgos Ergonómicos'),
    RiesgoTipoOption(5, 'Riesgos Mecánicos'),
    RiesgoTipoOption(6, 'Riesgos Psicosociales'),
    RiesgoTipoOption(7, 'Riesgos Ambientales'),
    RiesgoTipoOption(8, 'Riesgos Eléctricos'),
  ];
  int? _selectedTipoRiesgoId;

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
  num _countProbabilidadEval = 0;

  int? _severidadEval;

  // Riesgos (chips multiselección + agregar propio)
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

  // ====================================================
  // (Step 4) - MEDIDAS DE CONTROL
  // ====================================================
  int? _idEvaluacionRiesgo;
  List<int> _idControlesSelected = [];
  final _responsableControlCtrl = TextEditingController();
  DateTime? _fechaImplementacionControlCtrl;
  final _eficaciaControlCtrl = TextEditingController();
  final _estadoControlCtrl = TextEditingController();
  final _rutaControlCtrl = TextEditingController();
  final _evidenciaControlCtrl = TextEditingController();
  String _evidencia = "";

  String _stdControlCtrl = "activado";
  bool _switchValueControl = false;

  // final usuarioCreacion
  // Fecha creacion
  // Usuario modificacion}
  // Fecha modificacion

  final List<TipoControlOption> _eficaciaControles = const [
    TipoControlOption(1, 'ALTA'),
    TipoControlOption(2, 'MEDIA'),
    TipoControlOption(3, 'BAJA'),
  ];
  int? _selectedEficaciaControlId;

  final List<TipoControlOption> _estadoControles = const [
    TipoControlOption(1, 'COMPLETADO'),
    TipoControlOption(2, 'EN PROCESO'),
  ];
  int? _selectedEstadoControlId;

  bool _mostrarProbabilidades = false;
  bool _otroCheckbox = false;

  // ====================================================================
  // ================ LISTAS PARA TAER DE SQLITE ========================
  // ====================================================================
  // Puestos, tareas , peligros
  PuestoTrabajo? _selectedPuesto;
  Tarea? _selectedTarea;
  Peligro? _selectedPeligro;
  EvaluacionRiesgo? _selectedEvaluacionRiesgo;

  // Listas (luego puedes traerlas desde SQLite)
  List<PuestoTrabajo> _allPuestos = [];
  List<Tarea> _allTareas = [];
  List<Peligro> _allPeligros = [];
  List<EvaluacionRiesgo> _allEvaluacionRiesgos = [];
  List<Control> _allControles = [];

  // Lista para registrar los riesgos
  List<int> _riesgosSelected = []; // Solo almacenamos los IDs seleccionados

  /// Carga los datos desde la base de datos SQLite
  /// 1.- Puestos Trabajo
  void _refreshPuestosTrabajo() async {
    try {
      final data = await db.getPuestosTrabajo();
      setState(() {
        _allPuestos = data;
      });
    } catch (e) {
      debugPrint("Error cargando puestos de trabajo: $e");
    }
  }

  /// 2.- Pasos tarea
  void _refreshPasosTarea() async {
    try {
      final tareasData = await db.getPasosTarea();
      setState(() {
        _allTareas = tareasData;
        // _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error cargando pasos de tarea: $e");
    }
  }

  /// 3.- Peligro
  void _refreshPeligro() async {
    try {
      final peligrosData = await db.getPeligros();
      setState(() {
        _allPeligros = peligrosData;
      });
    } catch (e) {
      debugPrint("Error cargando peligros: $e");
    }
  }

  /// 4.- Evaluacion de Riesgos
  void _refreshEvaluacionRiesgos() async {
    try {
      final evaluacionRiesgosData = await db.getEvaluacionRiesgo();
      setState(() {
        _allEvaluacionRiesgos = evaluacionRiesgosData;
      });
    } catch (e) {
      debugPrint("Error cargando evaluaciones de risgos: $e");
    }
  }

  /// 5.- Controles
  void _refreshControles() async {
    try {
      final controlesData = await db.getControles();
      setState(() {
        _allControles = controlesData;
      });
    } catch (e) {
      debugPrint("Error cargando controles: $e");
    }
  }

  // ====================================================================
  // ============== FUNCIONES INSERT, UPDATE ============================
  // ====================================================================
  /// 1.- FUNCIONES INSERT - PELIGRO
  Future<void> _insertarPeligro() async {
    if (_formPeligrosKey.currentState!.validate()) {
      final nuevoPeligro = Peligro(
        nombre: _nombrePeligroCtrl.text,
        gravedad: _gravedadPeligroCtrl.text,
        fechaCreacion: _fechaString,
        // fechaCreacion: _fecha,
        std: _stdPeligroCtrl,
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

  /// 2.- FUNCIONES INSERT y UPDATE - EVALUACION RIESGO
  Future<void> _insertarEvaluacionRiesgo() async {
    if (_formEvaluacionkey.currentState!.validate()) {
      final nuevaEvaluacion = EvaluacionRiesgo(
        // Datos
        peligroId: _idPeligro,
        nombre: _riesgosSeleccionadosString,
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
        probabilidadEval: _countProbabilidadEval.toInt(),
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

  Future<void> _actualizarEvaluacionRiesgo(int evaluacionId) async {
    try {
      // Creamos un mapa con los datos de control que se van a actualizar
      final Map<String, dynamic> datosControl = {
        'personaExpuestaEval': _personaExpuestaEval,
        'procedimientoExistenteEval': _procedimientoExistenteEval,
        'capacitacionEval': _capacitacionEval,
        'exposicionRiesgoEval': _exposicionRiesgoEval,
        'probabilidadEval': _probabilidadEval,
        'severidadEval': _severidadEval,
      };

      // Llamamos al método del servicio/database
      await db.updateEvaluacionRiesgoById(evaluacionId, datosControl);

      // Mostramos confirmación visual
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Controles actualizados correctamente")),
      );
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar controles: $e")),
      );
    }
  }

  /// 3.- FUNCIONES INSERT y UPDATE - MEDIDAS DE CONTROL
  Future<void> _insertarMedidaControl() async {
    if (_formEvaluacionkey.currentState!.validate()) {
      final nuevaMedidaControl = MedidaControl(
        // Datos
        riesgoId: _idEvaluacionRiesgo,
        controlId: 1,
        responsable: _responsableControlCtrl.text,
        fechaImplementacion: _fecha,
        eficacia: _eficaciaControlCtrl.text,
        // eficacia: _eficaciaControles[_selectedEficaciaControlId!].label.toString(),
        estado: _estadoControlCtrl.text,
        //estado: _estadoControles[_selectedEstadoControlId!].label.toString(),
        ruta: _rutaControlCtrl.text,
        evidencia: _evidenciaControlCtrl.text,
        std: _stdControlCtrl,

        // Datos de usuario
        usuarioCreacion: 'Admin',
      );

      await db.insertMedidasControl(nuevaMedidaControl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Medida de control registrado correctamente"),
        ),
      );
    }
  }

  Future<void> _actualizarMedidaControl(int evaluacionId) async {
    try {
      // Creamos un mapa con los datos de control que se van a actualizar
      final Map<String, dynamic> datosControl = {
        'personaExpuestaEval': _personaExpuestaEval,
        'procedimientoExistenteEval': _procedimientoExistenteEval,
        'capacitacionEval': _capacitacionEval,
        'exposicionRiesgoEval': _exposicionRiesgoEval,
        'probabilidadEval': _probabilidadEval,
        'severidadEval': _severidadEval,
      };

      // Llamamos al método del servicio/database
      await db.updateEvaluacionRiesgoById(evaluacionId, datosControl);

      // Mostramos confirmación visual
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Controles actualizados correctamente")),
      );
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar controles: $e")),
      );
    }
  }

  // ====================================================================
  // ================ FUNCIONES PRINCIPALES =============================
  // ====================================================================
  void _selectDate() async {
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
    final newRisk = _nombresRiesgosCustomCtrl.text.trim();
    if (newRisk.isNotEmpty && !_riesgoCatalogo.contains(newRisk)) {
      setState(() {
        _riesgoCatalogo.add(newRisk);
        _riesgosSeleccionados.add(newRisk);
        _riesgosSeleccionadosString = _riesgosSeleccionados.join(", ");
        _nombresRiesgosCustomCtrl.clear();
      });
    }
  }

  @override
  void dispose() {
    // Libera los recursos en memoria usados por los controladores
    // ============================
    // STEP 2: IDENTIFICAR PELIGRO
    // ============================
    _nombrePeligroCtrl.dispose();
    _gravedadPeligroCtrl.dispose();
    _imagenPeligroCtrl.dispose();

    // ============================
    // STEP 3: EVALUACIÓN RIESGOS
    // ============================
    _nombresRiesgosCustomCtrl.dispose();
    _tipoEvalRiesgo.dispose();
    _observacionesEvalRiesgo.dispose();
    _stdEvalRiesgo.dispose();

    // ============================
    // STEP 4: MEDIDAS DE CONTROL
    // ============================
    _responsableControlCtrl.dispose();
    _eficaciaControlCtrl.dispose();
    _estadoControlCtrl.dispose();
    _rutaControlCtrl.dispose();
    _evidenciaControlCtrl.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _refreshPuestosTrabajo();
    _refreshPasosTarea();
    _refreshPeligro();
    _refreshEvaluacionRiesgos();
    _refreshControles();
  }

  // ====================================================================
  // =================== ACCIONES DE STEP'S =============================
  // ====================================================================
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
        setState(() {
          _refreshPeligro();
        });
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
    }
    if (_currentStep == 3) {
      // Validación Paso 4: al menos un control válido
      // y que todas las descripciones no estén vacías
      if (_formMedidasControlesKey.currentState!.validate()) {
        await _insertarMedidaControl();
      }

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

  // void _addControl() {
  //   setState(() {
  //     _controles.add(ControlEntry(type: ControlType.epp, description: ''));
  //   });
  // }

  // void _removeControl(int index) {
  //   setState(() {
  //     _controles.removeAt(index);
  //   });
  // }

  void _submit() {
    final data = HazardReport(
      peligro: "",
      descripcion: "",
      area: "",
      ubicacion: "",
      fecha: _fecha,
      riesgos: _riesgosSeleccionados.toList(),
      controles: [],
      // controles: []
    );

    //   // TODO: aquí puedes llamar a tu backend.
    //   debugPrint('HAZARD REPORT JSON: ${data.toJson()}');

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
      // endDrawer: Drawer(child: _drawerHeader(context)),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Seguridad/Protección'),
        actions: const [SizedBox(width: 8)],
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep >= 0 ? _currentStep : 0,
        onStepContinue: _next,
        onStepCancel: _back,
        steps: [
          _stepDatosTarea(),
          _stepIdentificarPeligro(),
          _stepEvaluacionRiesgos(),
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

  // ====================================================================
  // ========================= UI DE STEP'S =============================
  // ====================================================================
  /// 1.- Datos Tarea
  Step _stepDatosTarea() {
    return Step(
      // title: GestureDetector(
      //   onTap: toggleFirstStep,
      //   child: const Text('Datos de la Tarea'),
      // ),
      title: Text(""),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formDatosKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos de la Tarea',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(33, 33, 33, 1),
              ),
            ),
            const SizedBox(height: 20),
            // Select Puestos
            CustomSelect<PuestoTrabajo>(
              label: 'Puestos de trabajo',
              items: _allPuestos,
              // initialValue: _allPuestos.isNotEmpty ? _allPuestos[0] : null,
              initialValue: _selectedPuesto,
              onChanged: (value) {
                setState(() => _selectedPuesto = value);
                _idPuestoTrabajo = value!.id;
                _nombrePuestoTrabajoResumen = value!.nombre;
                // print("Seleccionado: ${value?.nombre}");
              },
              onAdd: () async {
                // Navegamos a la pantalla para agregar tareas
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AgregarPuestoTrabajo(),
                  ),
                );

                setState(() {
                  _refreshPuestosTrabajo();
                });
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
                _nombreTareaResumen = value!.nombre;
                _pasosTareaResumen = value!.pasos;

                // print("Seleccionado: ${value?.nombre} - ${value?.pasos}");
              },
              onAdd: () async {
                // Navegamos a la pantalla para agregar tareas
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AgregarPasosTareas()),
                );

                setState(() {
                  _refreshPasosTarea();
                });
              },
              itemLabel: (tarea) =>
                  "${tarea.id}.- ${tarea.nombre}: ${tarea.pasos}",
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 2.- Indentificar Peligro
  Step _stepIdentificarPeligro() {
    return Step(
      // title: GestureDetector(
      //   onTap: toggleFirstStep,
      //   child: const Text('Identificar Peligro'),
      // ),
      title: Text(""),
      isActive: _currentStep >= 1,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formPeligrosKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Identificar Peligro',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(33, 33, 33, 1),
              ),
            ),
            const SizedBox(height: 20),
            // Campo de Peligro + Botón de Lista
            LabeledField(
              label: '1.- Peligro (obligatorio)',
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
            const SizedBox(height: 25),

            // Campo de Gravedad
            LabeledField(
              label: '2.- Gravedad',
              child: TextFormField(
                controller: _gravedadPeligroCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Describe la gravedad del peligro',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Fecha + Switch STD en la misma fila
            Row(
              children: [
                // Campo de Fecha responsivo
                Expanded(
                  flex: 3,
                  child: LabeledField(
                    label: '3.- Fecha y Activación',
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
                              : '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 25),

                // Switch STD alineado a la derecha
                Expanded(
                  flex: 2,
                  child: Row(
                    verticalDirection: VerticalDirection.down,
                    children: [
                      const Text(
                        "STD:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _stdPeligroCtrl == 'activado',
                        onChanged: (value) {
                          setState(() {
                            _switchValuePeligro = value;
                            _stdPeligroCtrl = value
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
            const SizedBox(height: 25),

            // PhotoPicker
            PhotoPicker(
              label: "4.- Foto del incidente",
              onImageSelected: (url) {
                print("URL de la imagen en S3: $url");
                _imagenPeligroCtrl.text = url ?? "";
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

  /// 3.- Evaluacion Peligro
  Step _stepEvaluacionRiesgos() {
    return Step(
      // title: const Text('Evaluación Riesgos'),
      title: Text(""),
      isActive: _currentStep >= 2,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formEvaluacionkey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evaluación de Riesgos',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(33, 33, 33, 1),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '1.- Peligro y Tipo de riesgos:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
              itemLabel: (peligro) =>
                  "${peligro.id}.- ${peligro.nombre}: ${peligro.gravedad}",
            ),

            const SizedBox(height: 15),
            CustomSelect<RiesgoTipoOption>(
              label: "Tipo Riesgo",
              items: _tipoRiesgos,
              itemLabel: (tipoRiesgo) =>
                  "${tipoRiesgo.id}.- ${tipoRiesgo.label}",
            ),

            const SizedBox(height: 35),
            const Text(
              '2.- Asocia uno o varios riesgos:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nombresRiesgosCustomCtrl,
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
            const SizedBox(height: 35),

            // Probabilidades
            const Text(
              '3.- PROBABILIDAD:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

  /// 4.- Medidas Controles
  Step _stepMedidasControles() {
    return Step(
      // title: const Text('Medidas de Control'),
      title: Text(""),
      isActive: _currentStep >= 3,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formMedidasControlesKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medidas de Control',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(33, 33, 33, 1),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '1.- Seleciona el riesgo respectivo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            // Select Peligro
            CustomSelect<EvaluacionRiesgo>(
              label: 'Riesgos detectados:',
              items: _allEvaluacionRiesgos,
              // initialValue: _allPuestos.isNotEmpty ? _allPuestos[0] : null,
              initialValue: _selectedEvaluacionRiesgo,
              onChanged: (value) {
                setState(() => _selectedEvaluacionRiesgo = value);
                _idEvaluacionRiesgo = value!.id;
              },
              itemLabel: (evaluacionRiesgo) =>
                  "${evaluacionRiesgo.id}.- ${evaluacionRiesgo.nombre}",
            ),

            const SizedBox(height: 15),

            Text(
              '2.- Agrega y Seleciona un control:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                // onPressed: _addControl,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AgregarControl(),
                    ),
                  );

                  // context.go("/ssoma/seguridad_proteccion/add_controles");
                  setState(() {
                    _refreshControles();
                  });
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
                final descripcion = r.descripcion;
                final selected = _riesgosSelected.contains(id);
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
                        _riesgosSelected.add(id);
                        _refreshControles();

                        _evidenciaControlCtrl.text = descripcion;
                        // _refreshPuestos();
                      } else {
                        _riesgosSelected.remove(id);
                        _refreshControles();
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
              '3.- Datos del responsable:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                // Primer TextField
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Nombres",
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
                // Expanded(
                //   child: TextField(
                //     decoration: const InputDecoration(
                //       labelText: "Eficacia",
                //       border: OutlineInputBorder(),
                //     ),
                //     onChanged: (val) {
                //       setState(() {
                //         // _severidadIden = val;
                //       });
                //     },
                //     keyboardType: TextInputType
                //         .number, // Por si quieres que sea solo números
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                // Campo de Fecha responsivo
                Expanded(
                  flex: 3,
                  child: CustomSelect<TipoControlOption>(
                    label: "Eficacia",
                    items: _eficaciaControles,
                    itemLabel: (tipoRiesgo) =>
                        "${tipoRiesgo.id}.- ${tipoRiesgo.label}",
                  ),
                ),
                const SizedBox(width: 25),

                // Switch STD alineado a la derecha
                Expanded(
                  flex: 3,
                  child: CustomSelect<TipoControlOption>(
                    label: "Estado",
                    items: _estadoControles,
                    itemLabel: (estadoControl) =>
                        "${estadoControl.id}.- ${estadoControl.label}",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                // Campo de Fecha responsivo
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _evidenciaControlCtrl,
                    maxLines: 3,
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
                const SizedBox(width: 25),

                // Switch STD alineado a la derecha
                Expanded(
                  flex: 2,
                  child: Row(
                    verticalDirection: VerticalDirection.down,
                    children: [
                      const Text(
                        "STD:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _stdControlCtrl == 'activado',
                        onChanged: (value) {
                          setState(() {
                            _switchValueControl = value;
                            _stdControlCtrl = value
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
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ====== Checkboxes ======
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _mostrarProbabilidades,
                      onChanged: (value) {
                        setState(() {
                          _mostrarProbabilidades = value ?? false;
                        });
                      },
                    ),
                    const Text(
                      "¿Desea actualizar las probabilidades?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Checkbox(
                    //   value: _otroCheckbox,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _otroCheckbox = value ?? false;
                    //     });
                    //   },
                    // ),
                    // const Text(
                    //   "Otra opción",
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ],
                ),

                const SizedBox(height: 10),

                // ====== Bloque condicional ======
                if (_mostrarProbabilidades) ...[
                  const Text(
                    'Actualice las Probabilidades:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // Primera fila
                  Row(
                    children: [
                      LabeledSelectNum(
                        label: "Índ. Personas Exp. (A)",
                        initialValue: _personaExpuestaIden, // valor por defecto
                        onChanged: (val) {
                          setState(() {
                            _personaExpuestaEval = val;
                            _countProbabilidadEval += val ?? 0;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      LabeledSelectNum(
                        label: "Índ. Procedimientos (B)",
                        initialValue: _procedimientoExistenteIden,
                        onChanged: (val) {
                          setState(() {
                            _procedimientoExistenteEval = val;
                            _countProbabilidadEval += val ?? 0;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Segunda fila
                  Row(
                    children: [
                      LabeledSelectNum(
                        label: "Índ. Capacitación (C)",
                        initialValue: _capacitacionIden,
                        onChanged: (val) {
                          setState(() {
                            _capacitacionEval = val;
                            _countProbabilidadEval += val ?? 0;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      LabeledSelectNum(
                        label: "Índ. Exposición al Riesgo (D)",
                        initialValue: _exposicionRiesgoIden,
                        onChanged: (val) {
                          setState(() {
                            _exposicionRiesgoEval = val;
                            _countProbabilidadEval += val ?? 0;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Índice severidad
                  Row(
                    children: [
                      LabeledSelectNum(
                        label: "ÍNDICE DE SEVERIDAD",
                        initialValue: _severidadIden,
                        onChanged: (val) {
                          setState(() {
                            _severidadEval = val;
                            _countFase = (val ?? 0) * _countProbabilidadEval;
                          });
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 15),
            PhotoPicker(label: "4.- Imagen/Evidencia"),
          ],
        ),
      ),
    );
  }

  /// 5.- Resumen
  Step _stepResumen() {
    return Step(
      // title: const Text('Revisión'),
      title: Text(""),
      isActive: _currentStep >= 3,
      state: _currentStep == 3 ? StepState.editing : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: GridView.count(
          //     crossAxisCount: 2,
          //     crossAxisSpacing: 16,
          //     mainAxisSpacing: 16,
          //     children: const [
          //       CustomIconButton(
          //         icon: Icons.warning,
          //         label: 'Registros de Peligros',
          //         route: '/peligros',
          //         color: Colors.redAccent,
          //       ),
          //       CustomIconButton(
          //         icon: Icons.shield,
          //         label: 'Medidas de Control',
          //         route: '/medidas',
          //         color: Colors.green,
          //       ),
          //       CustomIconButton(
          //         icon: Icons.assignment_turned_in,
          //         label: 'Control',
          //         route: '/control',
          //         color: Colors.orange,
          //       ),
          //       CustomIconButton(
          //         icon: Icons.analytics,
          //         label: 'Evaluación de Riesgo',
          //         route: '/evaluacion',
          //         color: Colors.blue,
          //       ),
          //     ],
          //   ),
          // ),
          SummaryCard(
            title: '1.- Datos del puesto de trabajo',
            children: [
              // Row(
              //   children: [
              //     Expanded(
              //       child: _kv(
              //         'Puesto de trabajo',
              //         _nombrePuestoTrabajoResumen,
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(child: _kv('Tarea:', _nombreTareaResumen)),
              //   ],
              // ),
              _kv('Puesto de trabajo', _nombrePuestoTrabajoResumen),
              _kv('Tarea', _nombreTareaResumen),

              _kv('Pasos', _pasosTareaResumen),
            ],
          ),
          SummaryCard(
            title: '2.- Datos del peligro',
            children: [
              _kv('Peligro', _nombrePeligroCtrl.text),
              _kv('Descripción', _gravedadPeligroCtrl.text),
              // Row(
              //   children: [
              //     Expanded(child: _kv('Área/Proceso', _areaCtrl.text)),
              //     const SizedBox(width: 12),
              //     Expanded(child: _kv('Ubicación', _ubicacionCtrl.text)),
              //   ],
              // ),
              // _kv('Área/Proceso', _areaCtrl.text),
              _kv('Estado', _stdPeligroCtrl),
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
            title: '3.- Evaluación de Riesgos asociados',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _riesgosSeleccionados
                    .map((r) => Chip(label: Text(r)))
                    .toList(),
              ),

              Row(
                children: [
                  Expanded(
                    child: _kv(
                      'Ind. Persona Expuesta',
                      _personaExpuestaIden.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _kv(
                      'Ind. Procedimiento Esistente',
                      _procedimientoExistenteIden.toString(),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: _kv(
                      'Ind. Capacitacion',
                      _capacitacionIden.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _kv(
                      'Ind. Exp. Riesgo',
                      _exposicionRiesgoIden.toString(),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: _kv(
                      'Ind. Probabilidad',
                      _countProbabilidadIden.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _kv('Ind. Severidad', _severidadIden.toString()),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(child: _kv('Ind. Fase', _countFase.toString())),
                  const SizedBox(width: 12),
                ],
              ),

              // _kv('Ind. Persona Expuesta', _personaExpuestaIden.toString()),
              // _kv(
              //   'Ind. Procedimiento Esistente',
              //   _procedimientoExistenteIden.toString(),
              // ),
              // _kv('Ind. Capacitacion', _capacitacionIden.toString()),
              // _kv('Ind. Exp. Riesgo', _exposicionRiesgoIden.toString()),
              // _kv('Ind. Probabilidad', _countProbabilidadIden.toString()),
              // _kv('Ind. Severidad', _severidadIden.toString()),
              // _kv('Ind. Fase', _countFase.toString()),
            ],
          ),
          const SizedBox(height: 12),
          SummaryCard(
            title: '4.- Medidas de Control',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _kv(
                      'Eval. Persona Expuesta',
                      _personaExpuestaEval.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _kv(
                      'Eval. Procedimiento Existente',
                      _procedimientoExistenteEval.toString(),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: _kv(
                      'Eval. Capacitacion',
                      _capacitacionEval.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _kv(
                      'Eval. Exp. Riesgo',
                      _exposicionRiesgoEval.toString(),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: _kv(
                      'Eval. Probabilidad',
                      _countProbabilidadEval.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _kv('Eval. Severidad', _severidadEval.toString()),
                  ),
                ],
              ),

              // _kv('Eval. Persona Expuesta', _personaExpuestaEval.toString()),
              // _kv(
              //   'Eval. Procedimiento Esistente',
              //   _procedimientoExistenteEval.toString(),
              // ),
              // _kv('Eval. Capacitacion', _capacitacionEval.toString()),
              // _kv('Eval. Exp. Riesgo', _exposicionRiesgoEval.toString()),
              // _kv('Eval. Probabilidad', _countProbabilidadEval.toString()),
              // _kv('Eval. Severidad', _severidadEval.toString()),
            ],
          ),
          //   SummaryCard(
          //     title: 'Controles',
          //     children: _controles.isEmpty
          //         ? [const Text('Sin controles')]
          //         : _controles
          //               .map(
          //                 (c) => ListTile(
          //                   dense: true,
          //                   contentPadding: EdgeInsets.zero,
          //                   leading: const Icon(Icons.shield_moon),
          //                   title: Text(c.description),
          //                   subtitle: Text(c.type.label),
          //                 ),
          //               )
          //               .toList(),
          // ),
          const SizedBox(height: 12),
          const Text('Si todo es correcto, presiona "Registrar".'),
          const SizedBox(height: 12),
        ],
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
