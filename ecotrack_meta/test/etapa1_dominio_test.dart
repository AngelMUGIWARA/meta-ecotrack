// Etapa 1 — Dominio: reglas en Dart puro, sin Flutter.
//   flutter test test/etapa1_dominio_test.dart -r expanded

// Importa Consumo, laboratoriosUtez y validarLitros.
import 'package:ecotrack_meta/dominio/consumo.dart';
// Importa las reglas de la meta.
import 'package:ecotrack_meta/dominio/meta.dart';
// Importa test, expect y group.
import 'package:flutter_test/flutter_test.dart';

// Punto de entrada de las pruebas.
void main() {
  // Pruebas de la entidad y la constante.
  group('Consumo', () {
    // Los tres laboratorios, en este orden.
    test('laboratoriosUtez tiene los tres laboratorios', () {
      expect(laboratoriosUtez, ['Lab Química', 'Lab Redes', 'Lab Física']);
    });

    // La entidad guarda lo que recibe.
    test('Consumo guarda laboratorio y litros', () {
      const c = Consumo(laboratorio: 'Lab Redes', litros: 12.5);
      expect(c.laboratorio, 'Lab Redes');
      expect(c.litros, 12.5);
    });
  });

  // Pruebas de la regla de litros.
  group('validarLitros', () {
    // Texto que no es número llega como null.
    test('null pide número', () {
      expect(validarLitros(null), 'Escribe los litros con número');
    });

    // Cero y negativos se rechazan.
    test('cero o negativo se rechaza', () {
      expect(validarLitros(0), 'Los litros deben ser mayores que cero');
      expect(validarLitros(-3), 'Los litros deben ser mayores que cero');
    });

    // Más de 10000 se rechaza.
    test('más del tope se rechaza', () {
      expect(validarLitros(10001), 'Los litros superan el tope de 10000');
    });

    // Un valor normal no tiene error.
    test('un valor válido devuelve null', () {
      expect(validarLitros(12.5), isNull);
      expect(validarLitros(10000), isNull);
    });
  });

  // Pruebas de las reglas de la meta.
  group('Meta semanal', () {
    // Valores fijos del contrato.
    test('constantes de la meta', () {
      expect(metaInicial, 100.0);
      expect(pasoMeta, 10.0);
      expect(metaMinima, 10.0);
    });

    // Sube y baja con el cambio recibido.
    test('ajustarMeta suma el cambio', () {
      expect(ajustarMeta(100, 10), 110);
      expect(ajustarMeta(100, -10), 90);
    });

    // Nunca baja del mínimo.
    test('ajustarMeta no baja de metaMinima', () {
      expect(ajustarMeta(15, -10), metaMinima);
      expect(ajustarMeta(10, -10), metaMinima);
    });

    // Fracción usada entre 0 y 1.
    test('avanceDeMeta va de 0 a 1', () {
      expect(avanceDeMeta(total: 0, meta: 100), 0);
      expect(avanceDeMeta(total: 50, meta: 100), 0.5);
      expect(avanceDeMeta(total: 150, meta: 100), 1);
    });
  });
}
