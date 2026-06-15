class DateFormatter {
  static const List<String> _weekdays = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"];
  static const List<String> _monthsShort = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];
  static const List<String> _monthsFull = ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"];

  static String formatShortDate(DateTime date) {
    return "${_weekdays[date.weekday % 7]}, ${date.day} ${_monthsShort[date.month - 1]}".toUpperCase();
  }

  static String formatFullDate(DateTime date) {
    return "${date.day} de ${_monthsFull[date.month - 1]}";
  }

  static const List<String> weekDaysInitials = ["L", "M", "M", "J", "V", "S", "D"];
}