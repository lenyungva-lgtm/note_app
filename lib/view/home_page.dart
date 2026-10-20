import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saveapp/controller/save_controller.dart';
import 'package:saveapp/model/save_model.dart';
import 'package:saveapp/view/widgets/cart_target_and_average.dart';
import 'package:saveapp/view/widgets/transation_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moneyProvider);
    final controller = ref.read(moneyProvider.notifier);
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
          'Money Note',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Transactions',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const TransactionPage(),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          IconButton(
            tooltip: 'Add transaction',
            onPressed: () => _showAddTransaction(context, controller),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: state.when(
        data: (data) {
          final balance = data.fold<double>(0, (sum, item) => sum + item.money);
          final income = data
              .where((item) => item.money > 0)
              .fold<double>(0, (sum, item) => sum + item.money);
          final expenses = data
              .where((item) => item.money < 0)
              .fold<double>(0, (sum, item) => sum + item.money.abs());
          final average = data.isEmpty
              ? 0.0
              : data.fold<double>(0, (sum, item) => sum + item.money.abs()) /
                    data.length;

          return LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth > 700
                  ? 32.0
                  : 20.0;
              final contentWidth = constraints.maxWidth - horizontalPadding * 2;
              final overviewColumns = contentWidth >= 640 ? 4 : 2;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  100,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d').format(DateTime.now()),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        _BalanceCard(
                          balance: currency.format(balance),
                          income: currency.format(income),
                          expenses: currency.format(expenses),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your overview',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: overviewColumns,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: overviewColumns == 6.9 ? 1.1 : 1,
                          children: [
                            cardTargatAndSaving(
                              Icons.savings_outlined,
                              'Target',
                              currency.format(500),
                              const Color(0xFFE5EEFF),
                            ),
                            cardTargatAndSaving(
                              Icons.trending_up,
                              'Average',
                              currency.format(average),
                              const Color(0xFFFFE9E5),
                            ),
                            cardTargatAndSaving(
                              Icons.account_balance_wallet_outlined,
                              'Saving',
                              currency.format(balance),
                              const Color(0xFFE1F5E9),
                            ),
                            cardTargatAndSaving(
                              Icons.money_off_outlined,
                              'Loss',
                              currency.format(expenses),
                              const Color(0xFFFFF3D6),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent notes',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (data.length > 5)
                              TextButton(
                                onPressed: () =>
                                    _showAllNotes(context, data, currency),
                                child: const Text('See all'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (data.isEmpty)
                          _EmptyNotes(
                            onAdd: () {
                              _showAddTransaction(context, controller);
                            },
                          )
                        else
                          Card(
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.length < 5 ? data.length : 5,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                indent: 72,
                                color: Colors.grey.shade200,
                              ),
                              itemBuilder: (context, index) => _NoteTile(
                                note: data[index],
                                amount: currency.format(
                                  data[index].money.abs(),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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
              'Could not load your notes.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransaction(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Add note'),
      ),
    );
  }

  Future<void> _showAddTransaction(
    BuildContext context,
    SaveNotifire controller,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddTransactionSheet(onSave: controller.deposite),
    );
  }

  void _showAllNotes(
    BuildContext context,
    List<SaveModel> notes,
    NumberFormat currency,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'All notes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: notes.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (context, index) => _NoteTile(
                  note: notes[index],
                  amount: currency.format(notes[index].money.abs()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expenses,
  });

  final String balance;
  final String income;
  final String expenses;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF167A56), Color(0xFF0C533D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C533D).withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total balance',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            balance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _BalanceSummary(
                  title: 'Income',
                  amount: income,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BalanceSummary(
                  title: 'Expenses',
                  amount: expenses,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary({
    required this.title,
    required this.amount,
    required this.icon,
  });

  final String title;
  final String amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withValues(alpha: 0.16),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 3),
              Text(
                amount,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.amount});

  final SaveModel note;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final isIncome = note.money >= 0;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isIncome
            ? const Color(0xFFE1F5E9)
            : const Color(0xFFFFE9E5),
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? const Color(0xFF16804A) : Colors.red.shade700,
          size: 20,
        ),
      ),
      title: Text(
        note.note,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(note.date),
      trailing: Text(
        '${isIncome ? '+' : '-'}$amount',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isIncome ? const Color(0xFF16804A) : Colors.red.shade700,
        ),
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey[500]),
          const SizedBox(height: 12),
          const Text(
            'No notes yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first transaction to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add a note'),
          ),
        ],
      ),
    );
  }
}

class _AddTransactionSheet extends StatefulWidget {
  const _AddTransactionSheet({required this.onSave});

  final Future<void> Function(SaveModel save) onSave;

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'income';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final amount = double.parse(_amountController.text.trim());
    final isIncome = _type == 'income';
    try {
      await widget.onSave(
        SaveModel(
          note: _noteController.text.trim(),
          date: DateFormat('E dd MMM yyyy').format(DateTime.now()),
          type: _type,
          money: isIncome ? amount : -amount,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not save this note: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        top: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add a transaction',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'income',
                        label: Text('Income'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment(
                        value: 'expense',
                        label: Text('Expense'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: _saving
                        ? null
                        : (selection) =>
                              setState(() => _type = selection.first),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      hintText: 'e.g. Groceries',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a note'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    enabled: !_saving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final amount = double.tryParse(value?.trim() ?? '');
                      if (amount == null || !amount.isFinite || amount <= 0) {
                        return 'Enter an amount greater than 0';
                      }
                      return null;
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save transaction'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
