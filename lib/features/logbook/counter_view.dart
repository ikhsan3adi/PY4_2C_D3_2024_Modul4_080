import 'package:flutter/material.dart';
import 'package:logbook_app_080/features/logbook/counter_controller.dart';

class CounterView extends StatefulWidget {
  final String username;
  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // Initial check for loading data (Task 3 requirement effectively, but we'll do controller logic later)
    // We can just call load here or in initState
    // _controller.loadLastValue();

    return Scaffold(
      appBar: AppBar(
        title: Text('Logbook: ${widget.username}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingView(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Ya, Keluar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            spacing: 16,
            children: [
              Text('Selamat Datang, ${widget.username}!'), // Added welcome text
              Text('Total Hitungan'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  IconButton.filled(
                    onPressed: () => setState(() => _controller.decrement()),
                    icon: Icon(Icons.remove),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                  Text(
                    _controller.value.toString(),
                    style: TextStyle(fontSize: 40),
                  ),
                  IconButton.filled(
                    onPressed: () => setState(() => _controller.increment()),
                    icon: Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                icon: Icon(Icons.rotate_left),
                onPressed: () async {
                  if (await _showResetDialog(context) ?? false) {
                    setState(() => _controller.reset());
                  }
                },
                label: Text('Reset'),
              ),
              Divider(indent: 16, endIndent: 16),
              Text('Step / Langkah: ${_controller.step}'),
              Slider(
                value: _controller.step.toDouble(),
                onChanged: (value) => setState(() {
                  _controller.setStep(value.toInt());
                }),
                min: 1,
                max: 10,
                divisions: 9,
                label: 'Step',
              ),
              Divider(indent: 16, endIndent: 16),
              Text('Riwayat'),
              if (_controller.history.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'Belum Ada Riwayat',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.disabledColor),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      ..._controller.history.reversed.map(
                        (e) => Card(
                          color: e.$3,
                          child: ListTile(
                            leading: Icon(Icons.history_sharp),
                            title: Text(e.$1),
                            subtitle: Text(e.$2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showResetDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Reset'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua riwayat hitungan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hitungan telah direset')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
