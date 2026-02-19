import 'package:flutter/material.dart';
import 'package:logbook_app_080/features/logbook/log_controller.dart';
import 'package:logbook_app_080/features/logbook/models/log_model.dart';
import 'package:logbook_app_080/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_080/helpers/log_helper.dart';
import 'package:logbook_app_080/services/mongo_service.dart';

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = LogController.categories.first;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = LogController();
    Future.microtask(() => _initDatabase());
  }

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await LogHelper.writeLog(
        'UI: Memulai inisialisasi database...',
        source: 'log_view.dart',
      );

      await LogHelper.writeLog(
        'UI: Menghubungi MongoService.connect()...',
        source: 'log_view.dart',
      );

      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          'Koneksi Cloud Timeout. Periksa sinyal/IP Whitelist.',
        ),
      );

      await LogHelper.writeLog(
        'UI: Koneksi MongoService BERHASIL.',
        source: 'log_view.dart',
      );

      await LogHelper.writeLog(
        'UI: Memanggil controller.loadFromCloud()...',
        source: 'log_view.dart',
      );

      await _controller.loadFromCloud();

      await LogHelper.writeLog(
        'UI: Data berhasil dimuat ke Notifier.',
        source: 'log_view.dart',
      );
    } catch (e) {
      await LogHelper.writeLog(
        'UI: Error - $e',
        source: 'log_view.dart',
        level: 1,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Masalah: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddLogDialog() {
    _titleController.clear();
    _contentController.clear();
    _selectedCategory = LogController.categories.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          title: const Text('Tambah Catatan Baru'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Judul Catatan',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Isi Deskripsi',
                    prefixIcon: Icon(Icons.description),
                  ),
                  minLines: 1,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: LogController.categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(
                                LogController.categoryIcons[cat],
                                size: 16,
                                color: LogController.categoryAccentColors[cat],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat,
                                style: TextStyle(
                                  color:
                                      LogController.categoryAccentColors[cat],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => _selectedCategory = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty) return;
                await _controller.addLog(
                  _titleController.text,
                  _contentController.text,
                  category: _selectedCategory,
                );
                _titleController.clear();
                _contentController.clear();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    _selectedCategory = log.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          title: const Text('Edit Catatan'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Judul Catatan',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Isi Deskripsi',
                    prefixIcon: Icon(Icons.description),
                  ),
                  minLines: 1,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: LogController.categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(
                                LogController.categoryIcons[cat],
                                size: 16,
                                color: LogController.categoryAccentColors[cat],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat,
                                style: TextStyle(
                                  color:
                                      LogController.categoryAccentColors[cat],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => _selectedCategory = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty) return;
                await _controller.updateLog(
                  index,
                  _titleController.text,
                  _contentController.text,
                  category: _selectedCategory,
                );
                _titleController.clear();
                _contentController.clear();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _controller.removeLog(index);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Catatan dihapus')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

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
                        Navigator.pop(context);
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              onChanged: (value) => _controller.searchLog(value),
              decoration: InputDecoration(
                labelText: 'Cari Catatan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: ValueListenableBuilder<List<LogModel>>(
                  valueListenable: _controller.filteredLogs,
                  builder: (context, _, _) {
                    if (_searchController.text.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _controller.searchLog('');
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder<List<LogModel>>(
                valueListenable: _controller.filteredLogs,
                builder: (context, currentLogs, child) {
                  if (_isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Menghubungkan ke Database...'),
                        ],
                      ),
                    );
                  }

                  if (currentLogs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off,
                            size: 100,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada catatan di Database.',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _showAddLogDialog,
                            child: const Text('Buat Catatan Pertama'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => _controller.loadFromCloud(),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 80),
                      itemCount: currentLogs.length,
                      itemBuilder: (context, index) {
                        final log = currentLogs[index];
                        final cardColor =
                            LogController.categoryColors[log.category] ??
                            theme.cardColor;
                        final categoryIcon =
                            LogController.categoryIcons[log.category] ??
                            Icons.note;
                        final accentColor =
                            LogController.categoryAccentColors[log.category] ??
                            Colors.black;

                        return Dismissible(
                          key: Key(log.id?.oid ?? log.timestamp),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi Hapus'),
                                  content: const Text(
                                    'Apakah Anda yakin ingin menghapus catatan ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              _showEditLogDialog(index, log);
                            }
                            return null;
                          },
                          onDismissed: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              await _controller.removeLog(index);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Catatan dihapus'),
                                  ),
                                );
                              }
                            }
                          },
                          background: Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.only(left: 20),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: Card(
                            color: cardColor,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            clipBehavior: Clip.hardEdge,
                            child: ListTile(
                              leading: Icon(categoryIcon, color: accentColor),
                              title: Text(
                                log.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(log.description),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Chip(
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.5),
                                        avatar: Icon(
                                          categoryIcon,
                                          size: 14,
                                          color: accentColor,
                                        ),
                                        label: Text(
                                          log.category,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: accentColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.cloud_done,
                                        size: 14,
                                        color: Colors.green.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatTimestamp(log.timestamp),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.disabledColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () =>
                                          _showEditLogDialog(index, log),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _showDeleteConfirmation(index),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) return 'Baru saja';
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} menit yang lalu';
      }
      if (difference.inHours < 24) {
        return '${difference.inHours} jam yang lalu';
      }
      if (difference.inDays < 7) return '${difference.inDays} hari yang lalu';

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return timestamp;
    }
  }
}
