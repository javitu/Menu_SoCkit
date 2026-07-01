#!/usr/bin/env bash
#
# Compila el core "Menu" (SoCkit) con Quartus dentro del contenedor Docker
# de raetro (https://github.com/raetro/sdk-docker-fpga), usando la imagen
# con alias 'mister' (raetro/quartus:mister, Quartus 17.0 Lite / Cyclone V).
#
# El .rbf resultante se copia a releases/ con el formato habitual del repo:
#   releases/menu_YYYYMMDD.rbf
#
# Uso:
#   ./docker/build.sh
#
# Variables opcionales:
#   MISTER_IMAGE=raetro/quartus:mister   # imagen a usar
#
set -euo pipefail

# --- Rutas -------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

IMAGE="${MISTER_IMAGE:-raetro/quartus:mister}"
PROJECT="menu"
RBF="output_files/$PROJECT.rbf"

cd "$PROJECT_DIR"

echo ">>> Proyecto: $PROJECT_DIR"
echo ">>> Imagen:   $IMAGE"

# --- Ejecuta una herramienta de Quartus dentro del contenedor --------
run_quartus() {
  docker run --rm \
    -v "$PROJECT_DIR":/build \
    -w /build \
    -u "$(id -u):$(id -g)" \
    -e HOME=/tmp \
    "$IMAGE" \
    "$@"
}

# --- Imagen ------------------------------------------------------------------
docker pull "$IMAGE" || echo ">>> (ERROR) no se pudo hacer pull"

# --- Compilacion -------------------------------------------------------------
run_quartus quartus_sh --flow compile "$PROJECT.qpf"

if [[ ! -f "$RBF" ]]; then
  run_quartus quartus_asm "$PROJECT"
fi

if [[ ! -f "$RBF" ]]; then
  echo "ERROR: no se genero $RBF" >&2
  exit 1
fi

# --- Release -----------------------------------------------------------------
# BUILD_DATE viene en build_id.v como "YYMMDD" -> le anteponemos "20".
BUILD_DATE="$(grep -oE '"[0-9]{6}"' build_id.v 2>/dev/null | tr -d '"' || true)"
if [[ -z "$BUILD_DATE" ]]; then
  BUILD_DATE="$(date +%y%m%d)"
fi
RELEASE="releases/${PROJECT}_20${BUILD_DATE}.rbf"

mkdir -p releases
cp "$RBF" "$RELEASE"

echo ">>> Release generado: $RELEASE"
