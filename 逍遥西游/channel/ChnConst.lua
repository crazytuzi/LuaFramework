Update_Version_Url = "ver.txt"
Update_Version_Url_UC = "ver_uc.txt"
Update_Version_Url_UC_Test = "ver_uc_t.txt"
Update_Version_Url_LJ = "ver_lj.txt"
Update_Version_Url_LJ_Test = "ver_lj_t.txt"
Update_Version_Url_MomoAnd = "ver_momoand.txt"
Update_Version_Url_MomoAnd_Test = "ver_momoand_t.txt"
Update_Version_Url_Test1 = "ver_test.txt"
Update_Version_Url_Test2 = "ver_test2.txt"
Update_Version_Url_MOMO = "version_momo_ios.txt"
Update_Version_Url_MOMO_Test1 = "version_momo_ios_test.txt"
Update_Version_Url_YoukuAnd = "ver_youkuand.txt"
Update_Version_Url_YoukuAnd_Test = "ver_youkuand_t.txt"
Update_Version_Url_37DNTG = "ver_and37dntg.txt"
Update_Version_Url_37DNTG_Test = "ver_and37dntg_t.txt"
Update_Version_Url_37MMXY = "ver_and37mmxy.txt"
Update_Version_Url_37MMXY_Test = "ver_and37mmxy_t.txt"
if device.platform ~= "android" then
  function callStaticMethodJava(...)
    return true
  end
end
ChannelCallbackStatus = {
  "kInitSuccess",
  "kInitFail",
  "kLoginSuccess",
  "kLoginNetworkError",
  "kLoginNoNeed",
  "kLoginFail",
  "kLoginCancel",
  "kGuestRegistered",
  "kTokenInvild",
  "kLogoutSuccess",
  "kLogoutFail",
  "kPlatformEnter",
  "kPlatformBack",
  "kPausePage",
  "kExitPage",
  "kAntiAddictionQuery",
  "kRealNameRegister",
  "kAccountSwitchSuccess",
  "kAccountSwitchFail",
  "kOpenShop",
  "kAccountSwitchSuccess",
  "kAccountSwitchFail"
}
for idx, v in ipairs(ChannelCallbackStatus) do
  ChannelCallbackStatus[v] = idx
end
dump(ChannelCallbackStatus, "ChannelCallbackStatus")
ChannelToolBarPlace = {
  kToolBarTopLeft = 1,
  kToolBarTopRight = 2,
  kToolBarMidLeft = 3,
  kToolBarMidRight = 4,
  kToolBarBottomLeft = 5,
  kToolBarBottomRight = 6
}
local ChannelToolBarPlaceToPercentPos = {
  [ChannelToolBarPlace.kToolBarTopLeft] = {0, 0},
  [ChannelToolBarPlace.kToolBarTopRight] = {100, 0},
  [ChannelToolBarPlace.kToolBarMidLeft] = {0, 50},
  [ChannelToolBarPlace.kToolBarMidRight] = {100, 50},
  [ChannelToolBarPlace.kToolBarBottomLeft] = {0, 100},
  [ChannelToolBarPlace.kToolBarBottomRight] = {100, 100}
}
function getChannelTBPercentPosByPlace(place)
  local d = ChannelToolBarPlaceToPercentPos[place]
  if d then
    return d[1], d[2]
  end
  return 0, 0
end
ChannelPayResult = {
  kPaySucceed = 1001,
  kPayFailed = 1002,
  kPayViewClosed = 1003,
  kPayViewCommit = 1004
}
ChannelRenameType = {kRename_MoMoXiYou = 1, kRename_DaShengTianGong = 2}
ChannelRenameFileExt = {
  [ChannelRenameType.kRename_MoMoXiYou] = "_37",
  [ChannelRenameType.kRename_DaShengTianGong] = "_tg"
}
local fileExt_loadingbarframe = "xiyou/loading/loadingbarframe.png"
local filePath_logo = "views/pic/pic_logo.png"
local isRename = false
function ResetChannelRenameParam()
  local fileExt = ChannelRenameFileExt[channel.needRename]
  if channel.needRename == nil or fileExt == nil then
    fileExt_loadingbarframe = "xiyou/loading/loadingbarframe.png"
    filePath_logo = "views/pic/pic_logo.png"
    isRename = false
  else
    fileExt_loadingbarframe = string.format("xiyou/loading/loadingbarframe%s.png", fileExt)
    filePath_logo = string.format("views/pic/pic_logo%s.png", fileExt)
    isRename = true
  end
end
function getLoadingbarframeSpriteFilePath()
  return fileExt_loadingbarframe
end
function resetLogoSpriteWithSpriteNode(spriteNode)
  if isRename then
    spriteNode:loadTexture(CCFileUtils:sharedFileUtils():fullPathForFilename(filePath_logo), UI_TEX_TYPE_LOCAL)
  end
end
