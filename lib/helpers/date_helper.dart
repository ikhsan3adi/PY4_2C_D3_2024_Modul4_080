class DateHelper {
  static const List<String> _monthsId = [
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

  static String formatTimestamp(String timestamp) {
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

      return '${dateTime.day} ${_monthsId[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return timestamp;
    }
  }
}
