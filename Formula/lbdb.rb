class Lbdb < Formula
  desc "Little brother's database for the mutt mail reader"
  homepage "https://www.spinnaker.de/lbdb/"
  url "https://www.spinnaker.de/lbdb/download/lbdb_0.49.tar.gz"
  sha256 "f565b64a0bc8edb2a5a273e305d5cdecd9053d834fb96f6b2b2f353c99c3c887"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://www.spinnaker.de/lbdb/download/"
    regex(/href=.*?lbdb[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "9c79b0bbc8d13e16259bce83501a2d3f285f3ca2c6675f49cdb36a4ef4366fa1" => :catalina
    sha256 "71c3c794994b1ec594bdbbef70848c0e5bb43ab1f19e1edff7e0d17e9a2f9e98" => :mojave
    sha256 "03f4287b844059e3bc9787c97bc22b903a57067add3c3fe2913d2ca53537d34f" => :high_sierra
  end

  depends_on "abook"

  def install
    system "./configure", "--prefix=#{prefix}", "--libdir=#{lib}/lbdb"
    system "make", "install"
  end

  test do
    assert_match version.major_minor.to_s, shell_output("#{bin}/lbdbq -v")
  end
end
