import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveapp/database/save_helper.dart';
import 'package:saveapp/model/save_model.dart';

class SaveNotifire extends AsyncNotifier<List<SaveModel>> {
  SaveHelper helper = SaveHelper();

  double balance = 0.0;
  double income = 0.0;
  double expense = 0.0;
  double average = 0.0;

  @override
  Future<List<SaveModel>> build() async {
    refreshMoney();
    return await helper.getAllData();
  }

  void refreshMoney() async {
    balance = await helper.getBalance();
    income = await helper.getIncome();
    expense = await helper.getExpense();
    average = await helper.getAverage();
  }

  void loadData() async {
    refreshMoney();
    state = AsyncData(await helper.getAllData());
  }

  void deposite(SaveModel save) async {
    await helper.depositData(save);
    loadData();
  }
}

var moneyProvider = AsyncNotifierProvider<SaveNotifire, List<SaveModel>>(
  // ignore: unnecessary_constructor_name
  () => SaveNotifire.new(),
);
