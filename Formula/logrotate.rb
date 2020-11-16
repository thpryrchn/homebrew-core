class Logrotate < Formula
  desc "Rotates, compresses, and mails system logs"
  homepage "https://github.com/logrotate/logrotate"
  url "https://github.com/logrotate/logrotate/releases/download/3.17.0/logrotate-3.17.0.tar.xz"
  sha256 "58cc2178ff57faa3c0490181cce041345aeca6cff18dba1c5cd1398bf1c19294"
  license "GPL-2.0"

  bottle do
    cellar :any
    sha256 "d49cb61db83f22a4b739d78613fa45469ad3eeb03697c57a5a4ba15a5d135526" => :big_sur
    sha256 "cb0e376e957310bf7a5c3edcd4cdbc41b0f8d2aa12996a3b25f63174090b9358" => :catalina
    sha256 "94ab5540c338fa37c83de5ee0f1150b170c5bbb5dd50dcab592c9de74893febc" => :mojave
    sha256 "c40599d984c6c5da3818e7f86c95626bd3006e61ee0bd0e588bed07729bb1242" => :high_sierra
  end

  depends_on "popt"

  # https://github.com/logrotate/logrotate/pull/344
  patch do
    url "https://github.com/logrotate/logrotate/commit/5aee3d4d73bbdca7531bf641a78bcb5ec58d93ea.patch?full_index=1"
    sha256 "c0446056737c94e353893f9c6cba547b13cc34190df459c27b1a60654327759f"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-compress-command=/usr/bin/gzip",
                          "--with-uncompress-command=/usr/bin/gunzip",
                          "--with-state-file-path=#{var}/lib/logrotate.status"
    system "make", "install"

    inreplace "examples/logrotate.conf", "/etc/logrotate.d", "#{etc}/logrotate.d"
    etc.install "examples/logrotate.conf" => "logrotate.conf"
    (etc/"logrotate.d").mkpath
  end

  plist_options manual: "logrotate"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{sbin}/logrotate</string>
            <string>#{etc}/logrotate.conf</string>
          </array>
          <key>RunAtLoad</key>
          <false/>
          <key>StartCalendarInterval</key>
          <dict>
            <key>Hour</key>
            <integer>6</integer>
            <key>Minute</key>
            <integer>25</integer>
          </dict>
        </dict>
      </plist>
    EOS
  end

  test do
    (testpath/"test.log").write("testlograndomstring")
    (testpath/"testlogrotate.conf").write <<~EOS
      #{testpath}/test.log {
        size 1
        copytruncate
      }
    EOS
    system "#{sbin}/logrotate", "-s", "logstatus", "testlogrotate.conf"
    assert(File.size?("test.log").nil?, "File is not zero length!")
  end
end
