#!/usr/bin/env bash
set -euo pipefail

crossplane_bin="${CROSSPLANE_BIN:-./crossplane}"
if [ ! -x "$crossplane_bin" ]; then
	crossplane_bin="$(command -v crossplane)"
fi

configuration_from_upbound() {
	local api_dir="$1"
	local output_file="${api_dir}/configuration.yaml"

	mkdir -p "$api_dir"

	python3 - upbound.yaml "$output_file" <<'PY'
import re
import sys
import tempfile

try:
    import yaml
except Exception:
    target = f"{tempfile.gettempdir()}/aws-crossplane-stack-pyyaml"
    sys.path.insert(0, target)
    try:
        import yaml
    except Exception:
        import subprocess
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--quiet", "--target", target, "PyYAML"]
        )
        import yaml

in_file, out_file = sys.argv[1], sys.argv[2]

with open(in_file, "r", encoding="utf-8") as f:
    project = yaml.safe_load(f) or {}

metadata = project.get("metadata") or {}
spec = project.get("spec") or {}

name = metadata.get("name")
if not name:
    raise SystemExit("upbound.yaml is missing metadata.name")

maintainer = spec.get("maintainer", "")
if isinstance(maintainer, str):
    maintainer = re.sub(r"\s*<[^>]+>\s*$", "", maintainer).strip()

annotations = {
    "meta.crossplane.io/maintainer": maintainer,
    "meta.crossplane.io/source": spec.get("source", ""),
    "meta.crossplane.io/description": spec.get("description", ""),
}

depends_on = []
for dep in spec.get("dependsOn") or []:
    if not isinstance(dep, dict):
        continue

    kind = str(dep.get("kind", "")).strip().lower()
    package = dep.get("package")
    version = dep.get("version")
    if not package:
        continue

    if kind == "provider":
        item = {"provider": package}
    elif kind == "function":
        item = {"function": package}
    elif kind == "configuration":
        item = {"configuration": package}
    else:
        continue

    if version is not None:
        item["version"] = version
    depends_on.append(item)

output = {
    "apiVersion": "meta.pkg.crossplane.io/v1alpha1",
    "kind": "Configuration",
    "metadata": {
        "name": name,
        "annotations": {k: v for k, v in annotations.items() if v},
    },
    "spec": {
        "dependsOn": depends_on,
    },
}

with open(out_file, "w", encoding="utf-8") as f:
    yaml.safe_dump(output, f, sort_keys=False)

print(f"Wrote {out_file}")
PY
}

render_with_retry() {
	local attempt=1
	local max_attempts="${RENDER_RETRIES:-3}"
	local retry_delay="${RENDER_RETRY_DELAY_SECONDS:-5}"
	local status=0
	local output

	output="$(mktemp)"
	while true; do
		if up composition render "$@" >"$output"; then
			cat "$output"
			rm -f "$output"
			return 0
		fi

		status=$?
		rm -f "$output"
		if [ "$attempt" -ge "$max_attempts" ]; then
			return "$status"
		fi

		echo "Render attempt ${attempt}/${max_attempts} failed; retrying in ${retry_delay}s..." >&2
		sleep "$retry_delay"
		attempt=$((attempt + 1))
		output="$(mktemp)"
	done
}

while IFS= read -r entry; do
	[ -n "$entry" ] || continue

	example="${entry%%::*}"
	observed="${entry#*::}"
	api_dir="$(awk -F/ '{print "apis/" $2}' <<<"$example")"
	composition="${api_dir}/composition.yaml"
	definition="${api_dir}/definition.yaml"
	render_args=(--xrd="$definition" "$composition" "$example")

	if [ -n "$observed" ]; then
		render_args+=(--observed-resources="$observed")
	fi

	echo "=== Validating ${example} (api=${api_dir}) ==="
	configuration_from_upbound "$api_dir"

	render_with_retry "${render_args[@]}" --quiet >/dev/null

	"$crossplane_bin" beta validate "$example" "$api_dir"

	render_with_retry \
		"${render_args[@]}" \
		--include-full-xr \
		--quiet \
		| "$crossplane_bin" beta validate "$api_dir" --error-on-missing-schemas -

	echo ""
done < <(make --no-print-directory print-examples)
