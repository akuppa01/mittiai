import 'package:flutter/material.dart';

// Define your application's primary green color.
// IMPORTANT: Replace the hex value 0xFF4CAF50 with YOUR app's primary green color.
// Also, define the shades appropriately.
const MaterialColor primaryGreen = MaterialColor(
  0xFF4CAF50, // Example: Standard Green - REPLACE THIS
  <int, Color>{
     50: Color(0xFFE8F5E9), // Lightest shade - example
    100: Color(0xFFC8E6C9), // Used for primaryGreen.shade100 - example
    200: Color(0xFFA5D6A7), // example
    300: Color(0xFF81C784), // example
    400: Color(0xFF66BB6A), // example
    500: Color(0xFF4CAF50), // The primary color itself (must match the first argument)
    600: Color(0xFF43A047), // example
    700: Color(0xFF388E3C), // example
    800: Color(0xFF2E7D32), // example
    900: Color(0xFF1B5E20), // Darkest shade - example
  },
);

// You can define other colors your app uses here as well, for example:
// const Color secondaryAccent = Color(0xFFFFC107);
