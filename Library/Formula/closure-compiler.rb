require 'formula'

class ClosureCompiler < Formula
  homepage 'http://code.google.com/p/closure-compiler/'
  # Use an SVN download to get the externals as well
  url 'svn+http://closure-compiler.googlecode.com/svn/trunk/', :revision => '2180'
  version '20120917'

  head 'svn+http://closure-compiler.googlecode.com/svn/trunk/'

  def install
    system "ant", "clean"
    system "ant"

    libexec.install Dir['*']

    (bin/'closure-compiler').write <<-EOS.undent
      #!/bin/bash
      java -jar "#{libexec}/build/compiler.jar" "$@"
    EOS
  end
end
