import 'package:flutter/material.dart';

class TransationPage extends StatelessWidget {
  const TransationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Keep track of your transactions and manage your finances effectively with our app.',
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 500,
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Income'),
                      Tab(text: 'Expense'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Center(child: Text('Income Transactions')),
                        Center(child: Text('Expense Transactions')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
