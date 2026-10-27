// Etapa 4 — Vistas tontas + cableado A (ChangeNotifier puro, por constructor).
//   flutter test test/etapa4_change_notifier_test.dart -r expanded

// Importa la implementación en memoria.
import 'package:ecotrack_meta/datos/memoria_consumo_repository.dart';
// Importa la entidad Consumo.
import 'package:ecotrack_meta/dominio/consumo.dart';
// Importa el ViewModel.
import 'package:ecotrack_meta/presentacion/consumos_view_model.dart';
// Importa la variante A.
import 'package:ecotrack_meta/variantes/a_change_notifier.dart';
// Importa MaterialApp, Scaffold y Key.
import 'package:flutter/material.dart';
// Importa testWidgets, find y expect.
import 'package:flutter_test/flutter_test.dart';

// Importa los pasos comunes.
import 'soporte/flujos.dart';
// Importa el repositorio falso.
import 'soporte/repositorio_espia.dart';

// Punto de entrada de las pruebas.
void main() {
  // Criterio "Dato compartido": un solo dueño, tres pantallas que lo miran.
  testWidgets('Dato compartido: Registro guarda, Historial y Meta lo ven', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppChangeNotifier(repositorio: MemoriaConsumoRepository()),
    );
    await tester.pumpAndSettle();

    await guardarLitros(tester, '12.5');
    expect(find.text('Consumo guardado'), findsOneWidget);

    await irA(tester, 'Historial');
    expect(find.text('Total: 12.5 L'), findsOneWidget);

    await irA(tester, 'Meta');
    expect(find.text('Usado: 12.5 de 100.0 L'), findsOneWidget);
    expect(find.text('Dentro de la meta'), findsOneWidget);
  });

  // Criterio "Sustitución": otra fuente de datos, mismas pantallas.
  testWidgets(
    'Sustitución: con otra fuente de datos las pantallas no cambian',
    (tester) async {
      final espia = RepositorioEspia([
        const Consumo(laboratorio: 'Lab Redes', litros: 40),
      ]);
      await tester.pumpWidget(AppChangeNotifier(repositorio: espia));
      await tester.pumpAndSettle();

      await irA(tester, 'Historial');
      expect(find.text('Total: 40.0 L'), findsOneWidget);

      await irA(tester, 'Registro');
      await guardarLitros(tester, '12.5');
      await irA(tester, 'Historial');
      expect(espia.recibidos.single.litros, 12.5);
      expect(find.text('Total: 52.5 L'), findsOneWidget);
    },
  );

  // Criterio "Capas": la regla del dominio llega como error a la vista.
  testWidgets('Capas: el error del dominio aparece y no se guarda nada', (
    tester,
  ) async {
    final espia = RepositorioEspia();
    await tester.pumpWidget(AppChangeNotifier(repositorio: espia));
    await tester.pumpAndSettle();

    await guardarLitros(tester, '0');

    expect(find.text('Los litros deben ser mayores que cero'), findsOneWidget);
    expect(espia.recibidos, isEmpty);
  });

  // La meta es estado compartido que se cambia con acciones del ViewModel.
  testWidgets('Meta: los botones cambian la meta y el aviso de rebase', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppChangeNotifier(repositorio: MemoriaConsumoRepository()),
    );
    await tester.pumpAndSettle();

    await guardarLitros(tester, '120');
    await irA(tester, 'Meta');
    expect(find.text('Usado: 120.0 de 100.0 L'), findsOneWidget);
    expect(find.text('Te pasaste de la meta'), findsOneWidget);

    await tester.tap(find.byKey(const Key('subirMeta')));
    await tester.tap(find.byKey(const Key('subirMeta')));
    await tester.pumpAndSettle();
    expect(find.text('Usado: 120.0 de 120.0 L'), findsOneWidget);
    expect(find.text('Dentro de la meta'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bajarMeta')));
    await tester.pumpAndSettle();
    expect(find.text('Usado: 120.0 de 110.0 L'), findsOneWidget);
  });

  // Variante A: el adaptador recibe el ViewModel por constructor y lo escucha.
  testWidgets('HistorialCN recibe vm por constructor y se redibuja', (
    tester,
  ) async {
    final vm = ConsumosViewModel(MemoriaConsumoRepository());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HistorialCN(vm: vm)),
      ),
    );
    expect(find.text('Sin consumos'), findsOneWidget);

    await vm.guardar('Lab Redes', '5');
    await tester.pumpAndSettle();
    expect(find.text('Total: 5.0 L'), findsOneWidget);
    vm.dispose();
  });
}
