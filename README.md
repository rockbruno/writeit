# WriteIt
## 💻 macOS CLI static HTML page generator for blogs

Given a template html file containing a placeholder `<div>` and a list of "content" files (like blog posts), WriteIt merges the two together to generate a complete static website. This is used by https://swiftrocks.com to effortlessly publish a static website where the pages all have the same "shell", but with different contents:

<img src="https://i.imgur.com/UiNjggR.png" width=400>
<img src="https://i.imgur.com/DzWE9kz.png" width=400>

WriteIt can also assist in the creation of new posts by bootstrapping a started file containing all necessary properties. WriteIt is highly configurable and also supports generating sitemaps, RSS, and structured JSON objects for SEO.

## Installation

Download the latest release and put it in your `/usr/local/bin` (or wherever else you'd like it), or build it from source via Swift Package Manager:

```bash
swift build -c release
```

## Usage

WriteIt was developed for personal usage, so no docs or support is available at this time.
