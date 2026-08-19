# Junie Guidelines for this Project

## Node.js and Playwright
Node.js and Playwright are available in this environment, but they are located in a non-standard path managed by NVM.

- **Node.js Path:** `/Users/dloose/.nvm/versions/node/v22.22.2/bin`
- **Browser automation:** use the Playwright MCP server (`@playwright/mcp`), not a local Puppeteer script.

### Usage
To use `node`, `npm`, or `npx` (including the Playwright MCP server), you must prepend the path to the `PATH` environment variable:

```bash
export PATH=$PATH:/Users/dloose/.nvm/versions/node/v22.22.2/bin
node your-script.js
```

Or for single commands:

```bash
PATH=$PATH:/Users/dloose/.nvm/versions/node/v22.22.2/bin npx @playwright/mcp@latest
```

### Playwright MCP
Browser automation (navigation, screenshots, clicking, form-filling) should go through the `playwright` MCP server configured in `.mcp.json`, rather than launching Puppeteer directly.

Typical tools exposed by the server:
- `browser_navigate`: `{ "url": "string" }`
- `browser_take_screenshot`: 
  - `filename` (optional): Path to save the screenshot.
  - `scale` (required): `css` or `device`.
  - `type` (optional): `png`, `jpeg`, or `webp`.
  - `fullPage` (optional): Boolean.
- `browser_click`: `{ "selector": "string" }`
- `browser_snapshot`: Returns a simplified representation of the page.
- `browser_fill_form`: `{ "selector": "string", "value": "string" }`

When using the MCP server via `npx`, ensure the Node.js path is in your environment.

## GitHub (gh CLI)
The `gh` CLI is installed (`/opt/homebrew/bin/gh`) and authenticated as `dirkloose` over HTTPS. This repo's `origin` remote is `https://github.com/dirkloose/open-webui-local.git` (private). Use `gh` for repo/issue/PR operations instead of raw API calls; plain `git push`/`pull` work directly since `gh auth setup-git` configured the credential helper.
