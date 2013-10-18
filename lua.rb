require 'formula'

class Lua < Formula
  # 5.2 is not fully backwards compatible, and breaks e.g. luarocks.
  # It is available in Homebrew-versions for the time being.
  homepage 'http://www.lua.org/'
  url 'http://www.lua.org/ftp/lua-5.2.2.tar.gz'
  sha1 '0857e41e5579726a4cb96732e80d7aa47165eaf5'

  fails_with :llvm do
    build 2326
    cause "Lua itself compiles with LLVM, but may fail when other software tries to link."
  end

  option :universal
  option 'with-completion', 'Enables advanced readline support'
  option 'without-sigaction', 'Revert to ANSI signal instead of improved POSIX sigaction'

  V = "5.2"

  # Be sure to build a dylib, or else runtime modules will pull in another static copy of liblua = crashy
  # See: https://github.com/mxcl/homebrew/pull/5043
  def patches
    p = [DATA]
    # sigaction provided by posix signalling power patch from
    # http://lua-users.org/wiki/LuaPowerPatches
    unless build.without? 'sigaction'
      p << 'http://lua-users.org/files/wiki_insecure/power_patches/5.2/lua-5.2.2-sig_catch.patch'
    end
    # completion provided by advanced readline power patch from
    # http://lua-users.org/wiki/LuaPowerPatches
    if build.with? 'completion'
      p << 'http://luajit.org/patches/lua-5.2.0-advanced_readline.patch'
    end
    p
  end

  def install
    ENV.universal_binary if build.universal?

    # Use our CC/CFLAGS to compile.
    inreplace 'src/Makefile' do |s|
      s.remove_make_var! 'CC'
      s.change_make_var! 'CFLAGS', "#{ENV.cflags} -DLUA_COMPAT_ALL $(SYSCFLAGS) $(MYCFLAGS)"
      s.change_make_var! 'MYLDFLAGS', ENV.ldflags
    end

    # Fix path in the config header
    inreplace 'src/luaconf.h', '/usr/local', HOMEBREW_PREFIX

    # this ensures that this symlinking for lua starts at lib/lua/5.2 and not
    # below that, thus making luarocks work
    (HOMEBREW_PREFIX/"lib/lua/#{V}").mkpath

    system "make", "macosx", "INSTALL_TOP=#{prefix}", "INSTALL_MAN=#{man1}"
    system "make", "install", "INSTALL_TOP=#{prefix}", "INSTALL_MAN=#{man1}"
    (lib+"pkgconfig/lua#{V}.pc").write pc_file
    (lib+"pkgconfig/lua.pc").make_relative_symlink (lib+"pkgconfig/lua#{V}.pc")
  end
  def pc_file; <<-EOS.undent
    prefix=#{opt_prefix}
    exec_prefix=${prefix}
    libdir=${exec_prefix}/lib
    includedir=${prefix}/include/lua-#{V}
 
    Name: Lua
    Description: An Extensible Extension Language
    Version: #{version}
    Requires:
    Libs: -L${libdir} -llua.#{V} -lm
    Cflags: -I${includedir}
    EOS
  end
end

__END__
diff -r -U 3 lua-5.2.2.orig/Makefile lua-5.2.2/Makefile
--- lua-5.2.2.orig/Makefile	2012-05-17 17:05:54.000000000 +0300
+++ lua-5.2.2/Makefile	2013-10-17 14:55:44.000000000 +0300
@@ -41,12 +41,12 @@
 # What to install.
 TO_BIN= lua luac
 TO_INC= lua.h luaconf.h lualib.h lauxlib.h lua.hpp
-TO_LIB= liblua.a
+TO_LIB= liblua.5.2.2.dylib
 TO_MAN= lua.1 luac.1
 
 # Lua version and release.
 V= 5.2
-R= $V.1
+R= $V.2
 
 # Targets start here.
 all:	$(PLAT)
@@ -63,6 +63,8 @@
 	cd src && $(INSTALL_DATA) $(TO_INC) $(INSTALL_INC)
 	cd src && $(INSTALL_DATA) $(TO_LIB) $(INSTALL_LIB)
 	cd doc && $(INSTALL_DATA) $(TO_MAN) $(INSTALL_MAN)
+	ln -s -f liblua.5.2.2.dylib $(INSTALL_LIB)/liblua.5.2.dylib
+	ln -s -f liblua.5.2.dylib $(INSTALL_LIB)/liblua.dylib
 
 uninstall:
 	cd src && cd $(INSTALL_BIN) && $(RM) $(TO_BIN)
Only in lua-5.2.2: dist
diff -r -U 3 lua-5.2.2.orig/src/Makefile lua-5.2.2/src/Makefile
--- lua-5.2.2.orig/src/Makefile	2012-12-27 12:51:43.000000000 +0200
+++ lua-5.2.2/src/Makefile	2013-10-17 14:48:47.000000000 +0300
@@ -28,7 +28,7 @@
 
 PLATS= aix ansi bsd freebsd generic linux macosx mingw posix solaris
 
-LUA_A=	liblua.a
+LUA_A= liblua.5.2.2.dylib
 CORE_O=	lapi.o lcode.o lctype.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o \
 	lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o \
 	ltm.o lundump.o lvm.o lzio.o
@@ -56,11 +56,13 @@
 a:	$(ALL_A)
 
 $(LUA_A): $(BASE_O)
-	$(AR) $@ $(BASE_O)
-	$(RANLIB) $@
+	$(CC) -dynamiclib -install_name HOMEBREW_PREFIX/lib/liblua.5.2.dylib \
+		-compatibility_version 5.2 -current_version 5.2.2 \
+		-o liblua.5.2.2.dylib $^
 
 $(LUA_T): $(LUA_O) $(LUA_A)
-	$(CC) -o $@ $(LDFLAGS) $(LUA_O) $(LUA_A) $(LIBS)
+	$(CC) -fno-common $(MYLDFLAGS) \
+		-o $@ $(LUA_O) $(LUA_A) -L. -llua.5.2.2 $(LIBS)
 
 $(LUAC_T): $(LUAC_O) $(LUA_A)
 	$(CC) -o $@ $(LDFLAGS) $(LUAC_O) $(LUA_A) $(LIBS)
