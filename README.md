# CAMS Protocol Authoring Server

Stateful HTTP API for interactive authoring of CARP study protocols.

The server runs locally inside a small Flutter host app and exposes OpenAPI + Swagger UI for inspection and manual testing.

## Run Locally

### Prerequisites (Fedora)

```bash
sudo dnf install -y \
    cmake ninja-build pkg-config \
    gtk3-devel \
    clang libsecret-devel webkit2gtk4.1-devel \
    gstreamer1-devel gstreamer1-plugins-base-devel
```

### Start

```bash
flutter pub get
flutter run -d linux
```

The API server listens on `http://0.0.0.0:8080`.

## API Docs

1. OpenAPI JSON: `http://localhost:8080/openapi.json`
2. OpenAPI YAML: `http://localhost:8080/openapi.yaml`
3. Swagger UI: `http://localhost:8080/docs`

## What You Can Model

| Capability                          | Route modules                                                                               |
| ----------------------------------- | ------------------------------------------------------------------------------------------- |
| Session and core protocol lifecycle | `authoring_routes/core.dart`                                                                |
| Participant roles and expected data | `authoring_routes/participant_role.dart`, `authoring_routes/participant_expected_data.dart` |
| Primary and additional devices      | `authoring_routes/primary_device.dart`, `authoring_routes/devices.dart`                     |
| Tasks and triggers                  | `authoring_routes/tasks.dart`, `authoring_routes/triggers.dart`                             |
| Services and data endpoints         | `authoring_routes/services.dart`, `authoring_routes/data_endpoint.dart`                     |

## Architecture

```text
.
├── lib
│   ├── protocol_authoring_server.dart
│   └── src
│       ├── authoring_requirements.dart
│       ├── authoring_session/
│       │   ├── authoring_session.dart
│       │   └── *.dart (devices, participants, services, tasks, triggers)
│       ├── authoring_session_store.dart
│       ├── protocol_authoring_service.dart
│       ├── protocol_authoring_request_handler.dart
│       ├── task_measure_parser.dart
│       ├── openapi.dart
│       ├── openapi_annotations.dart
│       └── http
│           ├── dto
│           │   ├── request_bodies/
│           │   └── request_parsing_utils.dart
│           ├── handlers
│           │   ├── authoring_routes/
│           │   ├── authoring_routes.dart
│           │   └── docs_routes.dart
│           └── response
│               └── json_response.dart
├── openapi
│   └── openapi.yaml
└── test
    └── *_test.dart (session, service, endpoints, parsing, serialization, deployment)
```

### Layers

1. `authoring_session/*.dart`: domain state and protocol mutation rules.
2. `authoring_requirements.dart` + `task_measure_parser.dart`: cross-cutting validation and measure parsing.
3. `protocol_authoring_service.dart`: application/use-case orchestration.
4. `protocol_authoring_request_handler.dart`: Shelf middleware pipeline and route composition root.
5. `http/handlers/authoring_routes/*.dart`: endpoint handlers and OpenAPI metadata.
6. `http/dto/**/*.dart`: request DTOs and parsing helpers.
7. `http/response/json_response.dart`: shared JSON response formatting.

### Request Pipeline

1. Request logging.
2. Error mapping: `FormatException -> 400`, `AuthoringRequirementsException -> 409`, any other error -> 500.
3. Route handling with explicit 404 fallback.

## Testing

```bash
flutter test
```

Test suites cover session behavior, service logic, endpoint contracts, error handling, request parsing, serialization, and deployment payloads.

## OpenAPI Generation

This project uses a code-first OpenAPI workflow.

1. Route handlers define docs via `@ApiController` and `@ApiOperation` in `lib/src/http/handlers/authoring_routes/*.dart`.
2. `lib/openapi_spec_builder.dart` generates `openapi/openapi.yaml`.
3. `openapi_generator` builds the client in `lib/src/generated/openapi/`.

Regenerate spec and client:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Maturity and Limits

1. Current storage is in-memory (`InMemoryAuthoringSessionStore`).
2. Session state is not persisted across restarts.
3. The service is intended for local development and validation workflows.
