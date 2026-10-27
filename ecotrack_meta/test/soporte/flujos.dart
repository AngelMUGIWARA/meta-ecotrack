// Apoyo de pruebas: pasos que repite una persona usando la app.

// Importa Key.
import 'package:flutter/material.dart';
// Importa WidgetTester y find.
import 'package:flutter_test/flutter_test.dart';

// Escribe los litros en Registro y toca "Guardar".
Future<void> guardarLitros(WidgetTester tester, String litros) async {
  // Escribe en el campo con clave 'litros'.
  await tester.enterText(find.byKey(const Key('litros')), litros);
  // Toca el botón "Guardar".
  await tester.tap(find.text('Guardar'));
  // Espera a que terminen animaciones y tareas pendientes.
  await tester.pumpAndSettle();
}

// Toca una pestaña de la barra inferior: 'Registro', 'Historial' o 'Meta'.
Future<void> irA(WidgetTester tester, String pestana) async {
  // Toca la etiqueta de la pestaña.
  await tester.tap(find.text(pestana));
  // Espera a que se redibuje.
  await tester.pumpAndSettle();
}
