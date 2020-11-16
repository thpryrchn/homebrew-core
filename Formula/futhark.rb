class Futhark < Formula
  desc "Data-parallel functional programming language"
  homepage "https://futhark-lang.org/"
  url "https://github.com/diku-dk/futhark/archive/v0.18.3.tar.gz"
  sha256 "670c9fa4264f68df22a7fe30e4f5710235eeb30cbebb6b34751347264165d4fd"
  license "ISC"
  head "https://github.com/diku-dk/futhark.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "9c4c6c21b0b7d249f1b44beea41427a27f5d720d38c7788ecbc170f7bc6790d7" => :catalina
    sha256 "e98560b37baf37d00592b98dab0176f940c0948c0f34008d306007f227c78939" => :mojave
    sha256 "e1afafc5d6b899124a2cdef9f70b7f498e5fbf56fc93751855ed8f340d58fc0f" => :high_sierra
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "sphinx-doc" => :build

  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  def install
    system "cabal", "v2-update"
    system "cabal", "v2-install", *std_cabal_v2_args

    system "make", "-C", "docs", "man"
    man1.install Dir["docs/_build/man/*.1"]
  end

  test do
    (testpath/"test.fut").write <<~EOS
      let main (n: i32) = reduce (*) 1 (1...n)
    EOS
    system "#{bin}/futhark", "c", "test.fut"
    assert_equal "3628800i32", pipe_output("./test", "10", 0).chomp
  end
end
