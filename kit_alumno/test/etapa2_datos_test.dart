// Etapa 2 — Datos: contrato e implementación en memoria.
//   flutter test test/etapa2_datos_test.dart -r expanded

// Importa el contrato.
import 'package:ecotrack_meta/datos/consumo_repository.dart';
// Importa la implementación en memoria.
import 'package:ecotrack_meta/datos/memoria_consumo_repository.dart';
// Importa la entidad Consumo.
import 'package:ecotrack_meta/dominio/consumo.dart';
// Importa test y expect.
import 'package:flutter_test/flutter_test.dart';

// Punto de entrada de las pruebas.
void main() {
  // Pruebas del repositorio en memoria.
  group('MemoriaConsumoRepository', () {
    // Cumple el contrato, así puede sustituirse por otro.
    test('cumple el contrato ConsumoRepository', () {
      expect(MemoriaConsumoRepository(), isA<ConsumoRepository>());
    });

    // Arranca sin datos.
    test('empieza vacío', () async {
      expect(await MemoriaConsumoRepository().todos(), isEmpty);
    });

    // Guarda y devuelve en el mismo orden.
    test('guarda y devuelve en orden', () async {
      final repo = MemoriaConsumoRepository();
      await repo.guardar(const Consumo(laboratorio: 'Lab Redes', litros: 5));
      await repo.guardar(const Consumo(laboratorio: 'Lab Física', litros: 7));

      final todos = await repo.todos();
      expect(todos.map((c) => c.litros), [5, 7]);
      expect(todos.first.laboratorio, 'Lab Redes');
    });

    // Nadie puede modificar la fuente de verdad desde fuera.
    test('todos() no deja modificar la lista interna', () async {
      final repo = MemoriaConsumoRepository();
      final lista = await repo.todos();
      expect(
        () => lista.add(const Consumo(laboratorio: 'Lab Redes', litros: 1)),
        throwsUnsupportedError,
      );
    });
  });
}
