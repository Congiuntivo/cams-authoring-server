# Stateful Protocol Authoring Server (Dummy)

This project hosts a small in-memory HTTP server with a minimal state machine. It is intentionally lightweight and framework-free, while still exposing OpenAPI + Swagger docs.

## Linux

### Prerequisites

#### Fedora

```bash
sudo dnf install -y \
    cmake ninja-build pkg-config \
    gtk3-devel \
    clang libsecret-devel webkit2gtk4.1-devel \
    gstreamer1-devel gstreamer1-plugins-base-devel
```

### Run

```bash
flutter pub get
flutter run -d linux
```

The local app window only hosts the runtime; the API server itself listens on http://0.0.0.0:8080.

## Architecture

The project is organized in layers around routing, session state, and service orchestration.

```text
.
├── lib
│   ├── protocol_authoring_server.dart
│   └── src
│       ├── authoring_session.dart
│       ├── authoring_session_fsm.dart
│       ├── authoring_session_store.dart
│       ├── protocol_authoring_service.dart
│       ├── protocol_authoring_request_handler.dart
│       ├── openapi.dart
│       ├── openapi_annotations.dart
│       └── http
│           ├── handlers
│           │   ├── authoring_routes.dart
│           │   └── docs_routes.dart
│           └── response
│               └── json_response.dart
├── openapi
│   └── openapi.yaml
└── test
    ├── authoring_session_test.dart
    ├── protocol_authoring_service_test.dart
    └── protocol_authoring_endpoints_test.dart
```

Layer responsibilities:

- `authoring_session.dart` + `authoring_session_fsm.dart`: domain state, workflow transitions, and protocol mutation rules.
- `protocol_authoring_service.dart`: use-case/application layer coordinating session operations.
- `protocol_authoring_request_handler.dart`: Shelf middleware pipeline and route composition root.
- `http/handlers/*.dart`: endpoint handlers and OpenAPI metadata.
- `http/response/json_response.dart`: shared JSON response formatting.
- `openapi.dart` and `openapi/openapi.yaml`: OpenAPI loading/serving and API docs source.
- `test/*.dart`: unit + endpoint tests for session logic and HTTP behavior.

### Middleware Pipeline

The Shelf middleware stack includes:

1. **Request logging** — logs incoming requests and responses.
2. **Error handling** — catches `FormatException` (invalid JSON) and general errors, returning appropriate JSON errors.
3. **Route handling** — routes to endpoints and falls back to 404 for unknown paths.

## Automatic API Reference

- OpenAPI spec: `http://localhost:8080/openapi.json`
- OpenAPI YAML source: `http://localhost:8080/openapi.yaml`
- Swagger UI: `http://localhost:8080/docs`

It is possible to test endpoints directly from the Swagger UI.

## OpenAPI Generator

This project now uses a code-first setup for endpoint documentation.

- Endpoint docs live next to handlers in `lib/src/protocol_authoring_request_handler.dart` via `@ApiController` and `@ApiOperation` annotations.
- Endpoint docs live next to handlers in `lib/src/http/handlers/authoring_routes.dart` via `@ApiController` and `@ApiOperation` annotations.
- A custom `source_gen` builder (`lib/openapi_spec_builder.dart`) generates `openapi/openapi.yaml` from those annotations.
- `openapi_generator` then generates the Dart client from that generated spec into `lib/src/generated/openapi/`.

Regenerate OpenAPI YAML + client SDK with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This keeps route logic and OpenAPI metadata in one place while preserving the existing generated client flow.
