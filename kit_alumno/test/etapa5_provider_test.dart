// Etapa 5 — Cableado B (provider) sobre el MISMO ViewModel.
//   flutter test test/etapa5_provider_test.dart -r expanded

// Importa la implementación en memoria.
import 'package:ecotrack_meta/datos/memoria_consumo_repository.dart';
// Importa la entidad Consumo.
import 'package:ecotrack_meta/dominio/consumo.dart';
// Importa el MISMO ViewModel de la etapa 3.
import 'package:ecotrack_meta/presentacion/consumos_view_model.dart';
// Importa la variante provider.
import 'package:ecotrack_meta/variantes/b_provider.dart';
// Importa MaterialApp, Scaffold y Key.
import 'package:flutter/material.dart';
// Importa testWidgets, find y expect.
import 'package:flutter_test/flutter_test.dart';
// Importa ChangeNotifierProvider para montar adaptadores sueltos.
import 'package:provider/provider.dart';

// Importa los pasos comunes.
import 'soporte/flujos.dart';
// Importa el repositorio falso.
import 'soporte/repositorio_espia.dart';

// Punto de entrada de las pruebas.
void main() {
  // Criterio "Dato compartido".
  testWidgets('Dato compartido: Registro guarda, Historial y Meta lo ven', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppProvider(repositorio: MemoriaConsumoRepository()),
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

  // Criterio "Sustitución".
  testWidgets(
    'Sustitución: con otra fuente de datos las pantallas no cambian',
    (tester) async {
      final espia = RepositorioEspia([
        const Consumo(laboratorio: 'Lab Redes', litros: 40),
      ]);
      await tester.pumpWidget(AppProvider(repositorio: espia));
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

  // Criterio "Capas".
  testWidgets('Capas: el error del dominio aparece y no se guarda nada', (
    tester,
  ) async {
    final espia = RepositorioEspia();
    await tester.pumpWidget(AppProvider(repositorio: espia));
    await tester.pumpAndSettle();

    await guardarLitros(tester, '0');

    expect(find.text('Los litros deben ser mayores que cero'), findsOneWidget);
    expect(espia.recibidos, isEmpty);
  });

  // Meta con provider: watch para mostrar, read para actuar.
  testWidgets('Meta: los botones cambian la meta y el aviso de rebase', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppProvider(repositorio: MemoriaConsumoRepository()),
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

  // Variante B: los adaptadores NO reciben el ViewModel; lo piden al árbol.
  testWidgets(
    'Los adaptadores piden el ViewModel al árbol, no al constructor',
    (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ConsumosViewModel>(
          create: (_) => ConsumosViewModel(
            RepositorioEspia([
              const Consumo(laboratorio: 'Lab Física', litros: 8),
            ]),
          )..cargar(),
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(child: HistorialProvider()),
                  Expanded(child: MetaProvider()),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total: 8.0 L'), findsOneWidget);
      expect(find.text('Usado: 8.0 de 100.0 L'), findsOneWidget);

      await tester.tap(find.byKey(const Key('subirMeta')));
      await tester.pumpAndSettle();
      expect(find.text('Usado: 8.0 de 110.0 L'), findsOneWidget);
    },
  );
}
