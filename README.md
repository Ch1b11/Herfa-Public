# 🛠️ HERFA Mobile Architecture (Public Showcase)

> **Herfa (حِرفة)** is an AI-powered home maintenance and asset-lifecycle operating platform connecting homeowners with verified craftsmen and service professionals.  
> This repository serves as a **public architectural and code showcase** demonstrating production-grade **Clean Architecture**, **BLoC (Business Logic Component)** state management, and **adaptive multi-viewport UI patterns** in Flutter.

---

## 🏛️ Architecture & Design Principles

The mobile client is engineered around **Feature-First Clean Architecture** with strict layer boundary enforcement:

* **Domain Layer (`domain/`):** Pure Dart business entities, abstract repository contracts, and single-responsibility use cases utilizing functional error handling via `dartz` (`Either<Failure, T>`). Contains zero Flutter UI dependencies.
* **Data Layer (`data/`):** Remote data sources (REST API client), local data sources (NoSQL caching), DTO models with serialization/deserialization, and concrete repository implementations orchestrating data policies.
* **Presentation Layer (`presentation/`):** Predictable state management via BLoC/Cubit, immutable states, declarative events, responsive screen hosts, and modular component builders adapting across mobile, tablet, and desktop viewports.

---

## 🗺️ System File Map

The codebase strictly isolates platform infrastructure into `lib/core` and business domains into `lib/features`:

```text
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                       # WCAG & OLED dark/light theme color palette
│   │   └── constants.dart                        # Global API endpoints & application configurations
│   ├── di/
│   │   └── injection_container.dart              # Centralized Service Locator (GetIt) dependency injection
│   ├── errors/
│   │   ├── exceptions.dart                       # Low-level data layer exception definitions
│   │   └── failures.dart                         # Functional error failures (Either<Failure, T>)
│   ├── layout_manager/
│   │   └── adaptive_layout_manager.dart          # Responsive viewport layout switch (mobile, tablet, desktop)
│   ├── network/
│   │   ├── api_client.dart                       # Centralized Dio HTTP client configuration & timeout rules
│   │   ├── api_response.dart                     # Standardized server response wrapper
│   │   ├── auth_event_bus.dart                   # Decoupled stream bus for unauthorized 401 events
│   │   ├── auth_interceptor.dart                 # Silent token refresh interceptor & request queue
│   │   ├── basic_network_interceptor.dart        # Logging, device headers & user-agent interceptor
│   │   └── network_info.dart                     # Real-time WAN connectivity inspection contract
│   ├── routing/
│   │   ├── app_router.dart                       # Declarative GoRouter configuration & role redirect guards
│   │   ├── go_router_refresh_stream.dart         # Stream-to-Listenable bridge for reactive routing
│   │   ├── route_title_resolver.dart             # Dynamic app bar title resolver based on active route
│   │   └── router_refresh_stream.dart            # Router refresh stream listener
│   ├── services/
│   │   ├── audio_recorder_service.dart           # Device audio recording service (package:record)
│   │   ├── chat_socket_service.dart              # Real-time WebSocket connection manager (Socket.IO)
│   │   ├── session_manager.dart                  # User session persistence & state management
│   │   └── storage_service.dart                  # Hive NoSQL database manager & 7-box orchestrator
│   ├── shell/
│   │   ├── auth_shell.dart                       # Scaffolding shell for authentication workflows
│   │   └── main_app_shell.dart                   # Scaffolding shell with responsive navigation bars
│   ├── sync/
│   │   ├── async_lock.dart                       # Asynchronous FIFO mutex lock for outbox thread safety
│   │   ├── pending_mutation.dart                 # Data model for queued offline mutations
│   │   └── sync_service.dart                     # Background outbox sync engine & temp UUID resolver
│   ├── theme/
│   │   ├── language_cubit.dart                   # Locale state management (Arabic/English)
│   │   ├── theme.dart                            # Material 3 ThemeData specifications & typography
│   │   ├── theme_cubit.dart                      # Theme mode state management (Light/Dark/OLED)
│   │   └── theme_state.dart                      # Immutable theme state definition
│   ├── utils/
│   │   ├── bottom_sheet_utils.dart               # Modal bottom sheet helpers
│   │   ├── date_formatter.dart                   # Arabic/English localized timestamp formatting
│   │   ├── dio_error_parser.dart                 # Dio exception mapper & localized message parser
│   │   ├── error_translator.dart                 # Error message localization utility
│   │   ├── id_utils.dart                         # UUID generation & identifier validation helpers
│   │   ├── logger.dart                           # Structured console logger utility
│   │   └── snackbar_utils.dart                   # Top & bottom snackbar notification presenter
│   └── widgets/
│       ├── app_action_button.dart                # Styled primary, secondary & tonal action buttons
│       ├── app_content_card.dart                 # Elevation-styled card container
│       ├── app_skeleton.dart                     # Generic shimmer skeleton loader
│       ├── app_text_field.dart                   # Validated text input fields with icons
│       ├── audio_waveform_bubble.dart            # Audio playback scrubber & waveform visualization
│       ├── breadcrumbs.dart                      # Hierarchical navigation breadcrumb bar
│       ├── empty_state_indicator.dart            # Illustrated empty data view placeholder
│       ├── floating_bottom_nav_bar.dart          # Floating role-aware bottom navigation bar
│       ├── keyboard_safe_wrapper.dart            # Keyboard resize & bottom inset safe area wrapper
│       ├── language_toggle_button.dart           # Language switcher widget
│       ├── offline_sync_banner.dart              # Offline status & pending sync badge banner
│       ├── safety_warning_banner.dart            # High-contrast hazard & emergency directives banner
│       ├── skeleton_loader.dart                  # Shimmer animation wrapper for lazy components
│       ├── theme_toggle_icon.dart                # Dark/Light mode toggle button
│       └── ui_only_badge_wrapper.dart            # Badging wrapper for pending mutations
│
└── features/
    ├── ai_assistant/                             # Vernacular Arabic multimodal intake & AI triage
    ├── auth/                                     # Authentication, role onboarding & secure session
    ├── chat/                                     # Real-time WebSocket messaging & audio voice notes
    ├── dashboard/                                # Role-based home overview & home health score
    ├── discovery/                                # PostGIS geospatial craftsman search & filtering
    ├── earnings/                                 # Craftsman revenue tracking, charts & payouts
    ├── home_intelligence/                        # Digital Maintenance Passport & appliance ledger
    ├── jobs/                                     # End-to-end Service Request lifecycle (Customer & Craftsman)
    ├── profile/                                  # Customer & Craftsman identity, ratings & portfolios
    └── quotation_pricing/                        # Price benchmark engine & quotation item builder
```

---

## 🔍 Public Showcase Features

This public repository includes complete implementations of core platform features demonstrating the architectural paradigm:

### 1. Service Requests & Job Lifecycle (`lib/features/jobs/`)
* **Domain:** Pure business models modeling jobs across all statuses (`pending`, `scheduled`, `onTheWay`, `inProgress`, `completed`, `cancelled`), alongside specialized use cases for:
  * Creating broadcast service requests (`CreateBroadcastServiceRequestUseCase`)
  * Inspecting customer active service jobs (`GetCustomerActiveJobUseCase`)
  * Querying available broadcast jobs for nearby technicians (`GetAvailableBroadcastJobsUseCase`)
  * Accepting jobs and advancing progressive repair milestones (`AcceptBroadcastJobUseCase`, `UpdateJobStatusUseCase`)
* **Data:** Remote API integration via `Dio` handling pagination, status patches, and local caching.
* **Presentation:** Dual-role UI components with responsive layouts (`mobileLayout`, `tabletLayout`, `desktopLayout`), skeleton states, step progress indicators, and client details cards.

### 2. Authentication & Role Onboarding (`lib/features/auth/`)
* **Domain:** Dual-role entities (`Customer` vs `Provider/Craftsman`), password strength validation, and phone number normalization.
* **Data:** Remote authentication sources with hardware-backed credential persistence via `FlutterSecureStorage`.
* **Presentation:** Interactive role selection, segmented OTP inputs, and responsive authentication screens with unified design tokens.

---

## 💻 Tech Stack & Dependencies

* **Language:** Dart 3 / Flutter SDK
* **Architecture:** Clean Architecture (Feature-First)
* **State Management:** `flutter_bloc`, `equatable`
* **Dependency Injection:** `get_it`
* **Functional Programming:** `dartz`
* **Networking & REST:** `dio`
* **Secure Storage:** `flutter_secure_storage`
* **Navigation:** `go_router`
