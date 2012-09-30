require 'formula'

class Libm2handler < Formula
  head 'https://github.com/xrl/libm2handler.git'
  homepage 'https://github.com/xrl/libm2handler'

  depends_on 'zeromq'
  depends_on 'jansson'

  def install
    # Build in serial. See:
    # https://github.com/mxcl/homebrew/issues/8719
    ENV.j1

    # Mongrel2 pulls from these ENV vars instead
    ENV['OPTFLAGS'] = "#{ENV.cflags} #{ENV.cppflags}"
    ENV['OPTLIBS'] = ENV.ldflags

    system "/usr/local/bin/glibtoolize -c"
    system "autoreconf -fv --install"
    system "autoreconf -fv --install"
    system "./configure", "PREFIX=#{prefix}"
    system "make", "PREFIX=#{prefix}"
    system "make install", "PREFIX=#{prefix}"
  end
end
