# CAMS Protocol Authoring Server

Stateful HTTP API for interactive authoring of CARP study protocols.

The server runs in headless mode by default and exposes OpenAPI + Swagger UI for inspection and manual testing.

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

Environment variables:

1. `HOST` (default: `0.0.0.0`)
2. `PORT` (default: `8080`)

## Run With Docker

Build the image:

```bash
docker build -t cams-authoring-server:dev .
```

Run the container:

```bash
docker run --rm -p 8080:8080 cams-authoring-server:dev
```

Run with a custom port:

```bash
docker run --rm -e PORT=9090 -p 9090:9090 cams-authoring-server:dev
```

Notes:

1. The container runs the default headless entrypoint (`lib/main.dart`) on the Linux Flutter runner under a virtual X server, so no host UI window is shown.
2. Session state is in-memory and will reset when the container stops.
3. If port `8080` is already in use, remap with `-p <hostPort>:8080` and set `PORT=8080` in the container, or change both host and container port consistently.

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
│   ├── openapi_spec_builder.dart
│   └── src
│       ├── authoring_request_handler.dart
│       ├── authoring_session_store.dart
│       ├── authoring_service/
│       │   ├── utils/task_measure_parser.dart
│       │   ├── authoring_service.dart
│       │   └── *.dart (devices, services, tasks, triggers)
│       ├── authoring_session/
│       │   ├── utils/ (authoring_requirements, device_configuration_registry)
│       │   ├── authoring_session.dart
│       │   └── *.dart (devices, participants, primary_device, services, task_controls, tasks, triggers)
│       ├── http/
│       │   ├── dto/
│       │   │   ├── request_bodies/ (core, device, duration, service, task_control, task, trigger)
│       │   │   └── request_parsing_utils.dart
│       │   ├── handlers/
│       │   │   ├── authoring_routes/ (core, data_endpoint, devices, participant_*, primary_device, services, task_controls, tasks, triggers)
│       │   │   ├── authoring_routes.dart
│       │   │   └── docs_routes.dart
│       │   └── response/json_response.dart
│       └── openapi/
│           ├── openapi_annotations.dart
│           └── openapi.dart
├── openapi/
│   └── openapi.yaml
└── test/
    ├── protocol_authoring_endpoints/   (HTTP endpoint tests, domain-split)
    ├── protocol_authoring_service/     (service-layer unit tests, domain-split)
    └── *.dart (error handling, contract, serialization, deployment, parsing)
```

### Layers

1. `authoring_session/*.dart`: domain state and protocol mutation rules.
2. `authoring_session/utils/authoring_requirements.dart` + `authoring_service/helpers/task_measure_parser.dart`: cross-cutting validation and measure parsing.
3. `authoring_service/*.dart`: application/use-case orchestration.
4. `authoring_request_handler.dart`: Shelf middleware pipeline and route composition root.
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

1. Route handlers define docs via `@ApiController`, `@ApiOperation`, and `@ApiSchemas` in `lib/src/http/handlers/authoring_routes/*.dart`. `@ApiSchemas` on each mixin class declares the request/response schemas for that route domain; `@ApiController` on `AuthoringRoutes` declares cross-cutting schemas.
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
