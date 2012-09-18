require 'formula'

class Mongrel2CHandler < Formula
  head 'https://github.com/derdewey/mongrel2_c_handler.git'
  homepage 'https://github.com/derdewey/mongrel2_c_handler/'

  depends_on 'zeromq'
  depends_on 'jansson'

  def patches
    DATA
  end

  def install
    # Build in serial. See:
    # https://github.com/mxcl/homebrew/issues/8719
    ENV.j1

    # Mongrel2 pulls from these ENV vars instead
    ENV['OPTFLAGS'] = "#{ENV.cflags} #{ENV.cppflags}"
    ENV['OPTLIBS'] = ENV.ldflags

    cd "lib" do
      system "make", "install", "PREFIX=#{prefix}"
    end
  end
end

__END__
diff --git a/lib/Makefile b/lib/Makefile
index 78c979e..b344681 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -1,9 +1,9 @@
-OPTCFLAGS=-I/opt/local/include
-OPTLFLAGS=-L/opt/local/lib
+OPTCFLAGS=-I/usr/local/include
+OPTLFLAGS=-L/usr/local/lib
 LOCAL_MONGREL2_LIB=-L. -lm2handler
 
 CFLAGS=-g -std=c99 -Wall -Werror $(OPTCFLAGS)
-LFLAGS=-L/opt/local/lib $(OPTLFLAGS)
+LFLAGS=-L/usr/local/lib $(OPTLFLAGS)
 LIBS=-lzmq -ljansson
 PREFIX?=/usr/local
 
@@ -12,10 +12,10 @@ SOURCES=m2handler.c bstr/bstrlib.c bstrlib.c
 all : lib
 	
 m2handler.o : m2handler.h m2handler.c
-	$(CC) $(CFLAGS) -c -o m2handler.o m2handler.c -I/opt/local/include
+	$(CC) $(CFLAGS) -c -o m2handler.o m2handler.c -I/usr/local/include
 
 m2websocket.o : m2websocket.h m2websocket.c
-	$(CC) $(CFLAGS) -c -o m2websocket.o m2websocket.c -I/opt/local/include
+	$(CC) $(CFLAGS) -c -o m2websocket.o m2websocket.c -I/usr/local/include
 
 md5.o : md5/md5.h md5/md5.c md5/config.h
 	$(CC) $(CFLAGS) -c -o md5.o md5/md5.c
@@ -54,14 +54,14 @@ scan-build:
 	scan-build make test
 
 install: lib
-	install -d -o root $(PREFIX)/lib/
-	install -o root libm2handler.a $(PREFIX)/lib/
-	install -d -o root $(PREFIX)/include/
-	install -o root m2handler.h $(PREFIX)/include/
-	install -o root m2websocket.h $(PREFIX)/include/
-	install -d -o root $(PREFIX)/include/bstr/
-	install -o root bstr/bstrlib.h $(PREFIX)/include/bstr/
-	install -o root bstr/bstraux.h $(PREFIX)/include/bstr/
+	install -d $(PREFIX)/lib/
+	install libm2handler.a $(PREFIX)/lib/
+	install -d $(PREFIX)/include/
+	install m2handler.h $(PREFIX)/include/
+	install m2websocket.h $(PREFIX)/include/
+	install -d $(PREFIX)/include/bstr/
+	install bstr/bstrlib.h $(PREFIX)/include/bstr/
+	install bstr/bstraux.h $(PREFIX)/include/bstr/
 
 clean : 
 	rm -rf *.o m2handler libm2handler.a body_toupper_handler fifo_reader_handler ws_handshake_handler
diff --git a/lib/bstr/bstraux.c b/lib/bstr/bstraux.c
index 2bbb73b..7caf6de 100644
--- a/lib/bstr/bstraux.c
+++ b/lib/bstr/bstraux.c
@@ -22,6 +22,7 @@
 #include <string.h>
 #include <limits.h>
 #include <ctype.h>
+#include <stdint.h>
 #include "bstrlib.h"
 #include "bstraux.h"
 
@@ -197,10 +198,10 @@ int i, l, c;
 }
 
 static size_t readNothing (void *buff, size_t elsize, size_t nelem, void *parm) {
-	buff = buff;
-	elsize = elsize;
-	nelem = nelem;
-	parm = parm;
+    (void)(buff);
+    (void)(elsize);
+    (void)(nelem);
+    (void)(parm);
 	return 0; /* Immediately indicate EOF. */
 }
 
@@ -251,12 +252,13 @@ static struct bStream * bsFromBstrRef (struct tagbstring * t) {
  *           in the character position one past the "," terminator.
  */
 char * bStr2NetStr (const_bstring b) {
-char strnum[sizeof (b->slen) * 3 + 1];
+size_t numlen = sizeof (b->slen) * 3 + 1;
+char strnum[numlen+1];
 bstring s;
 unsigned char * buff;
 
 	if (b == NULL || b->data == NULL || b->slen < 0) return NULL;
-	sprintf (strnum, "%d:", b->slen);
+	snprintf(strnum, numlen+1, "%d:", b->slen);
 	if (NULL == (s = bfromcstr (strnum))
 	 || bconcat (s, b) == BSTR_ERR || bconchar (s, (char) ',') == BSTR_ERR) {
 		bdestroy (s);
@@ -313,12 +315,6 @@ bstring out;
 
 	out = bfromcstr ("");
 	for (i=0; i + 2 < b->slen; i += 3) {
-		if (i && ((i % 57) == 0)) {
-			if (bconchar (out, (char) '\015') < 0 || bconchar (out, (char) '\012') < 0) {
-				bdestroy (out);
-				return NULL;
-			}
-		}
 		c0 = b->data[i] >> 2;
 		c1 = ((b->data[i] << 4) |
 		      (b->data[i+1] >> 4)) & 0x3F;
@@ -334,13 +330,6 @@ bstring out;
 		}
 	}
 
-	if (i && ((i % 57) == 0)) {
-		if (bconchar (out, (char) '\015') < 0 || bconchar (out, (char) '\012') < 0) {
-			bdestroy (out);
-			return NULL;
-		}
-	}
-
 	switch (i + 2 - b->slen) {
 		case 0:	c0 = b->data[i] >> 2;
 				c1 = ((b->data[i] << 4) |
@@ -600,10 +589,11 @@ bstring b;
 	b = bfromcstralloc (256, "");
 	if (NULL == b || 0 > bsread (b, d, INT_MAX)) {
 		bdestroy (b);
+        b = NULL;
+    }
+
 		bsclose (d);
 		bsclose (s);
-		return NULL;
-	}
 	return b;
 }
 
@@ -931,54 +921,6 @@ int bSetChar (bstring b, int pos, char c) {
 
 #define INIT_SECURE_INPUT_LENGTH (256)
 
-/*  bstring bSecureInput (int maxlen, int termchar, 
- *                        bNgetc vgetchar, void * vgcCtx)
- *
- *  Read input from an abstracted input interface, for a length of at most
- *  maxlen characters.  If maxlen <= 0, then there is no length limit put
- *  on the input.  The result is terminated early if vgetchar() return EOF
- *  or the user specified value termchar.
- *
- */
-bstring bSecureInput (int maxlen, int termchar, bNgetc vgetchar, void * vgcCtx) {
-int i, m, c;
-bstring b, t;
-
-	if (!vgetchar) return NULL;
-
-	b = bfromcstralloc (INIT_SECURE_INPUT_LENGTH, "");
-	if ((c = UCHAR_MAX + 1) == termchar) c++;
-
-	for (i=0; ; i++) {
-		if (termchar == c || (maxlen > 0 && i >= maxlen)) c = EOF;
-		else c = vgetchar (vgcCtx);
-
-		if (EOF == c) break;
-
-		if (i+1 >= b->mlen) {
-
-			/* Double size, but deal with unusual case of numeric
-			   overflows */
-
-			if ((m = b->mlen << 1)   <= b->mlen &&
-			    (m = b->mlen + 1024) <= b->mlen &&
-			    (m = b->mlen + 16)   <= b->mlen &&
-			    (m = b->mlen + 1)    <= b->mlen) t = NULL;
-			else t = bfromcstralloc (m, "");
-
-			if (t) memcpy (t->data, b->data, i);
-			bSecureDestroy (b); /* Cleanse previous buffer */
-			b = t;
-			if (!b) return b;
-		}
-
-		b->data[i] = (unsigned char) c;
-	}
-
-	b->slen = i;
-	b->data[i] = (unsigned char) '\0';
-	return b;
-}
 
 #define BWS_BUFF_SZ (1024)
 
@@ -1135,3 +1077,25 @@ void * parm;
 	return parm;
 }
 
+
+// Values for a 32 bit hash. Note hash_val_t is now fixed to uint32_t.
+static const unsigned int FNV_PRIME = 16777619;
+static const unsigned int FNV_OFFSET_BASIS = 2166136261;
+
+// FNV1a hash from http://isthe.com/chongo/tech/comp/fnv/
+uint32_t bstr_hash_fun(const void *kv)
+{
+    bstring key = (bstring)kv;
+    const unsigned char *str = (const unsigned char *)bdata(key);
+
+    uint32_t acc = FNV_OFFSET_BASIS;
+
+    while(*str) {
+        acc ^= *str;
+        acc *= FNV_PRIME;
+        str++;
+    }
+
+    return acc;
+}
+
diff --git a/lib/bstr/bstraux.h b/lib/bstr/bstraux.h
index 9c24919..c7e0112 100644
--- a/lib/bstr/bstraux.h
+++ b/lib/bstr/bstraux.h
@@ -16,6 +16,7 @@
 #ifndef BSTRAUX_INCLUDE
 #define BSTRAUX_INCLUDE
 
+#include <stdint.h>
 #include <time.h>
 #include "bstrlib.h"
 
@@ -64,6 +65,9 @@ extern int bJustifyRight (bstring b, int width, int space);
 extern int bJustifyMargin (bstring b, int width, int space);
 extern int bJustifyCenter (bstring b, int width, int space);
 
+/** Used in hash_t construction for a good bstr hash value. */
+uint32_t bstr_hash_fun(const void *kv);
+
 /* Esoteric standards specific functions */
 extern char * bStr2NetStr (const_bstring b);
 extern bstring bNetStr2Bstr (const char * buf);
@@ -102,8 +106,6 @@ bstring bstr__tmp = (b);	                                            \
 	    (t).mlen = -1;                                                            \
 	}                                                                             \
 }
-extern bstring bSecureInput (int maxlen, int termchar, 
-                             bNgetc vgetchar, void * vgcCtx);
 
 #ifdef __cplusplus
 }
