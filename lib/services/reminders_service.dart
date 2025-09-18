// E:/MittiAI/lib/services/reminders_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For ChangeNotifier and kDebugMode
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_calendar/device_calendar.dart' as dc; // Added prefix for device_calendar
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:mitti_ai/data/reminder.dart' as app_data; // Added prefix for your app's Reminder

class RemindersService extends ChangeNotifier {
  static const _remindersKey = 'reminders';
  List<app_data.Reminder> _reminders = [];
  SharedPreferences? _prefs;

  final dc.DeviceCalendarPlugin _deviceCalendarPlugin = dc.DeviceCalendarPlugin();
  String? _selectedCalendarId;

  List<app_data.Reminder> get reminders => _reminders;

  RemindersService() {
    tzdata.initializeTimeZones();
    _loadReminders();
    _retrieveCalendarsAndPermissions();
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadReminders() async {
    await _initPrefs();
    final String? remindersString = _prefs?.getString(_remindersKey);
    if (remindersString != null) {
      final List<dynamic> remindersJson = jsonDecode(remindersString);
      _reminders = remindersJson.map((json) => app_data.Reminder.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveReminders() async {
    await _initPrefs();
    final String remindersString = jsonEncode(_reminders.map((r) => r.toJson()).toList());
    await _prefs?.setString(_remindersKey, remindersString);
  }

  Future<bool> _requestPermissions() async {
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !(permissionsGranted.data ?? false)) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !(permissionsGranted.data ?? false)) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('Calendar permissions not granted.');
        }
        return false;
      }
    }
    return true;
  }

  Future<void> _retrieveCalendarsAndPermissions() async {
    if (!await _requestPermissions()) {
      return;
    }

    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (calendarsResult.isSuccess && calendarsResult.data != null && calendarsResult.data!.isNotEmpty) {
      _selectedCalendarId = calendarsResult.data!.firstWhere(
              (cal) => cal.isDefault == true && cal.isReadOnly == false,
          orElse: () => calendarsResult.data!.firstWhere(
                  (cal) => cal.isReadOnly == false,
              orElse: () => calendarsResult.data!.first
          )
      ).id;
      if (kDebugMode) {
        // ignore: avoid_print
        print('Selected calendar ID: $_selectedCalendarId');
      }
    } else {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Failed to retrieve calendars or no calendars found.');
        if (calendarsResult.hasErrors) {
          for (var error in calendarsResult.errors) {
            // ignore: avoid_print
            print('Error retrieving calendars: ${error.errorMessage}');
          }
        }
      }
    }
  }

  dc.RecurrenceRule? _getRecurrenceRule(app_data.Reminder reminder) {
    if (reminder.repeatType == 'none' || reminder.repeatType == null) {
      return null;
    }

    final List<dc.DayOfWeek> daysOfWeekList = [];
    if (reminder.repeatType == 'weekly' && reminder.daysOfWeek != null) {
      for (var dayInt in reminder.daysOfWeek!) {
        if (dayInt == DateTime.monday) { daysOfWeekList.add(dc.DayOfWeek.Monday); }
        else if (dayInt == DateTime.tuesday) { daysOfWeekList.add(dc.DayOfWeek.Tuesday); }
        else if (dayInt == DateTime.wednesday) { daysOfWeekList.add(dc.DayOfWeek.Wednesday); }
        else if (dayInt == DateTime.thursday) { daysOfWeekList.add(dc.DayOfWeek.Thursday); }
        else if (dayInt == DateTime.friday) { daysOfWeekList.add(dc.DayOfWeek.Friday); }
        else if (dayInt == DateTime.saturday) { daysOfWeekList.add(dc.DayOfWeek.Saturday); }
        else if (dayInt == DateTime.sunday) { daysOfWeekList.add(dc.DayOfWeek.Sunday); }
      }
    }

    dc.RecurrenceFrequency frequency;
    switch (reminder.repeatType) {
      case 'daily':
        frequency = dc.RecurrenceFrequency.Daily;
        break;
      case 'weekly':
        frequency = dc.RecurrenceFrequency.Weekly;
        if (daysOfWeekList.isEmpty) {
           // ignore: avoid_print
           if (kDebugMode) print("Error: Weekly reminder specified but no daysOfWeek provided in app_data.Reminder.");
          return null;
        }
        break;
      case 'monthly':
        frequency = dc.RecurrenceFrequency.Monthly;
        if (reminder.dayOfMonth == null && kDebugMode) {
            // ignore: avoid_print
            print("Warning: Monthly reminder type chosen, but no specific dayOfMonth was set in app_data.Reminder. The reminder will recur on the day of the initial dueDate (${reminder.dueDate.day}).");
        } else if (reminder.dayOfMonth != null && reminder.dueDate.day != reminder.dayOfMonth && kDebugMode) {
          // ignore: avoid_print
          print("Warning: Monthly reminder's dueDate.day (${reminder.dueDate.day}) does not match specified dayOfMonth (${reminder.dayOfMonth}). The event will recur on ${reminder.dueDate.day} of the month, not necessarily on the ${reminder.dayOfMonth}th.");
        }
        break;
      default:
        return null;
    }

    return dc.RecurrenceRule(
      frequency,
      daysOfWeek: daysOfWeekList.isNotEmpty ? daysOfWeekList : null,
    );
  }

  Future<String?> _addEventToNativeCalendar(app_data.Reminder reminder) async {
    if (_selectedCalendarId == null) {
      await _retrieveCalendarsAndPermissions();
      if (_selectedCalendarId == null) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('No calendar selected/available to add event.');
        }
        return null;
      }
    }

    final location = tz.local;
    final tz.TZDateTime startDateTime = tz.TZDateTime.from(reminder.dueDate, location);
    final tz.TZDateTime endDateTime = tz.TZDateTime.from(reminder.dueDate.add(const Duration(hours: 1)), location);

    final event = dc.Event(
      _selectedCalendarId!,
      title: reminder.title,
      start: startDateTime,
      end: endDateTime,
      recurrenceRule: _getRecurrenceRule(reminder),
    );

    final createEventResult = await _deviceCalendarPlugin.createOrUpdateEvent(event);
    if (createEventResult?.isSuccess == true && createEventResult!.data != null) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Event added to native calendar. ID: ${createEventResult.data}');
      }
      return createEventResult.data;
    } else {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Failed to add event to native calendar.');
        if (createEventResult?.hasErrors == true) {
          for (var error in createEventResult!.errors) {
            // ignore: avoid_print
            print('Error: ${error.errorMessage}');
          }
        }
      }
      return null;
    }
  }

  // --- New method for removing event from native calendar ---
  Future<bool> _removeEventFromNativeCalendar(String? eventId) async {
    if (eventId == null || eventId.isEmpty) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('No native event ID provided, cannot remove from calendar.');
      }
      return false;
    }

    if (_selectedCalendarId == null) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('No calendar selected, cannot remove event. Attempting to retrieve calendars again.');
      }
      await _retrieveCalendarsAndPermissions(); 
      if (_selectedCalendarId == null) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('Still no calendar selected after retry. Cannot remove event.');
        }
        return false;
      }
    }

    final deleteResult = await _deviceCalendarPlugin.deleteEvent(_selectedCalendarId!, eventId);
    if (deleteResult.isSuccess) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Event ID $eventId successfully removed from native calendar $_selectedCalendarId.');
      }
      return true;
    } else {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Failed to remove event ID $eventId from native calendar.');
        if (deleteResult.hasErrors) {
          for (var error in deleteResult.errors) {
            // ignore: avoid_print
            print('Error: ${error.errorMessage}');
          }
        }
      }
      return false;
    }
  }

  Future<void> addReminder(app_data.Reminder reminder) async {
    String? nativeEventId = await _addEventToNativeCalendar(reminder);

    app_data.Reminder reminderToSave = reminder;
    if (nativeEventId != null) {
      reminderToSave = reminder.copyWith(nativeEventId: nativeEventId);
    }

    _reminders.add(reminderToSave);
    await _saveReminders();
    notifyListeners();
  }

  Future<void> removeReminder(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      app_data.Reminder reminderToRemove = _reminders[index];

      if (reminderToRemove.nativeEventId != null) {
        bool removedFromNative = await _removeEventFromNativeCalendar(reminderToRemove.nativeEventId);
        if (!removedFromNative && kDebugMode) {
          // ignore: avoid_print
          print("Failed to remove event ${reminderToRemove.nativeEventId} from native calendar, but proceeding with local removal.");
        }
      } else {
        if (kDebugMode) {
          // ignore: avoid_print
          print("Reminder ID ${reminderToRemove.id} has no nativeEventId. Skipping native calendar removal.");
        }
      }

      _reminders.removeAt(index);
      await _saveReminders();
      notifyListeners();
    }
  }

  Future<void> toggleReminderStatus(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final oldReminder = _reminders[index];
      app_data.Reminder newReminderData = oldReminder.copyWith(isCompleted: !oldReminder.isCompleted);

      if (newReminderData.isCompleted) {
        // If reminder is marked completed, try to remove its event from the native calendar.
        if (oldReminder.nativeEventId != null) {
          bool removed = await _removeEventFromNativeCalendar(oldReminder.nativeEventId);
          if (removed) {
            // Successfully removed from native calendar, so clear the nativeEventId locally.
            newReminderData = newReminderData.copyWith(nativeEventId: null);
             if (kDebugMode) {
              // ignore: avoid_print
              print("Event ${oldReminder.nativeEventId} removed from native calendar due to completion.");
            }
          } else {
            if (kDebugMode) {
              // ignore: avoid_print
              print("Failed to remove event ${oldReminder.nativeEventId} from native calendar for completed reminder. Local nativeEventId kept.");
            }
          }
        } else {
           if (kDebugMode) {
            // ignore: avoid_print
            print("Reminder ${oldReminder.id} had no nativeEventId when marked complete. No native removal needed.");
          }
        }
      } else {
        // If reminder is marked incomplete (i.e., active again),
        // try to add it back to the native calendar.
        app_data.Reminder reminderToReAdd = newReminderData.copyWith(nativeEventId: null);
        String? newNativeEventId = await _addEventToNativeCalendar(reminderToReAdd);
        if (newNativeEventId != null) {
          newReminderData = newReminderData.copyWith(nativeEventId: newNativeEventId);
          if (kDebugMode) {
            // ignore: avoid_print
            print("Event re-added to native calendar with new ID: $newNativeEventId for reminder ${newReminderData.id}.");
          }
        } else {
          if (kDebugMode) {
            // ignore: avoid_print
            print("Failed to re-add event to native calendar for reminder ${newReminderData.id}.");
          }
        }
      }

      _reminders[index] = newReminderData; // Update with potentially new nativeEventId or cleared one
      await _saveReminders();
      notifyListeners();
    }
  }
}
