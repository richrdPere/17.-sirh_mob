import 'package:sirh_mob/src/domain/models/ssoma_models/Control.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/EvaluacionRiesgo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Database Script Somma
import 'package:sirh_mob/src/data/datasource/local/db_sqlite/DatabaseScriptsSomma.dart';

// Modelos
import 'package:sirh_mob/src/domain/models/ssoma_models/Peligro.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/Tarea.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/PuestoTrabajo.dart';
// import 'package:sirh_mob/src/domain/models/ssoma_models/Control.dart';
// import 'package:sirh_mob/src/domain/models/ssoma_models/EvaluacionRiesgo.dart';
// import 'package:sirh_mob/src/domain/models/ssoma_models/MedidasControl.dart';

class DatabaseSsoma {
  static final DatabaseSsoma instance = DatabaseSsoma._init();
  static Database? _database;

  DatabaseSsoma._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ssoma.db');
    return _database!;
  }

  Future? get db => null;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute(DatabaseScriptsSsoma.createAreaMetaTable);
    await db.execute(DatabaseScriptsSsoma.createPeligroTable);
    await db.execute(DatabaseScriptsSsoma.createRiesgoTable);
    await db.execute(DatabaseScriptsSsoma.createControlTable);
    await db.execute(DatabaseScriptsSsoma.createPuestoTrabajoTable);
    await db.execute(DatabaseScriptsSsoma.createTareaTable);
    await db.execute(DatabaseScriptsSsoma.createEvaluacionRiesgoTable);
    await db.execute(DatabaseScriptsSsoma.createMedidaControlTable);
  }

  // ==============================================================
  // ============= MÉTODOS CRUD GENÉRICOS =========================
  // ==============================================================
  // Insertar
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final dbClient = await database;
    return await dbClient.insert(
      table,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Actualizar
  Future<int> update(
    String table,
    Map<String, dynamic> row,
    String where,
    List whereArgs,
  ) async {
    final dbClient = await database;
    return await dbClient.update(
      table,
      row,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // Eliminar
  Future<int> delete(String table, String where, List whereArgs) async {
    final dbClient = await database;
    return await dbClient.delete(table, where: where, whereArgs: whereArgs);
  }

  // Obtener todos los registros
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final dbClient = await database;
    return await dbClient.query(table);
  }

  // Obtener registro por ID
  Future<Map<String, dynamic>?> queryById(
    String table,
    String columnId,
    int id,
  ) async {
    final dbClient = await database;
    final res = await dbClient.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // ==============================================================
  // ============== FUNCIONES ESPECÍFICAS =========================
  // ==============================================================

  // ===========================================
  // 1.- PELIGRO
  // ===========================================
  Future<int> insertPeligro(Peligro peligro) async =>
      await insert('ss_peligro', peligro.toMap());

  Future<List<Peligro>> getPeligros() async {
    final maps = await queryAll('ss_peligro');
    return maps.map((m) => Peligro.fromMap(m)).toList();
  }

  Future<Peligro?> getPeligroById(int id) async {
    final map = await queryById('ss_peligro', 'pel_id', id);
    return map != null ? Peligro.fromMap(map) : null;
  }

  Future<int> updatePeligro(Peligro peligro) async =>
      await update('ss_peligro', peligro.toMap(), 'pel_id = ?', [peligro.id]);

  Future<int> deletePeligro(int id) async =>
      await delete('ss_peligro', 'pel_id = ?', [id]);

  // ===========================================
  // 2.- TRABAJO
  // ===========================================
  Future<int> insertPuestoTrabajo(PuestoTrabajo puesto) async =>
      await insert('ss_puesto_trabajo', puesto.toMap());

  Future<List<PuestoTrabajo>> getPuestosTrabajo() async {
    final maps = await queryAll('ss_puesto_trabajo');
    return maps.map((m) => PuestoTrabajo.fromMap(m)).toList();
  }

  Future<PuestoTrabajo?> getPuestoById(int id) async {
    final map = await queryById('ss_puesto_trabajo', 'ptr_id', id);
    return map != null ? PuestoTrabajo.fromMap(map) : null;
  }

  Future<int> updatePuestoTrabajo(PuestoTrabajo puesto) async => await update(
    'ss_puesto_trabajo',
    puesto.toMap(),
    'ptr_id = ?',
    [puesto.id],
  );

  Future<int> deletePuestoTrabajo(int id) async =>
      await delete('ss_puesto_trabajo', 'ptr_id = ?', [id]);

  // ===========================================
  // 3.- PASOS - TAREAS
  // ===========================================
  Future<int> insertPasosTarea(Tarea tarea) async =>
      await insert('ss_tarea', tarea.toMap());

  Future<List<Tarea>> getPasosTarea() async {
    final maps = await queryAll('ss_tarea');
    return maps.map((m) => Tarea.fromMap(m)).toList();
  }

  Future<Tarea?> getPasosTareaById(int id) async {
    final map = await queryById('ss_tarea', 'tar_id', id);
    return map != null ? Tarea.fromMap(map) : null;
  }

  Future<int> updatePasosTarea(Tarea puesto) async =>
      await update('ss_tarea', puesto.toMap(), 'tar_id = ?', [puesto.id]);

  Future<int> deletePasosTarea(int id) async =>
      await delete('ss_tarea', 'tar_id = ?', [id]);

  // ===========================================
  // 4. CONTROLES
  // ===========================================
  Future<int> insertControl(Control control) async =>
      await insert('ss_control', control.toMap());

  Future<List<Control>> getControles() async {
    final maps = await queryAll('ss_control');
    return maps.map((m) => Control.fromMap(m)).toList();
  }

  Future<Control?> getControlById(int id) async {
    final map = await queryById('ss_control', 'con_id', id);
    return map != null ? Control.fromMap(map) : null;
  }

  Future<int> updateControl(Control control) async =>
      await update('ss_control', control.toMap(), 'con_id = ?', [control.id]);

  Future<int> deleteControl(int id) async =>
      await delete('ss_control', 'con_id = ?', [id]);

  // ===========================================
  // 5.- MEDIDAS DE RIESGO
  // ===========================================
  Future<int> insertEvaluacionRiesgo(EvaluacionRiesgo evaluacionRiesgo) async =>
      await insert('ss_evaluacion_riesgo', evaluacionRiesgo.toMap());

  Future<List<EvaluacionRiesgo>> getEvaluacionRiesgo() async {
    final maps = await queryAll('ss_evaluacion_riesgo');
    return maps.map((m) => EvaluacionRiesgo.fromMap(m)).toList();
  }

  Future<EvaluacionRiesgo?> getEvaluacionRiesgoById(int id) async {
    final map = await queryById('ss_evaluacion_riesgo', 'eri_id', id);
    return map != null ? EvaluacionRiesgo.fromMap(map) : null;
  }

  Future<int> updateEvaluacionRiesgo(EvaluacionRiesgo evaluacionRiesgo) async =>
      await update(
        'ss_evaluacion_riesgo',
        evaluacionRiesgo.toMap(),
        'eri_id = ?',
        [evaluacionRiesgo.id],
      );

  Future<int> deleteEvaluacionRiesgo(int id) async =>
      await delete('ss_evaluacion_riesgo', 'eri_id = ?', [id]);

  // Aquí puedes seguir con Tarea, Control, EvaluacionRiesgo, etc.
}


















  // // ==============================================================
  // // ============== 1.- FUNCIONES PELIGRO =========================
  // // ==============================================================

  // // Insetar Peligro
  // Future<int> insertPeligro(Peligro peligro) async {
  //   final dbClient = await db;
  //   return await dbClient.insert('ss_peligro', peligro.toMap());
  // }

  // // Obtener todos los peligros
  // Future<List<Peligro>> getPeligros() async {
  //   final dbClient = await db;
  //   final List<Map<String, dynamic>> maps = await dbClient.query('ss_peligro');

  //   return List.generate(maps.length, (i) {
  //     return Peligro.fromMap(maps[i]);
  //   });
  // }

  // // ==============================================================
  // // ======== 2.- FUNCIONES  EVALUACION RIESGO ====================
  // // ==============================================================
  // //  Insertar EvaluacionRiesgo
  // Future<int> insertEvaluacionRiesgo(EvaluacionRiesgo evaluacion) async {
  //   final dbClient = await db;
  //   return await dbClient.insert(
  //     'ss_evaluacion_riesgo',
  //     evaluacion.toJson(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  // //  Obtener todas las evaluaciones de riesgo
  // Future<List<EvaluacionRiesgo>> getEvaluacionesRiesgo() async {
  //   final dbClient = await db;
  //   final List<Map<String, dynamic>> maps = await dbClient.query(
  //     'ss_evaluacion_riesgo',
  //   );

  //   return List.generate(maps.length, (i) {
  //     return EvaluacionRiesgo.fromJson(maps[i]);
  //   });
  // }

  // //  Obtener evaluación por ID
  // Future<EvaluacionRiesgo?> getEvaluacionRiesgoById(int id) async {
  //   final dbClient = await db;
  //   final List<Map<String, dynamic>> maps = await dbClient.query(
  //     'ss_evaluacion_riesgo',
  //     where: 'eri_id = ?',
  //     whereArgs: [id],
  //   );

  //   if (maps.isNotEmpty) {
  //     return EvaluacionRiesgo.fromJson(maps.first);
  //   }
  //   return null;
  // }

  // // ==============================================================
  // // =============== 3.- FUNCIONES CONTROL ========================
  // // ==============================================================
  // //  Insertar Control
  // Future<int> insertControl(Control control) async {
  //   final dbClient = await db;
  //   return await dbClient.insert(
  //     'ss_control',
  //     control.toMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  // //  Obtener todos los controles
  // Future<List<Control>> getControles() async {
  //   final dbClient = await db;
  //   final List<Map<String, dynamic>> maps = await dbClient.query('ss_control');

  //   return List.generate(maps.length, (i) {
  //     return Control.fromMap(maps[i]);
  //   });
  // }

  // //  Obtener control por ID
  // Future<Control?> getControlById(int id) async {
  //   final dbClient = await db;
  //   final List<Map<String, dynamic>> maps = await dbClient.query(
  //     'ss_control',
  //     where: 'con_id = ?',
  //     whereArgs: [id],
  //   );

  //   if (maps.isNotEmpty) {
  //     return Control.fromMap(maps.first);
  //   }
  //   return null;
  // }

  // // ==============================================================
  // // =============== 4.- FUNCIONES CONTROL ========================
  // // ==============================================================
  // //  Insertar MedidaControl
  // Future<int> insertMedidaControl(MedidaControl medida) async {
  //   final dbClient = await db;
  //   return await dbClient.insert(
  //     'ss_medida_control',
  //     medida.toMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  // //  Obtener todas las medidas
  // Future<List<MedidaControl>> getMedidasControl() async {
  //   final dbClient = await db;
  //   final List<Map<String, dynamic>> maps = await dbClient.query(
  //     'ss_medida_control',
  //   );

  //   return List.generate(maps.length, (i) {
  //     return MedidaControl.fromMap(maps[i]);
  //   });
  // }

  // //  Obtener una medida por ID
  // Future<MedidaControl?> getMedidaControlById(int id) async {
  //   final dbClient = await db;
  //   final List<Map<String, dynamic>> maps = await dbClient.query(
  //     'ss_medida_control',
  //     where: 'mec_id = ?',
  //     whereArgs: [id],
  //   );

  //   if (maps.isNotEmpty) {
  //     return MedidaControl.fromMap(maps.first);
  //   }
  //   return null;
  // }

  // // ==============================================================
  // // =========== 5.- FUNCIONES PUESTOS DE TRABAJO =================
  // // ==============================================================
  // // Insert Puesto de Trabajo
  // Future<int> insertPuestoTrabajo(PuestoTrabajo puesto) async {
  //   final dbClient = await db;
  //   return await dbClient.insert(
  //     'ss_puesto_trabajo',
  //     puesto.toMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  // // Obtener todas los puestos de trabajo
  // Future<List<PuestoTrabajo>> getPuestosTrabajo() async {
  //   final dbClient = await db;
  //   final List<Map<String, dynamic>> maps = await dbClient.query(
  //     'ss_puesto_trabajo',
  //   );

  //   return List.generate(maps.length, (i) {
  //     return PuestoTrabajo.fromMap(maps[i]);
  //   });
  // }

  // // Obtener un puesto de trabajo por ID
  // Future<PuestoTrabajo?> getPuestosTrabajoById(int id) async {
  //   final dbClient = await db;
  //   final List<Map<String, dynamic>> maps = await dbClient.query(
  //     'ss_puesto_trabajo',
  //     where: 'ptr_id = ?',
  //     whereArgs: [id],
  //   );

  //   if (maps.isNotEmpty) {
  //     return PuestoTrabajo.fromMap(maps.first);
  //   }
  //   return null;
  // }

  // // Actualizar un puesto de trabajo
  // Future<int> updatePuestoTrabajo(Map<String, dynamic> puesto) async {
  //   final dbClient = await db;
  //   return await dbClient.update(
  //     'ss_puesto_trabajo',
  //     {
  //       'ptr_id_area_meta': puesto['ptr_id_area_meta'],
  //       'ptr_nombre': puesto['ptr_nombre'],
  //       'ptr_descripcion': puesto['ptr_descripcion'],
  //       'ptr_std': puesto['ptr_std'],
  //       'ptr_user_mod': puesto['ptr_user_mod'],
  //       'ptr_fecha_mod': puesto['ptr_fecha_mod'],
  //     },
  //     where: 'ptr_id = ?',
  //     whereArgs: [puesto['ptr_id']],
  //   );
  // }

  // // Eliminar un puesto de trabajo
  // Future<int> deletePuestoTrabajo(int id) async {
  //   final dbClient = await db;
  //   return await dbClient.delete(
  //     'ss_puesto_trabajo',
  //     where: 'ptr_id = ?',
  //     whereArgs: [id],
  //   );
  // }

