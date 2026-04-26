# homebrew-youtube-search

Homebrew tap for [youtube-search](https://github.com/Woodman11/youtube-search) — a local Chrome extension + Python server that indexes YouTube transcripts in SQLite FTS5.

## Install

```bash
brew tap Woodman11/youtube-search
brew install youtube-search
brew services start youtube-search
```

Then load the bundled Chrome extension (one-time):

1. Open `chrome://extensions`
2. Enable **Developer mode** (top right)
3. Click **Load unpacked** → select the path printed in `brew info youtube-search`'s caveats (`#{libexec}/extension`)

Press **Shift+Y** on any YouTube video to save it, then click the extension icon to search across saved transcripts.

## What gets installed

| Command | Purpose |
|---------|---------|
| `youtube-search` | CLI search (`youtube-search "query"`) |
| `youtube-search-server` | The local HTTP server on `localhost:7799` (auto-started by `brew services`) |
| `youtube-search-maintain` | Retries failed transcripts, optimizes FTS5, rotates logs |

The DB lives at `~/Library/Application Support/MyYouTubeSearch/videos.db`.

## Updating

```bash
brew update
brew upgrade youtube-search
brew services restart youtube-search
```
