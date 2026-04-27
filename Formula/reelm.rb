class Reelm < Formula
  desc "Save & search YouTube transcripts locally (Chrome ext + local server)"
  homepage "https://github.com/Woodman11/youtube-search"
  url "https://github.com/Woodman11/youtube-search/archive/refs/tags/v0.2.2.tar.gz"
  sha256 "7f77d64e19bc8027a50410d0c117ddbf0da0a6c4ee7e072faed4d891d85b6e99"
  license "MIT"

  depends_on "python@3.13"
  depends_on "yt-dlp"

  def install
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

  service do
    run [opt_bin/"reelm-server"]
    keep_alive true
    log_path var/"log/reelm/server.log"
    error_log_path var/"log/reelm/server.log"
  end

  def caveats
    <<~EOS
      Chrome extension (manual one-time step):
        1. Open chrome://extensions
        2. Enable Developer mode (top right)
        3. Load unpacked → #{libexec}/extension
        4. Pin the icon if you want the popup search

      Start the server in the background:
        brew services start reelm

      The maintenance job (retry failed transcripts, optimize FTS, vacuum,
      rotate logs) is not auto-scheduled by this formula. Run it manually
      with `reelm-maintain`, or schedule it via launchd/cron.

      Database lives at: ~/Library/Application Support/Reelm/
      (an existing ~/Library/Application Support/MyYouTubeSearch/ DB will
      be migrated automatically on first run.)
    EOS
  end

  test do
    system bin/"reelm", "--help"
  end
end
