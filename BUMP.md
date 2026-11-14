# Bumping the snote formula (private draft, #444)

The formula in the tap `Donnishcomau/homebrew-snote` changes only as part of a release go, and only in three fields: `url`,
`sha256` and the version inside `url`. The new `sha256` never comes from a download or a copy of the release page.

1. Finish `docs/RELEASE-SIGNING.md` steps 1 to 7 and `docs/RELEASE-ASSETS.md` steps 1 to 4 for the release: the assets folder
   `/tmp/snote-public-assets/` then holds `snote-<version>.tar.gz` and the signed `ASSETS.SHA256SUMS`, and the last run of
   `scripts/release-gate.sh` was with the signature check on. Go on only when that run's output ends with
   `release-gate: OK for <version>` and does NOT contain `signature check skipped`: the gate has then verified
   `ASSETS.SHA256SUMS.sig` (`scripts/lib/release-trust.sh`) and that the tarball is exactly the files `SHA256SUMS` lists.
2. Copy `ASSETS.SHA256SUMS` and `ASSETS.SHA256SUMS.sig` from that `/tmp/snote-public-assets/` folder (the `<tree>-assets` folder
   of `SNOTE_RELEASE_TREE`, `/tmp/snote-public` by default) into a fresh folder `d=$(mktemp -d)`, and work only on that copy:
   another user can change files in the assets folder after the gate run. Verify the copy:
   `ssh-keygen -Y verify -f packaging/release/allowed_signers -I snote-release -n snote-release -s "$d/ASSETS.SHA256SUMS.sig" < "$d/ASSETS.SHA256SUMS"`
   must succeed, line 1 of the copy must be `snote-assets <version> <commit>` and line 2 must name `snote-<version>.tar.gz`.
   Take the hash only from line 2 of that verified copy, `<64 hex>  snote-<version>.tar.gz`. If anything ran in the assets
   folder after the gate run of step 1, run the gate again first. Never from the `release-asset:` line (it prints even when the
   signature check of the same gate run failed), never from the assets folder itself, never from a fresh `sha256sum`, and never
   after rerunning `release-asset.sh` without `--check`.
3. After the release asset is uploaded, download it from
   `https://github.com/donnishcomau/snote/releases/download/v<version>/snote-<version>.tar.gz` and run `sha256sum` on it: it must
   print the hash of step 2, read from the verified copy. If it differs, stop: do not bump.
4. In `Formula/snote.rb` set `url` to that address and `sha256` to the hash of step 2. Change nothing else. Keep
   `depends_on "node"`: never pin a versioned node formula (`node@22` is deprecated by Homebrew).
5. The tap CI (`brew style`, `brew audit --strict --new`, `brew install --build-from-source`, `brew test`) must pass on the
   bump's pull request before it merges. Pushing to the tap is an owner step.
