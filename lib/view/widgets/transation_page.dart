import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saveapp/controller/save_controller.dart';
import 'package:saveapp/model/save_model.dart';

class TransactionPage extends ConsumerWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moneyProvider);
    final currency = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F7),
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: state.when(
        data: (transactions) {
          final income = transactions
              .where((transaction) => transaction.type == 'income')
              .toList();
          final expenses = transactions
              .where((transaction) => transaction.type == 'expense')
              .toList();
          final incomeTotal = income.fold<double>(
            0,
            (sum, transaction) => sum + transaction.money.abs(),
          );
          final expenseTotal = expenses.fold<double>(
            0,
            (sum, transaction) => sum + transaction.money.abs(),
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final padding = constraints.maxWidth > 700 ? 32.0 : 20.0;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(padding, 8, padding, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your activity',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'A clear view of money coming in and going out.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _SummaryCard(
                                    title: 'Income',
                                    amount: currency.format(incomeTotal),
                                    count: income.length,
                                    icon: Icons.south_west_rounded,
                                    color: const Color(0xFF16804A),
                                    background: const Color(0xFFE6F4EB),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SummaryCard(
                                    title: 'Expenses',
                                    amount: currency.format(expenseTotal),
                                    count: expenses.length,
                                    icon: Icons.north_east_rounded,
                                    color: const Color(0xFFBC4B45),
                                    background: const Color(0xFFFFECE9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: padding,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: TabBar(
                                    dividerColor: Colors.transparent,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    indicator: BoxDecoration(
                                      color: const Color(0xFF167A56),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    labelColor: Colors.white,
                                    unselectedLabelColor: Colors.grey.shade700,
                                    labelStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    tabs: [
                                      const Tab(text: 'Income'),
                                      const Tab(text: 'Expense'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _TransactionList(
                                      transactions: income,
                                      isIncome: true,
                                      currency: currency,
                                      horizontalPadding: padding,
                                    ),
                                    _TransactionList(
                                      transactions: expenses,
                                      isIncome: false,
                                      currency: currency,
                                      horizontalPadding: padding,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load transactions.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.count,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String title;
  final String amount;
  final int count;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 138),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: background,
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count ${count == 1 ? 'transaction' : 'transactions'}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.transactions,
    required this.isIncome,
    required this.currency,
    required this.horizontalPadding,
  });

  final List<SaveModel> transactions;
  final bool isIncome;
  final NumberFormat currency;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                size: 36,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 12),
              Text(
                isIncome ? 'No income yet' : 'No expenses yet',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Your transactions will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    final amountColor = isIncome ? Colors.green.shade700 : Colors.red.shade700;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 24),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            leading: CircleAvatar(
              backgroundColor: isIncome
                  ? const Color(0xFFE6F4EB)
                  : const Color(0xFFFFECE9),
              child: Icon(
                isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                color: amountColor,
                size: 20,
              ),
            ),
            title: Text(
              transaction.note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(transaction.date),
            trailing: Text(
              '${isIncome ? '+' : '-'}${currency.format(transaction.money.abs())}',
              style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
