require 'formula'

class Ffms2 < Formula
  homepage 'http://code.google.com/p/ffmpegsource/'
  url 'http://ffmpegsource.googlecode.com/files/ffms-2.17-src.tar.bz2'
  version '2.17'
  sha1 '3bbd5b5f13dce4374efdd3e2bf048436295e6771'

  depends_on 'pkg-config'
  depends_on 'ffmpeg'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--enable-shared"
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
diff --git a/configure b/configure
index a7929a6..05df205 100755
--- a/configure
+++ b/configure
@@ -15716,7 +15716,7 @@ int
 main ()
 {
 
-                avcodec_init();
+                avcodec_register_all();
                 swscale_version();
                 #ifdef FFMS_USE_FFMPEG_COMPAT
                 int bogus = CODEC_ID_G2M;
@@ -15759,7 +15759,7 @@ int
 main ()
 {
 
-                avcodec_init();
+                avcodec_register_all();
                 swscale_version();
                 #ifdef FFMS_USE_FFMPEG_COMPAT
                 int bogus = CODEC_ID_G2M;
@@ -15790,7 +15790,7 @@ int
 main ()
 {
 
-                avcodec_init();
+                avcodec_register_all();
                 swscale_version();
                 #ifdef FFMS_USE_FFMPEG_COMPAT
                 int bogus = CODEC_ID_G2M;
diff --git a/src/core/matroskaaudio.cpp b/src/core/matroskaaudio.cpp
index 6e295aa..98688d6 100644
--- a/src/core/matroskaaudio.cpp
+++ b/src/core/matroskaaudio.cpp
@@ -45,7 +45,7 @@ FFMatroskaAudio::FFMatroskaAudio(const char *SourceFile, int Track, FFMS_Index &
 	CodecContext.reset(avcodec_alloc_context3(NULL), DeleteMatroskaCodecContext);
 	assert(CodecContext);
 
-	AVCodec *Codec = avcodec_find_decoder(MatroskaToFFCodecID(TI->CodecID, TI->CodecPrivate, 0, TI->AV.Audio.BitDepth));
+	AVCodec *Codec = avcodec_find_decoder(MatroskaToFFCodecID(TI->TICodecID, TI->CodecPrivate, 0, TI->AV.Audio.BitDepth));
 	if (!Codec) {
 		mkv_Close(MF);
 		throw FFMS_Exception(FFMS_ERROR_DECODING, FFMS_ERROR_CODEC, "Audio codec not found");
diff --git a/src/core/matroskaindexer.cpp b/src/core/matroskaindexer.cpp
index b90a4f9..3cbd739 100644
--- a/src/core/matroskaindexer.cpp
+++ b/src/core/matroskaindexer.cpp
@@ -50,7 +50,7 @@ FFMatroskaIndexer::FFMatroskaIndexer(const char *Filename) : FFMS_Indexer(Filena
 
 	for (unsigned int i = 0; i < mkv_GetNumTracks(MF); i++) {
 		TrackInfo *TI = mkv_GetTrackInfo(MF, i);
-		Codec[i] = avcodec_find_decoder(MatroskaToFFCodecID(TI->CodecID, TI->CodecPrivate, 0, TI->AV.Audio.BitDepth));
+		Codec[i] = avcodec_find_decoder(MatroskaToFFCodecID(TI->TICodecID, TI->CodecPrivate, 0, TI->AV.Audio.BitDepth));
 	}
 }
 
diff --git a/src/core/matroskaparser.c b/src/core/matroskaparser.c
index 8a7b22b..3f9c14e 100644
--- a/src/core/matroskaparser.c
+++ b/src/core/matroskaparser.c
@@ -1366,9 +1366,9 @@ static void parseTrackEntry(MatroskaFile *mf,ulonglong toplen) {
       readLangCC(mf, len, t.Language);
       break;
     case 0x86: // CodecID
-      if (t.CodecID)
+      if (t.TICodecID)
 	errorjmp(mf,"Duplicate CodecID");
-      STRGETA(mf,t.CodecID,len);
+      STRGETA(mf,t.TICodecID,len);
       break;
     case 0x63a2: // CodecPrivate
       if (cp)
@@ -1459,7 +1459,7 @@ static void parseTrackEntry(MatroskaFile *mf,ulonglong toplen) {
   ENDFOR(mf);
 
   // validate track info
-  if (!t.CodecID)
+  if (!t.TICodecID)
     errorjmp(mf,"Track has no Codec ID");
 
   if (t.UID != 0) {
@@ -1525,8 +1525,8 @@ static void parseTrackEntry(MatroskaFile *mf,ulonglong toplen) {
   // copy strings
   if (t.Name)
     cpadd += strlen(t.Name)+1;
-  if (t.CodecID)
-    cpadd += strlen(t.CodecID)+1;
+  if (t.TICodecID)
+    cpadd += strlen(t.TICodecID)+1;
 
   tp = mf->cache->memalloc(mf->cache,sizeof(*tp) + cplen + cslen + cpadd);
   if (tp == NULL)
@@ -1546,7 +1546,7 @@ static void parseTrackEntry(MatroskaFile *mf,ulonglong toplen) {
 
   cp = (char*)(tp+1) + cplen + cslen;
   CopyStr(&tp->Name,&cp);
-  CopyStr(&tp->CodecID,&cp);
+  CopyStr(&tp->TICodecID,&cp);
 
   // set default language
   if (!tp->Language[0])
diff --git a/src/core/matroskaparser.h b/src/core/matroskaparser.h
index b3e1f75..6aeca2f 100644
--- a/src/core/matroskaparser.h
+++ b/src/core/matroskaparser.h
@@ -161,7 +161,7 @@ struct TrackInfo {
   /* various strings */
   char			*Name;
   char			Language[4];
-  char			*CodecID;
+  char			*TICodecID;
 };
 
 typedef struct TrackInfo  TrackInfo;
diff --git a/src/core/matroskavideo.cpp b/src/core/matroskavideo.cpp
index 02230e2..903ff0b 100644
--- a/src/core/matroskavideo.cpp
+++ b/src/core/matroskavideo.cpp
@@ -71,7 +71,7 @@ FFMatroskaVideo::FFMatroskaVideo(const char *SourceFile, int Track,
 		CodecContext->thread_count = 1;
 #endif
 
-	Codec = avcodec_find_decoder(MatroskaToFFCodecID(TI->CodecID, TI->CodecPrivate));
+	Codec = avcodec_find_decoder(MatroskaToFFCodecID(TI->TICodecID, TI->CodecPrivate));
 	if (Codec == NULL)
 		throw FFMS_Exception(FFMS_ERROR_DECODING, FFMS_ERROR_CODEC,
 			"Video codec not found");
diff --git a/src/core/utils.cpp b/src/core/utils.cpp
index 441cf71..93a4b15 100644
--- a/src/core/utils.cpp
+++ b/src/core/utils.cpp
@@ -256,7 +256,7 @@ void InitializeCodecContextFromMatroskaTrackInfo(TrackInfo *TI, AVCodecContext *
 	uint8_t *PrivateDataSrc = static_cast<uint8_t *>(TI->CodecPrivate);
 	size_t PrivateDataSize = TI->CodecPrivateSize;
 	size_t BIHSize = sizeof(FFMS_BITMAPINFOHEADER); // 40 bytes
-	if (!strncmp(TI->CodecID, "V_MS/VFW/FOURCC", 15) && PrivateDataSize >= BIHSize) {
+	if (!strncmp(TI->TICodecID, "V_MS/VFW/FOURCC", 15) && PrivateDataSize >= BIHSize) {
 		// For some reason UTVideo requires CodecContext->codec_tag (i.e. the FourCC) to be set.
 		// Fine, it can't hurt to set it, so let's go find it.
 		// In a V_MS/VFW/FOURCC track, the codecprivate starts with a BITMAPINFOHEADER. If you treat that struct

