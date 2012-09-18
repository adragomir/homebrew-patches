require 'formula'

class Mongrel2CHandler < Formula
  head 'https://github.com/derdewey/mongrel2_c_handler.git'
  homepage 'https://github.com/derdewey/mongrel2_c_handler/'

  depends_on 'zeromq', 'jansson'

  def install
    # Build in serial. See:
    # https://github.com/mxcl/homebrew/issues/8719
    ENV.j1

    # Mongrel2 pulls from these ENV vars instead
    ENV['OPTFLAGS'] = "#{ENV.cflags} #{ENV.cppflags}"
    ENV['OPTLIBS'] = ENV.ldflags

    system "make", "install", "PREFIX=#{prefix}"
  end
end
