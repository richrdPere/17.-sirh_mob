import 'dart:convert';

class EvaluacionRiesgo {
  final int? id;
  final int? peligroId; // Relación con Peligro (solo guardamos el ID)
  final String? nombre;
  final String? tipo;
  final int? personaExpuestaIden;
  final int? procedimientoExistenteIden;
  final int? capacitacionIden;
  final int? exposicionRiesgoIden;
  final int? probabilidadIden;
  final int? severidadIden;
  final int? fase;
  final int? personaExpuestaEval;
  final int? procedimientoExistenteEval;
  final int? capacitacionEval;
  final int? exposicionRiesgoEval;
  final int? probabilidadEval;
  final int? severidadEval;
  final String? fechaEvaluacion;
  final String? observaciones;
  final String? std;
  final String? usuarioCreacion;
  final String? fechaCreacion;
  final String? usuarioModificacion;
  final String? fechaModificacion;

  EvaluacionRiesgo({
    this.id,
    this.peligroId,
    this.nombre,
    this.tipo,
    this.personaExpuestaIden,
    this.procedimientoExistenteIden,
    this.capacitacionIden,
    this.exposicionRiesgoIden,
    this.probabilidadIden,
    this.severidadIden,
    this.fase,
    this.personaExpuestaEval,
    this.procedimientoExistenteEval,
    this.capacitacionEval,
    this.exposicionRiesgoEval,
    this.probabilidadEval,
    this.severidadEval,
    this.fechaEvaluacion,
    this.observaciones,
    this.std,
    this.usuarioCreacion,
    this.fechaCreacion,
    this.usuarioModificacion,
    this.fechaModificacion,
  });

  // -------- JSON methods --------
  factory EvaluacionRiesgo.fromJson(Map<String, dynamic> json) {
    return EvaluacionRiesgo(
      id: json['eri_id'],
      peligroId: json['eri_id_peligro'], // relación
      nombre: json['eri_nombre'],
      tipo: json['eri_tipo'],
      personaExpuestaIden: json['eri_persona_expuesta_iden'],
      procedimientoExistenteIden: json['eri_procedimiento_existente_iden'],
      capacitacionIden: json['eri_capacitacion_iden'],
      exposicionRiesgoIden: json['eri_exposicion_riesgo_iden'],
      probabilidadIden: json['eri_probabilidad_iden'],
      severidadIden: json['eri_severidad_iden'],
      fase: json['eri_fase'],
      personaExpuestaEval: json['eri_persona_expuesta_eval'],
      procedimientoExistenteEval: json['eri_procedimiento_existente_eval'],
      capacitacionEval: json['eri_capacitacion_eval'],
      exposicionRiesgoEval: json['eri_exposicion_riesgo_eval'],
      probabilidadEval: json['eri_probabilidad_eval'],
      severidadEval: json['eri_severidad_eval'],
      fechaEvaluacion: json['rgo_fecha_evaluacion'],
      // fechaEvaluacion: json['rgo_fecha_evaluacion'] != null
      //     ? DateTime.tryParse(json['rgo_fecha_evaluacion'])
      //     : null,
      observaciones: json['eri_observaciones'],
      std: json['eri_std'],
      usuarioCreacion: json['eri_user_ins'],
      fechaCreacion: json['eri_fecha_ins'],
      // fechaCreacion: json['eri_fecha_ins'] != null
      //     ? DateTime.tryParse(json['eri_fecha_ins'])
      //     : null,
      usuarioModificacion: json['eri_user_mod'],
      fechaModificacion: json['eri_fecha_mod'],
      // fechaModificacion: json['eri_fecha_mod'] != null
      //     ? DateTime.tryParse(json['eri_fecha_mod'])
      //     : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eri_id': id,
      'eri_id_peligro': peligroId,
      'eri_nombre': nombre,
      'eri_tipo': tipo,
      'eri_persona_expuesta_iden': personaExpuestaIden,
      'eri_procedimiento_existente_iden': procedimientoExistenteIden,
      'eri_capacitacion_iden': capacitacionIden,
      'eri_exposicion_riesgo_iden': exposicionRiesgoIden,
      'eri_probabilidad_iden': probabilidadIden,
      'eri_severidad_iden': severidadIden,
      'eri_fase': fase,
      'eri_persona_expuesta_eval': personaExpuestaEval,
      'eri_procedimiento_existente_eval': procedimientoExistenteEval,
      'eri_capacitacion_eval': capacitacionEval,
      'eri_exposicion_riesgo_eval': exposicionRiesgoEval,
      'eri_probabilidad_eval': probabilidadEval,
      'eri_severidad_eval': severidadEval,
      'rgo_fecha_evaluacion': fechaEvaluacion,
      // 'rgo_fecha_evaluacion': fechaEvaluacion?.toIso8601String(),
      'eri_observaciones': observaciones,
      'eri_std': std,
      'eri_user_ins': usuarioCreacion,
      'eri_fecha_ins': fechaCreacion,
      // 'eri_fecha_ins': fechaCreacion?.toIso8601String(),
      'eri_user_mod': usuarioModificacion,
      'eri_fecha_mod': fechaModificacion,
      // 'eri_fecha_mod': fechaModificacion?.toIso8601String(),
    };
  }

  // ----------- TO MAP (SQLite) -----------
  Map<String, dynamic> toMap() {
    return {
      'eri_id': id,
      'eri_id_peligro': peligroId,
      'eri_nombre': nombre,
      'eri_tipo': tipo,
      'eri_persona_expuesta_iden': personaExpuestaIden,
      'eri_procedimiento_existente_iden': procedimientoExistenteIden,
      'eri_capacitacion_iden': capacitacionIden,
      'eri_exposicion_riesgo_iden': exposicionRiesgoIden,
      'eri_probabilidad_iden': probabilidadIden,
      'eri_severidad_iden': severidadIden,
      'eri_fase': fase,
      'eri_persona_expuesta_eval': personaExpuestaEval,
      'eri_procedimiento_existente_eval': procedimientoExistenteEval,
      'eri_capacitacion_eval': capacitacionEval,
      'eri_exposicion_riesgo_eval': exposicionRiesgoEval,
      'eri_probabilidad_eval': probabilidadEval,
      'eri_severidad_eval': severidadEval,
      'rgo_fecha_evaluacion': fechaEvaluacion,
      // 'rgo_fecha_evaluacion': fechaEvaluacion?.toIso8601String(),
      'eri_observaciones': observaciones,
      'eri_std': std,
      'eri_user_ins': usuarioCreacion,
      'eri_fecha_ins': fechaCreacion,
      // 'eri_fecha_ins': fechaCreacion?.toIso8601String(),
      'eri_user_mod': usuarioModificacion,
      'eri_fecha_mod': fechaModificacion,
      // 'eri_fecha_mod': fechaModificacion?.toIso8601String(),
    };
  }

  // ----------- FROM MAP (SQLite) -----------
  factory EvaluacionRiesgo.fromMap(Map<String, dynamic> map) {
    return EvaluacionRiesgo(
      id: map['eri_id'],
      peligroId: map['eri_id_peligro'],
      nombre: map['eri_nombre'],
      tipo: map['eri_tipo'],
      personaExpuestaIden: map['eri_persona_expuesta_iden'],
      procedimientoExistenteIden: map['eri_procedimiento_existente_iden'],
      capacitacionIden: map['eri_capacitacion_iden'],
      exposicionRiesgoIden: map['eri_exposicion_riesgo_iden'],
      probabilidadIden: map['eri_probabilidad_iden'],
      severidadIden: map['eri_severidad_iden'],
      fase: map['eri_fase'],
      personaExpuestaEval: map['eri_persona_expuesta_eval'],
      procedimientoExistenteEval: map['eri_procedimiento_existente_eval'],
      capacitacionEval: map['eri_capacitacion_eval'],
      exposicionRiesgoEval: map['eri_exposicion_riesgo_eval'],
      probabilidadEval: map['eri_probabilidad_eval'],
      severidadEval: map['eri_severidad_eval'],
      fechaEvaluacion: map['rgo_fecha_evaluacion'] ,
      // fechaEvaluacion: map['rgo_fecha_evaluacion'] != null
      //     ? DateTime.tryParse(map['rgo_fecha_evaluacion'])
      //     : null,
      observaciones: map['eri_observaciones'],
      std: map['eri_std'],
      usuarioCreacion: map['eri_user_ins'],
      fechaCreacion: map['eri_fecha_ins'] ,
      // fechaCreacion: map['eri_fecha_ins'] != null
      //     ? DateTime.tryParse(map['eri_fecha_ins'])
      //     : null,
      usuarioModificacion: map['eri_user_mod'],
      fechaModificacion: map['eri_fecha_mod'],
      // fechaModificacion: map['eri_fecha_mod'] != null
      //     ? DateTime.tryParse(map['eri_fecha_mod'])
      //     : null,
    );
  }
}
