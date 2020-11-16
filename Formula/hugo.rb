class Hugo < Formula
  desc "Configurable static site generator"
  homepage "https://gohugo.io/"
  url "https://github.com/gohugoio/hugo/archive/v0.78.2.tar.gz"
  sha256 "bbfacf3bf379911bc348e6300912838fd07a75ad6de6d41082c54226e0055029"
  license "Apache-2.0"
  head "https://github.com/gohugoio/hugo.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "5bee3cbeb5edff56c69fac4c199ed36baebb2725242b8f56c1349b846174b802" => :big_sur
    sha256 "5570d90b9105217c01ca2122eb356ad567288e29a1b6c538e143bb9d8ff4e622" => :catalina
    sha256 "9e96a53d7a2278e57d8eb148bfaf2c2866a817fac92d5020744d1293d3f1c57c" => :mojave
    sha256 "d0268bc16fe927844a7f95cb9754c8d129784446a5f8f882a151fd9f0a2c8522" => :high_sierra
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = HOMEBREW_CACHE/"go_cache"
    (buildpath/"src/github.com/gohugoio/hugo").install buildpath.children

    cd "src/github.com/gohugoio/hugo" do
      system "go", "build", "-o", bin/"hugo", "-tags", "extended", "main.go"

      # Build bash completion
      system bin/"hugo", "gen", "autocomplete", "--completionfile=hugo.sh"
      bash_completion.install "hugo.sh"

      # Build man pages; target dir man/ is hardcoded :(
      (Pathname.pwd/"man").mkpath
      system bin/"hugo", "gen", "man"
      man1.install Dir["man/*.1"]

      prefix.install_metafiles
    end
  end

  test do
    site = testpath/"hops-yeast-malt-water"
    system "#{bin}/hugo", "new", "site", site
    assert_predicate testpath/"#{site}/config.toml", :exist?
  end
end
