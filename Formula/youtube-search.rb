class YoutubeSearch < Formula
  desc "Save & search YouTube transcripts locally (Chrome ext + local server)"
  homepage "https://github.com/Woodman11/youtube-search"
  url "https://github.com/Woodman11/youtube-search/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "d733177818b06399357274bf67db96b6559d429e382d92ba133a92b8e863f8e3"

  depends_on "python@3.13"
  depends_on "yt-dlp"

  def install
    libexec.install "paths.py", "server.py", "maintain.py", "search.py", "extension"

    py = Formula["python@3.13"].opt_bin/"python3"
    ytdlp_bin = Formula["yt-dlp"].opt_bin

    {
      "server"   => "youtube-search-server",
      "maintain" => "youtube-search-maintain",
      "search"   => "youtube-search",
    }.each do |script, cmd|
      (bin/cmd).write <<~SH
        #!/bin/bash
        export PATH="#{ytdlp_bin}:$PATH"
        exec "#{py}" "#{libexec}/#{script}.py" "$@"
      SH
    end
  end

  service do
    run [opt_bin/"youtube-search-server"]
    keep_alive true
    log_path var/"log/youtube-search/server.log"
    error_log_path var/"log/youtube-search/server.log"
  end

  def caveats
    <<~EOS
      Chrome extension (manual one-time step):
        1. Open chrome://extensions
        2. Enable Developer mode (top right)
        3. Load unpacked → #{libexec}/extension
        4. Pin the icon if you want the popup search

      Start the server in the background:
        brew services start youtube-search

      The maintenance job (retry failed transcripts, optimize FTS, vacuum,
      rotate logs) is not auto-scheduled by this formula. Run it manually
      with `youtube-search-maintain`, or schedule it via launchd/cron.

      Database lives at: ~/Library/Application Support/MyYouTubeSearch/
    EOS
  end

  test do
    system bin/"youtube-search", "--help"
  end
end
