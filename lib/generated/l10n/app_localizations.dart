import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('te'),
  ];

  /// Greeting message on the voice assistant screen with user name
  ///
  /// In en, this message translates to:
  /// **'Hi {userName}, your farming assistant is here to help.'**
  String greetingWithName(String userName);

  /// No description provided for @stateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get stateLabel;

  /// No description provided for @stateHint.
  ///
  /// In en, this message translates to:
  /// **'Select your state'**
  String get stateHint;

  /// No description provided for @stateValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please select your state'**
  String get stateValidationError;

  /// No description provided for @formValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields and make selections.'**
  String get formValidationError;

  /// No description provided for @greetingWithoutName.
  ///
  /// In en, this message translates to:
  /// **'Your farming assistant is here to help.'**
  String get greetingWithoutName;

  /// No description provided for @voiceAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Assistant'**
  String get voiceAssistantTitle;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @infoLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get infoLibraryTitle;

  /// No description provided for @schemesTitle.
  ///
  /// In en, this message translates to:
  /// **'Schemes'**
  String get schemesTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @assistantNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistantNavLabel;

  /// No description provided for @remindersNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersNavLabel;

  /// No description provided for @infoNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoNavLabel;

  /// No description provided for @schemesNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Schemes'**
  String get schemesNavLabel;

  /// No description provided for @profileNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileNavLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutButton;

  /// No description provided for @setupScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mitti AI!'**
  String get setupScreenTitle;

  /// No description provided for @setupScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get your agricultural assistant ready.'**
  String get setupScreenSubtitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get nameHint;

  /// No description provided for @nameValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameValidationError;

  /// No description provided for @villageLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Village/Town'**
  String get villageLabel;

  /// No description provided for @villageHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the name of your village or town'**
  String get villageHint;

  /// No description provided for @villageValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your village/town'**
  String get villageValidationError;

  /// No description provided for @emailOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get emailOptionalLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Your email username'**
  String get emailHint;

  /// No description provided for @emailInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalidError;

  /// No description provided for @languageHint.
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get languageHint;

  /// No description provided for @languageValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please select a language'**
  String get languageValidationError;

  /// No description provided for @saveAndContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveAndContinueButton;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipButton;

  /// No description provided for @voiceAssistantHelpPrompt.
  ///
  /// In en, this message translates to:
  /// **'What can I help you with today?'**
  String get voiceAssistantHelpPrompt;

  /// No description provided for @tapToSpeakButton.
  ///
  /// In en, this message translates to:
  /// **'Tap to Speak'**
  String get tapToSpeakButton;

  /// No description provided for @pleaseWaitMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWaitMessage;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get tryAgainLater;

  /// No description provided for @noMessagesYetLabel.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYetLabel;

  /// No description provided for @upcomingRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Reminders'**
  String get upcomingRemindersTitle;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @addReminderFAB.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminderFAB;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders set yet.'**
  String get noReminders;

  /// No description provided for @saveReminderButton.
  ///
  /// In en, this message translates to:
  /// **'Save Reminder'**
  String get saveReminderButton;

  /// No description provided for @homeNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNavLabel;

  /// No description provided for @askYourDoubtsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Ask your doubts regarding agriculture'**
  String get askYourDoubtsPrompt;

  /// No description provided for @quickAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccessTitle;

  /// Title for the History section/screen
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @libraryNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryNavLabel;

  /// No description provided for @weatherNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weatherNavLabel;

  /// No description provided for @tipOfTheDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Tip of the Day'**
  String get tipOfTheDayTitle;

  /// No description provided for @tipOfTheDay1.
  ///
  /// In en, this message translates to:
  /// **'Rotate your crops to improve soil health and reduce pests.'**
  String get tipOfTheDay1;

  /// No description provided for @tipOfTheDay2.
  ///
  /// In en, this message translates to:
  /// **'Regularly check your plants for early signs of diseases.'**
  String get tipOfTheDay2;

  /// No description provided for @tipOfTheDay3.
  ///
  /// In en, this message translates to:
  /// **'Ensure your irrigation system is efficient to save water.'**
  String get tipOfTheDay3;

  /// No description provided for @voiceInputNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Voice input not implemented yet.'**
  String get voiceInputNotImplemented;

  /// No description provided for @agriAssistantTagline.
  ///
  /// In en, this message translates to:
  /// **'Your agri assistant is here to help'**
  String get agriAssistantTagline;

  /// No description provided for @speakCommandToSearch.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic and speak your query.'**
  String get speakCommandToSearch;

  /// No description provided for @profileUserDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get profileUserDetailsLabel;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// No description provided for @profileVillageLabel.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get profileVillageLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhoneLabel;

  /// No description provided for @profileCropTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop Type'**
  String get profileCropTypeLabel;

  /// No description provided for @languageSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettingsLabel;

  /// No description provided for @languageDropdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageDropdownLabel;

  /// No description provided for @loginButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Login / Complete Profile'**
  String get loginButtonLabel;

  /// No description provided for @remindersAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersAppBarTitle;

  /// No description provided for @noRemindersYet.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet.'**
  String get noRemindersYet;

  /// No description provided for @tapPlusToAddReminder.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add a new reminder.'**
  String get tapPlusToAddReminder;

  /// No description provided for @addReminderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminderTooltip;

  /// Indicates the due date of a reminder
  ///
  /// In en, this message translates to:
  /// **'Due on {date}'**
  String dueOn(String date);

  /// No description provided for @repeatsDaily.
  ///
  /// In en, this message translates to:
  /// **'Repeats daily'**
  String get repeatsDaily;

  /// Indicates weekly repetition on specific days
  ///
  /// In en, this message translates to:
  /// **'Repeats weekly on {days}'**
  String repeatsWeeklyOn(String days);

  /// No description provided for @repeatsWeekly.
  ///
  /// In en, this message translates to:
  /// **'Repeats weekly'**
  String get repeatsWeekly;

  /// Indicates monthly repetition on a specific day of the month
  ///
  /// In en, this message translates to:
  /// **'Repeats monthly on day {day}'**
  String repeatsMonthlyOnDay(String day);

  /// No description provided for @repeatsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Repeats monthly'**
  String get repeatsMonthly;

  /// No description provided for @addReminderDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Reminder'**
  String get addReminderDialogTitle;

  /// No description provided for @reminderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter reminder name'**
  String get reminderNameHint;

  /// No description provided for @fieldRequiredErrorText.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequiredErrorText;

  /// No description provided for @selectDatePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectDatePrompt;

  /// No description provided for @selectTimePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a time'**
  String get selectTimePrompt;

  /// No description provided for @repeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatLabel;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get repeatNone;

  /// No description provided for @selectDaysOfWeekPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select days of the week:'**
  String get selectDaysOfWeekPrompt;

  /// No description provided for @selectDayOfMonthPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select day of the month:'**
  String get selectDayOfMonthPrompt;

  /// No description provided for @addButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButtonLabel;

  /// No description provided for @ensureTitleDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Please ensure title, date, and time are set.'**
  String get ensureTitleDateAndTime;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Repeats daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Repeats weekly'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Repeats monthly'**
  String get repeatMonthly;

  /// No description provided for @speakingNowPrompt.
  ///
  /// In en, this message translates to:
  /// **'Listening... Speak now'**
  String get speakingNowPrompt;

  /// No description provided for @stopLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopLabel;

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @processingLabel.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingLabel;

  /// No description provided for @schemesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Government Schemes'**
  String get schemesScreenTitle;

  /// No description provided for @schemesScreenSelectStateHint.
  ///
  /// In en, this message translates to:
  /// **'Select State'**
  String get schemesScreenSelectStateHint;

  /// No description provided for @schemesScreenSelectDistrictHint.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get schemesScreenSelectDistrictHint;

  /// No description provided for @schemesScreenFetchingSchemes.
  ///
  /// In en, this message translates to:
  /// **'Fetching schemes...'**
  String get schemesScreenFetchingSchemes;

  /// No description provided for @schemesScreenErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get schemesScreenErrorPrefix;

  /// No description provided for @schemesScreenNoSchemesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No schemes available for the selected state/district.'**
  String get schemesScreenNoSchemesAvailable;

  /// No description provided for @schemeDialogViewSourceButton.
  ///
  /// In en, this message translates to:
  /// **'View Source'**
  String get schemeDialogViewSourceButton;

  /// No description provided for @schemeDialogCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get schemeDialogCloseButton;

  /// No description provided for @schemeDialogCouldNotLaunchPrefix.
  ///
  /// In en, this message translates to:
  /// **'Could not launch '**
  String get schemeDialogCouldNotLaunchPrefix;

  /// No description provided for @schemesScreenLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Login and select your state to view state-specific schemes.'**
  String get schemesScreenLoginPrompt;

  /// No description provided for @schemesScreenLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get schemesScreenLoginButton;

  /// No description provided for @schemesScreenUpdatingSchemes.
  ///
  /// In en, this message translates to:
  /// **'Updating schemes… (this may take 10–20s). Please wait.'**
  String get schemesScreenUpdatingSchemes;

  /// No description provided for @schemeDialogOpenWebsite.
  ///
  /// In en, this message translates to:
  /// **'Open website for more details.'**
  String get schemeDialogOpenWebsite;

  /// No description provided for @schemeDialogStepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Steps:'**
  String get schemeDialogStepsLabel;

  /// No description provided for @schemeDialogDocumentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Documents:'**
  String get schemeDialogDocumentsLabel;

  /// No description provided for @schemesScreenNoSchemesForState.
  ///
  /// In en, this message translates to:
  /// **'No schemes found for {stateName}. Try refreshing, or check back later.'**
  String schemesScreenNoSchemesForState(Object stateName);

  /// No description provided for @historyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyScreenTitle;

  /// No description provided for @clearHistoryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear history?'**
  String get clearHistoryDialogTitle;

  /// No description provided for @clearHistoryDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Delete all saved chats?'**
  String get clearHistoryDialogContent;

  /// No description provided for @cancelButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonLabel;

  /// No description provided for @clearButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearButtonLabel;

  /// No description provided for @noRecentChats.
  ///
  /// In en, this message translates to:
  /// **'No recent chats'**
  String get noRecentChats;

  /// No description provided for @refreshLabel.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshLabel;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @noLibraryItemsMessage.
  ///
  /// In en, this message translates to:
  /// **'No library items found. Pull down to refresh or try a different search.'**
  String get noLibraryItemsMessage;

  /// No description provided for @categorySeeds.
  ///
  /// In en, this message translates to:
  /// **'Seeds'**
  String get categorySeeds;

  /// No description provided for @categoryFertilizers.
  ///
  /// In en, this message translates to:
  /// **'Fertilizers'**
  String get categoryFertilizers;

  /// No description provided for @categoryPestsAndDiseases.
  ///
  /// In en, this message translates to:
  /// **'Pests & Diseases'**
  String get categoryPestsAndDiseases;

  /// No description provided for @microphonePermissionDeniedPreviously.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission was denied. Please grant it to use this feature.'**
  String get microphonePermissionDeniedPreviously;

  /// No description provided for @grantPermissionAction.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get grantPermissionAction;

  /// No description provided for @microphonePermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is permanently denied. Please enable it in app settings.'**
  String get microphonePermissionPermanentlyDenied;

  /// No description provided for @openSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettingsAction;

  /// No description provided for @microphonePermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to use voice input.'**
  String get microphonePermissionNeeded;

  /// No description provided for @microphonePermissionRestricted.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is restricted on this device.'**
  String get microphonePermissionRestricted;

  /// No description provided for @speechNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not available.'**
  String get speechNotAvailable;

  /// No description provided for @calendarPermissionNeededMessage.
  ///
  /// In en, this message translates to:
  /// **'To save reminders, the app needs permission to access your calendar.'**
  String get calendarPermissionNeededMessage;

  /// No description provided for @calendarPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Calendar permission was denied. Please grant access to create reminders.'**
  String get calendarPermissionDeniedMessage;

  /// No description provided for @calendarPermissionPermanentlyDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Calendar permission is permanently denied. Please go to settings to enable it if you want to create reminders.'**
  String get calendarPermissionPermanentlyDeniedMessage;

  /// No description provided for @calendarPermissionRestrictedMessage.
  ///
  /// In en, this message translates to:
  /// **'Calendar access is restricted on this device. Reminders cannot be saved.'**
  String get calendarPermissionRestrictedMessage;

  /// No description provided for @okAction.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okAction;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'12345 67890'**
  String get phoneHint;

  /// No description provided for @phoneValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get phoneValidationError;

  /// No description provided for @phoneInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 10 digits'**
  String get phoneInvalidError;

  /// No description provided for @cropTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop Type'**
  String get cropTypeLabel;

  /// No description provided for @cropTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Wheat, Rice'**
  String get cropTypeHint;

  /// No description provided for @cropTypeValidationError.
  ///
  /// In en, this message translates to:
  /// **'Crop type must be at least 3 characters long'**
  String get cropTypeValidationError;

  /// No description provided for @privacyPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLabel;

  /// No description provided for @privacyPolicyError.
  ///
  /// In en, this message translates to:
  /// **'Could not open privacy policy.'**
  String get privacyPolicyError;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @acceptAndContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Accept and Continue'**
  String get acceptAndContinueButton;

  /// No description provided for @supportText.
  ///
  /// In en, this message translates to:
  /// **'Support:'**
  String get supportText;

  /// No description provided for @supportMessage.
  ///
  /// In en, this message translates to:
  /// **'Any queries/support, follow the above link.'**
  String get supportMessage;

  /// No description provided for @emailError.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app.'**
  String get emailError;

  /// No description provided for @urlLaunchError.
  ///
  /// In en, this message translates to:
  /// **'Could not open support page.'**
  String get urlLaunchError;

  /// No description provided for @mittiAiSupportLink.
  ///
  /// In en, this message translates to:
  /// **'Mitti AI Support'**
  String get mittiAiSupportLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
