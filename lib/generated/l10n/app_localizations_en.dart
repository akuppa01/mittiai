// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String greetingWithName(String userName) {
    return 'Hi $userName, your farming assistant is here to help.';
  }

  @override
  String get stateLabel => 'State';

  @override
  String get stateHint => 'Select your state';

  @override
  String get stateValidationError => 'Please select your state';

  @override
  String get formValidationError =>
      'Please fill all required fields and make selections.';

  @override
  String get greetingWithoutName => 'Your farming assistant is here to help.';

  @override
  String get voiceAssistantTitle => 'Voice Assistant';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get infoLibraryTitle => 'Library';

  @override
  String get schemesTitle => 'Schemes';

  @override
  String get profileTitle => 'Profile';

  @override
  String get assistantNavLabel => 'Assistant';

  @override
  String get remindersNavLabel => 'Reminders';

  @override
  String get infoNavLabel => 'Info';

  @override
  String get schemesNavLabel => 'Schemes';

  @override
  String get profileNavLabel => 'Profile';

  @override
  String get languageLabel => 'Language';

  @override
  String get logoutButton => 'Log out';

  @override
  String get setupScreenTitle => 'Welcome to Mitti AI!';

  @override
  String get setupScreenSubtitle =>
      'Let\'s get your agricultural assistant ready.';

  @override
  String get nameLabel => 'Your Name';

  @override
  String get nameHint => 'Enter your full name';

  @override
  String get nameValidationError => 'Please enter your name';

  @override
  String get villageLabel => 'Your Village/Town';

  @override
  String get villageHint => 'Enter the name of your village or town';

  @override
  String get villageValidationError => 'Please enter your village/town';

  @override
  String get emailOptionalLabel => 'Email (Optional)';

  @override
  String get emailHint => 'Your email username';

  @override
  String get emailInvalidError => 'Please enter a valid email address';

  @override
  String get languageHint => 'Select your language';

  @override
  String get languageValidationError => 'Please select a language';

  @override
  String get saveAndContinueButton => 'Save & Continue';

  @override
  String get skipButton => 'Skip for now';

  @override
  String get voiceAssistantHelpPrompt => 'What can I help you with today?';

  @override
  String get tapToSpeakButton => 'Tap to Speak';

  @override
  String get pleaseWaitMessage => 'Please wait...';

  @override
  String get tryAgainLater => 'Please try again later.';

  @override
  String get noMessagesYetLabel => 'No messages yet';

  @override
  String get upcomingRemindersTitle => 'Upcoming Reminders';

  @override
  String get timeLabel => 'Time';

  @override
  String get dateLabel => 'Date';

  @override
  String get addReminderFAB => 'Add Reminder';

  @override
  String get noReminders => 'No reminders set yet.';

  @override
  String get saveReminderButton => 'Save Reminder';

  @override
  String get homeNavLabel => 'Home';

  @override
  String get askYourDoubtsPrompt => 'Ask your doubts regarding agriculture';

  @override
  String get quickAccessTitle => 'Quick Access';

  @override
  String get historyTitle => 'History';

  @override
  String get libraryNavLabel => 'Library';

  @override
  String get weatherNavLabel => 'Weather';

  @override
  String get tipOfTheDayTitle => 'Tip of the Day';

  @override
  String get tipOfTheDay1 =>
      'Rotate your crops to improve soil health and reduce pests.';

  @override
  String get tipOfTheDay2 =>
      'Regularly check your plants for early signs of diseases.';

  @override
  String get tipOfTheDay3 =>
      'Ensure your irrigation system is efficient to save water.';

  @override
  String get voiceInputNotImplemented => 'Voice input not implemented yet.';

  @override
  String get agriAssistantTagline => 'Your agri assistant is here to help';

  @override
  String get speakCommandToSearch => 'Tap the mic and speak your query.';

  @override
  String get profileUserDetailsLabel => 'User Details';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileVillageLabel => 'Village';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profilePhoneLabel => 'Phone';

  @override
  String get profileCropTypeLabel => 'Crop Type';

  @override
  String get languageSettingsLabel => 'Language Settings';

  @override
  String get languageDropdownLabel => 'Select Language';

  @override
  String get loginButtonLabel => 'Login / Complete Profile';

  @override
  String get remindersAppBarTitle => 'Reminders';

  @override
  String get noRemindersYet => 'No reminders yet.';

  @override
  String get tapPlusToAddReminder => 'Tap the + button to add a new reminder.';

  @override
  String get addReminderTooltip => 'Add Reminder';

  @override
  String dueOn(String date) {
    return 'Due on $date';
  }

  @override
  String get repeatsDaily => 'Repeats daily';

  @override
  String repeatsWeeklyOn(String days) {
    return 'Repeats weekly on $days';
  }

  @override
  String get repeatsWeekly => 'Repeats weekly';

  @override
  String repeatsMonthlyOnDay(String day) {
    return 'Repeats monthly on day $day';
  }

  @override
  String get repeatsMonthly => 'Repeats monthly';

  @override
  String get addReminderDialogTitle => 'Add New Reminder';

  @override
  String get reminderNameHint => 'Enter reminder name';

  @override
  String get fieldRequiredErrorText => 'This field is required';

  @override
  String get selectDatePrompt => 'Select a date';

  @override
  String get selectTimePrompt => 'Select a time';

  @override
  String get repeatLabel => 'Repeat';

  @override
  String get repeatNone => 'None';

  @override
  String get selectDaysOfWeekPrompt => 'Select days of the week:';

  @override
  String get selectDayOfMonthPrompt => 'Select day of the month:';

  @override
  String get addButtonLabel => 'Add';

  @override
  String get ensureTitleDateAndTime =>
      'Please ensure title, date, and time are set.';

  @override
  String get repeatDaily => 'Repeats daily';

  @override
  String get repeatWeekly => 'Repeats weekly';

  @override
  String get repeatMonthly => 'Repeats monthly';

  @override
  String get speakingNowPrompt => 'Listening... Speak now';

  @override
  String get stopLabel => 'Stop';

  @override
  String get closeLabel => 'Close';

  @override
  String get processingLabel => 'Processing...';

  @override
  String get schemesScreenTitle => 'Government Schemes';

  @override
  String get schemesScreenSelectStateHint => 'Select State';

  @override
  String get schemesScreenSelectDistrictHint => 'Select District';

  @override
  String get schemesScreenFetchingSchemes => 'Fetching schemes...';

  @override
  String get schemesScreenErrorPrefix => 'Error: ';

  @override
  String get schemesScreenNoSchemesAvailable =>
      'No schemes available for the selected state/district.';

  @override
  String get schemeDialogViewSourceButton => 'View Source';

  @override
  String get schemeDialogCloseButton => 'Close';

  @override
  String get schemeDialogCouldNotLaunchPrefix => 'Could not launch ';

  @override
  String get schemesScreenLoginPrompt =>
      'Login and select your state to view state-specific schemes.';

  @override
  String get schemesScreenLoginButton => 'Login';

  @override
  String get schemesScreenUpdatingSchemes =>
      'Updating schemes… (this may take 10–20s). Please wait.';

  @override
  String get schemeDialogOpenWebsite => 'Open website for more details.';

  @override
  String get schemeDialogStepsLabel => 'Steps:';

  @override
  String get schemeDialogDocumentsLabel => 'Documents:';

  @override
  String schemesScreenNoSchemesForState(Object stateName) {
    return 'No schemes found for $stateName. Try refreshing, or check back later.';
  }

  @override
  String get historyScreenTitle => 'History';

  @override
  String get clearHistoryDialogTitle => 'Clear history?';

  @override
  String get clearHistoryDialogContent => 'Delete all saved chats?';

  @override
  String get cancelButtonLabel => 'Cancel';

  @override
  String get clearButtonLabel => 'Clear';

  @override
  String get noRecentChats => 'No recent chats';

  @override
  String get refreshLabel => 'Refresh';

  @override
  String get searchHint => 'Search...';

  @override
  String get noLibraryItemsMessage =>
      'No library items found. Pull down to refresh or try a different search.';

  @override
  String get categorySeeds => 'Seeds';

  @override
  String get categoryFertilizers => 'Fertilizers';

  @override
  String get categoryPestsAndDiseases => 'Pests & Diseases';

  @override
  String get microphonePermissionDeniedPreviously =>
      'Microphone permission was denied. Please grant it to use this feature.';

  @override
  String get grantPermissionAction => 'Grant';

  @override
  String get microphonePermissionPermanentlyDenied =>
      'Microphone permission is permanently denied. Please enable it in app settings.';

  @override
  String get openSettingsAction => 'Open Settings';

  @override
  String get microphonePermissionNeeded =>
      'Microphone permission is required to use voice input.';

  @override
  String get microphonePermissionRestricted =>
      'Microphone access is restricted on this device.';

  @override
  String get speechNotAvailable => 'Speech recognition is not available.';

  @override
  String get calendarPermissionNeededMessage =>
      'To save reminders, the app needs permission to access your calendar.';

  @override
  String get calendarPermissionDeniedMessage =>
      'Calendar permission was denied. Please grant access to create reminders.';

  @override
  String get calendarPermissionPermanentlyDeniedMessage =>
      'Calendar permission is permanently denied. Please go to settings to enable it if you want to create reminders.';

  @override
  String get calendarPermissionRestrictedMessage =>
      'Calendar access is restricted on this device. Reminders cannot be saved.';

  @override
  String get okAction => 'OK';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get phoneHint => '12345 67890';

  @override
  String get phoneValidationError => 'Please enter your phone number';

  @override
  String get phoneInvalidError => 'Phone number must be 10 digits';

  @override
  String get cropTypeLabel => 'Crop Type';

  @override
  String get cropTypeHint => 'e.g., Wheat, Rice';

  @override
  String get cropTypeValidationError =>
      'Crop type must be at least 3 characters long';

  @override
  String get privacyPolicyLabel => 'Privacy Policy';

  @override
  String get privacyPolicyError => 'Could not open privacy policy.';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get acceptAndContinueButton => 'Accept and Continue';

  @override
  String get supportText => 'Support:';

  @override
  String get supportMessage => 'Any queries/support, follow the above link.';

  @override
  String get emailError => 'Could not open email app.';

  @override
  String get urlLaunchError => 'Could not open support page.';

  @override
  String get mittiAiSupportLink => 'Mitti AI Support';
}
