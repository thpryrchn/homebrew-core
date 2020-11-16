class Mgba < Formula
  desc "Game Boy Advance emulator"
  homepage "https://mgba.io/"
  url "https://github.com/mgba-emu/mgba/archive/0.8.4.tar.gz"
  sha256 "6b94873dac9040fd6fd9f13f76dc48f342e954f3b4cf82717b59601c3a32b72c"
  license "MPL-2.0"
  revision 1
  head "https://github.com/mgba-emu/mgba.git"

  livecheck do
    url "https://github.com/mgba-emu/mgba/releases/latest"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
  end

  bottle do
    sha256 "f691a03dc8505ed36f146d58a140573ffde40fd16086a01617b91a04f1fc085f" => :big_sur
    sha256 "bbee8886c0006db66d9dedb8c6215e5764554fe29c24aa19f41be72b35eefbe6" => :catalina
    sha256 "8acfbcc044e88e66422f0508fdfa79139fc5d9134656800997d5116bdc48a3c8" => :mojave
    sha256 "2c071d25f025b1db6cc61e2fb8909dce8119d9edcfa31bce13fe4ed50c686fc3" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "ffmpeg"
  depends_on "libepoxy"
  depends_on "libpng"
  depends_on "libzip"
  depends_on "qt"
  depends_on "sdl2"

  def install
    # Fix "error: 'future<void>' is unavailable: introduced in macOS 10.8"
    # Reported 11 Dec 2017 https://github.com/mgba-emu/mgba/issues/944
    ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version if MacOS.version <= :el_capitan

    # Install .app bundle into prefix, not prefix/Applications
    inreplace "src/platform/qt/CMakeLists.txt", "Applications", "."

    system "cmake", ".", *std_cmake_args
    system "make", "install"

    # Replace SDL frontend binary with a script for running Qt frontend
    # -DBUILD_SDL=OFF would be easier, but disable joystick support in Qt frontend
    rm bin/"mgba"
    bin.write_exec_script "#{prefix}/mGBA.app/Contents/MacOS/mGBA"
  end

  test do
    system "#{bin}/mGBA", "-h"
  end
end
