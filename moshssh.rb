require 'formula'

class Moshssh < Formula
  url 'https://github.com/downloads/keithw/mosh/mosh-1.2.2.tar.gz'
  md5 '7ed5b857307685794dcd120afe5bdf52'

  head 'https://github.com/keithw/mosh.git'
  homepage 'https://github.com/keithw/mosh/'

  def install
    # Build in serial. See:
    # https://github.com/mxcl/homebrew/issues/8719
    ENV.j1

    system "./configure", "make", "make install", "PREFIX=#{prefix}"
  end
end
