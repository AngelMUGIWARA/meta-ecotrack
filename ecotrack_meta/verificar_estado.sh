#!/usr/bin/env bash
# Práctica EcoTrack Meta — verificación de capas y cableado de estado
#
#   bash verificar_estado.sh
#
# Se corre desde la raíz de ecotrack_meta/ (o desde la carpeta que lo contiene).
# Las pruebas (flutter test) revisan que la app FUNCIONE; este script revisa
# que las capas estén separadas y que cada gestor esté cableado como se pidió.
#
# NO EDITAR: el docente vuelve a correr una copia limpia de este archivo.
#
# Si el archivo llegó con saltos de línea de Windows (CRLF), se corre una copia limpia. Esta línea debe terminar en "#".
if grep -q $'\r' "$0" 2>/dev/null; then d=$(cd "$(dirname "$0")" && pwd); limpio="${TMPDIR:-/tmp}/verificar_estado_lf.sh"; tr -d '\r' < "$0" > "$limpio"; VERIFICAR_DIR="$d" exec bash "$limpio" "$@"; fi #

aqui="${VERIFICAR_DIR:-$(cd "$(dirname "$0")" && pwd)}"

proyecto=""
for candidato in "$aqui" "$aqui/ecotrack_meta" "$PWD" "$PWD/ecotrack_meta"; do
  if [ -f "$candidato/pubspec.yaml" ] && grep -q "^name: ecotrack_meta" "$candidato/pubspec.yaml"; then
    proyecto="$candidato"
    break
  fi
done

if [ -z "$proyecto" ]; then
  echo "No encuentro el proyecto ecotrack_meta (falta pubspec.yaml con name: ecotrack_meta)."
  echo "Copien este script a la raíz de ecotrack_meta/ y córranlo desde ahí."
  exit 1
fi

cd "$proyecto" || exit 1
echo "Proyecto: $proyecto"

fallas=0

ok()    { echo "  OK     $1"; }
falta() { echo "  FALTA  $1"; fallas=$((fallas + 1)); }

# Solo cuentan las líneas import, no los comentarios que mencionan el paquete.
importa() { grep -rqnE "^[[:space:]]*import[[:space:]]+['\"].*$1" "$2"; }
# Código del archivo sin las líneas que son solo comentario.
codigo() { grep -vE "^[[:space:]]*//" "$1"; }
# true si el código (sin comentarios) contiene el patrón.
usa() { codigo "$2" | grep -qE "$1"; }

vm=lib/presentacion/consumos_view_model.dart
vistas=lib/presentacion/vistas.dart
va=lib/variantes/a_change_notifier.dart
vb=lib/variantes/b_provider.dart

echo
echo "1) Archivos del contrato"
for f in \
  lib/dominio/consumo.dart \
  lib/dominio/meta.dart \
  lib/datos/consumo_repository.dart \
  lib/datos/memoria_consumo_repository.dart \
  "$vm" \
  "$vistas" \
  "$va" \
  "$vb" \
  lib/main.dart \
  lib/main_change_notifier.dart \
  docs/estado.md; do
  if [ -f "$f" ]; then ok "$f"; else falta "$f no existe"; fi
done

echo
echo "2) Dominio y datos no conocen Flutter"
for capa in lib/dominio lib/datos; do
  if [ -d "$capa" ] && ! importa "package:flutter" "$capa"; then
    ok "$capa no importa package:flutter"
  else
    falta "$capa no existe o importa package:flutter"
  fi
done

echo
echo "3) El ViewModel avisa, no dibuja y no sabe de dónde salen los datos"
if [ -f "$vm" ]; then
  if importa "material.dart" "$vm"; then falta "$vm importa material.dart (usen foundation.dart)"; else ok "$vm no importa material.dart"; fi
  if usa "extends[[:space:]]+ChangeNotifier" "$vm"; then ok "ConsumosViewModel extiende ChangeNotifier"; else falta "ConsumosViewModel no extiende ChangeNotifier"; fi
  if usa "notifyListeners\(\)" "$vm"; then ok "$vm llama a notifyListeners()"; else falta "$vm nunca llama a notifyListeners()"; fi
  if usa "MemoriaConsumoRepository|memoria_consumo" "$vm"; then falta "$vm conoce la implementación en memoria"; else ok "$vm solo conoce el contrato ConsumoRepository"; fi
  if usa "provider" "$vm"; then falta "$vm menciona provider: el ViewModel no debe saber quién lo entrega"; else ok "$vm no depende de provider"; fi
  if usa "get[[:space:]]+total" "$vm" && ! usa "^[[:space:]]*(double|var|final|late)[^=;(]*[[:space:]]total[[:space:]]*(=[^>]|;)" "$vm"; then
    ok "total es estado derivado (getter), no un campo guardado"
  else
    falta "total debe ser un getter calculado, no un campo"
  fi
else
  falta "$vm no existe"
fi

echo
echo "4) Las vistas son tontas"
if [ -f "$vistas" ]; then
  if importa "provider" "$vistas"; then falta "$vistas importa provider"; else ok "$vistas no importa provider"; fi
  if importa "consumos_view_model" "$vistas"; then falta "$vistas importa el ViewModel"; else ok "$vistas no conoce el ViewModel"; fi
  if importa "datos/" "$vistas"; then falta "$vistas importa algo de lib/datos"; else ok "$vistas no importa nada de lib/datos"; fi
else
  falta "$vistas no existe"
fi

echo
echo "5) Variante A: ChangeNotifier puro, por constructor"
if [ -f "$va" ]; then
  if importa "provider" "$va"; then falta "$va importa provider"; else ok "$va no usa paquetes extra"; fi
  if usa "ListenableBuilder" "$va"; then ok "$va escucha con ListenableBuilder"; else falta "$va no usa ListenableBuilder"; fi
  if usa "required[[:space:]]+this\.vm" "$va"; then ok "$va pasa el ViewModel por constructor"; else falta "$va no recibe vm por constructor"; fi
  if usa "\.dispose\(\)" "$va"; then ok "$va libera el ViewModel en dispose()"; else falta "$va no libera el ViewModel"; fi
else
  falta "$va no existe"
fi

echo
echo "6) Variante B: provider sobre el MISMO ViewModel"
if [ -f "$vb" ]; then
  if importa "package:provider" "$vb"; then ok "$vb importa provider"; else falta "$vb no importa package:provider"; fi
  if usa "ChangeNotifierProvider" "$vb"; then ok "$vb cuelga el ViewModel con ChangeNotifierProvider"; else falta "$vb no usa ChangeNotifierProvider"; fi
  if usa "context\.watch<ConsumosViewModel>" "$vb"; then ok "$vb muestra con context.watch"; else falta "$vb no usa context.watch<ConsumosViewModel>"; fi
  if usa "context\.read<ConsumosViewModel>" "$vb"; then ok "$vb actúa con context.read"; else falta "$vb no usa context.read<ConsumosViewModel>"; fi
  if usa "ListenableBuilder|required[[:space:]]+this\.vm" "$vb"; then falta "$vb sigue pasando o escuchando el vm a mano"; else ok "$vb no pasa el vm por constructor"; fi
  if usa "class[[:space:]]+[A-Za-z]+[[:space:]]+extends[[:space:]]+ChangeNotifier" "$vb"; then falta "$vb define otro ChangeNotifier: debe reusar ConsumosViewModel"; else ok "$vb reusa ConsumosViewModel"; fi
else
  falta "$vb no existe"
fi

echo
echo "7) watch para mostrar, read para actuar"
malos=$(grep -rnE "(on[A-Z][A-Za-z]*|al[A-Z][A-Za-z]*)[[:space:]]*:.*\.watch|\(\)[[:space:]]*(async[[:space:]]*)?=>.*\.watch" lib/variantes 2>/dev/null \
  | grep -vE "^[^:]+:[0-9]+:[[:space:]]*//")
if [ -z "$malos" ]; then
  ok "ningún callback usa watch"
else
  while IFS= read -r m; do falta "watch dentro de un callback: $m"; done <<< "$malos"
fi

echo
echo "8) Solo main*.dart elige la fuente de datos"
intrusos=$(grep -rlE "^[[:space:]]*import[[:space:]]+['\"].*memoria_consumo_repository" lib 2>/dev/null \
  | grep -vE "lib/main[a-z_]*\.dart$")
if [ -z "$intrusos" ]; then
  ok "MemoriaConsumoRepository solo se importa en main*.dart"
else
  for i in $intrusos; do falta "$i importa la implementación en memoria"; done
fi
if [ -f lib/main.dart ] && usa "AppProvider" lib/main.dart; then ok "lib/main.dart arranca AppProvider"; else falta "lib/main.dart no arranca AppProvider"; fi
if [ -f lib/main_change_notifier.dart ] && usa "AppChangeNotifier" lib/main_change_notifier.dart; then ok "lib/main_change_notifier.dart arranca AppChangeNotifier"; else falta "lib/main_change_notifier.dart no arranca AppChangeNotifier"; fi

echo
if [ "$fallas" -eq 0 ]; then
  echo "Resultado: todo OK. Ahora corran: flutter test"
  exit 0
else
  echo "Resultado: $fallas punto(s) en FALTA."
  exit 1
fi
