# Gumagararcar rebuild

## Existing architecture and scope
Inspected every Dart source file, tests, pubspec, Android app config, and web bootstrap before rebuilding. Original app: main.dart owns navigation, catalog filtering, cart quantities and favorites; static CarProduct records in data/cars.dart; callback-heavy screen/widget tree; red/black single theme; model_viewer_plus loads one bundled GLB. No server, authentication, inventory or payments. Existing baseline: analyzer clean and four widget tests pass.

Observed problems: cart identifies only car, dropping chosen paint; settings only mutate switches; no persisted state or favorite collection view; duplicate home/catalog layouts; generic car icons instead of imagery; text controllers recreated inside builds; app looks and acts like a prototype. These are not reasons to invent a backend.

Original verified backup: C:/Users/Janelyn/gumagararcar_test_backup_20261109_205159.zip (176 files, per-file SHA-256 verified). Platform scaffolding, car IDs/names/prices/creators/colors and bundled GLB are preserved. User explicitly delegated design choices and requested a from-scratch replacement.

## Replacement architecture
- lib/main.dart: bootstrap and injected store lifecycle.
- lib/state/store_controller.dart: observable local state, variants, totals, favorites, settings, local demo receipts.
- lib/services/store_storage.dart: versioned SharedPreferences persistence with serialized writes and error reporting; memory implementation for tests.
- lib/models: original catalog product plus immutable cart/receipt values.
- lib/screens: adaptive shell, showroom, searchable/sortable collection, vehicle detail route, saved vehicles, cart and receipt, settings/team.
- lib/widgets: shared bounded page layout, photo media, vehicle tile and headings.
- lib/theme: light/dark tokens and consistent Material controls.

## Direction contract
THESIS: An automotive collection you can actually explore and configure, not a glowing product grid. Operate mode for browsing and shopping, image-led showroom entry.
OWN-WORLD: Deep petrol, ink, and cool porcelain with restrained electric-blue accents; blue-black surfaces in dark mode. Barlow Condensed display and Barlow UI text. Large landscape vehicle photographs, squared soft corners, clear product metadata, and deliberate whitespace. No gradients or generic car icons as product imagery.
STORY: Discover a featured concept, browse nine creator-owned builds, save a shortlist, choose paint, review cart variants, finish an explicitly local demo checkout. Settings change the real app.
FIRST VIEWPORT: Compact wordmark/nav; a solid petrol feature pairs a featured concept and its actual catalog metadata with illustrative car photography. Mobile stacks image before the concept details; desktop gives the photo more room than the copy. A direct detail action and quieter collection link avoid redundant CTAs.
FINISH: Implemented and reviewed at desktop and phone widths. DESIGN.md documents the product boundary, architecture, storage, and visual direction. All car images and local fonts are bundled and verified.

## Verification
- `flutter analyze` — clean.
- `flutter test` — 19 tests pass, including local persistence, variant cart behavior,
  photo/font asset loading, and a 360 px search-to-garage flow.
- `flutter build web --release` — succeeds; browser preview reviewed at desktop
  and 390 px widths.
- `flutter build apk --debug` — succeeds.

No production deployment, signing, backend, or real transaction is included.
