import 'package:flutter/material.dart';

// Amuma Health App Color Palette - Blue & Orange Theme
const primary = Color(0xFFDC143C); // Deep Blue - Main brand color
const primaryLight = Color(0xFFFFF3F7); // Light Blue - Accents and backgrounds

TimeOfDay parseTime(String timeString) {
  List<String> parts = timeString.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}
