require 'formula'

class Avxsynth < Formula
  homepage ''
  version '4.0'
  url 'https://github.com/avxsynth/avxsynth/tarball/master'
  sha1 '8238853d3ac1511f8a9fe425cc4b1abd95a43122'

  depends_on 'log4cpp'
  depends_on :x11
  depends_on 'pango'
  #depends_on 'cairo'
  depends_on 'fontconfig'
  depends_on 'freetype'
  depends_on 'libpng'

  def install
      system "autoreconf -i"
      system './configure', "--prefix=#{prefix}"
      system "make"
      system "make install"
  end

  def test
    system "false"
  end

  def patches
      DATA
  end

end


__END__
diff --git a/avxsynth/common/include/stdafx.h b/avxsynth/common/include/stdafx.h
index cf4fe7f..065fab8 100644
--- a/avxsynth/common/include/stdafx.h
+++ b/avxsynth/common/include/stdafx.h
@@ -5,7 +5,7 @@
 #include <stdio.h>
 #include <stdlib.h>
 #include <math.h>
-#include <malloc.h>
+#include <sys/malloc.h>
 #include <string.h>
 //#include <io.h>
 #include <ctype.h>
diff --git a/include/avxplugin.h b/include/avxplugin.h
index 3859638..f3b3677 100644
--- a/include/avxplugin.h
+++ b/include/avxplugin.h
@@ -82,7 +82,7 @@ typedef long			PixOffset;
   #include <crtdbg.h>
 #else
   #define _ASSERTE(x) assert(x)
-  #include <assert.h>
+//  #include <assert.h>
 #endif
 
 
diff --git a/avxsynth/core/src/core/avxsynth.cpp b/avxsynth/core/src/core/avxsynth.cpp
index 5a33e45..53f7013 100644
--- a/avxsynth/core/src/core/avxsynth.cpp
+++ b/avxsynth/core/src/core/avxsynth.cpp
@@ -892,7 +892,7 @@ private:
   Cache* CacheHead;
 
   HRESULT hrfromcoinit;
-  DWORD coinitThreadId;
+  pthread_t coinitThreadId;
 
   static long refcount; // Global to all ScriptEnvironment objects
 };
@@ -919,7 +919,7 @@ ScriptEnvironment::ScriptEnvironment()
       //CoUninitialize();
     }
     // Remember our threadId.
-    coinitThreadId=pthread_self(); // GetCurrentThreadId();
+    coinitThreadId = pthread_self(); // GetCurrentThreadId();
 
     CPU_id = CPUCheckForExtensions();
 
@@ -938,7 +938,7 @@ ScriptEnvironment::ScriptEnvironment()
 //      memory_max = (__int64)memstatus.dwAvailPhys >> 2;
 //    else
 //      memory_max = 16*1024*1024;
-#else      
+#elif 0
     long nPageSize               = sysconf(_SC_PAGE_SIZE);
     long nAvailablePhysicalPages = sysconf(_SC_AVPHYS_PAGES);
     memory_max = (__int64)(nPageSize*nAvailablePhysicalPages) >> 2;
diff --git a/avxsynth/core/src/core/main.cpp b/avxsynth/core/src/core/main.cpp
index 5867e05..379c101 100644
--- a/avxsynth/core/src/core/main.cpp
+++ b/avxsynth/core/src/core/main.cpp
@@ -39,7 +39,7 @@
 #define FP_STATE 0x9001f
 
 #include <stdio.h>
-#include <malloc.h>
+#include <sys/malloc.h>
 #include <limits.h>
 #include <math.h>
 #include <cstdarg>
diff --git a/avxsynth/core/src/windowsPorts.cpp b/avxsynth/core/src/windowsPorts.cpp
index 17e2c45..0ef76eb 100644
--- a/avxsynth/core/src/windowsPorts.cpp
+++ b/avxsynth/core/src/windowsPorts.cpp
@@ -4,6 +4,7 @@
 #include <ctype.h>
 #include <string.h>
 #include <dirent.h>
+#include <limits.h>
 
 namespace avxsynth{  
     
diff --git a/avxsynth/builtinfunctions/src/filters/transform.cpp b/avxsynth/builtinfunctions/src/filters/transform.cpp
index 50b6e76..4886cc0 100644
--- a/avxsynth/builtinfunctions/src/filters/transform.cpp
+++ b/avxsynth/builtinfunctions/src/filters/transform.cpp
@@ -410,15 +410,15 @@ PVideoFrame AddBorders::GetFrame(int n, IScriptEnvironment* env)
 
     BitBlt(dstp+initial_black, dst_pitch, srcp, src_pitch, src_row_size, src_height);
     for (int a=0; a<initial_black; a += 4)
-      *(unsigned __int32*)(dstp+a) = black;
+      *(uint32_t*)(dstp+a) = black;
     dstp += initial_black + src_row_size;
     for (int y=src_height-1; y>0; --y) {
       for (int b=0; b<middle_black; b += 4)
-        *(unsigned __int32*)(dstp+b) = black;
+        *(uint32_t*)(dstp+b) = black;
       dstp += dst_pitch;
     }
     for (int c=0; c<final_black; c += 4)
-      *(unsigned __int32*)(dstp+c) = black;
+      *(uint32_t*)(dstp+c) = black;
   }
   else if (vi.IsRGB24()) {
     const int ofs = dst_pitch - dst_row_size;
@@ -446,15 +446,15 @@ PVideoFrame AddBorders::GetFrame(int n, IScriptEnvironment* env)
   else {
     BitBlt(dstp+initial_black, dst_pitch, srcp, src_pitch, src_row_size, src_height);
     for (int i=0; i<initial_black; i+=4)
-      *(unsigned __int32*)(dstp+i) = clr;
+      *(uint32_t*)(dstp+i) = clr;
     dstp += initial_black + src_row_size;
     for (int y=src_height-1; y>0; --y) {
       for (int i=0; i<middle_black; i+=4)
-        *(unsigned __int32*)(dstp+i) = clr;
+        *(uint32_t*)(dstp+i) = clr;
       dstp += dst_pitch;
     } // for y
     for (int i=0; i<final_black; i+=4)
-      *(unsigned __int32*)(dstp+i) = clr;
+      *(uint32_t*)(dstp+i) = clr;
   } // end else
   return dst;
 }
