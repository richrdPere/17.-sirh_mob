// import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/identificarPeligro/IdentificarPeligro.dart';

// class ReportePeligro {
//   int? id;
//   String peligro;
//   String descripcion;
//   String area;
//   String ubicacion;
//   DateTime? fecha;
//   List<String> riesgos;
//   List<ControlEntry> controles;

//   ReportePeligro({
//     this.id,
//     required this.peligro,
//     required this.descripcion,
//     required this.area,
//     required this.ubicacion,
//     required this.fecha,
//     required this.riesgos,
//     required this.controles,
//   });

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'peligro': peligro,
//     'descripcion': descripcion,
//     'area': area,
//     'ubicacion': ubicacion,
//     'fecha': fecha?.toIso8601String(),
//     'riesgos': riesgos.join(','), // se guarda como texto
//     'controles': controles.map((e) => e.toJson()).toList(),
//   };

//   factory ReportePeligro.fromMap(Map<String, dynamic> map) {
//     return ReportePeligro(
//       id: map['id'],
//       peligro: map['peligro'],
//       descripcion: map['descripcion'],
//       area: map['area'],
//       ubicacion: map['ubicacion'],
//       fecha: map['fecha'] != null ? DateTime.parse(map['fecha']) : null,
//       riesgos: (map['riesgos'] as String).split(','),
//       controles: [], // luego se carga desde otra tabla
//     );
//   }
// }
