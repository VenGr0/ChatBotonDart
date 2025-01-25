import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(AIChatFlutterApp());
}

class AIChatFlutterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIChatFlutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/settings': (context) => ProviderSettingsPage(),
        '/statistics': (context) => TokenUsagePage(),
        '/expenses': (context) => DailyExpensesChartPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Главная страница')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: Text('Настройки провайдера'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/statistics');
              },
              child: Text('Статистика токенов'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/expenses');
              },
              child: Text('График расходов'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderSettingsPage extends StatefulWidget {
  @override
  _ProviderSettingsPageState createState() => _ProviderSettingsPageState();
}

class _ProviderSettingsPageState extends State<ProviderSettingsPage> {
  String selectedProvider = 'OpenRouter';
  TextEditingController keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedProvider = prefs.getString('provider') ?? 'OpenRouter';
      keyController.text = prefs.getString('apiKey') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('provider', selectedProvider);
    await prefs.setString('apiKey', keyController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Настройки сохранены!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Настройки провайдера')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedProvider,
              onChanged: (value) {
                setState(() {
                  selectedProvider = value!;
                });
              },
              items: ['OpenRouter', 'VSEGPT'].map((provider) {
                return DropdownMenuItem(
                  value: provider,
                  child: Text(provider),
                );
              }).toList(),
            ),
            TextField(
              controller: keyController,
              decoration: InputDecoration(labelText: 'Введите API ключ'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}

class TokenUsagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tokenUsage = [
      {'model': 'OpenAI GPT-4', 'tokens': '1500'},
      {'model': 'VSEGPT', 'tokens': '800'},
      {'model': 'OpenRouter', 'tokens': '1200'},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Статистика токенов')),
      body: DataTable(
        columns: [
          DataColumn(label: Text('Модель')),
          DataColumn(label: Text('Токены')),
        ],
        rows: tokenUsage.map((data) {
          return DataRow(cells: [
            DataCell(Text(data['model']!)),
            DataCell(Text(data['tokens']!)),
          ]);
        }).toList(),
      ),
    );
  }
}

class DailyExpensesChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<FlSpot> expenseData = [
      FlSpot(1, 5),
      FlSpot(2, 8),
      FlSpot(3, 6),
      FlSpot(4, 10),
      FlSpot(5, 4),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('График расходов')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString());
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Text('День ${value.toInt()}');
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: expenseData,
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
