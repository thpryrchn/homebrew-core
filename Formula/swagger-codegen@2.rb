class SwaggerCodegenAT2 < Formula
  desc "Generate clients, server stubs, and docs from an OpenAPI spec"
  homepage "https://swagger.io/swagger-codegen/"
  url "https://github.com/swagger-api/swagger-codegen/archive/v2.4.17.tar.gz"
  sha256 "8dbcd9311b22ca0aa16094fd616e6e6053ee081f06f26a1ae97df5b8e25dbb31"
  license "Apache-2.0"
  revision 1

  livecheck do
    url "https://github.com/swagger-api/swagger-codegen.git"
    regex(/^v?(2(?:\.\d+)+)$/i)
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "86fd64b89489cfb4a376aa5f37927d39a31c62822927dd111b690905b943aee8" => :catalina
    sha256 "a8d0a5b33d8e4fd77b2cfe7a1d606b32ceb63cba16116bda17c7222561278757" => :mojave
    sha256 "516a29728d07daae99423110c23082ceddef8638bd83d91721e80a42eb0af340" => :high_sierra
  end

  keg_only :versioned_formula

  depends_on "maven" => :build
  depends_on "openjdk@8"

  def install
    ENV["JAVA_HOME"] = Language::Java.java_home("1.8")

    system "mvn", "clean", "package"
    libexec.install "modules/swagger-codegen-cli/target/swagger-codegen-cli.jar"
    bin.write_jar_script libexec/"swagger-codegen-cli.jar", "swagger-codegen", java_version: "1.8"
  end

  test do
    (testpath/"minimal.yaml").write <<~EOS
      ---
      swagger: '2.0'
      info:
        version: 0.0.0
        title: Simple API
      paths:
        /:
          get:
            responses:
              200:
                description: OK
    EOS
    system "#{bin}/swagger-codegen", "generate", "-i", "minimal.yaml", "-l", "html2"
    assert_includes File.read(testpath/"index.html"), "<h1>Simple API</h1>"
  end
end
