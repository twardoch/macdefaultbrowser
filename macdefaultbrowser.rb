# this_file: macdefaultbrowser.rb

class Macdefaultbrowser < Formula
  desc "Command-line tool to manage the default web browser on macOS"
  homepage "https://github.com/twardoch/macdefaultbrowser"
  url "https://github.com/twardoch/macdefaultbrowser/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  license "MIT"

  depends_on :macos
  depends_on xcode: ["13.0", :build]

  def install
    system "make", "build"
    bin.install "macdefaultbrowser"
  end

  test do
    # Test that the binary runs and lists browsers
    output = shell_output("#{bin}/macdefaultbrowser")
    assert_match(/safari|chrome|firefox/, output.downcase)
  end
end