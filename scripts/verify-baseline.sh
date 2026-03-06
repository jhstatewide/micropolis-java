#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="micropolis-baseline:jdk17"
DOCKERFILE_PATH="docker/baseline.Dockerfile"
FORCE_REBUILD=0

usage() {
	cat <<'USAGE'
Usage: ./scripts/verify-baseline.sh [--rebuild]

Runs the local Ant baseline verification in Docker (JDK 17).

Options:
  --rebuild   Force rebuild of the Docker image before running.
USAGE
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
	usage
	exit 0
fi

if [[ "${1:-}" == "--rebuild" ]]; then
	FORCE_REBUILD=1
	shift
fi

if [[ $# -ne 0 ]]; then
	usage
	exit 2
fi

if ! command -v docker >/dev/null 2>&1; then
	echo "FAIL: docker is required but not installed or not on PATH." >&2
	exit 1
fi

if [[ ! -f "$DOCKERFILE_PATH" ]]; then
	echo "FAIL: missing Dockerfile at $DOCKERFILE_PATH" >&2
	exit 1
fi

if [[ "$FORCE_REBUILD" -eq 1 ]]; then
	echo "[setup] Rebuilding Docker image: $IMAGE_TAG"
	docker build -f "$DOCKERFILE_PATH" -t "$IMAGE_TAG" .
elif ! docker image inspect "$IMAGE_TAG" >/dev/null 2>&1; then
	echo "[setup] Building Docker image: $IMAGE_TAG"
	docker build -f "$DOCKERFILE_PATH" -t "$IMAGE_TAG" .
else
	echo "[setup] Using cached Docker image: $IMAGE_TAG"
fi

echo "[run] Starting baseline verification in Docker"

docker run --rm \
	-v "$PWD:/workspace" \
	-w /workspace \
	-e LANG=C.UTF-8 \
	-e LC_ALL=C.UTF-8 \
	-e TZ=UTC \
	-e JAVA_TOOL_OPTIONS=-Djava.awt.headless=true \
	"$IMAGE_TAG" \
	bash -lc '
	set -euo pipefail

	echo "[1/6] Toolchain"
	java -version 2>&1 | grep -q "version \"17\."

	echo "[2/6] Build"
	ant clean build

	echo "[3/6] Artifacts"
	test -f micropolisj.jar
	test -d build/16x16
	test -d build/8x8
	test -d build/32x32
	test -d build/sm
	test -f build/tiles/aliases.txt
	test -f build/tiles.rc

	echo "[4/6] Manifest"
	mf_dir="$(mktemp -d)"
	trap "rm -rf \"$mf_dir\"" EXIT
	(
		cd "$mf_dir"
		jar xf /workspace/micropolisj.jar META-INF/MANIFEST.MF
	)
	tr -d "\r" < "$mf_dir/META-INF/MANIFEST.MF" | grep -q "^Main-Class: micropolisj.Main$"

	echo "[5/6] Resources"
	test -d build/micropolisj
	test -f build/micropolism.png
	test -f build/micropolisj/CityMessages_fr.properties

	echo "[6/6] Smoke"
	java -cp build micropolisj.verify.EngineSmokeCheck

	echo "PASS: baseline verified in Docker (JDK 17)."
'
