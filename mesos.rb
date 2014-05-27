require 'formula'

class Mesos < Formula
  homepage 'http://mesos.apache.org'
  url 'http://mirrors.hostingromania.ro/apache.org/mesos/0.18.2/mesos-0.18.2.tar.gz'
  head 'https://github.com/apache/mesos.git'
  sha1 '7d99075b4ab329171a0f2b12a064232dd23350f8'

  def install
    system "./configure", "--disable-debug",
                           "--disable-dependency-tracking",
                           "--disable-silent-rules",
                           "--prefix=#{prefix}"

    system "make"
    system "make", "install"
  end

end
