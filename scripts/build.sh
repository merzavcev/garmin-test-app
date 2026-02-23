#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${ROOT_DIR}/manifest.xml"
JUNGLE="${ROOT_DIR}/monkey.jungle"
SOURCE_DIR="${ROOT_DIR}/source"
RESOURCES_DIR="${ROOT_DIR}/resources"
TARGET="${CIQ_TARGET:-vivoactive6}"
OUTPUT="${ROOT_DIR}/build/HelloGarmin.prg"

print_usage() {
  cat <<USAGE
Usage: $(basename "$0") [options]

Build and sign Connect IQ app with monkeyc.

Options:
  -t, --target <device>   Target device/product (default: vivoactive6 or CIQ_TARGET)
  -o, --output <file>     Output .prg path (default: build/HelloGarmin.prg)
      --unsigned          Build without signing key (debug builds)
  -h, --help              Show this help message

Required environment:
  CIQ_SDK_HOME            Path to Connect IQ SDK root
Optional environment:
  CIQ_DEVELOPER_KEY       Path to developer signing key (required unless --unsigned)
USAGE
}

UNSIGNED=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 1; }
      TARGET="$2"
      shift 2
      ;;
    -o|--output)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 1; }
      OUTPUT="$2"
      shift 2
      ;;
    --unsigned)
      UNSIGNED=1
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

: "${CIQ_SDK_HOME:?CIQ_SDK_HOME is not set. Please export path to Connect IQ SDK.}"
MONKEYC_BIN="${CIQ_SDK_HOME}/bin/monkeyc"

if [[ ! -x "${MONKEYC_BIN}" ]]; then
  echo "monkeyc not found or not executable: ${MONKEYC_BIN}" >&2
  exit 1
fi

for required_path in "${MANIFEST}" "${SOURCE_DIR}" "${RESOURCES_DIR}"; do
  if [[ ! -e "${required_path}" ]]; then
    echo "Required input missing: ${required_path}" >&2
    exit 1
  fi
done

mkdir -p "$(dirname "${OUTPUT}")"

cmd=("${MONKEYC_BIN}" -f "${JUNGLE}" -o "${OUTPUT}" -d "${TARGET}")

if [[ "${UNSIGNED}" -eq 0 ]]; then
  : "${CIQ_DEVELOPER_KEY:?CIQ_DEVELOPER_KEY is not set. Please export path to developer key.}"
  if [[ ! -f "${CIQ_DEVELOPER_KEY}" ]]; then
    echo "Developer key file not found: ${CIQ_DEVELOPER_KEY}" >&2
    exit 1
  fi
  cmd+=( -y "${CIQ_DEVELOPER_KEY}" )
fi

"${cmd[@]}"

if [[ "${UNSIGNED}" -eq 1 ]]; then
  echo "Build completed (unsigned): ${OUTPUT} (target: ${TARGET})"
else
  echo "Build completed (signed): ${OUTPUT} (target: ${TARGET})"
fi
