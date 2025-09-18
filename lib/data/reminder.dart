// E:/MittiAI/lib/data/reminder.dart
import 'package:flutter/foundation.dart'; // For listEquals

class Reminder {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final String? repeatType; // 'none', 'daily', 'weekly', 'monthly'
  final List<int>? daysOfWeek; // For weekly repeat, 1 (Mon) to 7 (Sun)
  final int? dayOfMonth; // For monthly repeat
  final String? nativeEventId; // To store the ID from the device's calendar

  Reminder({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    this.repeatType = 'none', // Default value if not provided
    this.daysOfWeek,
    this.dayOfMonth,
    this.nativeEventId,
  });

  Reminder copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    bool? isCompleted,
    String? repeatType,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    String? nativeEventId,
    bool clearNativeEventId = false,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatType: repeatType ?? this.repeatType,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      nativeEventId: clearNativeEventId ? null : nativeEventId ?? this.nativeEventId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'repeatType': repeatType,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'nativeEventId': nativeEventId,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      repeatType: json['repeatType'] as String? ?? 'none', // Ensure default if null from json
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)?.map((e) => e as int).toList(),
      dayOfMonth: json['dayOfMonth'] as int?,
      nativeEventId: json['nativeEventId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder &&
        other.id == id &&
        other.title == title &&
        other.dueDate == dueDate &&
        other.isCompleted == isCompleted &&
        other.repeatType == repeatType &&
        listEquals(other.daysOfWeek, daysOfWeek) && // from foundation.dart
        other.dayOfMonth == dayOfMonth &&
        other.nativeEventId == nativeEventId;
  }

  @override
  int get hashCode {
    // Non-nullable fields
    int result = id.hashCode;
    result = result ^ title.hashCode;
    result = result ^ dueDate.hashCode;
    result = result ^ isCompleted.hashCode;

    // Nullable fields - using ?? 0 to provide a default if null
    result = result ^ (repeatType?.hashCode ?? 0);
    result = result ^ (dayOfMonth?.hashCode ?? 0);
    result = result ^ (nativeEventId?.hashCode ?? 0);

    // For the list, handle null list and then fold
    if (daysOfWeek != null) {
      // Fold combines the hash codes of the elements in the list
      result = result ^ (daysOfWeek!.fold(0, (prev, element) => prev ^ element.hashCode));
    } else {
      // If daysOfWeek is null, XOR with 0 (or some other constant)
      result = result ^ 0;
    }
    return result;
  }
}

