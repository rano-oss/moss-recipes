# Build / publish moss packages for the IME dogfood stack.
set quiet

boulder := env('BOULDER', 'boulder')
boulder_args := env('BOULDER_ARGS', '')
profile := env('BOULDER_PROFILE', 'local-x86_64')
local_repo := env('LOCAL_REPO', env('HOME') / '.cache/local_repo/x86_64')
recipes := "pinyinwl-data libchewing-data pinyinwl chewingwl cosmic-comp cosmic-applets cosmic-session"
pkgs := "pinyinwl chewingwl cosmic-comp cosmic-applets cosmic-session"

# Expand __RECIPE_DIR__ placeholders, then boulder-build one recipe
build name:
    #!/usr/bin/env bash
    set -euo pipefail
    dir="{{ justfile_directory() / name }}"
    cd "$dir"
    recipe=stone.yaml
    if grep -q '__RECIPE_DIR__' stone.yaml; then
      recipe="$(mktemp ./stone.XXXXXX.yaml)"
      sed "s|__RECIPE_DIR__|${dir}|g" stone.yaml > "$recipe"
      trap 'rm -f "$recipe"' EXIT
    fi
    {{ boulder }} {{ boulder_args }} build -y -u -p {{ profile }} "$recipe"

# Move built .stone files from a recipe dir into the local repo and reindex
publish name:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    mkdir -p "{{ local_repo }}"
    stones=({{ justfile_directory() / name }}/*.stone)
    if (( ${#stones[@]} == 0 )); then
      echo "no .stone files in {{ name }}" >&2
      exit 1
    fi
    mv -v "${stones[@]}" "{{ local_repo }}/"
    moss index -i "{{ local_repo }}"
    echo "published {{ name }} → {{ local_repo }}"

# Build + publish one package
package name: (build name) (publish name)

# Build + publish the full IME stack (data first, then apps, then cosmic)
all:
    #!/usr/bin/env bash
    set -euo pipefail
    for name in {{ recipes }}; do
      echo "=== packaging $name ==="
      just --justfile "{{ justfile }}" package "$name"
    done

# Reindex local repo only
index:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "{{ local_repo }}"
    moss index -i "{{ local_repo }}"

# List stones in the local repo
ls-local:
    ls -lah "{{ local_repo }}"

# After upstream moss updates: re-sync so local priority-100 stones win
reapply:
    #!/usr/bin/env bash
    set -euo pipefail
    sudo moss repo update
    sudo moss pkg add {{ pkgs }}
    sudo moss sync -uy
    moss pkg list -i | rg 'pinyinwl|chewingwl|cosmic-comp|cosmic-session|cosmic-applets|libchewing-data|pinyinwl-data'
