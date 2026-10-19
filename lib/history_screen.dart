import 'package:flutter/material.dart';

import 'calculation_history.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.history});

  final CalculationHistory history;

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('All saved calculations will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) history.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: history,
      builder: (context, _) {
        final entries = history.entries;
        return Scaffold(
          appBar: AppBar(
            title: const Text('History'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear history',
                onPressed: entries.isEmpty
                    ? null
                    : () => _confirmClear(context),
              ),
            ],
          ),
          body: entries.isEmpty
              ? Center(
                  child: Text(
                    'No calculations yet',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => ListTile(
                    title: Text(
                      entries[index],
                      textAlign: .end,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
