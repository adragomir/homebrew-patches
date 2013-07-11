require 'formula'


class Jenv < Formula
  homepage 'https://github.com/gcuisinier/jenv'
  url 'https://github.com/gcuisinier/jenv/tarball/0.1.1'
  sha1 '3bc0b09f0f7b53e865cdbb4fda6e715cfa0ada56'
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
