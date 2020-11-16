class Act < Formula
  desc "Run your GitHub Actions locally 🚀"
  homepage "https://github.com/nektos/act"
  url "https://github.com/nektos/act/archive/v0.2.17.tar.gz"
  sha256 "124bfda32da78d38ba9d439a5671228fadb97c636092cdc9c911565bf2614c37"
  license "MIT"

  bottle do
    cellar :any_skip_relocation
    sha256 "2faa63c64245afacf70f1c61ae445a26571bfe7c190ee39169ab0d73b47cceda" => :big_sur
    sha256 "e91282fdbe17e8e559f99ac0e0d704ea541197587277428a21b9927cb30b009c" => :catalina
    sha256 "37e68207cd6dd80222e79501a2fc6870e0093b257c8b2700a428f91e4cefc834" => :mojave
    sha256 "259e716e51ba28f1b73f203acd3af2cd368789d41f83b000e7a8cf6b98c6e1ac" => :high_sierra
  end

  depends_on "go" => :build

  def install
    system "make", "build", "VERSION=#{version}"
    bin.install "dist/local/act"
  end

  test do
    system "git", "clone", "https://github.com/stefanzweifel/laravel-github-actions-demo.git"
    cd "laravel-github-actions-demo" do
      system "git", "checkout", "v2.0"

      pull_request_jobs = shell_output("#{bin}/act pull_request --list")
      assert_match "php-cs-fixer", pull_request_jobs

      push_jobs = shell_output("#{bin}/act push --list")
      assert_match "phpinsights", push_jobs
      assert_match "phpunit", push_jobs
    end
  end
end
