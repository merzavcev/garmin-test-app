#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${CIQ_TARGET:-vivoactive6}"
INPUT="${ROOT_DIR}/build/HelloGarmin.prg"
OUTPUT_DIR="${ROOT_DIR}/dist"
OUTPUT_NAME="HelloGarmin-${TARGET}.prg"

print_usage() {
  cat <<USAGE
Usage: $(basename "$0") [options]

Package signed .prg into dist/ artifact.

Options:
  -t, --target <device>   Target name used in artifact filename (default: vivoactive6 or CIQ_TARGET)
  -i, --input <file>      Input .prg file (default: build/HelloGarmin.prg)
  -o, --output-dir <dir>  Output directory (default: dist)
      --rebuild           Rebuild before packaging (signed)
  -h, --help              Show this help message
USAGE
}

REBUILD=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 1; }
      TARGET="$2"
      OUTPUT_NAME="HelloGarmin-${TARGET}.prg"
      shift 2
      ;;
    -i|--input)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 1; }
      INPUT="$2"
      shift 2
      ;;
    -o|--output-dir)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 1; }
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --rebuild)
      REBUILD=1
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      print_usage >&2
      exit 1
      ;;
  esac
done

if [[ "${REBUILD}" -eq 1 ]]; then
  "${ROOT_DIR}/scripts/build.sh" --target "${TARGET}" --output "${INPUT}"
fi

if [[ ! -f "${INPUT}" ]]; then
  echo "Input .prg not found: ${INPUT}" >&2
  echo "Run ./scripts/build.sh first or use --rebuild." >&2
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"
cp -f "${INPUT}" "${OUTPUT_DIR}/${OUTPUT_NAME}"

echo "Packaged artifact: ${OUTPUT_DIR}/${OUTPUT_NAME}"
