# this_file: macdefaultbrowser.rb
#
# Homebrew Formula for macdefaultbrowser
#
# To update the SHA256:
# 1. Create a new release on GitHub with tag vX.Y.Z
# 2. Download the source tarball: https://github.com/twardoch/macdefaultbrowser/archive/refs/tags/vX.Y.Z.tar.gz
# 3. Calculate SHA256: shasum -a 256 vX.Y.Z.tar.gz
# 4. Update the url and sha256 fields below
#
# To test locally:
# brew install --build-from-source macdefaultbrowser.rb
#
# To create a tap:
# 1. Create repo: homebrew-tap
# 2. Add this formula to: Formula/macdefaultbrowser.rb
# 3. Users can install with: brew tap twardoch/tap && brew install macdefaultbrowser

class Macdefaultbrowser < Formula
  desc "Command-line tool to manage the default web browser on macOS"
  homepage "https://github.com/twardoch/macdefaultbrowser"
  url "https://github.com/twardoch/macdefaultbrowser/archive/refs/tags/v1.2.1.tar.gz"
  sha256 "PLACEHOLDER_SHA256_RUN_shasum_-a_256_ON_TARBALL"
  license "MIT"
  head "https://github.com/twardoch/macdefaultbrowser.git", branch: "main"

  depends_on :macos
  depends_on xcode: ["13.0", :build]

  def install
    system "make", "build"
    bin.install "build/macdefaultbrowser"
  end

  test do
    # Test that the binary runs and lists browsers
    output = shell_output("#{bin}/macdefaultbrowser")
    assert_match(/safari|chrome|firefox/, output.downcase)
  end
end