import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  bool _isEditing = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('userName') ?? '';
    _goalController.text = prefs.getString('goal') ?? '';
    if (_nameController.text.isNotEmpty || _goalController.text.isNotEmpty) {
      setState(() => _isEditing = false);
    }
  }

  Future<void> _toggleEditOrSave() async {
    if (_isEditing) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text.trim());
      await prefs.setString('goal', _goalController.text.trim());
      if (!mounted) return;
      setState(() => _isEditing = false);
    } else {
      setState(() => _isEditing = true);
    }
  }

  Future<void> _confirmAndClearData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистити всі дані?'),
        content: const Text('Ви впевнені, що хочете видалити всі транзакції, доходи, бюджети та категорії? Це не можна буде скасувати.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Скасувати')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Так')),
        ],
      ),
    );

    if (confirm == true) {
      await Hive.deleteBoxFromDisk('transactions');
      await Hive.deleteBoxFromDisk('incomes');
      await Hive.deleteBoxFromDisk('budgets');
      await Hive.deleteBoxFromDisk('categories');
      await Hive.deleteBoxFromDisk('settings');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Всі дані очищено. Перезапустіть додаток.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currencies = ['UAH', 'USD', 'EUR', 'PLN'];

    return Scaffold(
      appBar: AppBar(title: const Text('Налаштування')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🔷 Користувач
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Користувач', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_isEditing) ...[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Ваше імʼя або псевдонім'),
                    ),
                    TextField(
                      controller: _goalController,
                      decoration: const InputDecoration(labelText: 'Фінансова мета'),
                    ),
                  ] else ...[
                    Text(
                      _nameController.text,
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      _goalController.text,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _toggleEditOrSave,
                      icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Theme.of(context).primaryColor),
                      label: Text(_isEditing ? 'Зберегти' : 'Редагувати'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔷 Базова валюта
            const Text('Базова валюта', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: settingsProvider.baseCurrency,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setBaseCurrency(value);
                }
              },
              items: currencies.map((code) {
                return DropdownMenuItem(
                  value: code,
                  child: Text(code),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),
            const Divider(),

            // 🔷 Про додаток
            const Text('Про додаток', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Версія: v1.0.0'),
            const Text('Збірка: stable'),

            const SizedBox(height: 32),

            // 🔷 Очистити всі дані
            ElevatedButton.icon(
              onPressed: () => _confirmAndClearData(context),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Очистити всі дані'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }
}
