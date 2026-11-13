#!/usr/bin/env bash
# Preserve installed clients' old Pages URLs without recreating the renamed Git repo.
set -euo pipefail
canonical=https://dixonsolutions.github.io/Godnotic
source_url=${SOURCE_URL:-$canonical}
out=${1:-site}
mkdir -p "$out/Xonotic-Touch/flatpak" "$out/Xonotic-Touch/click"
ostree init --repo="$out/Xonotic-Touch/flatpak" --mode=archive-z2
flatpak build-update-repo --redirect-url="$canonical/flatpak" --title=Godnotic "$out/Xonotic-Touch/flatpak"
curl -fsSL --retry 3 "$source_url/click/latest.json" -o "$out/Xonotic-Touch/click/latest.json"
python3 - "$out/Xonotic-Touch/click/latest.json" <<'PY'
import json,sys
p=sys.argv[1]
v=json.load(open(p))
for group in ('packages','versioned'):
    for key,url in v.get(group,{}).items():
        v[group][key]=url.replace('/Xonotic-Touch/','/Godnotic/')
with open(p,'w') as f:json.dump(v,f,indent=2)
PY
for abi in arm64 armhf; do
    curl -fsSL --retry 3 "$source_url/click/latest-$abi.click" -o "$out/Xonotic-Touch/click/latest-$abi.click"
done
curl -fsSL --retry 3 "$source_url/changelog.txt" -o "$out/Xonotic-Touch/changelog.txt"
for directory in "$out" "$out/Xonotic-Touch" "$out/Xonotic-Touch/click"; do
    printf '<!doctype html><html lang="en"><meta charset="utf-8"><meta http-equiv="refresh" content="0;url=%s/"><title>Godnotic</title><a href="%s/">Godnotic</a></html>\n' "$canonical" "$canonical" > "$directory/index.html"
done
mkdir -p "$out/Xonotic-Touch/web"
printf '<!doctype html><meta http-equiv="refresh" content="0;url=https://godnotic.vercel.app"><title>Godnotic</title><a href="https://godnotic.vercel.app">Play Godnotic</a>\n' > "$out/Xonotic-Touch/web/index.html"
touch "$out/.nojekyll"
