# Product and architecture

## Product

Gumagararcar is a student concept showroom for nine fictional vehicles. The
experience is designed around discovery and configuration: enter through the
showroom, explore and filter the full collection, save interesting concepts,
select a paint finish, and keep chosen variants in a garage.

Checkout is deliberately local-only. It records an immutable demo receipt and
clears the garage; it does not collect payment or create a real order. There is
no backend, login, live inventory, or remote service.

## Experience

- Deep petrol, ink, and cool porcelain anchor the showroom, with restrained
  electric-blue actions. Dark mode uses blue-black surfaces and pale blue
  accents for readable contrast.
- Barlow supports interface text; Barlow Condensed is used for display
  typography.
- The showroom leads with one featured concept, clear catalog metadata, and a
  direct path into its details. Layout favors editorial hierarchy and quiet
  separators over stacked decorative panels.
- Vehicle photography is illustrative reference imagery. A selected paint
  finish is stored with the cart item and does not alter the imagery or 3D
  model.
- Navigation uses a compact bottom bar on narrow screens and horizontal
  navigation on wider screens. Content is bounded and product listings reflow
  from one to three columns.
- The Apex GT includes an opt-in 3D preview. Rotation respects the saved
  preference and the system reduced-motion setting.

## Structure

| Area | Responsibility |
| --- | --- |
| `lib/main.dart` | App startup, store lifecycle, and theme selection |
| `lib/data/cars.dart` | Canonical static catalog |
| `lib/models/` | Catalog products, cart variants, and immutable demo receipts |
| `lib/state/store_controller.dart` | Observable shopping state and persistence coordination |
| `lib/services/store_storage.dart` | Storage interface, SharedPreferences implementation, and test memory storage |
| `lib/screens/` | App shell, showroom, collection, details, saved list, garage, receipts, and settings |
| `lib/widgets/shared.dart` | Responsive page layout and shared vehicle, media, and empty-state widgets |
| `lib/theme/app_theme.dart` | Light/dark Material theme |

The UI depends on `StoreController`, rather than the persistence implementation.
The controller owns cart quantities per vehicle-and-finish variant, favorites,
theme and rotation preferences, and local receipts. It serializes versioned
JSON snapshots through `StoreStorage`; writes remain ordered, and storage
failures are surfaced in the app rather than silently discarded.

## Assets and truthfulness

Vehicle reference images are bundled under `assets/images/`; font files are
bundled under `assets/fonts/`. Their origin and attribution notes are in
`assets/provenance.json`. The bundled GLB is used only for the Apex GT preview.
Do not present any of these as photographs or specifications of the fictional
vehicles.

All prices are Philippine pesos and are concept prices. No performance
specifications, availability, shipping, account, payment, or dealer capability
is implied.

## Local data

SharedPreferences stores one versioned JSON snapshot containing:

- Cart lines with catalog ID, ARGB paint value, and quantity
- Saved catalog IDs
- Theme mode and 3D auto-rotation preference
- Local demo receipts with their captured cart lines and creation time

Storage is per device/browser. Clearing local data removes saved cars, cart
contents, receipts, and preferences without changing the catalog.
