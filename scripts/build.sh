#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${ROOT_DIR}/manifest.xml"
SOURCE_DIR="${ROOT_DIR}/source"
RESOURCES_DIR="${ROOT_DIR}/resources"
OUTPUT="${ROOT_DIR}/build/HelloGarmin.prg"
TARGET="vivoactive6"

print_usage() {
  cat <<USAGE
Usage: $(basename "$0") [options]

Build Connect IQ app with monkeyc.

Options:
  -t, --target <device>   Target device/product (default: vivoactive6)
  -o, --output <file>     Output .prg path (default: build/HelloGarmin.prg)
  -h, --help              Show this help message

Required environment:
  CIQ_SDK_HOME            Path to Connect IQ SDK root
  CIQ_DEVELOPER_KEY       Path to developer signing key
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target)
      TARGET="$2"
      shift 2
      ;;
    -o|--output)
      OUTPUT="$2"
      shift 2
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
: "${CIQ_DEVELOPER_KEY:?CIQ_DEVELOPER_KEY is not set. Please export path to developer key.}"

MONKEYC_BIN="${CIQ_SDK_HOME}/bin/monkeyc"

if [[ ! -x "${MONKEYC_BIN}" ]]; then
  echo "monkeyc not found or not executable: ${MONKEYC_BIN}" >&2
  exit 1
fi

if [[ ! -f "${CIQ_DEVELOPER_KEY}" ]]; then
  echo "Developer key file not found: ${CIQ_DEVELOPER_KEY}" >&2
  exit 1
fi

for required_path in "${MANIFEST}" "${SOURCE_DIR}" "${RESOURCES_DIR}"; do
  if [[ ! -e "${required_path}" ]]; then
    echo "Required input missing: ${required_path}" >&2
    exit 1
  fi
done

mkdir -p "$(dirname "${OUTPUT}")"

"${MONKEYC_BIN}" \
  -f "${MANIFEST}" \
  -o "${OUTPUT}" \
  -d "${TARGET}" \
  -y "${CIQ_DEVELOPER_KEY}"

echo "Build completed: ${OUTPUT} (target: ${TARGET})"
