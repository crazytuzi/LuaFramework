Plugin_type = {
  kPluginAds = 16,
  kPluginAnalytics = 1,
  kPluginIAP = 8,
  kPluginShare = 4,
  kPluginUser = 32,
  kPluginSocial = 2,
  kPluginPush = 64
}
AdsResultCode = {
  kAdsReceived = 0,
  kAdsShown = 1,
  kAdsDismissed = 2,
  kPointsSpendSucceed = 3,
  kPointsSpendFailed = 4,
  kNetworkError = 5,
  kUnknownError = 6,
  kOfferWallOnPointsChanged = 7,
  kAdsExtension = 40000
}
AdsPos = {
  kPosCenter = 0,
  kPosTop = 1,
  kPosTopLeft = 2,
  kPosTopRight = 3,
  kPosBottom = 4,
  kPosBottomLeft = 5,
  kPosBottomRight = 6
}
AdsType = {
  AD_TYPE_BANNER = 0,
  AD_TYPE_FULLSCREEN = 1,
  AD_TYPE_MOREAPP = 2,
  AD_TYPE_OFFERWALL = 3
}
PayResultCode = {
  kPaySuccess = 0,
  kPayFail = 1,
  kPayCancel = 2,
  kPayNetworkError = 3,
  kPayProductionInforIncomplete = 4,
  kPayInitSuccess = 5,
  kPayInitFail = 6,
  kPayNowPaying = 7,
  kPayRechargeSuccess = 8,
  kPayExtension = 30000
}
PushActionResultCode = {kPushReceiveMessage = 0, kPushExtensionCode = 60000}
ShareResultCode = {
  kShareSuccess = 0,
  kShareFail = 1,
  kShareCancel = 2,
  kShareNetworkError = 3,
  kShareExtension = 10000
}
SocialRetCode = {
  kScoreSubmitSucceed = 1,
  kScoreSubmitfail = 2,
  kAchUnlockSucceed = 3,
  kAchUnlockFail = 4,
  kSocialSignInSucceed = 5,
  kSocialSignInFail = 6,
  kSocialSignOutSucceed = 7,
  kSocialSignOutFail = 8,
  kSocialGetGameFriends = 9,
  kSocialExtensionCode = 20000
}
UserActionResultCode = {
  kInitSuccess = 0,
  kInitFail = 1,
  kLoginSuccess = 2,
  kLoginNetworkError = 3,
  kLoginNoNeed = 4,
  kLoginFail = 5,
  kLoginCancel = 6,
  kLogoutSuccess = 7,
  kLogoutFail = 8,
  kPlatformEnter = 9,
  kPlatformBack = 10,
  kPausePage = 11,
  kExitPage = 12,
  kAntiAddictionQuery = 13,
  kRealNameRegister = 14,
  kAccountSwitchSuccess = 15,
  kAccountSwitchFail = 16,
  kOpenShop = 17,
  kUserExtension = 50000
}
ToolBarPlace = {
  kToolBarTopLeft = 1,
  kToolBarTopRight = 2,
  kToolBarMidLeft = 3,
  kToolBarMidRight = 4,
  kToolBarBottomLeft = 5,
  kToolBarBottomRight = 6
}
AccountType = {
  ANONYMOUS = 0,
  REGISTED = 1,
  SINA_WEIBO = 2,
  TENCENT_WEIBO = 3,
  QQ = 4,
  ND91 = 5
}
AccountOperate = {
  LOGIN = 0,
  LOGOUT = 1,
  REGISTER = 2
}
AccountGender = {
  MALE = 0,
  FEMALE = 1,
  UNKNOWN = 2
}
TaskType = {
  GUIDE_LINE = 0,
  MAIN_LINE = 1,
  BRANCH_LINE = 2,
  DAILY = 3,
  ACTIVITY = 4,
  OTHER = 5
}
