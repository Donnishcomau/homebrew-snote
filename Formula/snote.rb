# PRIVATE DRAFT (#444): the formula of the tap Donnishcomau/homebrew-snote. It is copied to the tap only on the owner's go;
# the snote public export does not carry homebrew/. Bump: homebrew/BUMP.md (url, sha256 and version only, after the gate).
class Snote < Formula
  desc "Terminal client for Simplenote notes"
  homepage "https://github.com/donnishcomau/snote"
  url "https://github.com/donnishcomau/snote/releases/download/v0.2.12/snote-0.2.12.tar.gz"
  sha256 "f60cd0548302652a31cdbc8278ae30099a843769e53064f02d8efed4b4c80b0f"
  license "GPL-2.0-only"

  depends_on "node"

  on_macos do
    depends_on "flock"
  end

  def install
    libexec.install Dir["*"]
    (bin/"snote").write <<~SH
      #!/bin/bash
      exec /usr/bin/env -u NODE_OPTIONS "#{formula_opt_bin("node")}/node" "#{libexec}/cli.js" "$@"
    SH
  end

  test do
    assert_match "snote #{version}", shell_output("#{bin}/snote --version")
  end
end
