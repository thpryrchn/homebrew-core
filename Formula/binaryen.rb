class Binaryen < Formula
  desc "Compiler infrastructure and toolchain library for WebAssembly"
  homepage "https://webassembly.org/"
  url "https://github.com/WebAssembly/binaryen/archive/version_98.tar.gz"
  sha256 "9f805db6735869ab52cde7c0404879c90cf386888c0f587e944737550171c1c4"
  license "Apache-2.0"
  head "https://github.com/WebAssembly/binaryen.git"

  bottle do
    cellar :any
    sha256 "5d5ac79ec3aabebd8e62433c84bd0d61b0f4ee44d56e4c4f47475276a6428bd8" => :big_sur
    sha256 "260a8deac0c78a9fead982cf6d05fd818330bc4e28cdc73ecd5de6952ded6e8b" => :catalina
    sha256 "7a68230a62307fbd61638803e942e4d556f99b8e4d6fbbdd3dbaf6997b3b2843" => :mojave
    sha256 "4656a9b10a7db143e3619126ea1e0c169d05b06b27c7e75d5f641c86135c7b1f" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "python@3.9" => :build
  depends_on macos: :el_capitan # needs thread-local storage

  def install
    ENV.cxx11

    system "cmake", ".", *std_cmake_args
    system "make", "install"

    pkgshare.install "test/"
  end

  test do
    system "#{bin}/wasm-opt", "-O", "#{pkgshare}/test/passes/O.wast", "-o", "1.wast"
  end
end
