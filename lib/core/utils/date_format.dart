import 'package:intl/intl.dart';

String formatDate(String date) {
  DateTime dateParse = DateTime.parse(date);
  final formatter = DateFormat('d/MM/yyyy');
  return formatter.format(dateParse);
}
