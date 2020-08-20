import 'package:intl/intl.dart';

String displayDefaultTextIfNull(String text) {
  return text.isEmpty ? '-' : text;
}

String formatText(dynamic text) {
  return text == null ? '-' : NumberFormat().format(text);
}

String formatCurrencyText(dynamic text) {
  return text == null ? '-' : NumberFormat.currency(name: '', symbol: '', decimalDigits: 2).format(text);
}

String compactText(dynamic text) {
  return text == null ? '-' : NumberFormat.compactSimpleCurrency(decimalDigits: 2).format(text);
}

/// This function will add a + sign to an string
/// based on the [change].
String determineTextBasedOnChange(double change) {
  return (change == null || change < 0)
    ? formatCurrencyText(change)
    : '+${formatCurrencyText(change)}';
}

/// This function will add a + sign to an string
/// based on the [change].
String determineTextPercentageBasedOnChange(double change) {
  return (change == null || change < 0)
    ? '${formatText(change)}%' 
    : '+${formatText(change)}%';
}