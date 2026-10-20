import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saveapp/controller/save_controller.dart';
import 'package:saveapp/model/save_model.dart';
import 'package:saveapp/main.dart';
import 'package:saveapp/view/home_page.dart';
import 'package:saveapp/view/widgets/transation_page.dart';

void main() {
  testWidgets('MyApp provides Riverpod scope when mounted directly', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Money Note'), findsOneWidget);
  });

  testWidgets('home page shows current balance and recent notes', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [moneyProvider.overrideWith(_TestSaveNotifier.new)],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Total balance'), findsOneWidget);
    expect(find.text('\$75.00'), findsNWidgets(2));
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('No notes yet'), findsNothing);
  });

  testWidgets('home page has no layout overflow on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [moneyProvider.overrideWith(_TestSaveNotifier.new)],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('transaction page filters income and expenses', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [moneyProvider.overrideWith(_TestSaveNotifier.new)],
        child: const MaterialApp(home: TransactionPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);

    await tester.tap(find.text('Expense'));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
  });

  testWidgets('transaction page has no overflow on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [moneyProvider.overrideWith(_TestSaveNotifier.new)],
        child: const MaterialApp(home: TransactionPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('home page opens the transaction screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [moneyProvider.overrideWith(_TestSaveNotifier.new)],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Income'), findsNWidgets(2));
    expect(find.text('Expense'), findsOneWidget);
  });

  test('save model accepts integer database amounts and omits null ids', () {
    final model = SaveModel.fromMap({
      'id': 1,
      'note': 'Lunch',
      'date': 'Today',
      'type': 'expense',
      'money': -10,
    });

    expect(model.money, -10.0);
    expect(
      SaveModel(
        note: 'Lunch',
        date: 'Today',
        type: 'expense',
        money: -10,
      ).toMap(),
      {'note': 'Lunch', 'date': 'Today', 'type': 'expense', 'money': -10.0},
    );
  });
}

class _TestSaveNotifier extends SaveNotifire {
  @override
  Future<List<SaveModel>> build() async => [
    SaveModel(note: 'Salary', date: 'Today', type: 'income', money: 100),
    SaveModel(note: 'Groceries', date: 'Today', type: 'expense', money: -25),
  ];
}
