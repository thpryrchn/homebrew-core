class Volk < Formula
  include Language::Python::Virtualenv

  desc "Vector Optimized Library of Kernels"
  homepage "https://libvolk.org"
  url "https://github.com/gnuradio/volk/releases/download/v2.3.0/volk-2.3.0.tar.xz"
  sha256 "40645886d713ed23295d7fb3e69734b5173a22259886b1a4abdad229a44123b9"
  license "GPL-3.0-or-later"
  revision 1

  bottle do
    sha256 "b7441460759ea94e1045325beb3d62e5d97e4d11bc80e60ace2242b225b13496" => :big_sur
    sha256 "863d6958c08b8f7bbe556c6435f086d7b8175eef7cc78c9f86abb78d27a6f493" => :catalina
    sha256 "f46852e225b61a10b6c36962298f88f6b17f707426f10052454ff8e497300ac9" => :mojave
    sha256 "cb355f044c6a69ef69f0375c57d2bf22ecd723dc1189a10cefd1466e5a0ee0d4" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "orc"
  depends_on "python@3.9"

  resource "Mako" do
    url "https://files.pythonhosted.org/packages/72/89/402d2b4589e120ca76a6aed8fee906a0f5ae204b50e455edd36eda6e778d/Mako-1.1.3.tar.gz"
    sha256 "8195c8c1400ceb53496064314c6736719c6f25e7479cd24c77be3d9361cddc27"
  end

  def install
    # Set up Mako
    venv_root = libexec/"venv"
    xy = Language::Python.major_minor_version "python3"
    ENV.prepend_create_path "PYTHONPATH", "#{venv_root}/lib/python#{xy}/site-packages"
    venv = virtualenv_create(venv_root, "python3")
    venv.pip_install resource("Mako")

    # Avoid references to the Homebrew shims directory
    inreplace "lib/CMakeLists.txt" do |s|
      s.gsub! "${CMAKE_C_COMPILER}", ENV.cc
      s.gsub! "${CMAKE_CXX_COMPILER}", ENV.cxx
    end

    args = %W[-DPYTHON_EXECUTABLE=#{venv_root}/bin/python -DENABLE_TESTING=OFF]
    system "cmake", ".", *std_cmake_args, *args
    system "make", "install"

    # Set up volk_modtool paths
    site_packages = lib/"python#{xy}/site-packages"
    pth_contents = "import site; site.addsitedir('#{site_packages}')\n"
    (venv_root/"lib/python#{xy}/site-packages/homebrew-volk.pth").write pth_contents
  end

  test do
    system "volk_modtool", "--help"
    system "volk_profile", "--iter", "10"
  end
end
