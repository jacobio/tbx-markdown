# An Enhanced Markdown Prototype for Tinderbox

> [!CAUTION]
> This installer will **replace/update the built-in Markdown prototype** in your Tinderbox document. Any customizations you have made to the existing Markdown prototype may be overwritten.

A one-line installer that adds an enhanced Markdown writing environment to any [Tinderbox](https://www.eastgate.com/Tinderbox/) document — with syntax highlighting, GitHub-styled preview, and HTML export. Includes [Mermaid](https://mermaid.js.org/) diagrams, [MathJax](https://www.mathjax.org/) math rendering, and [Prism](https://prismjs.com/) code highlighting out of the box.

If [MultiMarkdown](https://fletcherpenney.net/multimarkdown/) (`mmd`) is installed, the prototype uses it for HTML preview with sed post-processing fixes. Otherwise, it falls back to Tinderbox's built-in CommonMark parser.

## Install

Open any Tinderbox document, create a stamp with the following action code, and run it:

```
action(runCommand("curl -s https://raw.githubusercontent.com/jacobio/tbx-markdown/main/install.tbxc"));
```

All components are fetched from this repo at install time. The installer is safe to re-run.

## What Gets Installed

| Component | Path | Purpose |
|-----------|------|---------|
| **Prototypes** | `/Prototypes/Markdown` | Markdown writing prototype with syntax highlighting and preview |
| | `/Prototypes/Code` | Code/asset export prototype (raw text, no HTML markup) |
| **Highlighter** | `/Hints/Highlighters/Markdown` | Syntax highlighting for headings, bold, italic, links, code, etc. |
| **Templates** | `/Templates/Text Only` | Plain text export (used by Code prototype) |
| | `/Templates/HTML MD and Children` | Full HTML page with Prism, MathJax, and Mermaid support |
| **Assets** | `/Assets/Custom Styles` | Your CSS overrides (edit to customize) |
| **README** | `/README (Markdown)` | In-document documentation |

### Mermaid, MathJax, and Prism

The HTML template includes CDN-loaded support for:

- **[Mermaid](https://mermaid.js.org/)** — Diagrams and flowcharts. Use a fenced code block with the `mermaid` language tag. Automatically respects light/dark mode.
- **[MathJax](https://www.mathjax.org/)** — Math rendering. Use `\(...\)` for inline math and `\[...\]` or `$$...$$` for display math.
- **[Prism](https://prismjs.com/)** — Syntax highlighting for code blocks. Use fenced code blocks with a language tag (e.g., ` ```javascript `). Includes copy-to-clipboard and GitHub-themed light/dark styles.

These work in both Preview and HTML export with no additional setup.

### MultiMarkdown Detection

The installer checks for `mmd` on your system by sourcing `~/.zprofile` before running `which mmd`, with fallbacks to known Homebrew paths (`/opt/homebrew/bin/mmd`, `/usr/local/bin/mmd`) and system paths (`/usr/bin/mmd`). If found, it sets `$HTMLPreviewCommand` to pipe through `mmd` with sed post-processing that fixes links to internal and exported notes:

- Leading slashes in href attributes
- Spacing after closing anchor tags
- Bold/italic formatting around links

If `mmd` is not found, the prototype uses Tinderbox's built-in "CommonMark" parser.

## Prerequisites

- [Tinderbox](https://www.eastgate.com/Tinderbox/) (macOS)
- [MultiMarkdown](https://fletcherpenney.net/multimarkdown/) (optional, for enhanced preview)

### Installing MultiMarkdown

MultiMarkdown can be installed via [Homebrew](https://brew.sh/):

```bash
brew install multimarkdown
```

After installing, verify it works:

```bash
mmd --version
```

If you install MultiMarkdown after running the installer, just re-run the stamp to update the prototype.

## Repo Structure

```
tbx-markdown/
├── install.tbxc             # Main installer (fetched by the one-liner)
├── highlighters/
│   └── markdown.tbxc        # Syntax highlighter definitions
├── templates/
│   ├── html-md.html         # HTML page export template
│   └── html-md-item.html    # HTML child item template
├── assets/
│   └── custom-styles.css    # Custom CSS overrides
├── config/
│   └── sed-fixes.sh         # sed pipeline for mmd post-processing
├── readme-markdown.md       # In-document README (installed into Tinderbox)
└── LICENSE
```

## Credits

- GitHub Markdown CSS (CDN) by [Sindre Sorhus](https://github.com/sindresorhus/github-markdown-css)
- GitHub Prism theme by [Katorly](https://github.com/katorlys/prism-theme-github)

## License

MIT
