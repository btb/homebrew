require 'formula'

class Depan < Formula
  homepage 'http://avisynth.org.ru/depan/depan.html'
  url 'http://avisynth.org.ru/depan/depan1101src.zip'
  version '1.10.1'
  sha1 '80165661a5a99e34b7341ab33e489643d92d34b5'

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
    # were more thorough. Run the test with `brew test depan`.
    system "false"
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
new file mode 100644
index 0000000..29a50ad
--- /dev/null
+++ b/CMakeLists.txt
@@ -0,0 +1,12 @@
+cmake_minimum_required(VERSION 2.8)
+
+project(depan)
+
+find_package(PkgConfig)
+pkg_check_modules(AVXSYNTH REQUIRED avxsynth)
+
+include_directories(${AVXSYNTH_INCLUDEDIR})
+
+add_library(DePan SHARED compensate.cpp depanio.cpp info.cpp interface.cpp interpolate.cpp scenes.cpp stabilize.cpp transform.cpp)
+
+INSTALL(TARGETS DePan LIBRARY DESTINATION lib/avxsynth)
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
diff --git a/compensate.cpp b/compensate.cpp
index 3193820..9c4bca9 100644
--- a/compensate.cpp
+++ b/compensate.cpp
@@ -57,7 +57,7 @@
 
 */
 
-#include "windows.h"
+#include "windowsPorts/windows2linux.h"
 #include "avisynth.h"
 #include "math.h"
 #include "stdio.h"
diff --git a/depan.h b/depan.h
index 2d45521..1474d68 100644
--- a/depan.h
+++ b/depan.h
@@ -24,7 +24,9 @@
 #ifndef __DEPAN_H__
 #define __DEPAN_H__
 
-#include "windows.h"
+#include "windowsPorts/windows2linux.h"
+using namespace avxsynth;
+
 //#include "stdio.h"
 
 //#define MAX(x,y) ((x) > (y) ? (x) : (y))
diff --git a/depanio.cpp b/depanio.cpp
index d847c69..00c2849 100644
--- a/depanio.cpp
+++ b/depanio.cpp
@@ -20,7 +20,7 @@
 
 */
 
-#include "windows.h"
+#include "windowsPorts/windows2linux.h"
 #include "avisynth.h"
 #include "stdio.h"
 
diff --git a/depanio.h b/depanio.h
index 9ae8d17..42f40df 100644
--- a/depanio.h
+++ b/depanio.h
@@ -24,7 +24,7 @@
 #ifndef __DEPANIO_H__
 #define __DEPANIO_H__
 
-#include "windows.h"
+#include "windowsPorts/windows2linux.h"
 #include "stdio.h"
 
 //#define MAX(x,y) ((x) > (y) ? (x) : (y))
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
diff --git a/interface.cpp b/interface.cpp
index 1ccb867..98ac1d8 100644
--- a/interface.cpp
+++ b/interface.cpp
@@ -33,7 +33,7 @@
   v1.9 - Remove DePanEstimate function to separate plugin depanestimate.dll
 */
 
-#include "windows.h"
+#include "windowsPorts/windows2linux.h"
 #include "avisynth.h"
 
 //****************************************************************************
diff --git a/interpolate.cpp b/interpolate.cpp
index b0f3eba..983d872 100644
--- a/interpolate.cpp
+++ b/interpolate.cpp
@@ -20,7 +20,9 @@
 
 */
 
-#include "windows.h"
+#include <algorithm>
+
+#include "windowsPorts/windows2linux.h"
 //#include "avisynth.h"
 #include "math.h"
 #include "float.h"
@@ -66,7 +68,7 @@ void compensate_plane_nearest (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 	int mleft = mirror & MIRROR_LEFT;
 	int mright = mirror & MIRROR_RIGHT;
 
-	_controlfp(_MCW_RC, _RC_CHOP); // set rounding mode to truncate to zero mode (C++ standard) for /QIfist compiler option (which is for faster float-int conversion)
+	//_controlfp(_MCW_RC, _RC_CHOP); // set rounding mode to truncate to zero mode (C++ standard) for /QIfist compiler option (which is for faster float-int conversion)
 
 //	select if rotation, zoom?
 
@@ -102,7 +104,7 @@ void compensate_plane_nearest (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 					}
 					else if ( rowleft < 0 && mleft) {
 						if (blurmax>0) {
-							blurlen = min(blurmax, -rowleft);
+							blurlen = std::min(blurmax, -rowleft);
 							smoothed = 0;
 							for (i=-rowleft-blurlen+1; i<= -rowleft; i++)
 								smoothed += srcp[w0 + i];
@@ -114,7 +116,7 @@ void compensate_plane_nearest (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 					}
 					else if ( rowleft >= row_size && mright) {
 						if (blurmax>0) {
-							blurlen = min(blurmax, rowleft-row_size+1);
+							blurlen = std::min(blurmax, rowleft-row_size+1);
 							smoothed = 0;
 							for (i=row_size + row_size - rowleft -2; i<row_size + row_size - rowleft -2+blurlen ; i++)
 								smoothed += srcp[w0 + i];
@@ -175,7 +177,7 @@ void compensate_plane_nearest (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 					}
 					else if ( rowleft < 0 && mleft) {
 						if (blurmax>0) {
-							blurlen = min(blurmax, -rowleft);
+							blurlen = std::min(blurmax, -rowleft);
 							smoothed = 0;
 							for (i=-rowleft-blurlen+1; i<= -rowleft; i++)
 								smoothed += srcp[w0 + i];
@@ -187,7 +189,7 @@ void compensate_plane_nearest (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 					}
 					else if ( rowleft >= row_size && mright) {
 						if (blurmax>0) {
-							blurlen = min(blurmax, rowleft-row_size+1);
+							blurlen = std::min(blurmax, rowleft-row_size+1);
 							smoothed = 0;
 							for (i=row_size + row_size - rowleft -2; i<row_size + row_size - rowleft -2+blurlen ; i++)
 								smoothed += srcp[w0 + i];
@@ -259,7 +261,7 @@ void compensate_plane_nearest (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 		} //end for h
 	} // end if rotation
 
-	_controlfp(_MCW_RC, _RC_NEAR); // restore rounding mode to default (nearest) mode for /QIfist compiler option
+	//_controlfp(_MCW_RC, _RC_NEAR); // restore rounding mode to default (nearest) mode for /QIfist compiler option
 
 }
 
@@ -304,7 +306,7 @@ void compensate_plane_bilinear (BYTE *dstp,  int dst_pitch, const BYTE * srcp,
 
 	int rowgoodstart, rowgoodend, rowbadstart, rowbadend;
 
-	_controlfp(_MCW_RC, _RC_CHOP); // set rounding mode to truncate to zero mode (C++ standard) for /QIfist compiler option (which is for faster float-int conversion)
+	//_controlfp(_MCW_RC, _RC_CHOP); // set rounding mode to truncate to zero mode (C++ standard) for /QIfist compiler option (which is for faster float-int conversion)
 
 	// prepare interpolation coefficients tables
 	// for position of xsrc in integer grid
@@ -394,7 +396,7 @@ void compensate_plane_bilinear (BYTE *dstp,  int dst_pitch, const BYTE * srcp,
 
 					if ( rowleft < 0 && mleft) {
 						if (blurmax>0) {
-							blurlen = min(blurmax, -rowleft);
+							blurlen = std::min(blurmax, -rowleft);
 							smoothed = 0;
 							for (i=-rowleft-blurlen+1; i<= -rowleft; i++)
 								smoothed += srcp[w0 + i];
@@ -406,7 +408,7 @@ void compensate_plane_bilinear (BYTE *dstp,  int dst_pitch, const BYTE * srcp,
 					}
 					else if ( rowleft >= row_size-1 && mright) {
 						if (blurmax>0) {
-							blurlen = min(blurmax, rowleft-row_size+2); // v.1.10.1
+							blurlen = std::min(blurmax, rowleft-row_size+2); // v.1.10.1
 							smoothed = 0;
 							for (i=row_size+row_size-rowleft-2; i< row_size+row_size-rowleft-2+blurlen; i++)
 								smoothed += srcp[w0 + i];
@@ -504,7 +506,7 @@ void compensate_plane_bilinear (BYTE *dstp,  int dst_pitch, const BYTE * srcp,
 						pixel = ( intcoef2dzoom[ix2]*srcp[w] + intcoef2dzoom[ix2+1]*srcp[w+1]  + \
 								intcoef2dzoom[ix2+66]*srcp[w+src_pitch] + intcoef2dzoom[ix2+67]*srcp[w+src_pitch+1] )>>10; // v1.6
 
-//						dstp[row] = max(min(pixel,255),0);
+//						dstp[row] = std::max(std::min(pixel,255),0);
 						dstp[row] = pixel;   // maxmin disabled in v1.6
 					}
 					else if ( rowleft < 0 && mleft) {
@@ -512,7 +514,7 @@ void compensate_plane_bilinear (BYTE *dstp,  int dst_pitch, const BYTE * srcp,
 					}
 					else if ( rowleft >= row_size-1 && mright) {
 						if (blurmax>0) {
-							blurlen = min(blurmax, rowleft-row_size+2); // v1.10.1
+							blurlen = std::min(blurmax, rowleft-row_size+2); // v1.10.1
 							smoothed = 0;
 							for (i=row_size + row_size - rowleft -2; i<row_size + row_size - rowleft -2+blurlen ; i++)
 								smoothed += srcp[w0 + i];
@@ -584,7 +586,7 @@ void compensate_plane_bilinear (BYTE *dstp,  int dst_pitch, const BYTE * srcp,
 					pixel = ( (intcoef[ix2]*srcp[w0] + intcoef[ix2+1]*srcp[w0+1] )*intcoef[iy2] + \
 							(intcoef[ix2]*srcp[w0+src_pitch] + intcoef[ix2+1]*srcp[w0+src_pitch+1] )*intcoef[iy2+1] )>>10;
 
-//					dstp[row] = max(min(pixel,255),0);
+//					dstp[row] = std::max(std::min(pixel,255),0);
 					dstp[row] = pixel;       //maxmin disabled in v1.6
 				}
 				else {
@@ -608,7 +610,7 @@ void compensate_plane_bilinear (BYTE *dstp,  int dst_pitch, const BYTE * srcp,
 		} //end for h
 	} // end if rotation
 
-	_controlfp(_MCW_RC, _RC_NEAR); // restore rounding mode to default (nearest) mode for /QIfist compiler option
+	//_controlfp(_MCW_RC, _RC_NEAR); // restore rounding mode to default (nearest) mode for /QIfist compiler option
 
 }
 
@@ -649,7 +651,7 @@ void compensate_plane_bicubic (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 	int mleft = mirror & MIRROR_LEFT;
 	int mright = mirror & MIRROR_RIGHT;
 
-	_controlfp(_MCW_RC, _RC_CHOP); // set rounding mode to truncate to zero mode (C++ standard) for /QIfist compiler option (which is for faster float-int conversion)
+	//_controlfp(_MCW_RC, _RC_CHOP); // set rounding mode to truncate to zero mode (C++ standard) for /QIfist compiler option (which is for faster float-int conversion)
 
 	// prepare interpolation coefficients tables
 	// for position of xsrc in integer grid
@@ -723,12 +725,12 @@ void compensate_plane_bicubic (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 								intcoef2d[8]*srcp[w+src_pitch-1] + intcoef2d[9]*srcp[w+src_pitch] +	 intcoef2d[10]*srcp[w+src_pitch+1] + intcoef2d[11]*srcp[w+src_pitch+2] + \
 								intcoef2d[12]*srcp[w+src_pitch*2-1] + intcoef2d[13]*srcp[w+src_pitch*2] + intcoef2d[14]*srcp[w+src_pitch*2+1] + intcoef2d[15]*srcp[w+src_pitch*2+2] ) >>11;  // i.e. /2048
 
-						dstp[row] = max(min(pixel,255),0);
+						dstp[row] = std::max(std::min(pixel,255),0);
 
 					}
 					else if ( rowleft < 0 && mleft) {
 						if (blurmax>0) {
-							blurlen = min(blurmax, -rowleft);
+							blurlen = std::min(blurmax, -rowleft);
 							smoothed = 0;
 							for (i=-rowleft-blurlen+1; i<= -rowleft; i++)
 								smoothed += srcp[w0 + i];
@@ -740,7 +742,7 @@ void compensate_plane_bicubic (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 					}
 					else if ( rowleft >= row_size && mright) {
 						if (blurmax>0) {
-							blurlen = min(blurmax, rowleft-row_size+1);
+							blurlen = std::min(blurmax, rowleft-row_size+1);
 							smoothed = 0;
 							for (i=row_size + row_size - rowleft -2; i<row_size + row_size - rowleft -2+blurlen ; i++)
 								smoothed += srcp[w0 + i];
@@ -864,11 +866,11 @@ void compensate_plane_bicubic (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 
 						pixel =  (intcoef[iy4]*ts[0] + intcoef[iy4+1]*ts[1] +  intcoef[iy4+2]*ts[2] + intcoef[iy4+3]*ts[3] )>>22;
 
-						dstp[row] = max(min(pixel,255),0);
+						dstp[row] = std::max(std::min(pixel,255),0);
 					}
 					else if ( rowleft < 0 && mleft) {
 						if (blurmax>0) {
-							blurlen = min(blurmax, -rowleft);
+							blurlen = std::min(blurmax, -rowleft);
 							smoothed = 0;
 							for (i=-rowleft-blurlen+1; i<= -rowleft; i++)
 								smoothed += srcp[w0 + i];
@@ -880,7 +882,7 @@ void compensate_plane_bicubic (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 					}
 					else if ( rowleft >= row_size && mright) {
 						if (blurmax>0) {
-							blurlen = min(blurmax, rowleft-row_size+1);
+							blurlen = std::min(blurmax, rowleft-row_size+1);
 							smoothed = 0;
 							for (i=row_size + row_size - rowleft -2; i<row_size + row_size - rowleft -2+blurlen ; i++)
 								smoothed += srcp[w0 + i];
@@ -907,7 +909,7 @@ void compensate_plane_bicubic (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 						w = w0 + rowleft;
 						pixel = (int)( (1.0-sy)*( (1.0-sx)*srcp[w] + sx*srcp[w+1] ) + \
 							sy*((1.0-sx)*srcp[w+src_pitch] + sx*srcp[w+src_pitch+1] ) ); // bilinear
-						dstp[row] = max(min(pixel,255),0);
+						dstp[row] = std::max(std::min(pixel,255),0);
 					}
 					else if ( rowleft == row_size-1) { // added in v.1.1.1
 						dstp[row]= srcp[rowleft + w0];
@@ -1006,7 +1008,7 @@ void compensate_plane_bicubic (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 						iy4 = ((int)((ysrc-hlow)*256))<<2; //changed to shift in v.1.1.1
 
 						pixel =  (intcoef[iy4]*ts[0] + intcoef[iy4+1]*ts[1] +  intcoef[iy4+2]*ts[2] + intcoef[iy4+3]*ts[3] )>>22;
-						dstp[row] = max(min(pixel,255),0);
+						dstp[row] = std::max(std::min(pixel,255),0);
 				}
 				else {
 					if (hlow < 0 && mtop) hlow = - hlow;  // mirror borders
@@ -1027,7 +1029,7 @@ void compensate_plane_bicubic (BYTE *dstp,  int dst_pitch, const BYTE * srcp,  i
 		} //end for h
 	} // end if rotation
 
-	_controlfp(_MCW_RC, _RC_NEAR); // restore rounding mode to default (nearest) mode for /QIfist compiler option
+	//_controlfp(_MCW_RC, _RC_NEAR); // restore rounding mode to default (nearest) mode for /QIfist compiler option
 
 }
 
diff --git a/scenes.cpp b/scenes.cpp
index 098c6ea..fe7d768 100644
--- a/scenes.cpp
+++ b/scenes.cpp
@@ -31,7 +31,7 @@
 
 */
 
-#include "windows.h"
+#include "windowsPorts/windows2linux.h"
 #include "avisynth.h"
 #include "stdio.h"
 
diff --git a/stabilize.cpp b/stabilize.cpp
index 7a48a66..03e7f51 100644
--- a/stabilize.cpp
+++ b/stabilize.cpp
@@ -56,7 +56,9 @@
 
 */
 
-#include "windows.h"
+#include <algorithm>
+
+#include "windowsPorts/windows2linux.h"
 #include "avisynth.h"
 #include "math.h"
 #include "float.h"
@@ -215,8 +217,8 @@ DePanStabilize::DePanStabilize(PClip _child, PClip _DePanData, float _cutoff,
 
 //	matchfields =1;
 
-//	zoommax = max(zoommax, initzoom); // v1.7 to prevent user error
-	zoommax = zoommax > 0 ? max(zoommax, initzoom) : -max(-zoommax, initzoom) ; // v1.8.2
+//	zoommax = std::max(zoommax, initzoom); // v1.7 to prevent user error
+	zoommax = zoommax > 0 ? std::max(zoommax, initzoom) : -std::max(-zoommax, initzoom) ; // v1.8.2
 
 	int fieldbased = (vi.IsFieldBased()) ? 1 : 0;
 	TFF = (vi.IsTFF() ) ? 1 : 0;
@@ -360,9 +362,9 @@ DePanStabilize::DePanStabilize(PClip _child, PClip _DePanData, float _cutoff,
 
 	winrz = (float *)malloc((wintsize+1)*sizeof(float));
 	winfz = (float *)malloc((wintsize+1)*sizeof(float));
-	winrzsize = min(wintsize,int(fps*tzoom/4));
-//	winfzsize = min(wintsize,int(fps*tzoom*1.5/4));
-	winfzsize = min(wintsize,int(fps*tzoom/4));
+	winrzsize = std::min(wintsize,int(fps*tzoom/4));
+//	winfzsize = std::min(wintsize,int(fps*tzoom*1.5/4));
+	winfzsize = std::min(wintsize,int(fps*tzoom/4));
 	for (int i=0; i<winrzsize; i++)
 		winrz[i] = cosf(i*0.5f*PI/winrzsize);
 	for (int i=winrzsize; i<=wintsize; i++)
@@ -598,11 +600,11 @@ void DePanStabilize::Average(int nbase, int ndest, int nmax, transform * ptrdif)
 			trsmoothed[ndest].dyx = -trsmoothed[ndest].dxy*(pixaspect/nfields)*(pixaspect/nfields); // must be consistent
 			norm = 0;
 			trsmoothed[ndest].dxx = 0;
-			for (n=max(nbase, ndest-1); n<ndest; n++) { // very short interval
+			for (n=std::max(nbase, ndest-1); n<ndest; n++) { // very short interval
 				trsmoothed[ndest].dxx += trcumul[n].dxx*wint[ndest-n];
 				norm += wint[ndest-n];
 			}
-			for (n=ndest; n<=min(nmax,ndest+1); n++) {
+			for (n=ndest; n<=std::min(nmax,ndest+1); n++) {
 				trsmoothed[ndest].dxx += trcumul[n].dxx*wint[n-ndest];
 				norm += wint[n-ndest];
 			}
@@ -614,11 +616,11 @@ void DePanStabilize::Average(int nbase, int ndest, int nmax, transform * ptrdif)
 
 			if (addzoom) { // calculate and add adaptive zoom factor to fill borders (for all frames from base to ndest)
 
-				int nbasez = max(nbase, ndest-winfzsize);
-				int nmaxz = min(nmax, ndest+winrzsize);
+				int nbasez = std::max(nbase, ndest-winfzsize);
+				int nmaxz = std::min(nmax, ndest+winrzsize);
             	// symmetrical
- //               nmaxz = ndest + min(nmaxz-ndest, ndest-nbasez);
- //               nbasez = ndest - min(nmaxz-ndest, ndest-nbasez);
+ //               nmaxz = ndest + std::min(nmaxz-ndest, ndest-nbasez);
+ //               nbasez = ndest - std::min(nmaxz-ndest, ndest-nbasez);
 
 				azoom[nbasez] = initzoom;
 				for (n=nbasez+1; n<=nmaxz; n++) {
@@ -692,7 +694,7 @@ void DePanStabilize::Average(int nbase, int ndest, int nmax, transform * ptrdif)
 void DePanStabilize::InertialLimit(float *dxdif, float *dydif, float *zoomdif, float *rotdif, int ndest, int *nbase)
 {
 		// limit max motion corrections
-		if ( !(_finite(*dxdif)) ) // check added in v.1.1.3
+		if ( !(isfinite(*dxdif)) ) // check added in v.1.1.3
 		{// infinite or NAN
 				*dxdif = 0;
 				*dydif = 0;
@@ -716,7 +718,7 @@ void DePanStabilize::InertialLimit(float *dxdif, float *dydif, float *zoomdif, f
 			}
 		}
 
-		if ( !(_finite(*dydif)) )
+		if ( !(isfinite(*dydif)) )
 		{// infinite or NAN
 				*dxdif = 0;
 				*dydif = 0;
@@ -740,7 +742,7 @@ void DePanStabilize::InertialLimit(float *dxdif, float *dydif, float *zoomdif, f
 			}
 		}
 
-		if ( !(_finite(*zoomdif)) )
+		if ( !(isfinite(*zoomdif)) )
 		{// infinite or NAN
 				*dxdif = 0;
 				*dydif = 0;
@@ -764,7 +766,7 @@ void DePanStabilize::InertialLimit(float *dxdif, float *dydif, float *zoomdif, f
 			}
 		}
 
-		if ( !(_finite(*rotdif)) )
+		if ( !(isfinite(*rotdif)) )
 		{// infinite or NAN
 				*dxdif = 0;
 				*dydif = 0;
@@ -796,9 +798,9 @@ float DePanStabilize::Averagefraction(float dxdif, float dydif, float zoomdif, f
 	float fractionz = fabsf(zoomdif-1) / fabsf((fabsf(zoommax)-1));
 	float fractionr = fabsf(rotdif) / fabsf(rotmax);
 
-	float fraction = max(fractionx, fractiony);
-	fraction = max(fraction, fractionz);
-	fraction = max(fraction, fractionr);
+	float fraction = std::max(fractionx, fractiony);
+	fraction = std::max(fraction, fractionz);
+	fraction = std::max(fraction, fractionr);
 	return fraction;
 
 }
@@ -858,7 +860,7 @@ PVideoFrame __stdcall DePanStabilize::GetFrame(int ndest, IScriptEnvironment* en
 	if (method == 0) // inertial
 		nmax = ndest;
 	else
-		nmax = min(ndest + radius, vi.num_frames-1); // max n to take into account
+		nmax = std::min(ndest + radius, vi.num_frames-1); // max n to take into account
 
 	// get motion info about frames in interval from begin source to dest in reverse order
 	for (n = nbase; n <= ndest; n++) {
@@ -916,13 +918,13 @@ PVideoFrame __stdcall DePanStabilize::GetFrame(int ndest, IScriptEnvironment* en
 //		OutputDebugString(debugbuf);
 	// limit frame search range
 	if (n < nmax) {
-		nmax = max(n-1, ndest);  // set max frame to new scene start-1 if found
+		nmax = std::max(n-1, ndest);  // set max frame to new scene start-1 if found
 	}
 
 	if (method != 0)
 	{	// symmetrical
-		nmax = ndest + min(nmax-ndest, ndest-nbase);
-		nbase = ndest - min(nmax-ndest, ndest-nbase);
+		nmax = ndest + std::min(nmax-ndest, ndest-nbase);
+		nbase = ndest - std::min(nmax-ndest, ndest-nbase);
 	}
 
 //		sprintf(debugbuf,"DePanStabilize: nbase=%d ndest=%d nmax=%d\n", nbase, ndest, nmax);
@@ -981,8 +983,8 @@ PVideoFrame __stdcall DePanStabilize::GetFrame(int ndest, IScriptEnvironment* en
 			{
 				// decrease radius
 				radius1 = radius1*0.9;
-				nbase = max(nbase, ndest - radius1);
-				nmax = min(nmax, ndest + radius1);
+				nbase = std::max(nbase, ndest - radius1);
+				nmax = std::min(nmax, ndest + radius1);
 				// update wint and may be winz
 					float PI = 3.14159265258;
 					for (int i=0; i<radius1; i++)
@@ -995,7 +997,7 @@ PVideoFrame __stdcall DePanStabilize::GetFrame(int ndest, IScriptEnvironment* en
 				if (radius1 != radius) // was decreased
 					break;
 				// increase radius
-				radius1 = min(radius + 1, wintsize);
+				radius1 = std::min(radius + 1, wintsize);
 				if (radius1 != radius)
 				{
 					// update wint and may be winz
diff --git a/transform.cpp b/transform.cpp
index 8025504..a2ac4f1 100644
--- a/transform.cpp
+++ b/transform.cpp
@@ -20,7 +20,7 @@
 
 */
 
-#include "windows.h"
+#include "windowsPorts/windows2linux.h"
 //#include "avisynth.h"
 #include "math.h"
 
