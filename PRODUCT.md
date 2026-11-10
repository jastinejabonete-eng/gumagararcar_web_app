# Gumagararcar

A Group 1 mobile-development finals concept store. Eight fictional vehicles are associated with eight named creators. Original prices, model descriptions, categories, paint options and names are canonical in lib/data/cars.dart. Audience: classmates and evaluators exploring a Flutter car-shopping demo, primarily on Android phones with a browser demo on larger screens.

## Core tasks
Explore the collection, search/filter/sort, inspect a concept, choose a paint finish, save favorites, adjust a cart, complete an explicitly local demo checkout and review its receipt. Settings control appearance and 3D rotation. Team roles preserve those in the original app.

## Constraints and truth
No backend, real inventory, login, actual payments or push-notification service exists. Do not imply otherwise. Store shopping data locally, not remotely. Photos are illustrative reference vehicles, not photographs of the fictional products. The existing Apex GT GLB is a separate concept preview; changing paint selects the cart finish, not the photo/3D material. No invented performance specifications.

## Owner-delegated decisions
User requested a full rebuild and entrusted design/architecture decisions to the builder. Keep Flutter and platform scaffolding. Prefer small built-in state management and testable local persistence. Default light for readable classroom/daylight use; provide functioning dark and system modes. Layouts adapt to phones and desktop without treating either as a stretched version of the other.
