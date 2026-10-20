import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveapp/database/save_helper.dart';
import 'package:saveapp/model/save_model.dart';

class SaveNotifire extends AsyncNotifier<List<SaveModel>> {
  final SaveHelper helper = SaveHelper();

  @override
  Future<List<SaveModel>> build() => helper.getAllData();

  Future<void> deposite(SaveModel save) async {
    await helper.depositData(save);
    state = AsyncData(await helper.getAllData());
  }
}

var moneyProvider = AsyncNotifierProvider<SaveNotifire, List<SaveModel>>(
  // ignore: unnecessary_constructor_name
  () => SaveNotifire.new(),
);
