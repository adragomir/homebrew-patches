require 'formula'


class Jenv < Formula
  homepage 'https://github.com/gcuisinier/jenv'
  url 'https://github.com/gcuisinier/jenv/tarball/0.1.1'
  sha1 'fc672332d8f9013c6806d04d745b11af74f94808'
  head 'https://github.com/gcuisinier/jenv.git', :branch => master

  def install
     libexec.install Dir['*']
     bin.write_exec_script libexec/'bin/jenv'
   end

   def caveats; <<-EOS.undent
     To enable shims and autocompletion add to your profile:
       if which jenv > /dev/null; then eval "$(jenv init -)"; fi

     To use Homebrew's directories rather than ~/.jenv add to your profile:
       export JENV_ROOT=#{opt_prefix}
     EOS
   end
end
