class Zile < Formula
  desc "Text editor development kit"
  homepage "https://www.gnu.org/software/zile/"
  url "https://ftp.gnu.org/gnu/zile/zile-2.4.15.tar.gz"
  mirror "https://ftpmirror.gnu.org/zile/zile-2.4.15.tar.gz"
  sha256 "39c300a34f78c37ba67793cf74685935a15568e14237a3a66fda8fcf40e3035e"

  livecheck do
    url :stable
  end

  bottle do
    cellar :any
    sha256 "a968a290fab30518570f4b3b0c01c91014e421109d9b91ecbb4a42ee865aad69" => :big_sur
    sha256 "c87e1675d9eb1c34e66531c8dabdfb290acaff89c16649b57f0d225ae84fbf72" => :catalina
    sha256 "f153836d786658870d684374b310ce47a6658ad590bcaccc981c7a6b7c66947e" => :mojave
    sha256 "943f7ce5aba23fd916e4e89da5bae329471cafdd4261f13cd4bc6696d21bd4e6" => :high_sierra
  end

  depends_on "help2man" => :build
  depends_on "pkg-config" => :build
  depends_on "bdw-gc"

  uses_from_macos "ncurses"

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zile --version")
  end
end
