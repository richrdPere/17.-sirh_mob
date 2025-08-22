// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// // Modelos
// import 'package:sirh_mob/src/domain/models/ssoma_models/PuestoTrabajo.dart';
// import 'package:sirh_mob/src/domain/models/ssoma_models/Tarea.dart';

// class StepDatosTarea extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final List<PuestoTrabajo> allPuestos;
//   final List<Tarea> allTareas;
//   final PuestoTrabajo? selectedPuesto;
//   final Tarea? selectedTarea;
//   final Function(PuestoTrabajo?) onPuestoChanged;
//   final Function(Tarea?) onTareaChanged;
//   final VoidCallback onAddPuesto;
//   final VoidCallback onAddTarea;
//   final VoidCallback toggleFirstStep;
//   final int currentStep;

//   const StepDatosTarea({
//     Key? key,
//     required this.formKey,
//     required this.allPuestos,
//     required this.allTareas,
//     required this.selectedPuesto,
//     required this.selectedTarea,
//     required this.onPuestoChanged,
//     required this.onTareaChanged,
//     required this.onAddPuesto,
//     required this.onAddTarea,
//     required this.toggleFirstStep,
//     required this.currentStep,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Step(
//       title: GestureDetector(
//         onTap: toggleFirstStep,
//         child: const Text('Datos de la Tarea'),
//       ),
//       isActive: currentStep >= 0,
//       state: currentStep > 0 ? StepState.complete : StepState.indexed,
//       content: Form(
//         key: formKey,
//         child: Column(
//           children: [
//             const SizedBox(height: 10),
//             // Select Puestos
//             CustomSelect<PuestoTrabajo>(
//               label: 'Puestos de trabajo',
//               items: allPuestos,
//               initialValue: selectedPuesto,
//               onChanged: onPuestoChanged,
//               onAdd: onAddPuesto,
//               itemLabel: (puesto) => "${puesto.id}.- ${puesto.nombre}",
//             ),
//             const SizedBox(height: 20),
//             // Select Tareas
//             CustomSelect<Tarea>(
//               label: 'Tareas registradas',
//               items: allTareas,
//               initialValue: selectedTarea,
//               onChanged: onTareaChanged,
//               onAdd: onAddTarea,
//               itemLabel: (tarea) => "${tarea.id}.- ${tarea.pasos}",
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
