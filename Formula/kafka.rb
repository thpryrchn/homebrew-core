class Kafka < Formula
  desc "Publish-subscribe messaging rethought as a distributed commit log"
  homepage "https://kafka.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=kafka/2.6.0/kafka_2.13-2.6.0.tgz"
  mirror "https://archive.apache.org/dist/kafka/2.6.0/kafka_2.13-2.6.0.tgz"
  sha256 "7c789adaa89654d935a5558d0dacff7466e2cfec9620cb8177cec141e7b0fb92"
  license "Apache-2.0"
  revision 1

  livecheck do
    url :stable
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "12f128d0371a9dd24b2ed9909311c4626310ccbf90774d6c559e310f6b03f975" => :big_sur
    sha256 "83589fb8053e087bb0c667c491f1d688e186864fdb1ae40ea9c4c910c4b8cc02" => :catalina
    sha256 "8d3b3d4db0bbf7f8e6e9a606099570bfeabfd3ebe5c965203f884b6bfc900c7a" => :mojave
    sha256 "d6b2a8e37b0c682c49a3b9c6b47c5587b6a9e2f14505de84d56c26f3bd5777a4" => :high_sierra
  end

  depends_on "openjdk"
  depends_on "zookeeper"

  def install
    data = var/"lib"
    inreplace "config/server.properties",
      "log.dirs=/tmp/kafka-logs", "log.dirs=#{data}/kafka-logs"

    inreplace "config/zookeeper.properties",
      "dataDir=/tmp/zookeeper", "dataDir=#{data}/zookeeper"

    # remove Windows scripts
    rm_rf "bin/windows"

    libexec.install "libs"

    prefix.install "bin"
    bin.env_script_all_files(libexec/"bin", Language::Java.java_home_env)
    Dir["#{bin}/*.sh"].each { |f| mv f, f.to_s.gsub(/.sh$/, "") }

    mv "config", "kafka"
    etc.install "kafka"
    libexec.install_symlink etc/"kafka" => "config"

    # create directory for kafka stdout+stderr output logs when run by launchd
    (var+"log/kafka").mkpath
  end

  plist_options manual: "zookeeper-server-start #{HOMEBREW_PREFIX}/etc/kafka/zookeeper.properties & kafka-server-start #{HOMEBREW_PREFIX}/etc/kafka/server.properties"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>WorkingDirectory</key>
          <string>#{HOMEBREW_PREFIX}</string>
          <key>ProgramArguments</key>
          <array>
              <string>#{opt_bin}/kafka-server-start</string>
              <string>#{etc}/kafka/server.properties</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <true/>
          <key>StandardErrorPath</key>
          <string>#{var}/log/kafka/kafka_output.log</string>
          <key>StandardOutPath</key>
          <string>#{var}/log/kafka/kafka_output.log</string>
      </dict>
      </plist>
    EOS
  end

  test do
    ENV["LOG_DIR"] = "#{testpath}/kafkalog"

    (testpath/"kafka").mkpath
    cp "#{etc}/kafka/zookeeper.properties", testpath/"kafka"
    cp "#{etc}/kafka/server.properties", testpath/"kafka"
    inreplace "#{testpath}/kafka/zookeeper.properties", "#{var}/lib", testpath
    inreplace "#{testpath}/kafka/server.properties", "#{var}/lib", testpath

    begin
      fork do
        exec "#{bin}/zookeeper-server-start #{testpath}/kafka/zookeeper.properties " \
             "> #{testpath}/test.zookeeper-server-start.log 2>&1"
      end

      sleep 15

      fork do
        exec "#{bin}/kafka-server-start #{testpath}/kafka/server.properties " \
             "> #{testpath}/test.kafka-server-start.log 2>&1"
      end

      sleep 30

      system "#{bin}/kafka-topics --zookeeper localhost:2181 --create --if-not-exists --replication-factor 1 " \
             "--partitions 1 --topic test > #{testpath}/kafka/demo.out 2>/dev/null"
      pipe_output "#{bin}/kafka-console-producer --broker-list localhost:9092 --topic test 2>/dev/null",
                  "test message"
      system "#{bin}/kafka-console-consumer --bootstrap-server localhost:9092 --topic test --from-beginning " \
             "--max-messages 1 >> #{testpath}/kafka/demo.out 2>/dev/null"
      system "#{bin}/kafka-topics --zookeeper localhost:2181 --delete --topic test >> #{testpath}/kafka/demo.out " \
             "2>/dev/null"
    ensure
      system "#{bin}/kafka-server-stop"
      system "#{bin}/zookeeper-server-stop"
      sleep 10
    end

    assert_match(/test message/, IO.read("#{testpath}/kafka/demo.out"))
  end
end
