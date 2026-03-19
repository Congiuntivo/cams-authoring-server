# Stateful Protocol Authoring Server (Dummy)

This project hosts a small in-memory HTTP server with a minimal state machine. It is intentionally lightweight and framework-free, while still exposing OpenAPI + Swagger docs.

## Behavior

`POST /protocol/new` creates a new in-memory authoring session and returns a `sessionId`.

`GET /state` and `GET /serialize` are session-scoped and require a `sessionId`.

- Provide the session id as query parameter (`?sessionId=<id>`).
- If no session id is provided, the server returns `400`.
- If the session id does not exist, the server returns `404`.

## Endpoints

- `GET /state`
- `POST /protocol/new`
- `GET /serialize`
- `GET /openapi.json`
- `GET /openapi.yaml`
- `GET /docs`

`GET /serialize` returns a stable dummy payload for integration testing.

Example flow:

```bash
SESSION_ID=$(curl -s -X POST http://localhost:8080/protocol/new | jq -r '.sessionId')
curl "http://localhost:8080/state?sessionId=${SESSION_ID}"
curl "http://localhost:8080/serialize?sessionId=${SESSION_ID}"
```

## Linux

### Prerequisites

#### Fedora

```bash
sudo dnf install -y build-essential cmake ninja-build pkg-config gtk3-devel clang
```

### Run

```bash
flutter pub get
flutter run -d linux
```

The local app window only hosts the runtime; the API server itself listens on http://0.0.0.0:8080.

## Architecture

The server uses clean layering with **Shelf routing and middleware**:

- `lib/src/authoring_session.dart` — state machine and dummy serialization model.
- `lib/src/protocol_authoring_service.dart` — application/service logic (use-cases).
- `lib/src/protocol_authoring_request_handler.dart` — composition root for middleware + route registration.
- `lib/src/http/handlers/authoring_routes.dart` — authoring endpoints and OpenAPI annotations.
- `lib/src/http/handlers/docs_routes.dart` — docs/OpenAPI serving endpoints.
- `lib/src/http/response/json_response.dart` — shared JSON response helper.
- `lib/src/openapi.dart` — loads `openapi.yaml`, injects runtime server URL, and serves Swagger HTML.
- `lib/protocol_authoring_server.dart` — server bootstrap (Shelf serving).

### Middleware Pipeline

The Shelf middleware stack includes:

1. **Request logging** — logs incoming requests and responses.
2. **Error handling** — catches `FormatException` (invalid JSON) and general errors, returning appropriate JSON errors.
3. **Route handling** — routes to endpoints and falls back to 404 for unknown paths.

## Automatic API Reference

- OpenAPI spec: `http://localhost:8080/openapi.json`
- OpenAPI YAML source: `http://localhost:8080/openapi.yaml`
- Swagger UI: `http://localhost:8080/docs`

## OpenAPI Generator

This project now uses a code-first setup for endpoint documentation.

- Endpoint docs live next to handlers in `lib/src/protocol_authoring_request_handler.dart` via `@ApiController` and `@ApiOperation` annotations.
- Endpoint docs live next to handlers in `lib/src/http/handlers/authoring_routes.dart` via `@ApiController` and `@ApiOperation` annotations.
- A custom `source_gen` builder (`lib/openapi_spec_builder.dart`) generates `openapi/openapi.yaml` from those annotations.
- `openapi_generator` then generates the Dart client from that generated spec into `lib/src/generated/openapi/`.

Regenerate OpenAPI YAML + client SDK with:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This keeps route logic and OpenAPI metadata in one place while preserving the existing generated client flow.

## Architecture

The code is split into small layers under `lib/src/`:

- `authoring_session.dart` - state and dummy serialization model.
- `protocol_authoring_service.dart` - application/service logic.
- `protocol_authoring_request_handler.dart` - route handling and HTTP responses.
- `openapi.dart` - serves OpenAPI from `openapi/openapi.yaml` + Swagger page content.
