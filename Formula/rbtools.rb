class Rbtools < Formula
  include Language::Python::Virtualenv

  desc "CLI and API for working with code and document reviews on Review Board"
  homepage "https://www.reviewboard.org/downloads/rbtools/"
  url "https://files.pythonhosted.org/packages/04/98/10d5f67470c48e000cf9c95fb748f6a302eb01c0cb006d3ec37ff2f1e7c1/RBTools-1.0.3.tar.gz"
  sha256 "ff4cea3ad7b2d1b1666b811021cf5047f1fbe9417428fb5133a40ede81e3e83c"
  license "MIT"
  revision 1
  head "https://github.com/reviewboard/rbtools.git"

  livecheck do
    url :stable
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "6822bdaeada6203bd5a1a83088d0897fb3c4e87b44d821309e00de8208affc76" => :big_sur
    sha256 "0b12f736ad37628d1fb9c87c909985696a73518c9f7ff5377f48be9310ca399e" => :catalina
    sha256 "654a068175e2e29facbef092127b5848f3a4464fe1f2077cc08e0be1f3d93e5f" => :mojave
    sha256 "8982afb981edc037655be37cceaebd5a352f29b05e6385d8b67ce678f832c5bf" => :high_sierra
  end

  depends_on "python@3.9"

  resource "colorama" do
    url "https://files.pythonhosted.org/packages/76/53/e785891dce0e2f2b9f4b4ff5bc6062a53332ed28833c7afede841f46a5db/colorama-0.4.1.tar.gz"
    sha256 "05eed71e2e327246ad6b38c540c4a3117230b19679b875190486ddd2d721422d"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"
    sha256 "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"
  end

  resource "texttable" do
    url "https://files.pythonhosted.org/packages/04/c6/7d2514d76fefba65bfe2fa4e1082c3adea9edef5a149a3027b8f2d5ee0eb/texttable-1.6.1.tar.gz"
    sha256 "2b60a5304ccfbeac80ffae7350d7c2f5d7a24e9aab5036d0f82489746419d9b2"
  end

  resource "tqdm" do
    url "https://files.pythonhosted.org/packages/d0/0a/50a145091ce0c02db89d0342a59327c1ddeee206ef2991f09158d4e52406/tqdm-4.32.2.tar.gz"
    sha256 "25d4c0ea02a305a688e7e9c2cdc8f862f989ef2a4701ab28ee963295f5b109ab"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system "git", "init"
    system "#{bin}/rbt", "setup-repo", "--server", "https://demo.reviewboard.org"
    out = shell_output("#{bin}/rbt clear-cache")
    assert_match "Cleared cache in", out
  end
end
