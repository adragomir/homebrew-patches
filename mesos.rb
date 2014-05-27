require 'formula'

class Mesos < Formula
  homepage 'http://mesos.apache.org'
  url 'http://mirrors.hostingromania.ro/apache.org/mesos/0.18.2/mesos-0.18.2.tar.gz'
  head 'https://github.com/apache/mesos.git'
  sha1 '0b8e7ebd9c8a28f073b955f7229c5a28ee2d7120'

  def install
    system "./configure", "--disable-debug",
                           "--disable-dependency-tracking",
                           "--disable-silent-rules",
                           "--prefix=#{prefix}"

    system "make"
    system "make", "install"
  end

end
