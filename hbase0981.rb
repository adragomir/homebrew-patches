require 'formula'

class Hbase0981 < Formula
  homepage 'http://hbase.apache.org'
  url 'http://archive.apache.org/dist/hbase/hbase-0.98.1/hbase-0.98.1-hadoop2-bin.tar.gz'
  sha1 'a1bc4470975dd65f5804a31be6bf8761ca152de7'

  depends_on 'hadoop230'

  def install
    rm_f Dir["bin/*.cmd", "conf/*.cmd"]
    libexec.install %w[bin conf docs lib hbase-webapps]
    bin.write_exec_script Dir["#{libexec}/bin/*"]

    inreplace "#{libexec}/conf/hbase-env.sh",
      "# export JAVA_HOME=/usr/java/jdk1.6.0/",
      "export JAVA_HOME=\"$(/usr/libexec/java_home)\""
  end

  def caveats; <<-EOS.undent
    Requires Java 1.6.0 or greater.

    You must also edit the configs in:
      #{libexec}/conf
    to reflect your environment.

    For more details:
      http://wiki.apache.org/hadoop/Hbase
    EOS
  end
end
