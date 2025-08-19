// enum ControlType { eliminacion, sustitucion, ingenieria, administrativo, epp }

// extension ControlTypeText on ControlType {
//   String get label {
//     switch (this) {
//       case ControlType.eliminacion:
//         return 'Eliminación';
//       case ControlType.sustitucion:
//         return 'Sustitución';
//       case ControlType.ingenieria:
//         return 'Ingeniería';
//       case ControlType.administrativo:
//         return 'Administrativo';
//       case ControlType.epp:
//         return 'EPP';
//     }
//   }
// }

// class ControlEntry {
//   ControlType type;
//   String description;

//   ControlEntry({required this.type, required this.description});

//   Map<String, dynamic> toJson() => {
//         'type': type.label,
//         'description': description,
//       };

//   factory ControlEntry.fromMap(Map<String, dynamic> map) {
//     return ControlEntry(
//       type: ControlType.values.firstWhere(
//         (e) => e.label == map['type'],
//         orElse: () => ControlType.epp,
//       ),
//       description: map['description'] ?? '',
//     );
//   }
// }
