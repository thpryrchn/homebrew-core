class Suil < Formula
  desc "Lightweight C library for loading and wrapping LV2 plugin UIs"
  homepage "https://drobilla.net/software/suil/"
  url "https://download.drobilla.net/suil-0.10.8.tar.bz2"
  sha256 "91cd87e17e80d2e43d64700369b93a5c2d0f1648e36411e0233253a0c3840f40"
  license "ISC"

  bottle do
    sha256 "aea75cb3be00abce7094eed0be51b10ce8fd5d7ac8bd3514989dfa5e9e209880" => :big_sur
    sha256 "24627d37fb66084ea3c0577d2dac5df714611004fb5c8cd9fddf747005eaa5be" => :catalina
    sha256 "f84ea1b5e7a2b786e5f989093d72b2c7270218ef637b30a60df73e0ee7a517fb" => :mojave
    sha256 "9b197d98140760bbb1293b90674941a0b3d5614c9a7f8353bd5ff64c23f0cd3f" => :high_sierra
  end

  depends_on "pkg-config" => :build
  depends_on "gtk+"
  depends_on "lv2"

  def install
    system "./waf", "configure", "--prefix=#{prefix}"
    system "./waf", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <suil/suil.h>

      int main()
      {
        return suil_ui_supported("my-host", "my-ui");
      }
    EOS
    lv2 = Formula["lv2"].opt_include
    system ENV.cc, "-I#{lv2}", "-I#{include}/suil-0", "-L#{lib}", "-lsuil-0", "test.c", "-o", "test"
    system "./test"
  end
end
