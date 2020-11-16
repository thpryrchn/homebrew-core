class TreeSitter < Formula
  desc "Parser generator tool and incremental parsing library"
  homepage "https://tree-sitter.github.io/"
  url "https://github.com/tree-sitter/tree-sitter/archive/0.17.3.tar.gz"
  sha256 "a897e5c9a7ccb74271d9b20d59121d2d2e9de8b896c4d1cfaac0f8104c1ef9f8"
  license "MIT"
  head "https://github.com/tree-sitter/tree-sitter.git"

  bottle do
    cellar :any
    sha256 "d128dbb7c1f73425f69cbb23e391f3428b126930cae6e00ac731061f52840610" => :big_sur
    sha256 "5740ba521c1e62fcbd68545c41ce729356c9249412a283a3f695031935fa8831" => :catalina
    sha256 "40f05cfb205ab7eaaf59f2bf9351ce3735f07d19e6f999c777de43f5b9c44e66" => :mojave
    sha256 "f142b02c17ed1c789b1675a3e56f448cade7000752f099850c18764aca2b960f" => :high_sierra
  end

  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <string.h>
      #include <tree_sitter/api.h>
      int main(int argc, char* argv[]) {
        TSParser *parser = ts_parser_new();
        if (parser == NULL) {
          return 1;
        }
        // Because we have no language libraries installed, we cannot
        // actually parse a string succesfully. But, we can verify
        // that it can at least be attempted.
        const char *source_code = "empty";
        TSTree *tree = ts_parser_parse_string(
          parser,
          NULL,
          source_code,
          strlen(source_code)
        );
        if (tree == NULL) {
          printf("tree creation failed");
        }
        ts_tree_delete(tree);
        ts_parser_delete(parser);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-ltree-sitter", "-o", "test"
    assert_equal "tree creation failed", shell_output("./test")
  end
end
