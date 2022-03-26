String getDateText(date) {
  return 
      DateTime.parse(date.toString()).day.toString() +
      "/" +
      DateTime.parse(date.toString()).month.toString() +
      "/" +
      DateTime.parse(date.toString()).year.toString() +
      " at " +
      DateTime.parse(date.toString()).hour.toString() +
      ":" +
      DateTime.parse(date.toString()).minute.toString();
}
