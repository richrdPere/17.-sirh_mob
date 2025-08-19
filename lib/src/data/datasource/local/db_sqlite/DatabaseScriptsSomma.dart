// Script SQL para crear las tablas en SQLite
class DatabaseScriptsSsoma {
  // 1.- ss_area_meta
  static const String createAreaMetaTable = '''
  CREATE TABLE ss_area_meta (
    ame_id INTEGER PRIMARY KEY AUTOINCREMENT,
    ame_codigo TEXT,
    ame_nombre TEXT,
    ame_descripcion TEXT,
    ame_std TEXT,
    ame_user_ins TEXT,
    ame_fecha_ins TEXT,
    ame_user_mod TEXT,
    ame_fecha_mod TEXT
  );
  ''';

  // 2.- ss_peligro
  static const String createPeligroTable = '''
  CREATE TABLE ss_peligro (
    pel_id INTEGER PRIMARY KEY AUTOINCREMENT,
    pel_nombre TEXT,
    pel_descripcion TEXT,
    pel_std TEXT,
    pel_user_ins TEXT,
    pel_fecha_ins TEXT,
    pel_user_mod TEXT,
    pel_fecha_mod TEXT
  );
  ''';

  // 3.- ss_riesgo
  static const String createRiesgoTable = '''
  CREATE TABLE ss_riesgo (
    rie_id INTEGER PRIMARY KEY AUTOINCREMENT,
    rie_nombre TEXT,
    rie_descripcion TEXT,
    rie_std TEXT,
    rie_user_ins TEXT,
    rie_fecha_ins TEXT,
    rie_user_mod TEXT,
    rie_fecha_mod TEXT
  );
  ''';

  // 4.- ss_control
  static const String createControlTable = '''
  CREATE TABLE ss_control (
    con_id INTEGER PRIMARY KEY AUTOINCREMENT,
    con_nombre TEXT,
    con_descripcion TEXT,
    con_tipo TEXT,
    con_categoria TEXT,
    con_std TEXT,
    con_user_ins TEXT,
    con_fecha_ins TEXT,
    con_user_mod TEXT,
    con_fecha_mod TEXT
    );
    ''';

  // 5.- ss_puesto_trabajo
  static const String createPuestoTrabajoTable = '''
  CREATE TABLE ss_puesto_trabajo (
    ptr_id INTEGER PRIMARY KEY AUTOINCREMENT,
    ptr_id_area_meta INTEGER,
    ptr_nombre TEXT,
    ptr_descripcion TEXT,
    ptr_std TEXT,
    ptr_user_ins TEXT,
    ptr_fecha_ins TEXT,
    ptr_user_mod TEXT,
    ptr_fecha_mod TEXT
  );
  ''';

  // 6.- ss_tarea
  static const String createTareaTable = '''
  CREATE TABLE ss_tarea (
    tar_id INTEGER PRIMARY KEY AUTOINCREMENT,
    tar_nombre TEXT,
    tar_tipo TEXT,
    tar_pasos TEXT,
    tar_frecuencia TEXT,
    tar_std TEXT,
    tar_user_ins TEXT,
    tar_fecha_ins TEXT,
    tar_user_mod TEXT,
    tar_fecha_mod TEXT
  );
  ''';

  // 7.- ss_evaluacion_riesgo
  static const String createEvaluacionRiesgoTable = '''
  CREATE TABLE ss_evaluacion_riesgo (
    eri_id INTEGER PRIMARY KEY AUTOINCREMENT,
    eri_id_peligro INTEGER,
    eri_nombre TEXT,
    eri_tipo TEXT,
    eri_persona_expuesta_iden INTEGER,
    eri_procedimiento_existente_iden INTEGER,
    eri_capacitacion_iden INTEGER,
    eri_exposicion_riesgo_iden INTEGER,
    eri_probabilidad_iden INTEGER,
    eri_severidad_iden INTEGER,
    eri_fase INTEGER,
    eri_persona_expuesta_eval INTEGER,
    eri_procedimiento_existente_eval INTEGER,
    eri_capacitacion_eval INTEGER,
    eri_exposicion_riesgo_eval INTEGER,
    eri_probabilidad_eval INTEGER,
    eri_severidad_eval INTEGER,
    rgo_fecha_evaluacion TEXT,
    eri_observaciones TEXT,
    eri_std TEXT,
    eri_user_ins TEXT,
    eri_fecha_ins TEXT,
    eri_user_mod TEXT,
    eri_fecha_mod TEXT
  );
  ''';

  // 8.- ss_medida_control
  static const String createMedidaControlTable = '''
CREATE TABLE ss_medida_control (
  mec_id INTEGER PRIMARY KEY AUTOINCREMENT,
  pel_id_evaluacion_riesgo INTEGER,
  mec_id_control INTEGER,
  mec_responsable TEXT,
  mec_fecha_implementacion TEXT,
  mec_eficacia TEXT,
  mec_estado TEXT,
  mec_imagen TEXT,
  mec_evidencia TEXT,
  mec_std TEXT,
  mec_user_ins TEXT,
  mec_fecha_ins TEXT,
  mec_user_mod TEXT,
  mec_fecha_mod TEXT
);
''';

}
