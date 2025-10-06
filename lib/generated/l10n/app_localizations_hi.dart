// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String greetingWithName(String userName) {
    return 'नमस्ते $userName, आपका किसानी सहायक आपकी मदद के लिए यहाँ है।';
  }

  @override
  String get stateLabel => 'राज्य';

  @override
  String get stateHint => 'अपना राज्य चुनें';

  @override
  String get stateValidationError => 'कृपया अपना राज्य चुनें';

  @override
  String get formValidationError => 'कृपया सभी आवश्यक फ़ील्ड भरें और चयन करें।';

  @override
  String get greetingWithoutName =>
      'आपका किसानी सहायक आपकी मदद के लिए यहाँ है।';

  @override
  String get voiceAssistantTitle => 'वॉइस असिस्टेंट';

  @override
  String get remindersTitle => 'रिमाइंडर';

  @override
  String get infoLibraryTitle => 'लाइब्रेरी';

  @override
  String get schemesTitle => 'योजनाएं';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get assistantNavLabel => 'सहायक';

  @override
  String get remindersNavLabel => 'रिमाइंडर';

  @override
  String get infoNavLabel => 'सूचना';

  @override
  String get schemesNavLabel => 'योजनाएं';

  @override
  String get profileNavLabel => 'प्रोफ़ाइल';

  @override
  String get languageLabel => 'भाषा';

  @override
  String get logoutButton => 'लॉग आउट करें';

  @override
  String get setupScreenTitle => 'मिट्टी एआई में आपका स्वागत है!';

  @override
  String get setupScreenSubtitle => 'आइए आपके कृषि सहायक को तैयार करें।';

  @override
  String get nameLabel => 'आपका नाम';

  @override
  String get nameHint => 'अपना पूरा नाम दर्ज करें';

  @override
  String get nameValidationError => ' कृपया अपना नाम दर्ज करें';

  @override
  String get villageLabel => 'आपका गांव/शहर';

  @override
  String get villageHint => 'अपने गांव या कस्बे का नाम दर्ज करें';

  @override
  String get villageValidationError => ' कृपया अपना गांव/शहर दर्ज करें';

  @override
  String get emailOptionalLabel => 'ईमेल (वैकल्पिक)';

  @override
  String get emailHint => 'आपका ईमेल उपयोगकर्ता नाम';

  @override
  String get emailInvalidError => 'कृपया एक मान्य ईमेल पता दर्ज करें';

  @override
  String get languageHint => 'अपनी भाषा चुनें';

  @override
  String get languageValidationError => 'कृपया एक भाषा चुनें';

  @override
  String get saveAndContinueButton => 'सहेजें और जारी रखें';

  @override
  String get skipButton => 'अभी के लिए छोड़ें';

  @override
  String get voiceAssistantHelpPrompt => 'आज मैं आपकी क्या मदद कर सकता हूँ?';

  @override
  String get tapToSpeakButton => 'बोलने के लिए टैप करें';

  @override
  String get pleaseWaitMessage => 'कृपया प्रतीक्षा करें...';

  @override
  String get tryAgainLater => 'कृपया बाद में पुनः प्रयास करें।';

  @override
  String get noMessagesYetLabel => 'अभी तक कोई संदेश नहीं है।';

  @override
  String get upcomingRemindersTitle => 'आगामी रिमाइंडर';

  @override
  String get timeLabel => 'समय';

  @override
  String get dateLabel => 'तारीख';

  @override
  String get addReminderFAB => 'रिमाइंडर जोड़ें';

  @override
  String get noReminders => 'अभी तक कोई रिमाइंडर सेट नहीं है।';

  @override
  String get saveReminderButton => 'रिमाइंडर सहेजें';

  @override
  String get homeNavLabel => 'होम';

  @override
  String get askYourDoubtsPrompt => 'कृषि संबंधी अपने संदेह पूछें';

  @override
  String get quickAccessTitle => 'त्वरित पहुँच';

  @override
  String get historyTitle => 'इतिहास';

  @override
  String get libraryNavLabel => 'लाइब्रेरी';

  @override
  String get weatherNavLabel => 'मौसम';

  @override
  String get tipOfTheDayTitle => 'आज का सुझाव';

  @override
  String get tipOfTheDay1 =>
      'मिट्टी के स्वास्थ्य में सुधार और कीटों को कम करने के लिए अपनी फसलें बदलें।';

  @override
  String get tipOfTheDay2 =>
      'बीमारियों के शुरुआती लक्षणों के लिए नियमित रूप से अपने पौधों की जाँच करें।';

  @override
  String get tipOfTheDay3 =>
      'पानी बचाने के लिए सुनिश्चित करें कि आपकी सिंचाई प्रणाली कुशल है।';

  @override
  String get voiceInputNotImplemented =>
      'वॉयस इनपुट अभी लागू नहीं किया गया है।';

  @override
  String get agriAssistantTagline =>
      'आपका किसानी सहायक आपकी मदद के लिए यहाँ है।';

  @override
  String get speakCommandToSearch => 'माइक टैप करें और अपना प्रश्न बोलें।';

  @override
  String get profileUserDetailsLabel => 'उपयोगकर्ता विवरण';

  @override
  String get profileNameLabel => 'नाम';

  @override
  String get profileVillageLabel => 'गाँव';

  @override
  String get profileEmailLabel => 'ईमेल';

  @override
  String get profilePhoneLabel => 'फ़ोन';

  @override
  String get profileCropTypeLabel => 'फ़सल का प्रकार';

  @override
  String get languageSettingsLabel => 'भाषा सेटिंग्स';

  @override
  String get languageDropdownLabel => 'भाषा चुनें';

  @override
  String get loginButtonLabel => 'लॉग इन / प्रोफ़ाइल पूर्ण करें';

  @override
  String get remindersAppBarTitle => 'रिमाइंडर';

  @override
  String get noRemindersYet => 'अभी तक कोई रिमाइंडर नहीं।';

  @override
  String get tapPlusToAddReminder => '+ बटन टैप करके नया रिमाइंडर जोड़ें।';

  @override
  String get addReminderTooltip => 'रिमाइंडर जोड़ें';

  @override
  String dueOn(String date) {
    return '$date को देय';
  }

  @override
  String get repeatsDaily => 'रोजाना दोहराता है';

  @override
  String repeatsWeeklyOn(String days) {
    return 'साप्ताहिक रूप से $days को दोहराता है';
  }

  @override
  String get repeatsWeekly => 'साप्ताहिक रूप से दोहराता है';

  @override
  String repeatsMonthlyOnDay(String day) {
    return 'मासिक रूप से $day तारीख को दोहराता है';
  }

  @override
  String get repeatsMonthly => 'मासिक रूप से दोहराता है';

  @override
  String get addReminderDialogTitle => 'नया रिमाइंडर जोड़ें';

  @override
  String get reminderNameHint => 'रिमाइंडर का नाम दर्ज करें';

  @override
  String get fieldRequiredErrorText => 'यह फ़ील्ड आवश्यक है';

  @override
  String get selectDatePrompt => 'एक तारीख चुनें';

  @override
  String get selectTimePrompt => 'एक समय चुनें';

  @override
  String get repeatLabel => 'दोहराएँ';

  @override
  String get repeatNone => 'कोई नहीं';

  @override
  String get selectDaysOfWeekPrompt => 'सप्ताह के दिन चुनें:';

  @override
  String get selectDayOfMonthPrompt => 'महीने का दिन चुनें:';

  @override
  String get addButtonLabel => 'जोड़ें';

  @override
  String get ensureTitleDateAndTime =>
      'कृपया सुनिश्चित करें कि शीर्षक, तारीख और समय निर्धारित हैं।';

  @override
  String get repeatDaily => 'दैनिक';

  @override
  String get repeatWeekly => 'साप्ताहिक';

  @override
  String get repeatMonthly => 'मासिक';

  @override
  String get speakingNowPrompt => 'सुन रहा हूँ... अब बोलें';

  @override
  String get stopLabel => 'रोकें';

  @override
  String get closeLabel => 'बंद करें';

  @override
  String get processingLabel => 'प्रोसेस हो रहा है...';

  @override
  String get schemesScreenTitle => 'सरकारी योजनाएं';

  @override
  String get schemesScreenSelectStateHint => 'राज्य चुनें';

  @override
  String get schemesScreenSelectDistrictHint => 'जिला चुनें';

  @override
  String get schemesScreenFetchingSchemes => 'योजनाएं लाई जा रही हैं...';

  @override
  String get schemesScreenErrorPrefix => 'त्रुटि: ';

  @override
  String get schemesScreenNoSchemesAvailable =>
      'चयनित राज्य/जिले के लिए कोई योजना उपलब्ध नहीं है।';

  @override
  String get schemeDialogViewSourceButton => 'स्रोत देखें';

  @override
  String get schemeDialogCloseButton => 'बंद करें';

  @override
  String get schemeDialogCouldNotLaunchPrefix => 'लॉन्च नहीं किया जा सका ';

  @override
  String get schemesScreenLoginPrompt =>
      'राज्य-विशिष्ट योजनाएं देखने के लिए लॉगिन करें और अपना राज्य चुनें।';

  @override
  String get schemesScreenLoginButton => 'लॉग इन करें';

  @override
  String get schemesScreenUpdatingSchemes =>
      'योजनाएं अपडेट हो रही हैं... (इसमें 10-20 सेकंड लग सकते हैं)। कृपया प्रतीक्षा करें।';

  @override
  String get schemeDialogOpenWebsite => 'अधिक विवरण के लिए वेबसाइट खोलें।';

  @override
  String get schemeDialogStepsLabel => 'चरण:';

  @override
  String get schemeDialogDocumentsLabel => 'दस्तावेज़:';

  @override
  String schemesScreenNoSchemesForState(Object stateName) {
    return '$stateName के लिए कोई योजना नहीं मिली। कृपया रीफ्रेश करें, या बाद में देखें।';
  }

  @override
  String get historyScreenTitle => 'इतिहास';

  @override
  String get clearHistoryDialogTitle => 'इतिहास साफ़ करें?';

  @override
  String get clearHistoryDialogContent => 'सभी सहेजे गए चैट हटाएं?';

  @override
  String get cancelButtonLabel => 'रद्द करें';

  @override
  String get clearButtonLabel => 'साफ़ करें';

  @override
  String get noRecentChats => 'कोई हालिया चैट नहीं';

  @override
  String get refreshLabel => 'रीफ्रेश करें';

  @override
  String get searchHint => 'खोजें...';

  @override
  String get noLibraryItemsMessage =>
      'कोई लाइब्रेरी आइटम नहीं मिला। रीफ्रेश करने के लिए नीचे खींचें या कोई भिन्न खोज आज़माएँ।';

  @override
  String get categorySeeds => 'बीज';

  @override
  String get categoryFertilizers => 'उर्वरक';

  @override
  String get categoryPestsAndDiseases => 'कीट और रोग';

  @override
  String get microphonePermissionDeniedPreviously =>
      'माइक्रोफ़ोन अनुमति अस्वीकृत कर दी गई थी। कृपया इस सुविधा का उपयोग करने के लिए इसे प्रदान करें।';

  @override
  String get grantPermissionAction => 'अनुमति दें';

  @override
  String get microphonePermissionPermanentlyDenied =>
      'माइक्रोफ़ोन अनुमति स्थायी रूप से अस्वीकृत है। कृपया ऐप सेटिंग में इसे सक्षम करें।';

  @override
  String get openSettingsAction => 'सेटिंग्स खोलें';

  @override
  String get microphonePermissionNeeded =>
      'वॉइस इनपुट का उपयोग करने के लिए माइक्रोफ़ोन अनुमति आवश्यक है।';

  @override
  String get microphonePermissionRestricted =>
      'इस उपकरण पर माइक्रोफ़ोन पहुंच प्रतिबंधित है।';

  @override
  String get speechNotAvailable => 'वाक् पहचान उपलब्ध नहीं है।';

  @override
  String get calendarPermissionNeededMessage =>
      'रिमाइंडर सहेजने के लिए, ऐप को आपके कैलेंडर तक पहुंचने की अनुमति चाहिए।';

  @override
  String get calendarPermissionDeniedMessage =>
      'कैलेंडर अनुमति अस्वीकृत कर दी गई थी। कृपया रिमाइंडर बनाने के लिए पहुंच प्रदान करें।';

  @override
  String get calendarPermissionPermanentlyDeniedMessage =>
      'कैलेंडर अनुमति स्थायी रूप से अस्वीकृत है। यदि आप रिमाइंडर बनाना चाहते हैं तो कृपया इसे सक्षम करने के लिए सेटिंग में जाएं।';

  @override
  String get calendarPermissionRestrictedMessage =>
      'इस उपकरण पर कैलेंडर पहुंच प्रतिबंधित है। रिमाइंडर सहेजे नहीं जा सकते।';

  @override
  String get okAction => 'ठीक है';

  @override
  String get phoneLabel => 'फ़ोन नंबर';

  @override
  String get phoneHint => '12345 67890';

  @override
  String get phoneValidationError => 'कृपया अपना फ़ोन नंबर दर्ज करें';

  @override
  String get phoneInvalidError => 'फ़ोन नंबर 10 अंकों का होना चाहिए';

  @override
  String get cropTypeLabel => 'फ़सल का प्रकार';

  @override
  String get cropTypeHint => 'जैसे, गेहूँ, चावल';

  @override
  String get cropTypeValidationError =>
      'फ़सल का प्रकार कम से कम 3 अक्षर लंबा होना चाहिए';

  @override
  String get privacyPolicyLabel => 'गोपनीयता नीति';

  @override
  String get privacyPolicyError => 'गोपनीयता नीति नहीं खोली जा सकी।';

  @override
  String get privacyPolicyTitle => 'गोपनीयता नीति';

  @override
  String get acceptAndContinueButton => 'स्वीकार करें और जारी रखें';

  @override
  String get supportText => 'समर्थन:';

  @override
  String get supportMessage =>
      'किसी भी प्रश्न/समर्थन के लिए, इस उपरोक्त लिंक का अनुसरण करें।';

  @override
  String get emailError => 'ईमेल ऐप नहीं खोला जा सका।';

  @override
  String get urlLaunchError => 'समर्थन पृष्ठ नहीं खोला जा सका।';

  @override
  String get mittiAiSupportLink => 'मिट्टी एआई सहायता';
}
