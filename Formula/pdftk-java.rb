class PdftkJava < Formula
  desc "Port of pdftk in java"
  homepage "https://gitlab.com/pdftk-java/pdftk"
  url "https://gitlab.com/pdftk-java/pdftk/-/archive/v3.2.1/pdftk-v3.2.1.tar.gz"
  sha256 "16aacc54d5b3cd5da35e0d8e09a51bf4e5938f289cf32d09ef9225dda99041ed"
  license "GPL-2.0-or-later"
  revision 1
  head "https://gitlab.com/pdftk-java/pdftk.git"

  livecheck do
    url :head
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "f0e46fad9fca2e1f0f3031c365a0adbe642119cf7ad2fcd9236cbf12aef9d584" => :catalina
    sha256 "42b9233d31c2a91bdd3bff1e2e48bc4796d99878bf4ae0f0ff798d5f59b154c8" => :mojave
    sha256 "f4bbce8fdec9f897bac95e3a4006fe171f0d700bc832dd56243a39475e82789c" => :high_sierra
  end

  depends_on "gradle" => :build
  depends_on "openjdk@8"

  def install
    system "gradle", "shadowJar", "--no-daemon"
    libexec.install "build/libs/pdftk-all.jar"
    bin.write_jar_script libexec/"pdftk-all.jar", "pdftk", java_version: "1.8"
  end

  test do
    pdf = test_fixtures("test.pdf")
    output_path = testpath/"output.pdf"
    system bin/"pdftk", pdf, pdf, "cat", "output", output_path
    assert output_path.read.start_with?("%PDF")
  end
end
