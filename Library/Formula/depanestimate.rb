require 'formula'

class Depanestimate < Formula
  homepage 'http://avisynth.org.ru/depan/depan.html'
  url 'http://avisynth.org.ru/depan/depanestimate192.zip'
  version '1.9.2'
  sha1 'bf1d7e681331db4dd6453be90c1ac806d0e43853'

  depends_on 'cmake' => :build
  depends_on 'avxsynth'

  def install
    system "cmake", ".", *std_cmake_args
    system "make install"
  end

  def patches
    DATA
  end

  def test
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test depanestimate`.
    system "false"
  end
end

__END__
new file mode 100644
index 0000000..29a50ad
--- /dev/null
+++ b/CMakeLists.txt
@@ -0,0 +1,12 @@
+cmake_minimum_required(VERSION 2.8)
+
+project(depanestimate)
+
+find_package(PkgConfig)
+pkg_check_modules(AVXSYNTH REQUIRED avxsynth)
+
+include_directories(${AVXSYNTH_INCLUDEDIR})
+
+add_library(DePanEstimate MODULE depanestimate.cpp depanio.cpp estimate_fftw.cpp info.cpp)
+
+INSTALL(TARGETS DePanEstimate LIBRARY DESTINATION lib/avxsynth)
diff --git a/avisynth.h b/avisynth.h
index ec607cc..9c5e685 100644
--- a/avisynth.h
+++ b/avisynth.h
@@ -46,10 +46,11 @@ enum { AVISYNTH_INTERFACE_VERSION = 2 };
    Moved from internal.h */
 
 // Win32 API macros, notably the types BYTE, DWORD, ULONG, etc. 
-#include <windef.h>  
+#include "windowsPorts/basicDataTypeConversions.h"
+using namespace avxsynth;
 
 // COM interface macros
-#include <objbase.h>
+//#include <objbase.h>
 
 
 // Raster types used by VirtualDub & Avisynth
@@ -301,7 +302,7 @@ class VideoFrame {
   VideoFrame(VideoFrameBuffer* _vfb, int _offset, int _pitch, int _row_size, int _height);
   VideoFrame(VideoFrameBuffer* _vfb, int _offset, int _pitch, int _row_size, int _height, int _offsetU, int _offsetV, int _pitchUV);
 
-  void* operator new(unsigned size);
+  void* operator new(size_t size);
 // TESTME: OFFSET U/V may be switched to what could be expected from AVI standard!
 public:
   int GetPitch() const { return pitch; }
diff --git a/depanestimate.cpp b/depanestimate.cpp
index ae1915d..c5c5eb5 100644
--- a/depanestimate.cpp
+++ b/depanestimate.cpp
@@ -55,7 +55,7 @@
 
 */
 
-#include "windows.h"
+#include "windowsPorts/windows2linux.h"
 #include "avisynth.h"
 #include "estimate_fftw.h"
 
diff --git a/depanio.cpp b/depanio.cpp
index 7849e30..a52fc7f 100644
--- a/depanio.cpp
+++ b/depanio.cpp
@@ -20,7 +20,7 @@
 
 */
 
-#include "windows.h"
+#include "windowsPorts/windows2linux.h"
 #include "avisynth.h"
 #include "stdio.h"
 
diff --git a/depanio.h b/depanio.h
index 5a70914..6dd06bc 100644
--- a/depanio.h
+++ b/depanio.h
@@ -24,7 +24,7 @@
 #ifndef __DEPANIO_H__
 #define __DEPANIO_H__
 
-#include "windows.h"
+#include "windowsPorts/windows2linux.h"
 #include "stdio.h"
 
 //#define MAX(x,y) ((x) > (y) ? (x) : (y))
diff --git a/estimate_fftw.cpp b/estimate_fftw.cpp
index ffd1da9..8c7a8db 100644
--- a/estimate_fftw.cpp
+++ b/estimate_fftw.cpp
@@ -51,7 +51,10 @@
 
 */
 
-#include "windows.h"
+#include <algorithm>
+#include <dlfcn.h>
+
+#include "windowsPorts/windows2linux.h"
 #include "avisynth.h"
 #include "math.h"
 #include "stdio.h"
@@ -61,6 +64,8 @@
 #include "info.h"
 #include "estimate_fftw.h"
 
+#define OutputDebugString(x) fprintf(stderr, "%s", x)
+
 
 // constructor
 DePanEstimate_fftw::DePanEstimate_fftw(PClip _child, int _range, float _trust, int _winx, int _winy, int _dxmax, int _dymax, float _zoommax, int _improve, float _stab, float _pixaspect, int _info, const char * _logfilename, int _debug, int _show, const char * _extlogfilename, IScriptEnvironment* env) :
@@ -123,16 +128,16 @@ DePanEstimate_fftw::DePanEstimate_fftw(PClip _child, int _range, float _trust, i
 	if (dymax >= winy/2) env->ThrowError("DePanEstimate: DYMAX must be less WINY/2 !");
 
 
-	hinstLib = LoadLibrary("fftw3.dll"); // added in v 1.2 for delayed loading
+	hinstLib = dlopen("/usr/local/lib/libfftw3f.dylib", RTLD_LAZY); // added in v 1.2 for delayed loading
 	if (hinstLib != NULL)
 	{
-		fftwf_free_addr = (fftwf_free_proc) GetProcAddress(hinstLib, "fftwf_free");
-		fftwf_malloc_addr = (fftwf_malloc_proc)GetProcAddress(hinstLib, "fftwf_malloc");
-		fftwf_plan_dft_r2c_2d_addr = (fftwf_plan_dft_r2c_2d_proc) GetProcAddress(hinstLib, "fftwf_plan_dft_r2c_2d");
-		fftwf_plan_dft_c2r_2d_addr = (fftwf_plan_dft_c2r_2d_proc) GetProcAddress(hinstLib, "fftwf_plan_dft_c2r_2d");
-		fftwf_destroy_plan_addr = (fftwf_destroy_plan_proc) GetProcAddress(hinstLib, "fftwf_destroy_plan");
-		fftwf_execute_dft_r2c_addr = (fftwf_execute_dft_r2c_proc) GetProcAddress(hinstLib, "fftwf_execute_dft_r2c");
-		fftwf_execute_dft_c2r_addr = (fftwf_execute_dft_c2r_proc) GetProcAddress(hinstLib, "fftwf_execute_dft_c2r");
+		fftwf_free_addr = (fftwf_free_proc) dlsym(hinstLib, "fftwf_free");
+		fftwf_malloc_addr = (fftwf_malloc_proc)dlsym(hinstLib, "fftwf_malloc");
+		fftwf_plan_dft_r2c_2d_addr = (fftwf_plan_dft_r2c_2d_proc) dlsym(hinstLib, "fftwf_plan_dft_r2c_2d");
+		fftwf_plan_dft_c2r_2d_addr = (fftwf_plan_dft_c2r_2d_proc) dlsym(hinstLib, "fftwf_plan_dft_c2r_2d");
+		fftwf_destroy_plan_addr = (fftwf_destroy_plan_proc) dlsym(hinstLib, "fftwf_destroy_plan");
+		fftwf_execute_dft_r2c_addr = (fftwf_execute_dft_r2c_proc) dlsym(hinstLib, "fftwf_execute_dft_r2c");
+		fftwf_execute_dft_c2r_addr = (fftwf_execute_dft_c2r_proc) dlsym(hinstLib, "fftwf_execute_dft_c2r");
 	}
 	if (hinstLib==NULL || fftwf_free_addr==NULL || fftwf_malloc_addr==NULL || fftwf_plan_dft_r2c_2d_addr==NULL ||
 		fftwf_plan_dft_c2r_2d_addr==NULL || fftwf_destroy_plan_addr==NULL || fftwf_execute_dft_r2c_addr==NULL || fftwf_execute_dft_c2r_addr==NULL)
@@ -278,7 +283,7 @@ DePanEstimate_fftw::~DePanEstimate_fftw() {
 	free(trust);
 
 	if (hinstLib != NULL)
-		FreeLibrary(hinstLib);
+		dlclose(hinstLib);
 }
 
 
@@ -322,10 +327,11 @@ void DePanEstimate_fftw::frame_data2d (const BYTE * srcp0, int height, int src_w
 
 
 
+#if 1
 //****************************************************************************
 //
 //
-void mult_conj_data2d_nosse (fftwf_complex *fftnext, fftwf_complex *fftsrc, fftwf_complex *mult, int winx, int winy)
+void DePanEstimate_fftw::mult_conj_data2d (fftwf_complex *fftnext, fftwf_complex *fftsrc, fftwf_complex *mult, int winx, int winy)
 {
 	// multiply complex conj. *next to src
 	// (hermit)
@@ -344,6 +350,7 @@ void mult_conj_data2d_nosse (fftwf_complex *fftnext, fftwf_complex *fftsrc, fftw
 	}
 }
 
+#else
 //****************************************************************************
 //
 //
@@ -402,6 +409,7 @@ nextpair:
 	//}
 	}
 }
+#endif
 
 
 //****************************************************************************
@@ -962,13 +970,13 @@ PVideoFrame __stdcall DePanEstimate_fftw::GetFrame(int ndest, IScriptEnvironment
 							motionx[ncur] = (dx1 + dx2)/2;
 							motiony[ncur] = (dy1 + dy2)/2;
 							motionzoom[ncur] = zoom ;
-							trust[ncur] = min(trust1, trust2);
+							trust[ncur] = std::min(trust1, trust2);
 					}
 					else { // bad zoom,
 							motionx[ncur] = 0;
 							motiony[ncur] = 0;
 							motionzoom[ncur] = 1;
-							trust[ncur] = min(trust1, trust2);
+							trust[ncur] = std::min(trust1, trust2);
 					}
 
 //					if (improve != 0) / did not never really work, disabled in v1.6
diff --git a/estimate_fftw.h b/estimate_fftw.h
index e0af8e8..2d39acf 100644
--- a/estimate_fftw.h
+++ b/estimate_fftw.h
@@ -50,7 +50,7 @@
 #ifndef __ESTIMATE_FFTW_H__
 #define __ESTIMATE_FFTW_H__
 
-#include "windows.h"
+#include "windowsPorts/windows2linux.h"
 #include "avisynth.h"
 #include "stdio.h"
 //#include "fftw\fftw3.h"
diff --git a/fftwlite.h b/fftwlite.h
index 0de0a65..3723c4a 100644
--- a/fftwlite.h
+++ b/fftwlite.h
@@ -6,7 +6,7 @@
 typedef float fftwf_complex[2];
 typedef struct fftwf_plan_s  *fftwf_plan;
 typedef fftwf_complex* (*fftwf_malloc_proc)(size_t n); 
-typedef VOID (*fftwf_free_proc) (void *ppp);
+typedef void (*fftwf_free_proc) (void *ppp);
 typedef fftwf_plan (*fftwf_plan_dft_r2c_2d_proc) (int winy, int winx, float *realcorrel, fftwf_complex *correl, int flags);
 typedef fftwf_plan (*fftwf_plan_dft_c2r_2d_proc) (int winy, int winx, fftwf_complex *correl, float *realcorrel, int flags);
 typedef void (*fftwf_destroy_plan_proc) (fftwf_plan);
@@ -14,4 +14,4 @@ typedef void (*fftwf_execute_dft_r2c_proc) (fftwf_plan, float *realdata, fftwf_c
 typedef void (*fftwf_execute_dft_c2r_proc) (fftwf_plan, fftwf_complex *fftsrc, float *realdata);
 #define FFTW_ESTIMATE (1U << 6)
 
-#endif
\ No newline at end of file
+#endif
diff --git a/info.h b/info.h
index 1528eab..326ef97 100644
--- a/info.h
+++ b/info.h
@@ -3,7 +3,7 @@
 #ifndef __INFO_H__
 #define __INFO_H__
 
-#include "windows.h" 
+#include "windowsPorts/windows2linux.h"
 #include "avisynth.h"
 
 void DrawString(PVideoFrame &dst, int x, int y, const char *s, int bIsYUY2); 
