# carp-mcp

FastMCP sidecar that exposes the CARP authoring HTTP API (see the parent project) as MCP tools by consuming `../openapi/openapi.yaml`.

The sidecar holds no state of its own — it forwards every MCP tool call to the Dart server running on `http://localhost:8080`. Start the Dart server first; this process is a thin client.

## Install

```bash
uv sync
```

This creates `.venv/` and installs `fastmcp`, `httpx`, `pyyaml`.

## Run

Default transport is stdio (for Claude Desktop and other MCP clients):

```bash
uv run carp-mcp
```

For local exploration with the FastMCP inspector:

```bash
uvx fastmcp dev src/carp_mcp/server.py
```

## Configuration

All configuration is via environment variables:

| Variable               | Default                                  | Purpose                                |
| ---------------------- | ---------------------------------------- | -------------------------------------- |
| `CARP_API_BASE_URL`    | `http://localhost:8080`                  | Base URL of the running Dart server.   |
| `CARP_OPENAPI_PATH`    | `<repo>/openapi/openapi.yaml`            | Override the OpenAPI document to load. |
| `CARP_MCP_TRANSPORT`   | `stdio`                                  | `stdio` or `http`.                     |

Example — run over HTTP against a remote server:

```bash
CARP_MCP_TRANSPORT=http \
CARP_API_BASE_URL=https://example.internal \
uv run carp-mcp
```

## How tools map to endpoints

FastMCP generates one MCP tool per OpenAPI operation, named after the `operationId`. Every operation in `openapi.yaml` already has one, so all 45 endpoints surface as tools. Re-run the Dart project's spec generator (`dart run build_runner build --delete-conflicting-outputs`) whenever endpoints change — this sidecar reads the spec at startup.

## Quickstart: connect to Claude Code

From inside `mcp_server/`:

```bash
claude mcp add carp-mcp -- uv run --directory "$(pwd)" carp-mcp
```

That registers the sidecar at local scope (this project, your user). Swap in `--scope user` for global, or `--scope project` to write a checked-in `.mcp.json`. Pass overrides with `--env`, e.g. `--env CARP_API_BASE_URL=http://localhost:9090`.

Start the Dart server first — Claude Code will spawn the sidecar on demand and every tool call is forwarded to `CARP_API_BASE_URL`. Verify with `claude mcp list`; tear down with `claude mcp remove carp-mcp`.
