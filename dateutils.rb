require 'formula'

# Documentation: https://github.com/mxcl/homebrew/wiki/Formula-Cookbook
#                /usr/local/Library/Contributions/example-formula.rb
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Dateutils < Formula
  homepage ''
  url 'https://bitbucket.org/hroptatyr/dateutils/downloads/dateutils-0.2.5.tar.xz'
  sha1 '47f2ba469daff7586d47473f54a77848b724ba45'
  head 'https://github.com/hroptatyr/dateutils.git'

  # depends_on 'cmake' => :build

  def patches
    DATA
  end

  def install
    # ENV.j1  # if your formula's build system can't parallelize

    # Remove unrecognized options if warned by configure
    if build.head?
      system "autoreconf -i"
    end

    system "./configure", # "--disable-debug",
                        #  "--disable-dependency-tracking",
                        #  "--disable-silent-rules",
                          "--prefix=#{prefix}"
    # system "cmake", ".", *std_cmake_args
    system "make", "install" # if this fails, try separate make/make install steps
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test dateutils`.
    system "false"
  end
end

__END__
diff --git a/lib/boops.h b/lib/boops.h
index ca6fd8c..682fd20 100644
--- a/lib/boops.h
+++ b/lib/boops.h
@@ -138,7 +138,7 @@
 # elif defined WORDS_BIGENDIAN
 #  define be32toh(x)	(x)
 # else	/* need some swaps */
-#  define be32toh(x)	htooe32(x)
+#  define be32toh(x)	ntohl(x)
 # endif
 #endif	/* !be32toh */
 
