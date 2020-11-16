class LibtensorflowAT1 < Formula
  include Language::Python::Virtualenv

  desc "C interface for Google's OS library for Machine Intelligence"
  homepage "https://www.tensorflow.org/"
  url "https://github.com/tensorflow/tensorflow/archive/v1.15.4.tar.gz"
  sha256 "e18c55e771ad136f9bf3a70ea8f0e2d36662b2ba7c890f9eaf7950554557c7fa"
  license "Apache-2.0"
  revision 1

  bottle do
    cellar :any
    sha256 "30aa7f3e8e2a98bbc16bfcf75595fa9cf11cead941c2cf81dd630a913100710b" => :big_sur
    sha256 "9763732a2181ccbd646821c7bdf4e59dbefa67e9d70616b11492d3860d59710d" => :catalina
    sha256 "0d60e4fdc3565e394a87824af4ad5612d059a38c9a48babfe3dee85d372d3cc6" => :mojave
    sha256 "958c949341285f4cb069a1a8ff3477dae75aea70f5d6f86cf4c9af42c29ee2ab" => :high_sierra
  end

  keg_only :versioned_formula

  depends_on "bazel" => :build
  depends_on "python@3.9" => :build

  def install
    venv_root = "#{buildpath}/venv"
    virtualenv_create(venv_root, "python3")

    ENV["PYTHON_BIN_PATH"] = "#{venv_root}/bin/python"
    ENV["CC_OPT_FLAGS"] = "-march=native"
    ENV["TF_IGNORE_MAX_BAZEL_VERSION"] = "1"
    ENV["TF_NEED_JEMALLOC"] = "1"
    ENV["TF_NEED_GCP"] = "0"
    ENV["TF_NEED_HDFS"] = "0"
    ENV["TF_ENABLE_XLA"] = "0"
    ENV["USE_DEFAULT_PYTHON_LIB_PATH"] = "1"
    ENV["TF_NEED_OPENCL"] = "0"
    ENV["TF_NEED_CUDA"] = "0"
    ENV["TF_NEED_MKL"] = "0"
    ENV["TF_NEED_VERBS"] = "0"
    ENV["TF_NEED_MPI"] = "0"
    ENV["TF_NEED_S3"] = "1"
    ENV["TF_NEED_GDR"] = "0"
    ENV["TF_NEED_KAFKA"] = "0"
    ENV["TF_NEED_OPENCL_SYCL"] = "0"
    ENV["TF_NEED_ROCM"] = "0"
    ENV["TF_DOWNLOAD_CLANG"] = "0"
    ENV["TF_SET_ANDROID_WORKSPACE"] = "0"
    ENV["TF_CONFIGURE_IOS"] = "0"
    system "./configure"

    bazel_compatibility_flags = %w[
      --noincompatible_remove_legacy_whole_archive
    ]
    system "bazel", "build", "--jobs", ENV.make_jobs, "--compilation_mode=opt",
                    "--copt=-march=native", *bazel_compatibility_flags, "tensorflow:libtensorflow.so"
    lib.install Dir["bazel-bin/tensorflow/*.so*", "bazel-bin/tensorflow/*.dylib*"]
    (include/"tensorflow/c").install %w[
      tensorflow/c/c_api.h
      tensorflow/c/c_api_experimental.h
      tensorflow/c/tf_attrtype.h
      tensorflow/c/tf_datatype.h
      tensorflow/c/tf_status.h
      tensorflow/c/tf_tensor.h
    ]

    (lib/"pkgconfig/tensorflow.pc").write <<~EOS
      Name: tensorflow
      Description: Tensorflow library
      Version: #{version}
      Libs: -L#{lib} -ltensorflow
      Cflags: -I#{include}
    EOS
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <tensorflow/c/c_api.h>
      int main() {
        printf("%s", TF_Version());
      }
    EOS
    system ENV.cc, "-L#{lib}", "-I#{include}", "-ltensorflow", "-o", "test_tf", "test.c"
    assert_equal version, shell_output("./test_tf")
  end
end
