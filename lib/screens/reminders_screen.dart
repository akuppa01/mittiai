import 'package:flutter/material.dart';
import 'package:mitti_ai/generated/l10n/app_localizations.dart';
import 'package:mitti_ai/services/reminders_service.dart';
import 'package:mitti_ai/theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'package:mitti_ai/data/reminder.dart';

class RemindersScreen extends StatefulWidget {
  final bool isRootScreenForTab;
  final VoidCallback? onGoToVoiceAssistantTab;

  const RemindersScreen(
      {super.key,
      required this.isRootScreenForTab,
      this.onGoToVoiceAssistantTab});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    // _requestInitialCalendarPermission(); // Removed
  }

  // Removed _requestInitialCalendarPermission method

  void _showSnackBarWithAction(
      String message, String actionLabel, VoidCallback onActionPressed) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.yellow[100], // Set the background color
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.black87), // Set message text color
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87, // Set button text color
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onActionPressed,
            child: Text(actionLabel),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _handleFabClick() async {
    final l = AppLocalizations.of(context)!;
    var status = await Permission.calendar.status;

    if (status.isGranted) {
      _showAddReminderDialog(context, Provider.of<RemindersService>(context, listen: false), l);
    } else if (status.isDenied) { // This now covers the first request as well
      _showSnackBarWithAction(
        l.calendarPermissionDeniedMessage,
        l.grantPermissionAction,
        () async {
          final newStatus = await Permission.calendar.request();
          if (newStatus.isGranted) {
            _showAddReminderDialog(context, Provider.of<RemindersService>(context, listen: false), l);
          } else if (newStatus.isPermanentlyDenied) {
             _showSnackBarWithAction(
                l.calendarPermissionPermanentlyDeniedMessage,
                l.openSettingsAction,
                openAppSettings);
          }
        },
      );
    } else if (status.isPermanentlyDenied) {
      _showSnackBarWithAction(
          l.calendarPermissionPermanentlyDeniedMessage, l.openSettingsAction, openAppSettings);
    } else if (status.isRestricted) {
       _showSnackBarWithAction(
          l.calendarPermissionRestrictedMessage, l.okAction, () {}); // OK action might just dismiss
    }
  }
  
  // Define an 'okAction' localization string if you want a specific term for dismissing a restricted snackbar
  // For now, it will use the generic 'Grant' or 'Open Settings' if not handled specifically.
  // Adding a general "OK" for restricted might be:
  // "okAction": "OK" in .arb files.
  // For now, the restricted case above will show a snackbar that might not be ideal without an "OK" specific action.
  // Consider adding "okAction" to your .arb files and using it:
  // l.okAction in the restricted case.

  Widget _buildReminderItem(BuildContext context, Reminder reminder,
      RemindersService service, AppLocalizations l) {
    String formattedDate =
        DateFormat('MMM d, yyyy hh:mm a').format(reminder.dueDate);
    String subtitle = l.dueOn(formattedDate);
    String repeatInfo = '';

    if (reminder.repeatType != 'none' && reminder.repeatType != null) {
      switch (reminder.repeatType) {
        case 'daily':
          repeatInfo = l.repeatsDaily;
          break;
        case 'weekly':
          if (reminder.daysOfWeek != null &&
              reminder.daysOfWeek!.isNotEmpty) {
            final sortedDays = List<int>.from(reminder.daysOfWeek!)..sort();
            final days = sortedDays.map((d) {
              if (d >= DateTime.monday && d <= DateTime.sunday) {
                return DateFormat.E().dateSymbols.SHORTWEEKDAYS[(d % 7)];
              }
              return '';
            }).where((s) => s.isNotEmpty).join(', ');
            repeatInfo = l.repeatsWeeklyOn(days);
          } else {
            repeatInfo = l.repeatsWeekly; // Fallback
          }
          break;
        case 'monthly':
          if (reminder.dayOfMonth != null) {
            repeatInfo =
                l.repeatsMonthlyOnDay(reminder.dayOfMonth.toString());
          } else {
            repeatInfo = l.repeatsMonthly; // Fallback
          }
          break;
      }
      subtitle += '\n$repeatInfo';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          reminder.isCompleted
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: reminder.isCompleted
              ? Colors.green
              : Theme.of(context).primaryColor,
          size: 30,
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            decoration:
                reminder.isCompleted ? TextDecoration.lineThrough : null,
            color: reminder.isCompleted ? Colors.grey : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            service.removeReminder(reminder.id);
          },
        ),
        onTap: () {
          service.toggleReminderStatus(reminder.id);
        },
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context, RemindersService service, AppLocalizations l) {
    final titleController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String selectedRepeatType = 'none';
    List<int> selectedDaysOfWeek = [];
    int? selectedDayOfMonth;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(l.addReminderDialogTitle),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(hintText: l.reminderNameHint),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l.fieldRequiredErrorText;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(l.dateLabel),
                        subtitle: Text(selectedDate != null
                            ? DateFormat.yMMMd().format(selectedDate!)
                            : l.selectDatePrompt),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(DateTime.now().year + 5),
                          );
                          if (picked != null && picked != selectedDate) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(l.timeLabel),
                        subtitle: Text(selectedTime != null
                            ? selectedTime!.format(context)
                            : l.selectTimePrompt),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ??
                                TimeOfDay.fromDateTime(
                                    DateTime.now().add(const Duration(hours: 1))),
                          );
                          if (picked != null && picked != selectedTime) {
                            setState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: l.repeatLabel),
                        value: selectedRepeatType,
                        items: [
                          DropdownMenuItem(
                              value: 'none', child: Text(l.repeatNone)),
                          DropdownMenuItem(
                              value: 'daily', child: Text(l.repeatDaily)),
                          DropdownMenuItem(
                              value: 'weekly', child: Text(l.repeatWeekly)),
                          DropdownMenuItem(
                              value: 'monthly', child: Text(l.repeatMonthly)),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRepeatType = newValue!;
                            if (selectedRepeatType != 'weekly') {
                              selectedDaysOfWeek.clear();
                            }
                            if (selectedRepeatType != 'monthly') {
                              selectedDayOfMonth = null;
                            }
                          });
                        },
                      ),
                      if (selectedRepeatType == 'weekly') ...[
                        const SizedBox(height: 8),
                        Text(l.selectDaysOfWeekPrompt,
                            style: Theme.of(context).textTheme.bodySmall),
                        Wrap(
                          spacing: 8.0,
                          children: List<Widget>.generate(7, (int index) {
                            final dayConstant = index + 1; // DateTime.monday is 1, sunday is 7
                            final dayName = DateFormat.E().dateSymbols.SHORTWEEKDAYS[(dayConstant % 7)]; // Adjust index for SHORTWEEKDAYS
                            return ChoiceChip(
                              label: Text(dayName),
                              selected: selectedDaysOfWeek.contains(dayConstant),
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    selectedDaysOfWeek.add(dayConstant);
                                  } else {
                                    selectedDaysOfWeek
                                        .removeWhere((item) => item == dayConstant);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      if (selectedRepeatType == 'monthly') ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                              labelText: l.selectDayOfMonthPrompt),
                          value: selectedDayOfMonth,
                          items: List<DropdownMenuItem<int>>.generate(31,
                              (int index) {
                            final day = index + 1;
                            return DropdownMenuItem(
                                value: day, child: Text(day.toString()));
                          }),
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedDayOfMonth = newValue;
                            });
                          },
                          hint: Text(l.selectDayOfMonthPrompt),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(l.cancelButtonLabel),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  child: Text(l.addButtonLabel),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (selectedDate == null || selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(l.ensureTitleDateAndTime)),
                        );
                        return;
                      }

                      final DateTime combinedDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );

                      final newReminder = Reminder(
                        id: const Uuid().v4(),
                        title: titleController.text,
                        dueDate: combinedDateTime,
                        isCompleted: false,
                        repeatType: selectedRepeatType,
                        daysOfWeek: selectedRepeatType == 'weekly'
                            ? List<int>.from(selectedDaysOfWeek)
                            : null,
                        dayOfMonth: selectedRepeatType == 'monthly'
                            ? selectedDayOfMonth
                            : null,
                      );
                      service.addReminder(newReminder);
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final remindersService = Provider.of<RemindersService>(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        toolbarHeight: 80.0,
        centerTitle: true,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.isRootScreenForTab && widget.onGoToVoiceAssistantTab != null) {
              widget.onGoToVoiceAssistantTab!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(l.remindersAppBarTitle,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold)),
      ),
      body: remindersService.reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.alarm_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    l.noRemindersYet,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.tapPlusToAddReminder,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: remindersService.reminders.length,
              itemBuilder: (context, index) {
                final reminder = remindersService.reminders[index];
                return _buildReminderItem(
                    context, reminder, remindersService, l);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleFabClick, // Changed to _handleFabClick
        tooltip: l.addReminderTooltip,
        backgroundColor: primaryGreen,
        child: const Icon(Icons.add_alarm, color: Colors.white),
      ),
    );
  }
}
