import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saveapp/controller/save_controller.dart';
import 'package:saveapp/model/save_model.dart';

import 'package:saveapp/view/widgets/cart_target_and_average.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var state = ref.watch(moneyProvider);
    var controller = ref.read(moneyProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('Money Note')),

      body: state.when(
        data: (data) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 250,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.green,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Balance',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${controller.balance}',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 30),
                          Row(
                            spacing: 50,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Total Income',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${controller.income}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Total Expense',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${controller.expense}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      cardTargatAndSaving(
                        Icons.savings,
                        "Target",
                        '500',
                        Colors.blue.shade200,
                      ),
                      cardTargatAndSaving(
                        Icons.trending_up,
                        'Average',
                        '1.11',
                        Colors.red.shade200,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Notes'),
                        TextButton(onPressed: () {}, child: Text('See All')),
                      ],
                    ),
                  ),

                  if (data.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No notes yet. Tap + to add one.'),
                    )
                  else
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: data.length < 5 ? data.length : 5,
                      itemBuilder: (context, index) {
                        final d = data[index];

                        return ListTile(
                          title: Text(d.note),
                          subtitle: Text(d.date),
                          trailing: Text(
                            '${d.money.toStringAsFixed(2)} \$',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: d.money < 0 ? Colors.red : Colors.green,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
        error: (error, stackTrace) => Text(error.toString()),
        loading: () => CircularProgressIndicator(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.deposite(
            SaveModel(
              note: 'salary',
              date: DateFormat('E dd MMM yyyy').format(DateTime.now()),
              type: 'income',
              money: 3000,
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
