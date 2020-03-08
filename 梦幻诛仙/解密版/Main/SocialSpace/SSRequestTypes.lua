local Lplus = require("Lplus")
local ECDebugOption = require("Main.ECDebugOption")
local ECSocialSpaceMan = Lplus.ForwardDeclare("ECSocialSpaceMan")
local ECGame = Lplus.ForwardDeclare("ECGame")
local SSRequestBase = require("Main.SocialSpace.SSRequestBase")
local SSRequestErrorCode = require("Main.SocialSpace.SSRequestErrorCode")
local SSRGetSpaceData = Lplus.Extend(SSRequestBase, "SSRGetSpaceData")
do
  local def = SSRGetSpaceData.define
  def.final("=>", SSRGetSpaceData).new = function()
    local obj = SSRGetSpaceData()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getspaceinfo"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      ECSocialSpaceMan.Instance():onGetSpaceData(JsonData)
    end
  end
  def.override("number", "=>", "boolean").onDealSpecialRetcode = function(self, retcode)
    return true
  end
  def.override("number", "string", "=>", "boolean").onDealConnectError = function(self, errorCode, errorMsg)
    return true
  end
  SSRGetSpaceData.Commit()
end
local SSRGetPlayerStatus = Lplus.Extend(SSRequestBase, "SSRGetPlayerStatus")
do
  local def = SSRGetPlayerStatus.define
  def.final("=>", SSRGetPlayerStatus).new = function()
    local obj = SSRGetPlayerStatus()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "gettargetrolemomentlist"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      ECSocialSpaceMan.Instance():onGetMomentList(JsonData.momentList, JsonData.roleId)
    end
  end
  SSRGetPlayerStatus.Commit()
end
local SSRGetFriendNewStatus = Lplus.Extend(SSRequestBase, "SSRGetFriendNewStatus")
do
  local def = SSRGetFriendNewStatus.define
  def.final("=>", SSRGetFriendNewStatus).new = function()
    local obj = SSRGetFriendNewStatus()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getallmomentlist"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      ECSocialSpaceMan.Instance():onGetMomentList(JsonData.momentList, JsonData.roleId)
    end
  end
  SSRGetFriendNewStatus.Commit()
end
local SSRGetHotStatus = Lplus.Extend(SSRequestBase, "SSRGetHotStatus")
do
  local def = SSRGetHotStatus.define
  def.final("=>", SSRGetHotStatus).new = function()
    local obj = SSRGetHotStatus()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "gethotmomentlist"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      ECSocialSpaceMan.Instance():onGetHotMomentList(JsonData.momentList)
    end
  end
  SSRGetHotStatus.Commit()
end
local SSRUpdateHpSignature = Lplus.Extend(SSRequestBase, "SSRUpdateHpSignature")
do
  local def = SSRUpdateHpSignature.define
  def.final("=>", SSRUpdateHpSignature).new = function()
    local obj = SSRUpdateHpSignature()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "updaterolesign"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    local retcode = tonumber(JsonData.retcode)
    if retcode == 0 then
      FlashTipMan.FlashTip(StringTable.Get(28210))
    else
      FlashTipMan.FlashTip(StringTable.Get(28211):format(retcode))
    end
  end
  SSRUpdateHpSignature.Commit()
end
local SSRUploadPortraitPhoto = Lplus.Extend(SSRequestBase, "SSRUploadPortraitPhoto")
do
  local def = SSRUploadPortraitPhoto.define
  def.final("=>", SSRUploadPortraitPhoto).new = function()
    local obj = SSRUploadPortraitPhoto()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "uploadportrait"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRUploadPortraitPhoto.Commit()
end
local SSRUpdateSpaceSetting = Lplus.Extend(SSRequestBase, "SSRUpdateSpaceSetting")
do
  local def = SSRUpdateSpaceSetting.define
  def.final("=>", SSRUpdateSpaceSetting).new = function()
    local obj = SSRUpdateSpaceSetting()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "updatespacesetting"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRUpdateSpaceSetting.Commit()
end
local SSRPublishNewStatus = Lplus.Extend(SSRequestBase, "SSRPublishNewStatus")
do
  local def = SSRPublishNewStatus.define
  def.final("=>", SSRPublishNewStatus).new = function()
    local obj = SSRPublishNewStatus()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "pubmoment"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      FlashTipMan.FlashTip(StringTable.Get(28214))
    end
  end
  SSRPublishNewStatus.Commit()
end
local SSRDeleteStatus = Lplus.Extend(SSRequestBase, "SSRDeleteStatus")
do
  local def = SSRDeleteStatus.define
  def.final("=>", SSRDeleteStatus).new = function()
    local obj = SSRDeleteStatus()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "delmoment"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      FlashTipMan.FlashTip(StringTable.Get(28215))
    end
  end
  SSRDeleteStatus.Commit()
end
local SSRAddFavorToStatus = Lplus.Extend(SSRequestBase, "SSRAddFavorToStatus")
do
  local def = SSRAddFavorToStatus.define
  def.final("=>", SSRAddFavorToStatus).new = function()
    local obj = SSRAddFavorToStatus()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "votemoment"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      FlashTipMan.FlashTip(StringTable.Get(28242))
    end
  end
  SSRAddFavorToStatus.Commit()
end
local SSRCancelFavorToStatus = Lplus.Extend(SSRequestBase, "SSRCancelFavorToStatus")
do
  local def = SSRCancelFavorToStatus.define
  def.final("=>", SSRCancelFavorToStatus).new = function()
    local obj = SSRCancelFavorToStatus()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "cancelvotemoment"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      FlashTipMan.FlashTip(StringTable.Get(28243))
    end
  end
  SSRCancelFavorToStatus.Commit()
end
local SSRReplyStatus = Lplus.Extend(SSRequestBase, "SSRReplyStatus")
do
  local def = SSRReplyStatus.define
  def.final("=>", SSRReplyStatus).new = function()
    local obj = SSRReplyStatus()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "replymoment"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  def.override("number", "=>", "boolean").onDealSpecialRetcode = function(self, retcode)
    if retcode == SSRequestErrorCode.REPLY_FORBID then
      Toast(textRes.SocialSpace[43])
      return true
    elseif retcode == SSRequestErrorCode.FRIENDSHIP_NOT_EXIST or retcode == SSRequestErrorCode.FRIENDSHIP_ALREADY_DELETE then
      Toast(textRes.SocialSpace[44])
      return true
    end
    return false
  end
  SSRReplyStatus.Commit()
end
local SSRDeleteReplyMsg = Lplus.Extend(SSRequestBase, "SSRDeleteReplyMsg")
do
  local def = SSRDeleteReplyMsg.define
  def.final("=>", SSRDeleteReplyMsg).new = function()
    local obj = SSRDeleteReplyMsg()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "delmomentreply"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      FlashTipMan.FlashTip(StringTable.Get(28216))
    end
  end
  SSRDeleteReplyMsg.Commit()
end
local SSRGetPlayerLeaveMsg = Lplus.Extend(SSRequestBase, "SSRGetPlayerLeaveMsg")
do
  local def = SSRGetPlayerLeaveMsg.define
  def.final("=>", SSRGetPlayerLeaveMsg).new = function()
    local obj = SSRGetPlayerLeaveMsg()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getmessages"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      ECSocialSpaceMan.Instance():onGetLeaveMsgList(JsonData.messageList)
    end
  end
  SSRGetPlayerLeaveMsg.Commit()
end
local SSRDoLeaveMsg = Lplus.Extend(SSRequestBase, "SSRDoLeaveMsg")
do
  local def = SSRDoLeaveMsg.define
  def.final("=>", SSRDoLeaveMsg).new = function()
    local obj = SSRDoLeaveMsg()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "leavemessage"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  def.override("number", "=>", "boolean").onDealSpecialRetcode = function(self, retcode)
    if retcode == SSRequestErrorCode.REPLY_FORBID then
      Toast(textRes.SocialSpace[41])
      return true
    elseif retcode == SSRequestErrorCode.FRIENDSHIP_NOT_EXIST or retcode == SSRequestErrorCode.FRIENDSHIP_ALREADY_DELETE then
      Toast(textRes.SocialSpace[42])
      return true
    end
    return false
  end
  SSRDoLeaveMsg.Commit()
end
local SSRDeleteLeaveMsg = Lplus.Extend(SSRequestBase, "SSRDeleteLeaveMsg")
do
  local def = SSRDeleteLeaveMsg.define
  def.final("=>", SSRDeleteLeaveMsg).new = function()
    local obj = SSRDeleteLeaveMsg()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "delmessage"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRDeleteLeaveMsg.Commit()
end
local SSRGetGiftRecords = Lplus.Extend(SSRequestBase, "SSRGetGiftRecords")
do
  local def = SSRGetGiftRecords.define
  def.final("=>", SSRGetGiftRecords).new = function()
    local obj = SSRGetGiftRecords()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getgiftrecords"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      ECSocialSpaceMan.Instance():onGetGiftHistory(JsonData.giftRecords)
    end
  end
  SSRGetGiftRecords.Commit()
end
local SSRPutGiftRecords = Lplus.Extend(SSRequestBase, "SSRPutGiftRecords")
do
  local def = SSRPutGiftRecords.define
  def.final("=>", SSRPutGiftRecords).new = function()
    local obj = SSRPutGiftRecords()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getleavegiftrecords"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRPutGiftRecords.Commit()
end
local SSRSpacePopularRecords = Lplus.Extend(SSRequestBase, "SSRSpacePopularRecords")
do
  local def = SSRSpacePopularRecords.define
  def.final("=>", SSRSpacePopularRecords).new = function()
    local obj = SSRSpacePopularRecords()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getsteprecords"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      ECSocialSpaceMan.Instance():onGetGuestHistory(JsonData.stepRecords)
    end
  end
  SSRSpacePopularRecords.Commit()
end
local SSRGetHpNewMsg = Lplus.Extend(SSRequestBase, "SSRGetHpNewMsg")
do
  local def = SSRGetHpNewMsg.define
  def.final("=>", SSRGetHpNewMsg).new = function()
    local obj = SSRGetHpNewMsg()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getnews"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      ECSocialSpaceMan.Instance():onGetNewMsgList(JsonData.news)
    end
  end
  SSRGetHpNewMsg.Commit()
end
local SSRGetHpNewMsgCount = Lplus.Extend(SSRequestBase, "SSRGetHpNewMsgCount")
do
  local def = SSRGetHpNewMsgCount.define
  def.final("=>", SSRGetHpNewMsgCount).new = function()
    local obj = SSRGetHpNewMsgCount()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getnewssize"
  end
  def.override("number", "string", "=>", "boolean").onDealConnectError = function(self, errorCode, errorMsg)
    return true
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  def.override("number", "=>", "boolean").onDealSpecialRetcode = function(self, retcode)
    return true
  end
  SSRGetHpNewMsgCount.Commit()
end
local SSRReport = Lplus.Extend(SSRequestBase, "SSRReport")
do
  local def = SSRReport.define
  def.final("=>", SSRReport).new = function()
    local obj = SSRReport()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "reportillegal"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRReport.Commit()
end
local SSRGetPicUrls = Lplus.Extend(SSRequestBase, "SSRGetPicUrls")
do
  local def = SSRGetPicUrls.define
  def.final("=>", SSRGetPicUrls).new = function()
    local obj = SSRGetPicUrls()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getheadmomentpicurls"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRGetPicUrls.Commit()
end
local SSRGetHeadlineStatus = Lplus.Extend(SSRequestBase, "SSRGetHeadlineStatus")
do
  local def = SSRGetHeadlineStatus.define
  def.final("=>", SSRGetHeadlineStatus).new = function()
    local obj = SSRGetHeadlineStatus()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getheadmomentlist"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      ECSocialSpaceMan.Instance():onGetHeadlineMomentList(JsonData.momentList)
    end
  end
  SSRGetHeadlineStatus.Commit()
end
local SSRAddFavorToReply = Lplus.Extend(SSRequestBase, "SSRAddFavorToReply")
do
  local def = SSRAddFavorToReply.define
  def.final("=>", SSRAddFavorToReply).new = function()
    local obj = SSRAddFavorToReply()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "votereply"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      FlashTipMan.FlashTip(StringTable.Get(28242))
    end
  end
  SSRAddFavorToReply.Commit()
end
local SSRCancelFavorToReply = Lplus.Extend(SSRequestBase, "SSRCancelFavorToReply")
do
  local def = SSRCancelFavorToReply.define
  def.final("=>", SSRCancelFavorToReply).new = function()
    local obj = SSRCancelFavorToReply()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "cancelvotereply"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      FlashTipMan.FlashTip(StringTable.Get(28243))
    end
  end
  SSRCancelFavorToReply.Commit()
end
local SSRDetectNewStatus = Lplus.Extend(SSRequestBase, "SSRDetectNewStatus")
do
  local def = SSRDetectNewStatus.define
  def.final("=>", SSRDetectNewStatus).new = function()
    local obj = SSRDetectNewStatus()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "detectnewhotmoment"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRDetectNewStatus.Commit()
end
local SSRGetStatuReplyList = Lplus.Extend(SSRequestBase, "SSRGetStatuReplyList")
do
  local def = SSRGetStatuReplyList.define
  def.final("=>", SSRGetStatuReplyList).new = function()
    local obj = SSRGetStatuReplyList()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getmomentreplylist"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRGetStatuReplyList.Commit()
end
local SSRGetUploadFileSign = Lplus.Extend(SSRequestBase, "SSRGetUploadFileSign")
do
  local def = SSRGetUploadFileSign.define
  def.final("=>", SSRGetUploadFileSign).new = function()
    local obj = SSRGetUploadFileSign()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getuploadfilesign"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRGetUploadFileSign.Commit()
end
local SSRGetTopic = Lplus.Extend(SSRequestBase, "SSRGetTopic")
do
  local def = SSRGetTopic.define
  def.final("=>", SSRGetTopic).new = function()
    local obj = SSRGetTopic()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getmomentsubject"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRGetTopic.Commit()
end
local SSRGetTopicHotStatus = Lplus.Extend(SSRequestBase, "SSRGetTopicHotStatus")
do
  local def = SSRGetTopicHotStatus.define
  def.final("=>", SSRGetTopicHotStatus).new = function()
    local obj = SSRGetTopicHotStatus()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getsubjecthotmomentlist"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
    if tonumber(JsonData.retcode) == 0 then
      ECSocialSpaceMan.Instance():onGetTopicHotMomentList(JsonData.momentList)
    end
  end
  SSRGetTopicHotStatus.Commit()
end
local SSRGetStatuFavorList = Lplus.Extend(SSRequestBase, "SSRGetStatuFavorList")
do
  local def = SSRGetStatuFavorList.define
  def.final("=>", SSRGetStatuFavorList).new = function()
    local obj = SSRGetStatuFavorList()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getmomentvotelist"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRGetStatuFavorList.Commit()
end
local SSRGetStatusInfo = Lplus.Extend(SSRequestBase, "SSRGetStatusInfo")
do
  local def = SSRGetStatusInfo.define
  def.final("=>", SSRGetStatusInfo).new = function()
    local obj = SSRGetStatusInfo()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getmomentbyid"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRGetStatusInfo.Commit()
end
local SSRAddRoleToBlacklist = Lplus.Extend(SSRequestBase, "SSRAddRoleToBlacklist")
do
  local def = SSRAddRoleToBlacklist.define
  def.final("=>", SSRAddRoleToBlacklist).new = function()
    local obj = SSRAddRoleToBlacklist()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "addblacklist"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRAddRoleToBlacklist.Commit()
end
local SSRDelRoleFromBlacklist = Lplus.Extend(SSRequestBase, "SSRDelRoleFromBlacklist")
do
  local def = SSRDelRoleFromBlacklist.define
  def.final("=>", SSRDelRoleFromBlacklist).new = function()
    local obj = SSRDelRoleFromBlacklist()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "delblacklist"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRDelRoleFromBlacklist.Commit()
end
local SSRGetBlacklist = Lplus.Extend(SSRequestBase, "SSRGetBlacklist")
do
  local def = SSRGetBlacklist.define
  def.final("=>", SSRGetBlacklist).new = function()
    local obj = SSRGetBlacklist()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getblacklist"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRGetBlacklist.Commit()
end
local SSRGetFriends = Lplus.Extend(SSRequestBase, "SSRGetFriends")
do
  local def = SSRGetFriends.define
  def.final("=>", SSRGetFriends).new = function()
    local obj = SSRGetFriends()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getfriends"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRGetFriends.Commit()
end
local SSRGetLeaveMessageById = Lplus.Extend(SSRequestBase, "SSRGetLeaveMessageById")
do
  local def = SSRGetLeaveMessageById.define
  def.final("=>", SSRGetLeaveMessageById).new = function()
    local obj = SSRGetLeaveMessageById()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getmessagebyid"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRGetLeaveMessageById.Commit()
end
local SSRGetCosConfig = Lplus.Extend(SSRequestBase, "SSRGetCosConfig")
do
  local def = SSRGetCosConfig.define
  def.final("=>", SSRGetCosConfig).new = function()
    local obj = SSRGetCosConfig()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getcosconfig"
  end
  def.override().FillBaseInfo = function(self)
    self.mRequestData.gameId = _G.ZL_GAMEID
  end
  def.override("number", "=>", "boolean").onDealSpecialRetcode = function(self, retcode)
    return true
  end
  def.override("number", "string", "=>", "boolean").onDealConnectError = function(self, errorCode, errorMsg)
    return true
  end
  def.override("=>", "boolean").IsAbortWhenOutWorld = function(self)
    return false
  end
  SSRGetCosConfig.Commit()
end
local SSRGetFocusList = Lplus.Extend(SSRequestBase, "SSRGetFocusList")
do
  local def = SSRGetFocusList.define
  def.final("=>", SSRGetFocusList).new = function()
    local obj = SSRGetFocusList()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getfocus"
  end
  def.override("number", "=>", "boolean").onDealSpecialRetcode = function(self, retcode)
    return true
  end
  def.override("number", "string", "=>", "boolean").onDealConnectError = function(self, errorCode, errorMsg)
    return true
  end
  SSRGetFocusList.Commit()
end
local SSRAddFocus = Lplus.Extend(SSRequestBase, "SSRAddFocus")
do
  local def = SSRAddFocus.define
  def.final("=>", SSRAddFocus).new = function()
    local obj = SSRAddFocus()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "addfocus"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRAddFocus.Commit()
end
local SSRDelFocus = Lplus.Extend(SSRequestBase, "SSRDelFocus")
do
  local def = SSRDelFocus.define
  def.final("=>", SSRDelFocus).new = function()
    local obj = SSRDelFocus()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "delfocus"
  end
  def.override("table").onGetJsonData = function(self, JsonData)
  end
  SSRDelFocus.Commit()
end
local SSRGetRoleProfile = Lplus.Extend(SSRequestBase, "SSRGetRoleProfile")
do
  local def = SSRGetRoleProfile.define
  def.final("=>", SSRGetRoleProfile).new = function()
    local obj = SSRGetRoleProfile()
    obj:InitAddress()
    return obj
  end
  def.override().InitAddress = function(self)
    self.mGetAddress = "getprofile"
  end
  def.override("number", "=>", "boolean").onDealSpecialRetcode = function(self, retcode)
    return true
  end
  def.override("number", "string", "=>", "boolean").onDealConnectError = function(self, errorCode, errorMsg)
    return true
  end
  SSRGetRoleProfile.Commit()
end
return {
  SSRequestBase = SSRequestBase,
  SSRGetSpaceData = SSRGetSpaceData,
  SSRGetPlayerStatus = SSRGetPlayerStatus,
  SSRGetFriendNewStatus = SSRGetFriendNewStatus,
  SSRUpdateHpSignature = SSRUpdateHpSignature,
  SSRUploadPortraitPhoto = SSRUploadPortraitPhoto,
  SSRUpdateSpaceSetting = SSRUpdateSpaceSetting,
  SSRPublishNewStatus = SSRPublishNewStatus,
  SSRDeleteStatus = SSRDeleteStatus,
  SSRAddFavorToStatus = SSRAddFavorToStatus,
  SSRCancelFavorToStatus = SSRCancelFavorToStatus,
  SSRReplyStatus = SSRReplyStatus,
  SSRDeleteReplyMsg = SSRDeleteReplyMsg,
  SSRGetPlayerLeaveMsg = SSRGetPlayerLeaveMsg,
  SSRDoLeaveMsg = SSRDoLeaveMsg,
  SSRDeleteLeaveMsg = SSRDeleteLeaveMsg,
  SSRGetGiftRecords = SSRGetGiftRecords,
  SSRPutGiftRecords = SSRPutGiftRecords,
  SSRSpacePopularRecords = SSRSpacePopularRecords,
  SSRGetHpNewMsg = SSRGetHpNewMsg,
  SSRGetHpNewMsgCount = SSRGetHpNewMsgCount,
  SSRReport = SSRReport,
  SSRGetHotStatus = SSRGetHotStatus,
  SSRGetPicUrls = SSRGetPicUrls,
  SSRGetHeadlineStatus = SSRGetHeadlineStatus,
  SSRAddFavorToReply = SSRAddFavorToReply,
  SSRCancelFavorToReply = SSRCancelFavorToReply,
  SSRDetectNewStatus = SSRDetectNewStatus,
  SSRGetStatuReplyList = SSRGetStatuReplyList,
  SSRGetUploadFileSign = SSRGetUploadFileSign,
  SSRGetTopic = SSRGetTopic,
  SSRGetTopicHotStatus = SSRGetTopicHotStatus,
  SSRGetStatuFavorList = SSRGetStatuFavorList,
  SSRGetStatusInfo = SSRGetStatusInfo,
  SSRAddRoleToBlacklist = SSRAddRoleToBlacklist,
  SSRDelRoleFromBlacklist = SSRDelRoleFromBlacklist,
  SSRGetBlacklist = SSRGetBlacklist,
  SSRGetFriends = SSRGetFriends,
  SSRGetLeaveMessageById = SSRGetLeaveMessageById,
  SSRGetFocusList = SSRGetFocusList,
  SSRAddFocus = SSRAddFocus,
  SSRDelFocus = SSRDelFocus,
  SSRGetCosConfig = SSRGetCosConfig,
  SSRGetRoleProfile = SSRGetRoleProfile
}
