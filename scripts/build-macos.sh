#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dist_dir="${1:-$project_root/dist}"
release_name="PiliPala-1.0.25-macos.1-arm64"
temporary_dir=""
trap 'if [[ -n "$temporary_dir" ]]; then rm -rf -- "$temporary_dir"; fi' EXIT

if [[ "$(uname -s)" != Darwin || "$(uname -m)" != arm64 ]]; then
  echo "This build script targets Apple Silicon Macs." >&2
  exit 1
fi
command -v flutter >/dev/null
command -v pod >/dev/null
flutter_version="$(flutter --version --machine | python3 -c 'import json,sys; print(json.load(sys.stdin)["frameworkVersion"])')"
if [[ "$flutter_version" != 3.24.5 ]]; then
  echo "Use Flutter 3.24.5 (found $flutter_version)." >&2
  exit 1
fi

flutter_root="$(python3 -c 'import os,shutil; print(os.path.dirname(os.path.dirname(os.path.realpath(shutil.which("flutter")))))')"
flutter precache --macos

# Flutter 3.24.5 selects an Intel gen_snapshot even with the arm64 SDK.
# Use the official arm64 artifact from the EXACT SAME engine revision.
snapshot_path="$flutter_root/bin/cache/artifacts/engine/darwin-x64-release/gen_snapshot_arm64"
if ! lipo "$snapshot_path" -verify_arch arm64 >/dev/null 2>&1; then
  engine_revision="$(cat "$flutter_root/bin/internal/engine.version")"
  if [[ "$engine_revision" != a18df97ca57a249df5d8d68cd0820600223ce262 ]]; then
    echo "Unexpected Flutter engine revision; refusing to replace gen_snapshot." >&2
    exit 1
  fi
  temporary_dir="$(mktemp -d "${TMPDIR:-/tmp}/pilipala-native.XXXXXX")"
  native_archive="$temporary_dir/artifacts.zip"
  curl -fL --retry 3 \
    "https://storage.googleapis.com/flutter_infra_release/flutter/$engine_revision/darwin-arm64-release/artifacts.zip" \
    -o "$native_archive"
  printf '%s  %s\n' \
    e56194b76c8eab484af4a7dfb2e8fb6cb205a94543f9a87a3430c015978da143 \
    "$native_archive" | shasum -a 256 -c -
  ditto -xk "$native_archive" "$temporary_dir/native"
  install -m 755 "$temporary_dir/native/gen_snapshot" "$snapshot_path"
fi

cd "$project_root"
flutter pub get --enforce-lockfile
flutter build macos --release --no-pub
app_path="$project_root/build/macos/Build/Products/Release/PiliPala.app"
cp LICENSE "$app_path/Contents/Resources/PiliPala-COPYING.txt"
codesign --force --sign - --entitlements macos/Runner/Release.entitlements "$app_path"
codesign --verify --deep --strict "$app_path"
lipo "$app_path/Contents/MacOS/PiliPala" -verify_arch arm64

mkdir -p "$dist_dir"
dist_dir="$(cd "$dist_dir" && pwd)"
ditto -c -k --sequesterRsrc --keepParent "$app_path" "$dist_dir/$release_name.zip"

if [[ -z "$temporary_dir" ]]; then
  temporary_dir="$(mktemp -d "${TMPDIR:-/tmp}/pilipala-native.XXXXXX")"
fi
staging_dir="$temporary_dir/dmg"
mkdir -p "$staging_dir"
ditto "$app_path" "$staging_dir/PiliPala.app"
ln -s /Applications "$staging_dir/Applications"
cp LICENSE "$staging_dir/LICENSE.txt"
hdiutil create -volname PiliPala -srcfolder "$staging_dir" -ov -format UDZO \
  "$dist_dir/$release_name.dmg"
cd "$dist_dir"
shasum -a 256 "$release_name.zip" "$release_name.dmg" > SHA256SUMS.txt
echo "Created packages in $dist_dir"
