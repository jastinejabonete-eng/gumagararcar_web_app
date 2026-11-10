import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gumagararcar/data/cars.dart';
import 'package:gumagararcar/main.dart';
import 'package:gumagararcar/services/store_storage.dart';
import 'package:gumagararcar/state/store_controller.dart';

void main() {
  testWidgets('rebuilt showroom offers collection and saved navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const GumagararcarApp());
    await tester.pumpAndSettle();
    expect(find.text('Apex GT'), findsWidgets);
    expect(find.text('View concept'), findsOneWidget);
    expect(find.text('Collection'), findsWidgets);
    expect(find.text('Saved'), findsWidgets);
    expect(find.byIcon(Icons.settings_outlined), findsWidgets);
  });

  testWidgets('collection search and paint selection reach the garage', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = StoreController(storage: MemoryStoreStorage());
    addTearDown(store.dispose);
    await tester.pumpWidget(GumagararcarApp(controller: store));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav_1')));
    await tester.pumpAndSettle();
    final search = find.byKey(const ValueKey('catalog_search'));
    await tester.enterText(search, 'Baniaga');
    await tester.pumpAndSettle();
    expect(find.text('1 concept'), findsOneWidget);
    expect(find.text('Ember GT'), findsOneWidget);
    await tester.enterText(search, 'Apex GT');
    await tester.pumpAndSettle();
    expect(find.text('1 concept'), findsOneWidget);

    final openCar = find.byKey(const ValueKey('open_jabacon'));
    await tester.ensureVisible(openCar);
    await tester.tap(openCar);
    await tester.pumpAndSettle();
    final selectedPaint = cars.first.colors[1];
    final paint = find.byKey(ValueKey('paint_${selectedPaint.toARGB32()}'));
    await tester.ensureVisible(paint);
    await tester.tap(paint);
    final addToGarage = find.byKey(const ValueKey('add_to_garage'));
    await tester.ensureVisible(addToGarage);
    await tester.tap(addToGarage);
    await tester.pumpAndSettle();

    expect(store.cartLines, hasLength(1));
    expect(store.cartLines.single.color, selectedPaint);
    final viewGarage = find.text('View garage');
    await tester.ensureVisible(viewGarage);
    await tester.tap(viewGarage);
    await tester.pumpAndSettle();
    expect(find.text('Your garage.'), findsOneWidget);
    expect(find.byKey(const ValueKey('cart_total')), findsOneWidget);
    await store.flush();
  });

  test('bundled catalog photos and typography are available', () async {
    expect(cars, hasLength(9));
    expect(cars.singleWhere((car) => car.owner == 'Baniaga').name, 'Ember GT');
    for (final car in cars) {
      await rootBundle.load('assets/images/${car.id}.jpg');
    }
    await rootBundle.load('assets/fonts/Barlow-Regular.ttf');
    await rootBundle.load('assets/fonts/Barlow-SemiBold.ttf');
    await rootBundle.load('assets/fonts/BarlowCondensed-SemiBold.ttf');
  });
}
