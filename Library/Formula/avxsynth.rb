require 'formula'

class Avxsynth < Formula
  homepage 'https://github.com/avxsynth/avxsynth/wiki'
  #version '4.0'
  #url 'https://github.com/avxsynth/avxsynth/tarball/master'
  #sha1 '8238853d3ac1511f8a9fe425cc4b1abd95a43122'

  head 'https://github.com/avxsynth/avxsynth.git'

  depends_on 'automake'
  depends_on 'libtool'
  #depends_on 'log4cpp'
  depends_on :x11
  depends_on 'pango'
  #depends_on 'cairo'
  depends_on 'fontconfig'
  depends_on 'freetype'
  depends_on 'libpng'
  depends_on 'qt'

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
    # apply pull request 84 (OSX Support)
    "https://github.com/avxsynth/avxsynth/pull/84.diff"
  end

end
