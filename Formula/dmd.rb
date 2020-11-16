class Dmd < Formula
  desc "D programming language compiler for macOS"
  homepage "https://dlang.org/"
  license "BSL-1.0"

  stable do
    url "https://github.com/dlang/dmd/archive/v2.094.1.tar.gz"
    sha256 "63271e939dbe5c39e866074b97f53c515c2b9161fcae9bae1df3b38924b0098d"

    resource "druntime" do
      url "https://github.com/dlang/druntime/archive/v2.094.1.tar.gz"
      sha256 "4bd91e438996363ec62f0b72392fa88f9d53ee73c51bea1c3be1ae97bd28d30c"
    end

    resource "phobos" do
      url "https://github.com/dlang/phobos/archive/v2.094.1.tar.gz"
      sha256 "e84536c538f47247d4803a9d2163f32e4b1e03acac090fa195a77083147c556f"
    end

    resource "tools" do
      url "https://github.com/dlang/tools/archive/v2.094.1.tar.gz"
      sha256 "5cf52d884b2951de9f27b9a6429133b9f60d103599349b49717d9172d6e97dfa"
    end
  end

  bottle do
    rebuild 1
    sha256 "d3e2451ad512f6201db49c6a0cca0a78ed4f0651a2169acf6dae0bba0328130b" => :big_sur
    sha256 "093076f19bfb6318241800aff24c6ba78a743e4ea28b13454d375b79de7da71f" => :catalina
    sha256 "e3fd5e418d448bebcead72a1f4cc0dea9edbeb2615be05561e821a3ee7ffca26" => :mojave
    sha256 "07b2d68d37fb32f0f4409a840a92fa084ec3623e5ebca5b54c4e0df589e44b28" => :high_sierra
  end

  head do
    url "https://github.com/dlang/dmd.git"

    resource "druntime" do
      url "https://github.com/dlang/druntime.git"
    end

    resource "phobos" do
      url "https://github.com/dlang/phobos.git"
    end

    resource "tools" do
      url "https://github.com/dlang/tools.git"
    end
  end

  uses_from_macos "unzip" => :build
  uses_from_macos "xz" => :build

  def install
    # DMD defaults to v2.088.0 to bootstrap as of DMD 2.090.0
    # On MacOS Catalina, a version < 2.087.1 would not work due to TLS related symbols missing

    make_args = %W[
      INSTALL_DIR=#{prefix}
      MODEL=64
      BUILD=release
      -f posix.mak
    ]

    dmd_make_args = %W[
      SYSCONFDIR=#{etc}
      TARGET_CPU=X86
      AUTO_BOOTSTRAP=1
      ENABLE_RELEASE=1
    ]

    system "make", *dmd_make_args, *make_args

    make_args.unshift "DMD_DIR=#{buildpath}", "DRUNTIME_PATH=#{buildpath}/druntime", "PHOBOS_PATH=#{buildpath}/phobos"

    (buildpath/"druntime").install resource("druntime")
    system "make", "-C", "druntime", *make_args

    (buildpath/"phobos").install resource("phobos")
    system "make", "-C", "phobos", "VERSION=#{buildpath}/VERSION", *make_args

    resource("tools").stage do
      inreplace "posix.mak", "install: $(TOOLS) $(CURL_TOOLS)", "install: $(TOOLS) $(ROOT)/dustmite"
      system "make", "install", *make_args
    end

    on_macos do
      bin.install "generated/osx/release/64/dmd"
    end
    on_linux do
      bin.install "generated/linux/release/64/dmd"
    end
    pkgshare.install "samples"
    man.install Dir["docs/man/*"]

    (include/"dlang/dmd").install Dir["druntime/import/*"]
    cp_r ["phobos/std", "phobos/etc"], include/"dlang/dmd"
    lib.install Dir["druntime/**/libdruntime.*", "phobos/**/libphobos2.*"]

    (buildpath/"dmd.conf").write <<~EOS
      [Environment]
      DFLAGS=-I#{opt_include}/dlang/dmd -L-L#{opt_lib}
    EOS
    etc.install "dmd.conf"
  end

  # Previous versions of this formula may have left in place an incorrect
  # dmd.conf.  If it differs from the newly generated one, move it out of place
  # and warn the user.
  def install_new_dmd_conf
    conf = etc/"dmd.conf"

    # If the new file differs from conf, etc.install drops it here:
    new_conf = etc/"dmd.conf.default"
    # Else, we're already using the latest version:
    return unless new_conf.exist?

    backup = etc/"dmd.conf.old"
    opoo "An old dmd.conf was found and will be moved to #{backup}."
    mv conf, backup
    mv new_conf, conf
  end

  def post_install
    install_new_dmd_conf
  end

  test do
    system bin/"dmd", pkgshare/"samples/hello.d"
    system "./hello"
  end
end
