require 'formula'

class Libslack < Formula
  url 'http://libslack.org/download/libslack-0.6.tar.gz'
  md5 '0e22e1d38865be2d94372027e5c42b58'

  def install
    # Build in serial. See:
    # https://github.com/mxcl/homebrew/issues/8719
    ENV.j1

    # Mongrel2 pulls from these ENV vars instead

    system "make", "osx", "PREFIX=#{prefix}"
  end
end
