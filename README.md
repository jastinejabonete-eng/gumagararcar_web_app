# Gumagararcar

A Flutter concept-car showroom and local demo storefront for a mobile-development
finals project. Browse nine creator-owned vehicles, save a shortlist, choose
paint finishes, and complete a checkout that creates only a local demo receipt.

## Run

```shell
flutter pub get
flutter run
```

## Verify

```shell
flutter analyze
flutter test
flutter build web
```

## What is included

- Responsive showroom, searchable/filterable collection, vehicle detail pages,
  saved cars, garage, demo receipts, and settings/team information.
- Light, dark, and system appearance; 3D preview rotation preference.
- Device-local persistence for cart variants, favorites, preferences, and demo
  receipts. No server, account, inventory, payment, or remote checkout.
- Original catalog names, creators, categories, prices, and paint options in
  `lib/data/cars.dart`.

The vehicle photographs are illustrative references, not images of the fictional
concepts. Paint selection records the chosen finish but does not recolor the
photo or 3D model. Asset origins are listed in `assets/provenance.json`.

See [DESIGN.md](DESIGN.md) for the architecture, product boundaries, and design
decisions.
