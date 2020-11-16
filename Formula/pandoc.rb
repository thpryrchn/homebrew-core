class Pandoc < Formula
  desc "Swiss-army knife of markup format conversion"
  homepage "https://pandoc.org/"
  url "https://hackage.haskell.org/package/pandoc-2.11.1.1/pandoc-2.11.1.1.tar.gz"
  sha256 "6864116101e725967d19b5328f9e73abf2b82ec379dc61ad8a0b63e7349d2644"
  license "GPL-2.0"
  head "https://github.com/jgm/pandoc.git"

  livecheck do
    url :stable
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "7cdcf09a97ea9156a2450f67f597099b31f6e9826d4e3cbcd1312871f05964f9" => :catalina
    sha256 "5365310e20e9caa6f14f2c884c9a05348568d96398cd05b5c497ca65e2106a53" => :mojave
    sha256 "383bbdec7227f3c0a07b193d2ff00915c654e8d3bce59528f2450ec6a4d18d60" => :high_sierra
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build

  uses_from_macos "unzip" => :build # for cabal install
  uses_from_macos "zlib"

  def install
    system "cabal", "v2-update"
    system "cabal", "v2-install", *std_cabal_v2_args
    (bash_completion/"pandoc").write `#{bin}/pandoc --bash-completion`
    man1.install "man/pandoc.1"
  end

  test do
    input_markdown = <<~EOS
      # Homebrew

      A package manager for humans. Cats should take a look at Tigerbrew.
    EOS
    expected_html = <<~EOS
      <h1 id="homebrew">Homebrew</h1>
      <p>A package manager for humans. Cats should take a look at Tigerbrew.</p>
    EOS
    assert_equal expected_html, pipe_output("#{bin}/pandoc -f markdown -t html5", input_markdown)
  end
end
