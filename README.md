# moss-recipes (IME dogfood)

Priority-100 moss packages for the COSMIC xx-im / IME stack.
GitHub Actions (ubuntu-latest + boulder from os-tools) builds `.stone`
packages and publishes an indexed repo to GitHub Pages (repo is public so
Pages works on the free plan).

## Install on another AerynOS machine

```bash
sudo moss repo add ime https://rano-oss.github.io/moss-recipes/x86_64/stone.index -p 100
sudo moss sync -u
sudo moss install -y pinyinwl chewingwl cosmic-comp cosmic-applets cosmic-session
```

`pinyinwl-data` and `libchewing-data` install automatically as rundeps.

Priority **100** overrides stock `unstable` / `volatile` packages with the same names.

## Packages

| Package | Source |
|---------|--------|
| `pinyinwl` | `rano-oss/pinyinwl` (xx-im) |
| `chewingwl` | `rano-oss/chewingwl` (xx-im) |
| `pinyinwl-data` | lexicon tarball (rundep of pinyinwl) |
| `libchewing-data` | chewing tables tarball (rundep of chewingwl) |
| `cosmic-comp` | `rano-oss/cosmic-comp` `experimental/xx-im-preedit-start` |
| `cosmic-applets` | `rano-oss/cosmic-applets` `input-method-unstable-v3` |
| `cosmic-session` | `rano-oss/cosmic-session` `input-method-unstable-v3` (launches IMEs via `wp_security_context`) |

Release numbers are `1000+` so they stay ahead of distro releases with the same version.

## Local builds (AerynOS)

```bash
# one-time: boulder profile local-x86_64 with local repo @ priority 100
just package pinyinwl          # build + publish one
just all                       # full stack into ~/.cache/local_repo/x86_64
just reapply                   # after a normal moss update pulled stock packages back
```

When upstream commits move, bump `ref:` / `release:` in the relevant `stone.yaml`,
push, and let CI republish — or `just package <name>` locally.

## CI

Workflow [`.github/workflows/build.yml`](.github/workflows/build.yml) runs on
`ubuntu-latest`, installs moss/boulder from [AerynOS/os-tools](https://github.com/AerynOS/os-tools),
builds all recipes, indexes `repo/x86_64/`, and deploys to GitHub Pages.
