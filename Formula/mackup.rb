class Mackup < Formula
  include Language::Python::Virtualenv

  desc "Keep your Mac's application settings in sync"
  homepage "https://github.com/lra/mackup"
  url "https://files.pythonhosted.org/packages/66/de/e2c0c5145046cd261b4564840ee7fef66a278fa11d5db082e5659535cdc1/mackup-0.8.29.tar.gz"
  sha256 "6918d9caba1c0e849f63f1868ce3c51e87d33ce0e5a5eb4266a553b6ac22871e"
  license "GPL-3.0"
  revision 1
  head "https://github.com/lra/mackup.git"

  livecheck do
    url :stable
  end

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "6b0b3e3a437afca62c19f6af8d1c0b1ebeb0ee14fd53bb63f3016fb08f9b117a" => :big_sur
    sha256 "8a4175d131fc7b0cbbaf7392bb1b8e991cedd1b0fe50491773b072e4f9df76db" => :catalina
    sha256 "69f1b05d7d304e78e581176fa497ac66a2afb068f913337575460dc5dad7b238" => :mojave
    sha256 "92b2c325f723586c3b1ed28ed313c5b8a0e2968cd594d1b184b497a87c06deab" => :high_sierra
  end

  depends_on "python@3.9"

  resource "docopt" do
    url "https://files.pythonhosted.org/packages/a2/55/8f8cab2afd404cf578136ef2cc5dfb50baa1761b68c9da1fb1e4eed343c9/docopt-0.6.2.tar.gz"
    sha256 "49b3a825280bd66b3aa83585ef59c4a8c82f2c8a522dbe754a8bc8d08c85c491"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/6b/34/415834bfdafca3c5f451532e8a8d9ba89a21c9743a0c59fbd0205c7f9426/six-1.15.0.tar.gz"
    sha256 "30639c035cdb23534cd4aa2dd52c3bf48f06e5f4a941509c8bafd8ce11080259"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system "#{bin}/mackup", "--help"
  end
end
