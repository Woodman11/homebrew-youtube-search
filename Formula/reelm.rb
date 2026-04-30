class Reelm < Formula
  desc "Save & search YouTube transcripts locally (Chrome ext + local server)"
  homepage "https://github.com/Woodman11/reelm"
  url "https://github.com/Woodman11/reelm/archive/refs/tags/v0.2.2.tar.gz"
  sha256 "7dcffee2a9ac3fcc13ac66a3e12fe2549383a4780aa156c21b9bcc886f62ecbf"
  license "MIT"

  depends_on "python@3.13"
  depends_on "yt-dlp"

  def install
    (var/"log/reelm").mkpath
    libexec.install "paths.py", "server.py", "maintain.py", "search.py", "extension"

    # Use the versioned python3.13 binary — the bare `python3` symlink
    # isn't always present (e.g. on GitHub Actions macOS runners).
    py = Formula["python@3.13"].opt_bin/"python3.13"
    ytdlp_bin = Formula["yt-dlp"].opt_bin

    {
      "server"   => "reelm-server",
      "maintain" => "reelm-maintain",
      "search"   => "reelm",
    }.each do |script, cmd|
      (bin/cmd).write <<~SH
        #!/bin/bash
        export PATH="#{ytdlp_bin}:$PATH"
        exec "#{py}" "#{libexec}/#{script}.py" "$@"
      SH
    end
  end

  def post_install
    system "mkdir", "-p", "#{Dir.home}/Library/Logs/reelm"
    system "mkdir", "-p", "#{Dir.home}/Library/Application Support/Reelm"
  end

  service do
    run [opt_bin/"reelm-server"]
    keep_alive true
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
      Find reeLm and enable it, then: brew services restart reelm

      The maintenance job (retry failed transcripts, optimize FTS, vacuum,
      rotate logs) is not auto-scheduled by this formula. Run it manually
      with `reelm-maintain`, or schedule it via launchd/cron.

      Database:  ~/Library/Application Support/Reelm/videos.db
      Logs:      ~/Library/Logs/reelm/server.log
    EOS
  end

  test do
    system bin/"reelm", "--help"
  end
end
