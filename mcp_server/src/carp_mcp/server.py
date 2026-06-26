import os
from pathlib import Path

import httpx
import yaml
from fastmcp import FastMCP

DEFAULT_SPEC = Path(__file__).resolve().parents[3] / "openapi" / "openapi.yaml"


def main() -> None:
    spec_path = Path(os.environ.get("CARP_OPENAPI_PATH", DEFAULT_SPEC))
    base_url = os.environ.get("CARP_API_BASE_URL", "http://localhost:8080")
    transport = os.environ.get("CARP_MCP_TRANSPORT", "stdio")

    spec = yaml.safe_load(spec_path.read_text())
    client = httpx.AsyncClient(base_url=base_url)
    mcp = FastMCP.from_openapi(
        openapi_spec=spec,
        client=client,
        name="CARP Authoring",
    )
    mcp.run(transport=transport)


if __name__ == "__main__":
    main()
