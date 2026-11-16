# moss-recipes (IME dogfood)

Priority-100 moss packages for the COSMIC xx-im / IME stack.
GitHub Actions (ubuntu-latest + boulder from os-tools) builds `.stone`
packages and publishes an indexed repo to GitHub Pages (repo is public so
Pages works on the free plan).

CI only rebuilds recipes whose paths changed (or those passed to
`workflow_dispatch`); other stones are reused from the live Pages repo.

## Install on another AerynOS machine

```bash
sudo moss repo add ime https://rano-oss.github.io/moss-recipes/x86_64/stone.index -p 100
sudo moss sync -u
sudo moss install -y pinyinwl chewingwl cosmic-comp cosmic-applets cosmic-session
```

`pinyinwl-data` / `libchewing-data` install as rundeps.

### `input_method_map` registration

Each IME package drops a fragment and a moss **sys** trigger:

- `pinyinwl` → `/usr/share/cosmic/.../input_method_map.d/cn.ron`
- `chewingwl` → `/usr/share/cosmic/.../input_method_map.d/tw.ron`
- `/usr/bin/cosmic-ime-merge-map` rebuilds `input_method_map` from whatever
  fragments are installed (system default under `/usr/share/cosmic/...`, and
  any existing `~/.config/cosmic/com.system76.CosmicComp/v1/`)

Removing an IME removes its fragment; the next sync/trigger rewrite drops
that layout key. You still need matching xkb layouts (`cn` / `tw`).

`active_layout` is runtime state written by cosmic-comp when you switch
layouts — not something the IME packages install.

## Packages

| Package | Source |
|---------|--------|
| `pinyinwl` | `rano-oss/pinyinwl` (xx-im) + map fragment `cn` |
| `chewingwl` | `rano-oss/chewingwl` (xx-im) + map fragment `tw` |
| `pinyinwl-data` | lexicon tarball (rundep of pinyinwl) |
| `libchewing-data` | chewing tables tarball (rundep of chewingwl) |
| `cosmic-comp` | `rano-oss/cosmic-comp` `experimental/xx-im-preedit-start` |
| `cosmic-applets` | `rano-oss/cosmic-applets` `input-method-unstable-v3` |
| `cosmic-session` | `rano-oss/cosmic-session` `input-method-unstable-v3` |

Release numbers are `1000+` so they stay ahead of distro releases with the same version.

## Local builds (AerynOS)

```bash
just package pinyinwl          # build + publish one
just all                       # full stack into ~/.cache/local_repo/x86_64
just reapply                   # after a normal moss update pulled stock packages back
```

When upstream commits move, bump `ref:` / `release:` in the relevant `stone.yaml`
and push — only that recipe rebuilds in CI.
