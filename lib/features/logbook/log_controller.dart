import 'package:flutter/material.dart';
import 'package:logbook_app_080/features/logbook/models/log_model.dart';
import 'package:logbook_app_080/helpers/log_helper.dart';
import 'package:logbook_app_080/services/mongo_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

  LogController();

  List<LogModel> get logs => logsNotifier.value;

  Future<void> addLog(
    String title,
    String desc, {
    String category = 'Pribadi',
  }) async {
    final newLog = LogModel(
      id: ObjectId(),
      title: title,
      description: desc,
      timestamp: DateTime.now().toString(),
      category: category,
    );

    try {
      await MongoService().insertLog(newLog);

      final currentLogs = List<LogModel>.from(logsNotifier.value);
      currentLogs.add(newLog);
      logsNotifier.value = currentLogs;
      filteredLogs.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Tambah data '${newLog.title}'",
        source: 'log_controller.dart',
      );
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Gagal sinkronisasi Add - $e',
        source: 'log_controller.dart',
        level: 1,
      );
    }
  }

  Future<void> updateLog(
    int index,
    String title,
    String desc, {
    String category = 'Pribadi',
  }) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id,
      title: title,
      description: desc,
      timestamp: DateTime.now().toString(),
      category: category,
    );

    try {
      await MongoService().updateLog(updatedLog);

      currentLogs[index] = updatedLog;
      logsNotifier.value = currentLogs;
      filteredLogs.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update '${oldLog.title}' Berhasil",
        source: 'log_controller.dart',
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Gagal sinkronisasi Update - $e',
        source: 'log_controller.dart',
        level: 1,
      );
    }
  }

  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    try {
      if (targetLog.id == null) {
        throw Exception(
          'ID Log tidak ditemukan, tidak bisa menghapus di Cloud.',
        );
      }

      await MongoService().deleteLog(targetLog.id!);

      currentLogs.removeAt(index);
      logsNotifier.value = currentLogs;
      filteredLogs.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Hapus '${targetLog.title}' Berhasil",
        source: 'log_controller.dart',
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Gagal sinkronisasi Hapus - $e',
        source: 'log_controller.dart',
        level: 1,
      );
    }
  }

  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value.where((log) {
        bool searchTitle = log.title.toLowerCase().contains(
          query.toLowerCase(),
        );
        bool searchDesc = log.description.toLowerCase().contains(
          query.toLowerCase(),
        );
        return searchTitle || searchDesc;
      }).toList();
    }
  }

  Future<void> loadFromCloud() async {
    final cloudData = await MongoService().getLogs();
    logsNotifier.value = cloudData;
    filteredLogs.value = cloudData;
  }
}
