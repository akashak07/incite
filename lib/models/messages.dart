class Messages {
  String? currentDate;
  String? wrongEmailAndPassword;
  String? emailNotExist;
  String? profileUpdated;
  String? noLanguageFound;
  String? login;
  String? dashboard;
  String? myProfile;
  String? myStories;
  String? fontSize;
  String? signOut;
  String? aboutUs;
  String? joinUs;
  String? advertise;
  String? contactUs;
  String? policyAndTerms;
  String? guest;
  String? darkMode;
  String? notifications;
  String? logout;
  String? areYouSureYouWantToLogout;
  String? no;
  String? yes;
  String? submit;
  String? resetPassword;
  String? forgotPassword;
  String? signIn;
  String? signUp;
  String? adPage;
  String? showBanner;
  String? showBannerWithOffset;
  String? removeBanner;
  String? information;
  String? facebookLoginNotAvailable;
  String? ok;
  String? appname;
  String? skip;
  String? updatingFeed;
  String? categoryPost;
  String? noResultsFoundMatchingWithYourKeyword;
  String? eNews;
  String? thatsAllFolks;
  String? stayBlessedAndConnected;
  String? welcome;
  String? welcomeGuest;
  String? featuredStories;
  String? filterByTopics;
  String? myFeed;
  String? latestPost;
  String? liveNews;
  String? image;
  String? toStopPlayingTapAgain;
  String? swipeTo;
  String? readFull;
  String? doYouAgree;
  String? thankYouForParticipating;
  String? mySavedStories;
  String? noSavedPostFound;
  String? searchStories;
  String? view;
  String? eDIT;
  String? name;
  String? email;
  String? mobile;
  String? password;
  String? deleteAccount;
  String? confirmDeleteAccount;
  String? updateProfile;
  String? enterAValidEmail;
  String? reEnterPassword;
  String? newEnterPassword;
  String? tap;
  String? enterAValidPassword;
  String? otp;
  String? enterAValidOtp;
  String? passwordShouldBeMoreThanThereeCharacter;
  String? newUser;
  String? enterAValidPhoneNumber;
  String? alreadyHaveAnAccount;
  String? userName;
  String? enterAValidUserName;
  String? phoneNumber;
  String? alredayHaveAccout;
  String? noNewsAvilable;
  String? openingNewsInWeb;
  String? invalidLink;
  String? noResultFound;
  String? invalidOtpEntered;
  String? passwordAndConfirmPasswordShouldBeSame;
  String? profileUpdatedSuccessfully;
  String? shareMessage;
  String? blogFontSize;
  String? rateUs;
  String? settings;
  String? enableDisablePushNotification;
  String? enableDisableDarkMode;
  String? selectPersonalization;
  String? selectLanguage;
  String? chooseYourAppLanguage;
  String? setYourBlogFontSize;
  String? saveYourInterestsForBetterContentExperience;
  String? saveInterests;
  String? settingsPage;
  String? edit;
  String? noInternetConnection;
  String? chooseYourLanguage;
  String? chooseYourLanguage2;

  Messages(
      {this.currentDate,
      this.wrongEmailAndPassword,
      this.emailNotExist,
      this.profileUpdated,
      this.noLanguageFound,
      this.login,
      this.dashboard,
      this.myProfile,
      this.myStories,
      this.fontSize,
      this.signOut,
      this.aboutUs,
      this.joinUs,
      this.advertise,
      this.contactUs,
      this.policyAndTerms,
      this.guest,
      this.darkMode,
      this.notifications,
      this.logout,
      this.areYouSureYouWantToLogout,
      this.no,
      this.yes,
      this.submit,
      this.resetPassword,
      this.forgotPassword,
      this.signIn,
      this.signUp,
      this.adPage,
      this.showBanner,
      this.showBannerWithOffset,
      this.removeBanner,
      this.information,
      this.facebookLoginNotAvailable,
      this.ok,
      this.appname,
      this.skip,
      this.updatingFeed,
      this.categoryPost,
      this.noResultsFoundMatchingWithYourKeyword,
      this.eNews,
      this.thatsAllFolks,
      this.stayBlessedAndConnected,
      this.welcome,
      this.welcomeGuest,
      this.featuredStories,
      this.filterByTopics,
      this.myFeed,
      this.latestPost,
      this.liveNews,
      this.image,
      this.toStopPlayingTapAgain,
      this.swipeTo,
      this.readFull,
      this.doYouAgree,
      this.thankYouForParticipating,
      this.mySavedStories,
      this.noSavedPostFound,
      this.searchStories,
      this.view,
      this.eDIT,
      this.name,
      this.email,
      this.mobile,
      this.password,
      this.deleteAccount,
      this.confirmDeleteAccount,
      this.updateProfile,
      this.enterAValidEmail,
      this.reEnterPassword,
      this.newEnterPassword,
      this.tap,
      this.enterAValidPassword,
      this.otp,
      this.enterAValidOtp,
      this.passwordShouldBeMoreThanThereeCharacter,
      this.newUser,
      this.enterAValidPhoneNumber,
      this.alreadyHaveAnAccount,
      this.userName,
      this.enterAValidUserName,
      this.phoneNumber,
      this.alredayHaveAccout,
      this.noNewsAvilable,
      this.openingNewsInWeb,
      this.invalidLink,
      this.noResultFound,
      this.invalidOtpEntered,
      this.shareMessage,
      this.passwordAndConfirmPasswordShouldBeSame,
      this.profileUpdatedSuccessfully,
      this.settings,
      this.selectPersonalization,
      this.selectLanguage,
      this.saveInterests,
      this.settingsPage,
      this.edit,
      this.chooseYourAppLanguage,
      this.enableDisableDarkMode,
      this.enableDisablePushNotification,
      this.rateUs,
      this.saveYourInterestsForBetterContentExperience,
      this.setYourBlogFontSize,
      this.blogFontSize,
      this.chooseYourLanguage,
      this.chooseYourLanguage2,
      this.noInternetConnection,
      });

  Messages.fromJson(Map<String, dynamic> json) {
    currentDate = json['current_date'];
    wrongEmailAndPassword = json['wrong_email_and_password'];
    emailNotExist = json['email_not_exist'];
    profileUpdated = json['profile_updated'];
    noLanguageFound = json['no_language_found'];
    login = json['login'];
    dashboard = json['dashboard'];
    myProfile = json['my_profile'];
    myStories = json['my_stories'];
    fontSize = json['font_size'];
    signOut = json['sign_out'];
    aboutUs = json['about_us'];
    joinUs = json['join_us'];
    advertise = json['advertise'];
    contactUs = json['contact_us'];
    policyAndTerms = json['policy_and_terms'];
    guest = json['guest'];
    darkMode = json['dark_mode'];
    notifications = json['notifications'];
    logout = json['logout'];
    areYouSureYouWantToLogout = json['are_you_sure_you_want_to_logout'];
    no = json['no'];
    yes = json['yes'];
    submit = json['submit'];
    resetPassword = json['reset_password'];
    forgotPassword = json['forgot_password'];
    signIn = json['sign_in'];
    signUp = json['sign_up'];
    adPage = json['ad_page'];
    showBanner = json['show_banner'];
    showBannerWithOffset = json['show_banner_with_offset'];
    removeBanner = json['remove_banner'];
    information = json['information'];
    facebookLoginNotAvailable = json['facebook_login_not_available'];
    ok = json['ok'];
    appname = json['appname'];
    skip = json['skip'];
    updatingFeed = json['updating_feed'];
    categoryPost = json['category_post'];
    noResultsFoundMatchingWithYourKeyword =
        json['no_results_found_matching_with_your_keyword'];
    eNews = json['e_news'];
    thatsAllFolks = json['thats_all_folks'];
    stayBlessedAndConnected = json['stay_blessed_and_Connected'];
    welcome = json['welcome'];
    welcomeGuest = json['welcome_guest'];
    featuredStories = json['featured_stories'];
    filterByTopics = json['filter_by_topics'];
    myFeed = json['my_feed'];
    latestPost = json['latest_post'];
    liveNews = json['live_news'];
    image = json['image'];
    toStopPlayingTapAgain = json['to_stop_playing_tap_again'];
    swipeTo = json['swipe_to'];
    readFull = json['read_full'];
    doYouAgree = json['do_you_agree'];
    thankYouForParticipating = json['thank_you_for_participating'];
    mySavedStories = json['my_saved_stories'];
    noSavedPostFound = json['no_saved_post_found'];
    searchStories = json['search_stories'];
    view = json['view'];
    eDIT = json['eDIT'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    password = json['password'];
    deleteAccount = json['delete Account'];
    confirmDeleteAccount = json['confirm_delete_account'];
    updateProfile = json['update_profile'];
    enterAValidEmail = json['enter_a_valid_email'];
    reEnterPassword = json['re_enter_password'];
    newEnterPassword = json['new_enter_password'];
    tap = json['tap_me'];
    enterAValidPassword = json['enter_a_valid_password'];
    otp = json['otp'];
    enterAValidOtp = json['enter_a_valid_otp'];
    passwordShouldBeMoreThanThereeCharacter =
        json['password_should_be_more_than_theree_character'];
    newUser = json['new_user'];
    enterAValidPhoneNumber = json['enter_a_valid_phone_number'];
    alreadyHaveAnAccount = json['already_have_an_account'];
    userName = json['user_name'];
    enterAValidUserName = json['enter_a_valid_user_name'];
    phoneNumber = json['phone_number'];
    alredayHaveAccout = json['alreday_have_accout'];
    noNewsAvilable = json['no_news_avilable'];
    openingNewsInWeb = json['opening_news_in_web'];
    invalidLink = json['invalid_link'];
    noResultFound = json['no_result_found'];
    invalidOtpEntered = json['invalid_otp_entered'];
    passwordAndConfirmPasswordShouldBeSame =
        json['password_and_confirm_password_should_be_same'];
    profileUpdatedSuccessfully = json['profile_updated_successfully'];
    shareMessage = json['share_message'];
    rateUs = json['rate_us'];
    settings = json['settings'];
    enableDisablePushNotification = json['enable_disable_push_notification'];
    enableDisableDarkMode = json['enable_disable_dark_mode'];
    selectPersonalization = json['select_personalization'];
    selectLanguage = json['select_language'];
    chooseYourAppLanguage = json['choose_your_app_language'];
    setYourBlogFontSize = json['set_your_blog_font_size'];
    saveYourInterestsForBetterContentExperience = json['save_your_interests_for_better_content_experience'];
    saveInterests = json['save_interests'];
    settingsPage = json['settings_page'];
    edit = json['edit'];
    blogFontSize = json['blog_font_size'];
    noInternetConnection = json['no_internet_connection'];
    chooseYourLanguage = json['choose_your_language'];
    chooseYourLanguage2 = json['choose_your_language2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_date'] = this.currentDate;
    data['wrong_email_and_password'] = this.wrongEmailAndPassword;
    data['email_not_exist'] = this.emailNotExist;
    data['profile_updated'] = this.profileUpdated;
    data['no_language_found'] = this.noLanguageFound;
    data['login'] = this.login;
    data['dashboard'] = this.dashboard;
    data['my_profile'] = this.myProfile;
    data['my_stories'] = this.myStories;
    data['font_size'] = this.fontSize;
    data['sign_out'] = this.signOut;
    data['about_us'] = this.aboutUs;
    data['join_us'] = this.joinUs;
    data['advertise'] = this.advertise;
    data['contact_us'] = this.contactUs;
    data['policy_and_terms'] = this.policyAndTerms;
    data['guest'] = this.guest;
    data['dark_mode'] = this.darkMode;
    data['notifications'] = this.notifications;
    data['logout'] = this.logout;
    data['are_you_sure_you_want_to_logout'] = this.areYouSureYouWantToLogout;
    data['no'] = this.no;
    data['yes'] = this.yes;
    data['submit'] = this.submit;
    data['reset_password'] = this.resetPassword;
    data['forgot_password'] = this.forgotPassword;
    data['sign_in'] = this.signIn;
    data['sign_up'] = this.signUp;
    data['ad_page'] = this.adPage;
    data['show_banner'] = this.showBanner;
    data['show_banner_with_offset'] = this.showBannerWithOffset;
    data['remove_banner'] = this.removeBanner;
    data['information'] = this.information;
    data['facebook_login_not_available'] = this.facebookLoginNotAvailable;
    data['ok'] = this.ok;
    data['appname'] = this.appname;
    data['skip'] = this.skip;
    data['updating_feed'] = this.updatingFeed;
    data['category_post'] = this.categoryPost;
    data['no_results_found_matching_with_your_keyword'] =
        this.noResultsFoundMatchingWithYourKeyword;
    data['e_news'] = this.eNews;
    data['thats_all_folks'] = this.thatsAllFolks;
    data['stay_blessed_and_Connected'] = this.stayBlessedAndConnected;
    data['welcome'] = this.welcome;
    data['welcome_guest'] = this.welcomeGuest;
    data['featured_stories'] = this.featuredStories;
    data['filter_by_topics'] = this.filterByTopics;
    data['my_feed'] = this.myFeed;
    data['latest_post'] = this.latestPost;
    data['live_news'] = this.liveNews;
    data['image'] = this.image;
    data['to_stop_playing_tap_again'] = this.toStopPlayingTapAgain;
    data['swipe_to'] = this.swipeTo;
    data['read_full'] = this.readFull;
    data['do_you_agree'] = this.doYouAgree;
    data['thank_you_for_participating'] = this.thankYouForParticipating;
    data['my_saved_stories'] = this.mySavedStories;
    data['no_saved_post_found'] = this.noSavedPostFound;
    data['search_stories'] = this.searchStories;
    data['view'] = this.view;
    data['eDIT'] = this.eDIT;
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['password'] = this.password;
    data['delete Account'] = this.deleteAccount;
    data['confirm_delete_account'] = this.confirmDeleteAccount;
    data['update_profile'] = this.updateProfile;
    data['enter_a_valid_email'] = this.enterAValidEmail;
    data['re_enter_password'] = this.reEnterPassword;
    data['new_enter_password'] = this.newEnterPassword;
    data['tap_me'] = this.tap;
    data['enter_a_valid_password'] = this.enterAValidPassword;
    data['otp'] = this.otp;
    data['enter_a_valid_otp'] = this.enterAValidOtp;
    data['password_should_be_more_than_theree_character'] =
        this.passwordShouldBeMoreThanThereeCharacter;
    data['new_user'] = this.newUser;
    data['enter_a_valid_phone_number'] = this.enterAValidPhoneNumber;
    data['already_have_an_account'] = this.alreadyHaveAnAccount;
    data['user_name'] = this.userName;
    data['enter_a_valid_user_name'] = this.enterAValidUserName;
    data['phone_number'] = this.phoneNumber;
    data['alreday_have_accout'] = this.alredayHaveAccout;
    data['no_news_avilable'] = this.noNewsAvilable;
    data['opening_news_in_web'] = this.openingNewsInWeb;
    data['invalid_link'] = this.invalidLink;
    data['no_result_found'] = this.noResultFound;
    data['invalid_otp_entered'] = this.invalidOtpEntered;
    data['password_and_confirm_password_should_be_same'] =
        this.passwordAndConfirmPasswordShouldBeSame;
    data['profile_updated_successfully'] = this.profileUpdatedSuccessfully;
    data['share_message'] = shareMessage;
    data['rate_us'] = rateUs;
    data['settings'] = settings;
    data['enable_disable_push_notification'] = enableDisablePushNotification;
    data['enable_disable_dark_mode'] = enableDisableDarkMode;
    data['select_personalization'] = selectPersonalization;
    data['select_language'] = selectLanguage;
    data['choose_your_app_language'] = chooseYourAppLanguage;
    data['set_your_blog_font_size'] = setYourBlogFontSize;
    data['save_your_interests_for_better_content_experience'] = saveYourInterestsForBetterContentExperience;
    data['save_interests'] = saveInterests;
    data['settings_page'] = settingsPage;
    data['edit'] = edit;
    data['blog_font_size'] = blogFontSize;
    data['no_internet_connection'] = noInternetConnection;
    data['choose_your_language'] = chooseYourLanguage;
    data['choose_your_language2'] = chooseYourLanguage2;
    return data;
  }
}
