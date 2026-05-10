class Reelm < Formula
  desc "Save & search YouTube transcripts locally (Chrome ext + local server)"
  homepage "https://github.com/Woodman11/reelm"
  url "https://github.com/Woodman11/reelm/archive/refs/tags/v0.2.5.tar.gz"
  sha256 "a2498d3b510ea256bb3fc3422dd3403938e35e122c8285292a38045ed3065e52"
  license "MIT"

  depends_on "go" => :build
  depends_on "yt-dlp"

  def install
    system "go", "build", "-o", bin/"reelm", "."
    libexec.install "extension"

    (bin/"reelm-maintain").write <<~SH
      #!/bin/bash
      exec "#{bin}/reelm" maintain "$@"
    SH
  end

  def post_install
    FileUtils.mkdir_p "#{Dir.home}/Library/Logs/reelm"
    FileUtils.mkdir_p "#{Dir.home}/Library/Application Support/Reelm"
  rescue StandardError
    nil
  end

  service do
    run [opt_bin/"reelm", "serve"]
    keep_alive true
    environment_variables PATH: "#{Formula["yt-dlp"].opt_bin}:#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    log_path "#{Dir.home}/Library/Logs/reelm/server.log"
    error_log_path "#{Dir.home}/Library/Logs/reelm/server.log"
  end

  def caveats
    <<~EOS
      Chrome extension (manual one-time step):
        1. Open chrome://extensions
        2. Enable Developer mode (top right)
        3. Click Load unpacked — in the dialog press Cmd+Shift+G, paste:
             #{libexec}/extension
           and hit Enter
        4. Pin the icon if you want the popup search

      Start the server in the background:
        brew services start reelm

      If macOS blocks the service at first login, go to:
        System Settings → General → Login Items & Extensions
      Find the magnifying glass entry for reeLm, toggle it OFF then ON,
      then run: brew services restart reelm

      The maintenance job (retry failed transcripts, optimize FTS, vacuum,
      rotate logs) is not auto-scheduled by this formula. Run it manually
      with `reelm-maintain`, or schedule it via launchd/cron.

      Database:  ~/Library/Application Support/Reelm/videos.db
      Logs:      ~/Library/Logs/reelm/server.log
    EOS
  end

  test do
    assert_match "usage", shell_output("#{bin}/reelm 2>&1", 1)
  end
end
