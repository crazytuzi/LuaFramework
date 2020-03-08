local Lplus = require("Lplus")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
local ECSSRequestTypes = require("Main.SocialSpace.SSRequestTypes")
local ECSocialSpaceConfig = require("Main.SocialSpace.ECSocialSpaceConfig")
local Network = require("netio.Network")
local json = require("Utility.json")
local SocialSpaceUtils = require("Main.SocialSpace.SocialSpaceUtils")
local SocialSpaceProtocol = require("Main.SocialSpace.SocialSpaceProtocol")
local SocialSpaceSettingMan = require("Main.SocialSpace.SocialSpaceSettingMan")
local SocialSpaceFocusMan = require("Main.SocialSpace.SocialSpaceFocusMan")
local SocialSpaceProfileMan = require("Main.SocialSpace.SocialSpaceProfileMan")
local DecorationNotificationMan = require("Main.SocialSpace.DecorationNotificationMan")
local ECDebugOption = require("Main.ECDebugOption")
local IReqTimeoutChecker = import(".IReqTimeoutChecker")
local DecoType = require("consts.mzm.gsp.item.confbean.FriendsCircleOrnamentItemType")
local SSRequestErrorCode = require("Main.SocialSpace.SSRequestErrorCode")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local SpaceData = Lplus.Class("SpaceData")
do
  local def = SpaceData.define
  def.field(ECSpaceMsgs.ECSpaceBaseInfo).baseInfo = nil
  def.field("table").msgs = BLANK_TABLE_INIT
  def.field("table").leaveMsgs = BLANK_TABLE_INIT
  def.field("table").newMsgs = BLANK_TABLE_INIT
  def.field("table").clientNewMsgs = BLANK_TABLE_INIT
  def.field("table").getGiftHistory = BLANK_TABLE_INIT
  def.field("table").guestHistory = BLANK_TABLE_INIT
  SpaceData.Commit()
end
local CommonSpaceData = Lplus.Class("CommonSpaceData")
do
  local def = CommonSpaceData.define
  def.field("table").hotMsgs = BLANK_TABLE_INIT
  def.field("table").headlineMsgs = BLANK_TABLE_INIT
  def.field("table").topicHotMsgs = BLANK_TABLE_INIT
  def.field("table").picUrls = BLANK_TABLE_INIT
  def.field("table").topic = BLANK_TABLE_INIT
  CommonSpaceData.Commit()
end
local SendGiftData = Lplus.Class("SendGiftData")
do
  local def = SendGiftData.define
  SendGiftData.Commit()
end
local ECSocialSpaceMan = Lplus.Class("ECSocialSpaceMan").Implement(IReqTimeoutChecker)
local def = ECSocialSpaceMan.define
local m_Instance
def.static("=>", ECSocialSpaceMan).Instance = function()
  if m_Instance == nil then
    m_Instance = ECSocialSpaceMan()
  end
  return m_Instance
end
local REQUEST_TYPE = {
  GET_SPACE_DATA = 1,
  GET_PLAYER_STATUS = 2,
  GET_FRIENDS_NEW_STATUS = 3,
  UPDATE_HP_SIGNATURE = 4,
  UPLOAD_PORTRAIT_PHOTO = 5,
  UPDATE_SPACE_SETTING = 6,
  PUBLISH_NEW_STATUS = 7,
  DEL_STATUS = 8,
  ADD_FAVOR_TO_STATUS = 9,
  CANCEL_FAVOR_TO_STATUS = 10,
  REPLY_STATUS = 11,
  DEL_REPLY_MSG = 12,
  GET_PLAYER_LEAVE_MSG = 13,
  DO_LEAVE_MSG = 14,
  DEL_LEAVE_MSG = 15,
  GET_GIFT_RECORDS = 16,
  PUT_GIFT_RECORDS = 17,
  GET_SPACE_POPULAR_RECORDS = 18,
  GET_HP_NEW_MSG = 19,
  GET_HP_NEW_MSG_COUNT = 20,
  REPORT = 21,
  GET_HOT_STATUS = 22,
  GET_PIC_URLS = 23,
  GET_HEADLINE_STATUS = 24,
  ADD_FAVOR_TO_REPLY = 25,
  CANCEL_FAVOR_TO_REPLY = 26,
  DETECT_NEW_STATUS = 27,
  GET_STATUS_REPLY_LIST = 28,
  GET_UPLOAD_FILE_SIGN = 29,
  GET_TOPIC = 30,
  GET_TOPIC_HOST_STATUS = 31,
  GET_STATUS_FAVOR_LIST = 32,
  GET_STATUS_INFO = 33,
  ADD_ROLE_TO_BLACKLIST = 34,
  DEL_ROLE_FROM_BLACKLIST = 35,
  GET_BLACKLIST = 36,
  GET_FRIENDS = 37,
  GET_LEAVE_MSG_INFO = 38,
  GET_COS_CONFIG = 39,
  GET_FOCUS_LIST = 40,
  ADD_FOCUS = 41,
  DEL_FOCUS = 42,
  GET_ROLE_PROFILE = 43
}
local STATUS_SORT_TYPE = {
  NONE = 0,
  TIMESTAMP = 1,
  FAVOR = 2
}
def.const("number").SIGN_TOKEN_ALIVE_SECONDS = 1200
def.const("string").SECRET_KEY = ""
def.const("table").REQUEST_TYPE = REQUEST_TYPE
def.const("table").STATUS_SORT_TYPE = STATUS_SORT_TYPE
def.const("string").TREAD_ROLE_KEY_PREFIX = "SOCIAL_SPACE_TREAD_ROLE_"
def.field(SpaceData).m_selfData = nil
def.field(CommonSpaceData).m_commonSpaceData = nil
def.field("table").m_playerCache = BLANK_TABLE_INIT
def.field("number").NextUnqiueID = 0
def.field("number").m_checkNewMsgTimerID = 0
def.field("number").m_checkNewStatusTimerID = 0
def.field("number").m_checkTimeoutTimerID = 0
def.field("number").m_forbidenSpeakEndTime = 0
def.field("string").m_forbidenReason = ""
def.field("boolean").m_bActiveSocialSpace = false
def.field("number").m_unreadCount = 0
def.field("table").m_requests = BLANK_TABLE_INIT
def.field("table").m_blacklistRoles = nil
def.field("string").m_signedMD5Token = ""
def.field("number").m_tokenExpireTime = 0
def.field("userdata").m_tokenTimeStamp = Zero_Int64_Init
def.field("table").m_requestSentTimes = BLANK_TABLE_INIT
def.field("table").m_waitTokenList = BLANK_TABLE_INIT
def.field("function").m_tokenHandler = nil
def.field("table").m_decorateDatas = nil
def.field("table").m_savedDecorateData = nil
def.field("boolean").m_isSelfSpacePanelOpened = false
def.field("boolean").m_isInited = false
def.method().OnInit = function(self)
  SocialSpaceFocusMan.Instance():Init(self)
  if self.m_isInited then
    return
  end
  if not self.m_commonSpaceData then
    self.m_commonSpaceData = CommonSpaceData()
    self.m_commonSpaceData.hotMsgs = {}
  end
  self:StartCheckNewMsgTimer()
  SocialSpaceProfileMan.Instance():Init(self)
end
def.method().OnLeaveWorldClear = function(self)
end
def.method().OnLeaveWorldStageClear = function(self)
  self.m_isInited = false
  self.m_selfData = nil
  self.m_playerCache = {}
  self.NextUnqiueID = 0
  self.m_tokenExpireTime = 0
  self.m_tokenTimeStamp = Zero_Int64
  self.m_signedMD5Token = ""
  self.m_requestSentTimes = {}
  self.m_waitTokenList = {}
  self.m_bActiveSocialSpace = false
  self.m_decorateDatas = nil
  self.m_savedDecorateData = nil
  self.m_unreadCount = 0
  self.m_requests = {}
  self.m_forbidenSpeakEndTime = 0
  self.m_forbidenReason = ""
  self.m_isSelfSpacePanelOpened = false
  self.m_blacklistRoles = nil
  SocialSpaceFocusMan.Instance():Clear()
  SocialSpaceProfileMan.Instance():Clear()
  DecorationNotificationMan.Instance():Clear()
  self:RemoveCheckNewMsgTimer()
  self:RemoveCheckTimeoutTimer()
end
def.method().StartCheckNewMsgTimer = function(self)
  self:RemoveCheckNewMsgTimer()
  local function run()
    if self:IsNeedReqNewMsgCount() then
      self:Req_GetHostPlayerNewMsgCount()
    end
  end
  if self.m_checkNewMsgTimerID == 0 then
    run()
    self.m_checkNewMsgTimerID = GameUtil.AddGlobalTimer(300, false, function()
      run()
    end)
  end
end
def.method("=>", "boolean").IsNeedReqNewMsgCount = function(self)
  if not _G.IsConnected() then
    return false
  end
  if self.m_unreadCount > 0 and not self.m_isSelfSpacePanelOpened then
    return false
  end
  if _G.IsCrossingServer() then
    return false
  end
  if self:CheckActiveSocialSpace(false) then
    return true
  end
  return false
end
def.method().RemoveCheckNewMsgTimer = function(self)
  if self.m_checkNewMsgTimerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_checkNewMsgTimerID)
    self.m_checkNewMsgTimerID = 0
  end
end
def.method().StartCheckNewStatusTimer = function(self)
  self:RemoveCheckNewStatusTimer()
  if self.m_checkNewStatusTimerID == 0 then
    self.m_checkNewStatusTimerID = GameUtil.AddGlobalTimer(600, false, function()
      if self.m_bActiveSocialSpace or self:CheckActiveSocialSpace(false) then
        self:Req_DetectNewStatus()
      end
    end)
  end
end
def.method().RemoveCheckNewStatusTimer = function(self)
  if self.m_checkNewStatusTimerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_checkNewStatusTimerID)
    self.m_checkNewStatusTimerID = 0
  end
end
def.method().StartCheckTimeoutTimer = function(self)
  if self.m_checkTimeoutTimerID ~= 0 then
    return
  end
  self.m_checkTimeoutTimerID = GameUtil.AddGlobalTimer(1, false, function()
    self:OnCheckTimeout()
  end)
end
def.method().RemoveCheckTimeoutTimer = function(self)
  if self.m_checkTimeoutTimerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_checkTimeoutTimerID)
    self.m_checkTimeoutTimerID = 0
  end
end
def.method("number", "number", "=>", "number").CheckInCoolDownTime = function(self, request_type, curTime)
  local sentTime = self.m_requestSentTimes[request_type]
  if sentTime == nil then
    return 0
  end
  local coolDownCfg = ECSocialSpaceConfig.getCoolDownCfg()
  local coolTime = coolDownCfg[request_type] or coolDownCfg.default
  local elapsedTime = curTime - sentTime
  local leftTime = math.max(0, coolTime - elapsedTime)
  return leftTime
end
def.method("number", "table", "function").AddToWaitTokenList = function(self, request_type, params, callback)
  local function tokenHandler(self, retcode, msg)
    if retcode == 0 then
      self:SendRequest(request_type, params, callback)
    else
      local request = self:CreateRequest(request_type)
      request:SetCallback(callback)
      request:DealConnectError(retcode, msg)
    end
  end
  self:ReqNewToken(tokenHandler, self)
end
def.method("function", "table").ReqNewToken = function(self, callback, context)
  table.insert(self.m_waitTokenList, {_context = context, _callback = callback})
  if not self.m_tokenHandler then
    function self.m_tokenHandler(p)
      if p then
        self.m_signedMD5Token = _G.GetStringFromOcts(p.sign)
        self.m_tokenTimeStamp = p.timestamp
        self.m_tokenExpireTime = (p.timestamp / 1000 + ECSocialSpaceMan.SIGN_TOKEN_ALIVE_SECONDS):ToNumber()
        for i = 1, #self.m_waitTokenList do
          local data = self.m_waitTokenList[i]
          _G.SafeCallback(data._callback, data._context, 0)
        end
      else
        for i = 1, #self.m_waitTokenList do
          local data = self.m_waitTokenList[i]
          _G.SafeCallback(data._callback, data._context, SSRequestErrorCode.GET_SIGN_TIMEOUT, textRes.SocialSpace[63] or "Get sign timeout")
        end
      end
      self.m_waitTokenList = {}
      self.m_tokenHandler = nil
    end
  end
  SocialSpaceProtocol.CGetFriendsCircleSign(self.m_tokenHandler)
end
def.method("number", "table", "function", "boolean").RequestData = function(self, request_type, params, callback, bCheckCoolTime)
  local curTime = _G.GetServerTime()
  if bCheckCoolTime then
    local coolDown = self:CheckInCoolDownTime(request_type, curTime)
    if coolDown > 0 then
      Toast(textRes.SocialSpace[9])
      if callback then
        callback({
          retcode = SSRequestErrorCode.TOO_FREQUENTLY,
          errorMsg = textRes.SocialSpace[9]
        })
      end
      return
    else
      self.m_requestSentTimes[request_type] = curTime
    end
  end
  if curTime > self.m_tokenExpireTime then
    self:AddToWaitTokenList(request_type, params, callback)
    return
  end
  if self:ShowLog() then
  end
  self:SendRequest(request_type, params, callback)
end
def.method("number", "=>", ECSSRequestTypes.SSRequestBase).CreateRequest = function(self, request_type)
  local request
  if request_type == REQUEST_TYPE.GET_SPACE_DATA then
    request = ECSSRequestTypes.SSRGetSpaceData.new()
  elseif request_type == REQUEST_TYPE.GET_PLAYER_STATUS then
    request = ECSSRequestTypes.SSRGetPlayerStatus.new()
  elseif request_type == REQUEST_TYPE.GET_FRIENDS_NEW_STATUS then
    request = ECSSRequestTypes.SSRGetFriendNewStatus.new()
  elseif request_type == REQUEST_TYPE.UPDATE_HP_SIGNATURE then
    request = ECSSRequestTypes.SSRUpdateHpSignature.new()
  elseif request_type == REQUEST_TYPE.UPLOAD_PORTRAIT_PHOTO then
    request = ECSSRequestTypes.SSRUploadPortraitPhoto.new()
  elseif request_type == REQUEST_TYPE.UPDATE_SPACE_SETTING then
    request = ECSSRequestTypes.SSRUpdateSpaceSetting.new()
  elseif request_type == REQUEST_TYPE.PUBLISH_NEW_STATUS then
    request = ECSSRequestTypes.SSRPublishNewStatus.new()
  elseif request_type == REQUEST_TYPE.DEL_STATUS then
    request = ECSSRequestTypes.SSRDeleteStatus.new()
  elseif request_type == REQUEST_TYPE.ADD_FAVOR_TO_STATUS then
    request = ECSSRequestTypes.SSRAddFavorToStatus.new()
  elseif request_type == REQUEST_TYPE.CANCEL_FAVOR_TO_STATUS then
    request = ECSSRequestTypes.SSRCancelFavorToStatus.new()
  elseif request_type == REQUEST_TYPE.REPLY_STATUS then
    request = ECSSRequestTypes.SSRReplyStatus.new()
  elseif request_type == REQUEST_TYPE.DEL_REPLY_MSG then
    request = ECSSRequestTypes.SSRDeleteReplyMsg.new()
  elseif request_type == REQUEST_TYPE.GET_PLAYER_LEAVE_MSG then
    request = ECSSRequestTypes.SSRGetPlayerLeaveMsg.new()
  elseif request_type == REQUEST_TYPE.DO_LEAVE_MSG then
    request = ECSSRequestTypes.SSRDoLeaveMsg.new()
  elseif request_type == REQUEST_TYPE.DEL_LEAVE_MSG then
    request = ECSSRequestTypes.SSRDeleteLeaveMsg.new()
  elseif request_type == REQUEST_TYPE.GET_GIFT_RECORDS then
    request = ECSSRequestTypes.SSRGetGiftRecords.new()
  elseif request_type == REQUEST_TYPE.PUT_GIFT_RECORDS then
    request = ECSSRequestTypes.SSRPutGiftRecords.new()
  elseif request_type == REQUEST_TYPE.GET_SPACE_POPULAR_RECORDS then
    request = ECSSRequestTypes.SSRSpacePopularRecords.new()
  elseif request_type == REQUEST_TYPE.GET_HP_NEW_MSG then
    request = ECSSRequestTypes.SSRGetHpNewMsg.new()
  elseif request_type == REQUEST_TYPE.GET_HP_NEW_MSG_COUNT then
    request = ECSSRequestTypes.SSRGetHpNewMsgCount.new()
  elseif request_type == REQUEST_TYPE.REPORT then
    request = ECSSRequestTypes.SSRReport.new()
  elseif request_type == REQUEST_TYPE.GET_HOT_STATUS then
    request = ECSSRequestTypes.SSRGetHotStatus.new()
  elseif request_type == REQUEST_TYPE.GET_PIC_URLS then
    request = ECSSRequestTypes.SSRGetPicUrls.new()
  elseif request_type == REQUEST_TYPE.GET_HEADLINE_STATUS then
    request = ECSSRequestTypes.SSRGetHeadlineStatus.new()
  elseif request_type == REQUEST_TYPE.ADD_FAVOR_TO_REPLY then
    request = ECSSRequestTypes.SSRAddFavorToReply.new()
  elseif request_type == REQUEST_TYPE.CANCEL_FAVOR_TO_REPLY then
    request = ECSSRequestTypes.SSRCancelFavorToReply.new()
  elseif request_type == REQUEST_TYPE.DETECT_NEW_STATUS then
    request = ECSSRequestTypes.SSRDetectNewStatus.new()
  elseif request_type == REQUEST_TYPE.GET_STATUS_REPLY_LIST then
    request = ECSSRequestTypes.SSRGetStatuReplyList.new()
  elseif request_type == REQUEST_TYPE.GET_UPLOAD_FILE_SIGN then
    request = ECSSRequestTypes.SSRGetUploadFileSign.new()
  elseif request_type == REQUEST_TYPE.GET_TOPIC then
    request = ECSSRequestTypes.SSRGetTopic.new()
  elseif request_type == REQUEST_TYPE.GET_TOPIC_HOST_STATUS then
    request = ECSSRequestTypes.SSRGetTopicHotStatus.new()
  elseif request_type == REQUEST_TYPE.GET_STATUS_FAVOR_LIST then
    request = ECSSRequestTypes.SSRGetStatuFavorList.new()
  elseif request_type == REQUEST_TYPE.GET_STATUS_INFO then
    request = ECSSRequestTypes.SSRGetStatusInfo.new()
  elseif request_type == REQUEST_TYPE.GET_BLACKLIST then
    request = ECSSRequestTypes.SSRGetBlacklist.new()
  elseif request_type == REQUEST_TYPE.GET_FRIENDS then
    request = ECSSRequestTypes.SSRGetFriends.new()
  elseif request_type == REQUEST_TYPE.GET_LEAVE_MSG_INFO then
    request = ECSSRequestTypes.SSRGetLeaveMessageById.new()
  elseif request_type == REQUEST_TYPE.GET_COS_CONFIG then
    request = ECSSRequestTypes.SSRGetCosConfig.new()
  elseif request_type == REQUEST_TYPE.GET_FOCUS_LIST then
    request = ECSSRequestTypes.SSRGetFocusList.new()
  elseif request_type == REQUEST_TYPE.ADD_FOCUS then
    request = ECSSRequestTypes.SSRAddFocus.new()
  elseif request_type == REQUEST_TYPE.DEL_FOCUS then
    request = ECSSRequestTypes.SSRDelFocus.new()
  elseif request_type == REQUEST_TYPE.GET_ROLE_PROFILE then
    request = ECSSRequestTypes.SSRGetRoleProfile.new()
  end
  return request
end
def.method("number", "table", "function").SendRequest = function(self, request_type, params, callback)
  local request = self:CreateRequest(request_type)
  if not request then
    warn("no suit RequestClass", request_type)
    return
  end
  request:SetTimeoutChecker(self)
  request:SendRequest(params, callback)
  self:StartCheckTimeoutTimer()
end
def.method("userdata", "function", "table").LoadSpaceData = function(self, roleId, callback, extra)
  extra = extra or {}
  if not extra.uptodate then
    local spaceData = self:GetSpaceData(roleId)
    if spaceData and callback then
      callback(spaceData)
      return
    end
  end
  local params = {}
  params.ownerGameId = _G.ZL_GAMEID
  params.ownerServerId = self:GetHostServerId()
  params.ownerId = roleId
  self:RequestData(REQUEST_TYPE.GET_SPACE_DATA, params, function(data)
    local spaceData
    if data.retcode == 0 then
      spaceData = self:GetSpaceData(roleId)
    end
    if callback then
      callback(spaceData)
    end
  end, false)
end
def.method("=>", CommonSpaceData).GetCommonSpaceData = function(self)
  return self.m_commonSpaceData
end
def.method("=>", SpaceData).GetSelfSpaceData = function(self)
  return self.m_selfData
end
def.method("userdata", "=>", SpaceData).GetSpaceData = function(self, roleId)
  local hostRoleId = self:GetHostRoleId()
  local bRequest = true
  if hostRoleId == roleId and self.m_selfData then
    return self.m_selfData
  else
    for i = 1, #self.m_playerCache do
      if self.m_playerCache[i].baseInfo.roleId == roleId then
        return self.m_playerCache[i]
      end
    end
  end
  return nil
end
def.method("boolean", "=>", "boolean").CheckActiveSocialSpace = function(self, showTip)
  local info
  self.m_bActiveSocialSpace, info = gmodule.moduleMgr:GetModule(ModuleId.SOCIAL_SPACE):IsOpen()
  if showTip then
    Toast(info)
  end
  return self.m_bActiveSocialSpace
end
def.method("userdata").EnterSpace = function(self, roleId)
  self:EnterSpaceWithMsgId(roleId, nil)
end
def.method("userdata", "userdata").EnterSpaceWithMsgId = function(self, roleId, msgId)
  self:EnterSpaceWithServerId(roleId, nil, msgId)
end
def.method("userdata", "dynamic", "userdata").EnterSpaceWithServerId = function(self, roleId, serverId, msgId)
  local params = {
    roleId = roleId,
    serverId = serverId,
    msgId = msgId
  }
  self:EnterSpaceWithParams(params)
end
def.method("table").EnterSpaceWithParams = function(self, esParams)
  local roleId = esParams.roleId
  local serverId, msgId, onPanelReady = esParams.serverId, esParams.msgId, esParams.onPanelReady
  local leaveMsgId = esParams.leaveMsgId
  if serverId == nil then
    serverId = self:GetRoleServerId(roleId)
  end
  if self:CheckIsRoleInBlacklist(roleId, textRes.SocialSpace[110]) then
    return
  end
  local WaitingTip = require("GUI.WaitingTip")
  WaitingTip.ShowTipEx(textRes.SocialSpace[60], {delayTime = 1})
  local params = {}
  params.ownerGameId = _G.ZL_GAMEID
  params.ownerServerId = serverId
  params.ownerId = tostring(roleId)
  self:RequestData(REQUEST_TYPE.GET_SPACE_DATA, params, function(data)
    WaitingTip.HideTip()
    if data.retcode ~= 0 then
      local retcode = data.retcode
      if retcode == SSRequestErrorCode.ACTIVE_BLACKLIST or retcode == SSRequestErrorCode.MUTUAL_BLACKLIST then
        Toast(textRes.SocialSpace[110])
      elseif retcode == SSRequestErrorCode.PASSIVE_BLACKLIST then
        Toast(textRes.SocialSpace[111])
      else
        ECSSRequestTypes.SSRequestBase.PostDealError(data)
      end
      return
    end
    local function enter()
      local SocialSpacePanel = require("Main.SocialSpace.ui.SocialSpacePanel")
      local panelParams = {ownerId = roleId, msgId = msgId}
      panelParams.onPanelReady = onPanelReady
      panelParams.leaveMsgId = leaveMsgId
      SocialSpacePanel.ShowPanel(panelParams)
    end
    if msgId and msgId:gt(0) then
      self:Req_GetStatusInfo(msgId, enter, false)
    else
      enter()
    end
  end, false)
end
def.method("table").onGetSpaceData = function(self, data)
  warn("onGetSpaceData")
  local baseInfo = ECSpaceMsgs.ECSpaceBaseInfo()
  baseInfo.roleId = Int64.ParseString(data.ownerInfo.roleId)
  baseInfo.playerName = data.ownerInfo.roleName
  baseInfo.serverId = tonumber(data.ownerInfo.serverId)
  baseInfo.level = tonumber(data.ownerInfo.level)
  baseInfo.gender = tonumber(data.ownerInfo.gender)
  baseInfo.prof = tonumber(data.ownerInfo.prof) or 0
  baseInfo.idphoto, baseInfo.avatarFrameId, baseInfo.urlphoto = ECSpaceMsgs.ParsePhoto(data.ownerInfo.photoId)
  baseInfo.race = tonumber(data.ownerInfo.race)
  baseInfo.factionId = tonumber(data.ownerInfo.corpsId)
  baseInfo.factionName = data.ownerInfo.corpsName
  baseInfo.signature = data.ownerInfo.signature
  baseInfo.lastWeekPopular = tonumber(data.ownerInfo.lastWeekPopularity)
  baseInfo.thisWeekPopular = tonumber(data.ownerInfo.thisWeekPopularity)
  baseInfo.totalPopular = tonumber(data.ownerInfo.allPopularity)
  baseInfo.gainGiftCount = tonumber(data.ownerInfo.gainGiftCount)
  baseInfo.giftCount = tonumber(data.ownerInfo.giftCount)
  baseInfo.status = tonumber(data.ownerInfo.status)
  self:OnGetForbiddenInfo(data.ownerInfo)
  self:ParseLocation(baseInfo, data.ownerInfo)
  self:ParseSpaceStyle(baseInfo, data.spaceStyle)
  self:ParseSpaceSetting(baseInfo, data.spaceSetting)
  local hostRoleId = self:GetHostRoleId()
  if baseInfo.roleId == hostRoleId then
    if not self.m_selfData then
      self.m_selfData = SpaceData()
    else
      self.m_selfData.msgs = {}
      self.m_selfData.leaveMsgs = {}
      self.m_selfData.newMsgs = {}
      self.m_selfData.clientNewMsgs = {}
      self.m_unreadCount = 0
    end
    self.m_selfData.baseInfo = baseInfo
  else
    local bFind = false
    for i = 1, #self.m_playerCache do
      if self.m_playerCache[i].baseInfo and self.m_playerCache[i].baseInfo.roleId == baseInfo.roleId then
        bFind = true
        self.m_playerCache[i].baseInfo = baseInfo
        self.m_playerCache[i].msgs = {}
        self.m_playerCache[i].leaveMsgs = {}
      end
    end
    if not bFind then
      local spaceData = SpaceData()
      spaceData.baseInfo = baseInfo
      if #self.m_playerCache == ECSocialSpaceConfig.getMaxPlayerDataCacheCount() then
        table.remove(self.m_playerCache, 1)
      end
      table.insert(self.m_playerCache, spaceData)
    end
  end
  self:onGetMomentList(data.momentList, data.ownerInfo.roleId)
  if baseInfo.roleId == hostRoleId and tonumber(data.newsSize) then
    local count = tonumber(data.newsSize)
    self.m_unreadCount = count
    Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.SpaceNewMsg, {count})
  end
  Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.SpaceDataUpdate, {
    data.ownerInfo.roleId
  })
end
def.method("table", "dynamic").onGetMomentList = function(self, data, ownerId)
  if not data or #data == 0 then
    return
  end
  local curMomentList
  local hostRoleId = self:GetHostRoleId()
  local roleId = Int64.ParseString(ownerId)
  if roleId == hostRoleId then
    curMomentList = self.m_selfData and self.m_selfData.msgs
  else
    for i = 1, #self.m_playerCache do
      if self.m_playerCache[i].baseInfo and self.m_playerCache[i].baseInfo.roleId == roleId then
        curMomentList = self.m_playerCache[i].msgs
        break
      end
    end
  end
  if not curMomentList then
    warn("get player momentList without player cache", debug.traceback())
    return
  end
  local newMomentList = {}
  for i = 1, #data do
    local msg = self:ParseECSpaceMsg(data[i])
    msg.msgIdClient = self.NextUnqiueID
    table.insert(newMomentList, msg)
    self.NextUnqiueID = self.NextUnqiueID + 1
  end
  local NewMsgList = self:MergeSort(curMomentList, newMomentList, STATUS_SORT_TYPE.TIMESTAMP, ECSocialSpaceConfig.getStatusMaxSaveCount())
  local data = self:GetSpaceData(roleId)
  data.msgs = {}
  for i = 1, #NewMsgList do
    table.insert(data.msgs, NewMsgList[i])
  end
end
def.method("table").onGetLeaveMsgList = function(self, data)
  if not data or #data == 0 then
    return
  end
  local curLeaveMsgList
  local hostRoleId = self:GetHostRoleId()
  local roleId = Int64.ParseString(data[1].ownerId)
  if roleId == hostRoleId then
    curLeaveMsgList = self.m_selfData and self.m_selfData.leaveMsgs
  else
    for i = 1, #self.m_playerCache do
      if self.m_playerCache[i].baseInfo and self.m_playerCache[i].baseInfo.roleId == roleId then
        curLeaveMsgList = self.m_playerCache[i].leaveMsgs
        break
      end
    end
  end
  if not curLeaveMsgList then
    warn("get player momentList without player cache")
    return
  end
  local newLeaveMsgList = {}
  for i = 1, #data do
    local curMsg = data[i]
    local msg = ECSpaceMsgs.ECLeaveMsg()
    msg.ID = Int64.ParseString(curMsg.messageId)
    msg.roleId = Int64.ParseString(curMsg.commenterId)
    msg.serverId = tonumber(curMsg.commenterServerId)
    msg.playerName = curMsg.commenterName
    msg.idphoto, msg.avatarFrameId, msg.urlphoto = ECSpaceMsgs.ParsePhoto(curMsg.commenterPhotoId)
    msg.timestamp = math.floor(tonumber(curMsg.createTime) / 1000)
    msg.targetId = Int64.ParseString(curMsg.ownerId)
    msg.replyRoleId = curMsg.targetId and Int64.ParseString(curMsg.targetId) or Zero_Int64
    msg.replyRoleName = curMsg.targetName or ""
    msg.deleted = tonumber(curMsg.status) == 1
    msg.strPlainMsg = self:FilterSensitiveWords(curMsg.content)
    msg.strData = curMsg.supplement
    msg.strRichMsg = ECSocialSpaceMan.BuildSpaceRichContent(msg.strPlainMsg, msg.strData)
    msg.status = tonumber(curMsg.status)
    local remindList = json.decode(curMsg.remindList)
    for k = 1, #remindList do
      local _data = remindList[k]
      table.insert(msg.atPlayerList, {
        id = Int64.ParseString(_data.roleId),
        name = _data.roleName
      })
    end
    table.insert(newLeaveMsgList, msg)
  end
  warn("#data", #data)
  local NewMsgList = {}
  local i, j, idx = 1, 1, 1
  while i <= #curLeaveMsgList and j <= #newLeaveMsgList do
    if curLeaveMsgList[i].ID == newLeaveMsgList[j].ID then
      NewMsgList[idx] = newLeaveMsgList[j]
      j = j + 1
      i = i + 1
    elseif curLeaveMsgList[i].timestamp > newLeaveMsgList[j].timestamp then
      NewMsgList[idx] = curLeaveMsgList[i]
      i = i + 1
    else
      NewMsgList[idx] = newLeaveMsgList[j]
      j = j + 1
    end
    idx = idx + 1
  end
  if i < #curLeaveMsgList then
    for k = i, #curLeaveMsgList do
      NewMsgList[idx] = curLeaveMsgList[k]
      idx = idx + 1
    end
  else
    for k = j, #newLeaveMsgList do
      NewMsgList[idx] = newLeaveMsgList[k]
      idx = idx + 1
    end
  end
  if #NewMsgList > ECSocialSpaceConfig.getLeaveMsgMaxSaveCount() then
    for i = #NewMsgList, ECSocialSpaceConfig.getLeaveMsgMaxSaveCount() + 1, -1 do
      table.remove(NewMsgList, i)
    end
  end
  local data = self:GetSpaceData(roleId)
  data.leaveMsgs = {}
  for i = 1, #NewMsgList do
    table.insert(data.leaveMsgs, NewMsgList[i])
  end
  if self:ShowLog() then
    print("LeaveMsgList:")
    for i = 1, #NewMsgList do
      print(NewMsgList[i].ID)
    end
  end
end
def.method("table").onGetHotMomentList = function(self, data)
  if not data or #data == 0 then
    return
  end
  if not self.m_commonSpaceData then
    warn("commonSpaceData is nil")
    return
  end
  local curMomentList = self.m_commonSpaceData.hotMsgs
  if not curMomentList then
    warn("get hot momentList field", debug.traceback())
    return
  end
  local newMomentList = {}
  for i = 1, #data do
    local msg = self:ParseECSpaceMsg(data[i])
    table.insert(newMomentList, msg)
  end
  local NewMsgList = self:MergeSort(curMomentList, newMomentList, STATUS_SORT_TYPE.TIMESTAMP, ECSocialSpaceConfig.getStatusMaxSaveCount())
  local data = self.m_commonSpaceData
  data.hotMsgs = {}
  for i = 1, #NewMsgList do
    table.insert(data.hotMsgs, NewMsgList[i])
  end
end
def.method("table").onGetHeadlineMomentList = function(self, data)
  if not data or #data == 0 then
    return
  end
  if not self.m_commonSpaceData then
    warn("commonSpaceData is nil")
    return
  end
  local curMomentList = self.m_commonSpaceData.headlineMsgs
  if not curMomentList then
    warn("get headline momentList field", debug.traceback())
    return
  end
  local newMomentList = {}
  for i = 1, #data do
    local msg = self:ParseECSpaceMsg(data[i])
    table.insert(newMomentList, msg)
  end
  local NewMsgList = self:MergeSort(curMomentList, newMomentList, STATUS_SORT_TYPE.NONE, ECSocialSpaceConfig.getStatusMaxSaveCount())
  local data = self.m_commonSpaceData
  data.headlineMsgs = {}
  for i = 1, #NewMsgList do
    table.insert(data.headlineMsgs, NewMsgList[i])
  end
  if #NewMsgList > 0 then
    UserData.Instance():SetRoleCfg("SpaceHeadlineMsgId", NewMsgList[1].ID)
  end
end
def.method("table").onGetTopicHotMomentList = function(self, data)
  if not data or #data == 0 then
    return
  end
  if not self.m_commonSpaceData then
    warn("commonSpaceData is nil")
    return
  end
  local curMomentList = self.m_commonSpaceData.topicHotMsgs
  if not curMomentList then
    warn("get headline momentList field", debug.traceback())
    return
  end
  local newMomentList = {}
  for i = 1, #data do
    local msg = self:ParseECSpaceMsg(data[i])
    table.insert(newMomentList, msg)
  end
  local sortByfavor = function(left, right)
    return left.voteSize > right.voteSize
  end
  table.sort(newMomentList, sortByfavor)
  local NewMsgList = self:MergeSort(curMomentList, newMomentList, STATUS_SORT_TYPE.FAVOR, ECSocialSpaceConfig.getTopicStatusMaxSaveCount())
  local data = self.m_commonSpaceData
  data.topicHotMsgs = {}
  for i = 1, #NewMsgList do
    table.insert(data.topicHotMsgs, NewMsgList[i])
  end
end
def.method("table", "table", "number", "number", "=>", "table").MergeSort = function(self, curMomentList, newMomentList, sortType, maxCount)
  local NewMsgList = {}
  local i, j, idx = 1, 1, 1
  while i <= #curMomentList and j <= #newMomentList do
    if curMomentList[i].ID == newMomentList[j].ID then
      NewMsgList[idx] = newMomentList[j]
      j = j + 1
      i = i + 1
    elseif sortType == STATUS_SORT_TYPE.FAVOR then
      if curMomentList[i].voteSize > newMomentList[j].voteSize then
        NewMsgList[idx] = curMomentList[i]
        i = i + 1
      else
        NewMsgList[idx] = newMomentList[j]
        j = j + 1
      end
    elseif sortType == STATUS_SORT_TYPE.TIMESTAMP then
      if curMomentList[i].timestamp > newMomentList[j].timestamp then
        NewMsgList[idx] = curMomentList[i]
        i = i + 1
      else
        NewMsgList[idx] = newMomentList[j]
        j = j + 1
      end
    else
      NewMsgList[idx] = curMomentList[i]
      i = i + 1
    end
    idx = idx + 1
  end
  for k = i, #curMomentList do
    NewMsgList[idx] = curMomentList[k]
    idx = idx + 1
  end
  for k = j, #newMomentList do
    NewMsgList[idx] = newMomentList[k]
    idx = idx + 1
  end
  if maxCount > 0 and maxCount < #NewMsgList then
    for i = #NewMsgList, maxCount + 1, -1 do
      table.remove(NewMsgList, i)
    end
  end
  return NewMsgList
end
def.method("table", "=>", ECSpaceMsgs.ECSpaceMsg).ParseECSpaceMsg = function(self, curMsg)
  local msg = ECSpaceMsgs.ECSpaceMsg()
  msg.ID = Int64.ParseString(curMsg.momentId)
  msg.serverId = tonumber(curMsg.serverId)
  msg.roleId = Int64.ParseString(curMsg.roleId)
  msg.playerName = curMsg.roleName
  msg.idphoto, msg.avatarFrameId, msg.urlphoto = ECSpaceMsgs.ParsePhoto(curMsg.photoId)
  msg.strPlainMsg = self:FilterSensitiveWords(curMsg.content)
  msg.strData = curMsg.supplement
  msg.strRichMsg = ECSocialSpaceMan.BuildSpaceRichContent(msg.strPlainMsg, msg.strData)
  msg.timestamp = math.floor(tonumber(curMsg.createTime) / 1000)
  if curMsg.voteSize and curMsg.voteSize ~= "" then
    msg.voteSize = tonumber(curMsg.voteSize)
  end
  if curMsg.hasVoted then
    msg.hasVoted = curMsg.hasVoted
  end
  msg.favorList = {}
  for j = 1, #curMsg.voteRecordList do
    local data = curMsg.voteRecordList[j]
    local favorer = self:ParseECFavorer(data)
    table.insert(msg.favorList, favorer)
  end
  msg.pics = {}
  local function addPicUrl(picUrl)
    if picUrl and #picUrl > 0 then
      table.insert(msg.pics, picUrl)
    end
  end
  addPicUrl(curMsg.pic1)
  addPicUrl(curMsg.pic2)
  addPicUrl(curMsg.pic3)
  addPicUrl(curMsg.pic4)
  if curMsg.hotStatus then
    msg.hotStatus = tonumber(curMsg.hotStatus)
  end
  if curMsg.hotTime then
    msg.hotTime = tonumber(curMsg.hotTime)
  end
  if curMsg.replySize and curMsg.replySize ~= "" then
    msg.replySize = tonumber(curMsg.replySize)
  end
  msg.replyMsgList = {}
  curMsg.replyList = curMsg.replyList or {}
  for j = 1, #curMsg.replyList do
    local replyData = curMsg.replyList[j]
    local reply = self:ParseECReplyMsg(replyData)
    table.insert(msg.replyMsgList, reply)
  end
  return msg
end
def.method("table", "=>", ECSpaceMsgs.ECReplyMsg).ParseECReplyMsg = function(self, replyData)
  local reply = ECSpaceMsgs.ECReplyMsg()
  reply.roleId = Int64.ParseString(replyData.replierId)
  reply.serverId = tonumber(replyData.replierServerid)
  reply.playerName = replyData.replierName
  if replyData.replierPhotoId then
    reply.idphoto, reply.avatarFrameId, reply.urlphoto = ECSpaceMsgs.ParsePhoto(replyData.replierPhotoId)
  end
  reply.replyRoleId = replyData.targetId and Int64.ParseString(replyData.targetId) or Zero_Int64
  reply.replyRoleName = replyData.targetName and replyData.targetName or ""
  reply.replyId = Int64.ParseString(replyData.replyId)
  reply.msgID = Int64.ParseString(replyData.momentId)
  reply.atPlayerList = {}
  local remindList = json.decode(replyData.remindList)
  for k = 1, #remindList do
    local _data = remindList[k]
    table.insert(reply.atPlayerList, {
      roleId = Int64.ParseString(_data.roleId),
      roleName = _data.roleName,
      gameId = _G.ZL_GAMEID
    })
  end
  reply.strPlainMsg = self:FilterSensitiveWords(replyData.content)
  reply.strData = replyData.supplement
  reply.strRichMsg = ECSocialSpaceMan.BuildSpaceRichContent(reply.strPlainMsg, reply.strData)
  reply.timestamp = tonumber(replyData.createTime) / 1000
  if replyData.hasVoted then
    reply.hasVoted = replyData.hasVoted
  end
  if replyData.voteSize then
    reply.voteSize = tonumber(replyData.voteSize)
  end
  return reply
end
def.method("table", "=>", ECSpaceMsgs.ECFavorer).ParseECFavorer = function(self, data)
  local favorer = ECSpaceMsgs.ECFavorer()
  favorer.id = Int64.ParseString(data.roleId)
  favorer.name = data.roleName
  favorer.serverId = tonumber(data.serverId)
  favorer.idphoto, favorer.avatarFrameId, favorer.urlphoto = ECSpaceMsgs.ParsePhoto(data.photoId)
  return favorer
end
def.method("table").onGetNewMsgList = function(self, data)
  if not self.m_selfData then
    self.m_selfData = SpaceData()
  end
  self.m_selfData.newMsgs = {}
  if (not data or #data == 0) and #self.m_selfData.clientNewMsgs == 0 then
    return
  end
  for i = 1, #data do
    local curMsg = data[i]
    local msg = ECSpaceMsgs.ECNewMsg()
    msg.newMsgType = tonumber(curMsg.type)
    msg.roleId = Int64.ParseString(tostring(curMsg.senderId))
    msg.playerName = curMsg.senderName
    msg.strPlainMsg = self:FilterSensitiveWords(curMsg.preface)
    if curMsg.senderPhotoId then
      msg.idphoto, msg.avatarFrameId, msg.urlphoto = ECSpaceMsgs.ParsePhoto(curMsg.senderPhotoId)
    end
    msg.strData = curMsg.supplement
    msg.timestamp = math.floor(curMsg.sendTime / 1000)
    msg.msgID = Int64.ParseString(curMsg.momentId)
    msg.replyId = Int64.ParseString(curMsg.replyId)
    msg.leaveMsgId = Int64.ParseString(curMsg.messageId)
    msg.sourceType = tonumber(curMsg.sourceType) or 0
    msg.sourceContent = curMsg.sourceContent or ""
    msg.sourceSupplement = curMsg.sourceSupplement or ""
    msg = ECSocialSpaceMan.BuildNewMsgContent(msg)
    table.insert(self.m_selfData.newMsgs, msg)
  end
  local sortByTimestamp = function(left, right)
    return left.timestamp > right.timestamp
  end
  table.sort(self.m_selfData.newMsgs, sortByTimestamp)
  local NewMsgList = self:MergeNewMsgSort(self.m_selfData.newMsgs, self.m_selfData.clientNewMsgs)
  self.m_selfData.newMsgs = {}
  self.m_selfData.clientNewMsgs = {}
  for i = 1, #NewMsgList do
    table.insert(self.m_selfData.newMsgs, NewMsgList[i])
  end
  self.m_unreadCount = self.m_unreadCount - #data - #self.m_selfData.clientNewMsgs
  if #self.m_selfData.newMsgs > ECSocialSpaceConfig.getNewMsgMaxSaveCount() then
    for i = #self.m_selfData.newMsgs, ECSocialSpaceConfig.getNewMsgMaxSaveCount(), -1 do
      table.remove(self.m_selfData.newMsgs, i)
    end
  end
  Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.SpaceNewMsg, {
    self.m_unreadCount
  })
end
def.method("table", "table", "=>", "table").MergeNewMsgSort = function(self, curList, clientList)
  local RetList = {}
  local i, j, idx = 1, 1, 1
  while i <= #curList and j <= #clientList do
    if curList[i].timestamp > clientList[j].timestamp then
      RetList[idx] = curList[i]
      i = i + 1
    else
      RetList[idx] = clientList[j]
      j = j + 1
    end
    idx = idx + 1
  end
  for k = i, #curList do
    RetList[idx] = curList[k]
    idx = idx + 1
  end
  for k = j, #clientList do
    RetList[idx] = clientList[k]
    idx = idx + 1
  end
  return RetList
end
def.method("table").onGetGiftHistory = function(self, data)
  if not data or #data == 0 then
    return
  end
  local roleId = Int64.ParseString(data[1].targetId)
  local spaceData = self:GetSpaceData(roleId)
  if not spaceData then
    warn("get GiftHistory without player cache")
    return
  end
  spaceData.getGiftHistory = {}
  local len = #data < ECSocialSpaceConfig.getGiftHistoryMaxSaveCount() and #data or ECSocialSpaceConfig.getGiftHistoryMaxSaveCount()
  for i = 1, len do
    local curGift = data[i]
    local msg = ECSpaceMsgs.ECGetGiftHistory()
    if tonumber(curGift.status) == 1 then
      msg.roleId = Zero_Int64
      msg.playerName = textRes.SocialSpace[106]
      msg.idphoto = 0
      msg.urlphoto = ""
      msg.level = tonumber(curGift.giverLevel)
    else
      msg.roleId = Int64.ParseString(curGift.giverId)
      msg.playerName = curGift.giverName
      msg.idphoto, msg.avatarFrameId, msg.urlphoto = ECSpaceMsgs.ParsePhoto(curGift.giverPhotoId)
      msg.level = tonumber(curGift.giverLevel)
    end
    msg.receiverId = Int64.ParseString(curGift.targetId)
    msg.giftId = tonumber(curGift.giftId)
    msg.giftCount = tonumber(curGift.giftCount)
    msg.content = SocialSpaceUtils.BuildSpaceRichContent(curGift.message, "")
    msg.timestamp = tonumber(curGift.createTime / 1000)
    table.insert(spaceData.getGiftHistory, msg)
  end
  if self:ShowLog() then
    print("GiftHistory:", #spaceData.getGiftHistory)
    local malut = require("Utility.malut")
    malut.printTable(spaceData.getGiftHistory)
  end
end
def.method("table").onGetGuestHistory = function(self, data)
  if not data or #data == 0 then
    return
  end
  local roleId = Int64.ParseString(data[1].ownerId)
  local spaceData = self:GetSpaceData(roleId)
  if not spaceData then
    warn("get GuestHistory without player cache")
    return
  end
  spaceData.guestHistory = {}
  local len = #data < ECSocialSpaceConfig.getGuestHistoryMaxSaveCount() and #data or ECSocialSpaceConfig.getGuestHistoryMaxSaveCount()
  for i = 1, len do
    local curHis = data[i]
    local msg = ECSpaceMsgs.ECSpaceHistory()
    msg.roleId = Int64.ParseString(curHis.stepperId)
    msg.serverId = tonumber(curHis.stepperServerId)
    msg.playerName = curHis.stepperName
    msg.hostId = Int64.ParseString(curHis.ownerId)
    msg.idphoto, msg.avatarFrameId, msg.urlphoto = ECSpaceMsgs.ParsePhoto(curHis.stepperPhotoId)
    msg.level = tonumber(curHis.stepperLevel)
    msg.historyType = tonumber(curHis.getGiftCount) == 0 and 1 or 2
    table.insert(spaceData.guestHistory, msg)
  end
end
def.method("table").OnGetForbiddenInfo = function(self, data)
  local hostRoleId = self:GetHostRoleId()
  if Int64.ParseString(data.roleId) == hostRoleId then
    self.m_forbidenSpeakEndTime = tonumber(data.forbidTime / 1000)
    local reason = tostring(data.forbidReason)
    if reason == nil or reason == "" then
      reason = textRes.SocialSpace[57]
    end
    self.m_forbidenReason = textRes.SocialSpace[49]:format(reason)
  end
end
def.method("=>", "boolean").CheckIsForbiddenSpeak = function(self)
  local curTime = _G.GetServerTime()
  if curTime < self.m_forbidenSpeakEndTime then
    Toast(self.m_forbidenReason)
    return true
  end
  return false
end
def.method("userdata", "varlist", "=>", "boolean").CheckIsRoleInBlacklist = function(self, roleId, toastContent)
  if self.m_blacklistRoles == nil then
    return false
  end
  local strRoleId = tostring(roleId)
  local roleInfo = self.m_blacklistRoles[strRoleId]
  if roleInfo == nil then
    return false
  end
  if bit.band(roleInfo.status, ECSpaceMsgs.BlacklistStatus.ACTIVE) ~= 0 then
    if toastContent == nil then
      toastContent = textRes.SocialSpace[97]
    end
    if toastContent ~= "" then
      Toast(toastContent)
    end
    return true
  end
  return false
end
def.method("table", "table").ParseLocation = function(self, baseInfo, ownerInfo)
  if ownerInfo.location then
    local jsonData = json.decode(ownerInfo.location) or {}
    local province = tonumber(jsonData.province) or 0
    local city = tonumber(jsonData.city) or 0
    baseInfo.location = require("netio.protocol.mzm.gsp.personal.Location").new(province, city)
  else
    baseInfo.location = nil
  end
end
def.method("userdata", "boolean", "function", "boolean").Req_GetTargetPlayerStatus = function(self, roleId, bRefreshNew, callback, bCheckCoolTime)
  local params = {}
  params.ownerGameId = _G.ZL_GAMEID
  params.ownerServerId = self:GetRoleServerId(roleId)
  params.ownerId = tostring(roleId)
  if bRefreshNew then
    params.momentId = 0
  else
    local spaceData = self:GetSpaceData(roleId)
    if not spaceData then
      warn("No spaceData")
      return
    end
    params.momentId = 0 < #spaceData.msgs and spaceData.msgs[#spaceData.msgs].ID or 0
  end
  self:RequestData(REQUEST_TYPE.GET_PLAYER_STATUS, params, callback, bCheckCoolTime)
end
def.method("boolean", "function", "boolean").Req_GetSelfFriendsStatus = function(self, bRefreshNew, callback, bCheckCoolTime)
  local hostRoleId = self:GetHostRoleId()
  local params = {}
  params.ownerGameId = _G.ZL_GAMEID
  params.ownerServerId = self:GetHostServerId()
  params.ownerId = tostring(hostRoleId)
  params.ownerUserId = self:GetHostUserId()
  if bRefreshNew then
    params.momentId = 0
  else
    local spaceData = self.m_selfData
    if not spaceData then
      warn("No spaceData")
      return
    end
    params.momentId = 0 < #spaceData.msgs and spaceData.msgs[#spaceData.msgs].ID or 0
  end
  self:RequestData(REQUEST_TYPE.GET_FRIENDS_NEW_STATUS, params, callback, bCheckCoolTime)
end
def.method("boolean", "function", "boolean").Req_GetHotStatus = function(self, bRefreshNew, callback, bCheckCoolTime)
  local commonSpaceData = self.m_commonSpaceData
  if not commonSpaceData then
    warn("No commonSpaceData")
    return
  end
  local params = {}
  if bRefreshNew then
    params.momentId = 0
    commonSpaceData.hotMsgs = {}
  else
    params.momentId = 0 < #commonSpaceData.hotMsgs and commonSpaceData.hotMsgs[#commonSpaceData.hotMsgs].ID or 0
  end
  self:RequestData(REQUEST_TYPE.GET_HOT_STATUS, params, callback, bCheckCoolTime)
end
def.method("boolean", "function", "boolean").Req_GetHeadlineStatus = function(self, bRefreshNew, callback, bCheckCoolTime)
  local commonSpaceData = self.m_commonSpaceData
  if not commonSpaceData then
    warn("No commonSpaceData")
    return
  end
  local params = {}
  if bRefreshNew then
    commonSpaceData.headlineMsgs = {}
    params.momentId = 0
  else
    params.momentId = #commonSpaceData.headlineMsgs > 0 and commonSpaceData.headlineMsgs[#commonSpaceData.headlineMsgs].ID or 0
  end
  self:RequestData(REQUEST_TYPE.GET_HEADLINE_STATUS, params, callback, bCheckCoolTime)
end
def.method("boolean", "function", "boolean").Req_GetTopicHotStatus = function(self, bRefreshNew, callback, bCheckCoolTime)
  local commonSpaceData = self.m_commonSpaceData
  if not commonSpaceData then
    warn("No commonSpaceData")
    return
  end
  local params = {}
  if bRefreshNew then
    commonSpaceData.topicHotMsgs = {}
    params.momentId = 0
  else
    params.momentId = #commonSpaceData.topicHotMsgs > 0 and commonSpaceData.topicHotMsgs[#commonSpaceData.topicHotMsgs].ID or 0
  end
  self:RequestData(REQUEST_TYPE.GET_TOPIC_HOST_STATUS, params, callback, bCheckCoolTime)
end
def.method("string", "function", "boolean").Req_UpdateSignature = function(self, signature, callback, bCheckCoolTime)
  local hostRoleId = self:GetHostRoleId()
  if self:CheckIsForbiddenSpeak() then
    return
  end
  local params = {}
  params.personalizedSignature = signature
  self:RequestData(REQUEST_TYPE.UPDATE_HP_SIGNATURE, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    self.m_selfData.baseInfo.signature = signature
    callback(data)
    self:OnUpdateSignatureSuccess(signature)
  end, bCheckCoolTime)
end
def.method("string").OnUpdateSignatureSuccess = function(self, signature)
  if signature:trim() == "" then
    return
  end
  local msg = ECSpaceMsgs.ECSpaceMsg()
  msg.strPlainMsg = signature
  self:Req_PublishNewStatus(msg, function(data)
    if data.retcode == 0 then
    end
  end, false)
end
def.method("string", "function", "boolean").Req_UploadPortratiPhoto = function(self, url, callback, bCheckCoolTime)
  local params = {}
  params.portraitFile = url
  self:RequestData(REQUEST_TYPE.UPLOAD_PORTRAIT_PHOTO, params, function(data)
    if not self.m_selfData then
      return
    end
    if data.retcode == 0 then
      self.m_selfData.baseInfo.urlphoto = url
    end
    if callback then
      callback(data)
    end
  end, bCheckCoolTime)
end
def.method("table", "function", "boolean").Req_UpdateSpaceSetting = function(self, updateSetting, callback, bCheckCoolTime)
  local baseInfo = self.m_selfData.baseInfo
  local params = {}
  params.remindNews = baseInfo.remindNews and 0 or 1
  params.commentSetting = updateSetting.commentSetting or baseInfo.commentType
  params.messageSetting = updateSetting.messageSetting or baseInfo.messageType
  self:RequestData(REQUEST_TYPE.UPDATE_SPACE_SETTING, params, function(data)
    if self.m_selfData == nil then
      return
    end
    if self.m_selfData.baseInfo == nil then
      return
    end
    if tonumber(data.retcode) == 0 then
      self:ParseSpaceSetting(self.m_selfData.baseInfo, params)
      callback(data)
    end
  end, bCheckCoolTime)
end
def.method(ECSpaceMsgs.ECSpaceMsg, "function", "boolean", "=>", "boolean").Req_PublishNewStatus = function(self, msg, callback, bCheckCoolTime)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_RELEASE_DYNAMIC) then
    Toast(textRes.SocialSpace[45])
    return false
  end
  if self:CheckIsForbiddenSpeak() then
    return false
  end
  msg.timestamp = _G.GetServerTime()
  local params = {}
  params.content = msg.strPlainMsg
  params.supplement = msg.strData
  params.remindList = json.encode(msg.atPlayerList)
  if msg.pics then
    for i, picUrl in ipairs(msg.pics) do
      if #picUrl > 0 then
        params["pic" .. i] = picUrl
      end
    end
  end
  if msg.topicid ~= 0 then
    params.subjectId = msg.topicid
  end
  self:RequestData(REQUEST_TYPE.PUBLISH_NEW_STATUS, params, function(data)
    if data.retcode == 0 then
      local hostRoleId = self:GetHostRoleId()
      local spaceData = self:GetSpaceData(hostRoleId)
      msg.ID = Int64.ParseString(data.momentId)
      local hp = self:GetHostPlayerInfos()
      msg.roleId = hp.roleId
      msg.serverId = hp.serverId
      msg.playerName = hp.name
      msg.idphoto = hp.avatarId
      msg.avatarFrameId = hp.avatarFrameId
      msg.strRichMsg = ECSocialSpaceMan.BuildSpaceRichContent(msg.strPlainMsg, msg.strData)
      local idx
      for i, v in ipairs(spaceData.msgs) do
        if msg.timestamp > v.timestamp then
          idx = i
          break
        end
      end
      if idx == nil then
        idx = #spaceData.msgs + 1
      end
      table.insert(spaceData.msgs, idx, msg)
      Toast(textRes.SocialSpace[65])
      Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.MsgPublished, {
        msgId = msg.ID
      })
    end
    callback(data)
  end, bCheckCoolTime)
  return true
end
def.method("function").Req_GetPicUrls = function(self, callback)
  local commonSpaceData = self.m_commonSpaceData
  if not commonSpaceData then
    warn("No commonSpaceData")
    return
  end
  local params = {}
  self:RequestData(REQUEST_TYPE.GET_PIC_URLS, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    if #data.picUrls > #commonSpaceData.picUrls then
      commonSpaceData.picUrls = data.picUrls
    end
    if callback then
      callback(data)
    end
  end, false)
end
def.method("userdata", "userdata", "number", "boolean", "function", "boolean").LoadPlayerMsgListBeforeID = function(self, roleId, ID, len, bOnlySelf, callback, bCheckCoolTime)
  self:LoadMsgListBeforeID(ECSpaceMsgs.MSG_TYPE.NORMAL, roleId, ID, len, bOnlySelf, callback, bCheckCoolTime)
end
def.method("userdata", "userdata", "number", "=>", "table").GetPlayerLeaveMsgsBeforeIDInCache = function(self, roleId, ID, len)
  local data = self:GetSpaceData(roleId)
  local t = {}
  if data and len > 0 then
    local begIdx, _ = 0, nil
    if ID ~= Zero_Int64 then
      _, begIdx = self:FindPlayerLeaveMsgByID(roleId, ID)
    end
    local msgs = data.leaveMsgs
    for i = begIdx + 1, #msgs do
      local msg = msgs[i]
      table.insert(t, msg)
      if #t == len then
        return t
      end
    end
  end
  return t
end
def.method("userdata", "userdata", "number", "function", "boolean").LoadPlayerLeaveMsgsBeforeID = function(self, roleId, ID, len, callback, bCheckCoolTime)
  print("LoadPlayerLeaveMsgsBeforeID", ID:tostring())
  if len <= 0 then
    return
  end
  local msgList = self:GetPlayerLeaveMsgsBeforeIDInCache(roleId, ID, len)
  if ID ~= Zero_Int64 and #msgList == len then
    callback(msgList)
  else
    local hp = _G.GetHeroProp()
    if not hp then
      return
    end
    self:Req_GetPlayerLeaveMsgs(roleId, ID, function(data)
      if data.retcode ~= 0 then
        return
      end
      local msgList = self:GetPlayerLeaveMsgsBeforeIDInCache(roleId, ID, len)
      callback(msgList)
    end, bCheckCoolTime)
  end
end
def.method("userdata", "userdata", "=>", ECSpaceMsgs.ECSpaceMsg, "number").FindPlayerSpaceMsgByID = function(self, roleId, ID)
  return self:FindMsgByID(ECSpaceMsgs.MSG_TYPE.NORMAL, ID, roleId)
end
def.method("userdata", "userdata", "=>", ECSpaceMsgs.ECLeaveMsg, "number").FindPlayerLeaveMsgByID = function(self, roleId, ID)
  local data = self:GetSpaceData(roleId)
  if data then
    for i = 1, #data.leaveMsgs do
      local msg = data.leaveMsgs[i]
      if msg.ID == ID then
        return msg, i
      end
    end
  end
  return nil, 0
end
def.method("number", "userdata", "userdata", "userdata", "=>", ECSpaceMsgs.ECReplyMsg, "number", "number").FindPlayerReplyMsgByID = function(self, msgType, roleId, msgID, replyId)
  local msg, msgIdx = self:FindMsgByID(msgType, msgID, roleId)
  if not msg then
    return nil, 0, 0
  end
  for i = 1, #msg.replyMsgList do
    if replyId == msg.replyMsgList[i].replyId then
      return msg.replyMsgList[i], msgIdx, i
    end
  end
  return nil, 0, 0
end
def.method("userdata", "=>", ECSpaceMsgs.ECSpaceMsg, "number").FindHeadlineMsgByID = function(self, ID)
  return self:FindMsgByID(ECSpaceMsgs.MSG_TYPE.HEADLINE, ID, Zero_Int64)
end
def.method("userdata", "number", "function", "boolean").LoadHeadlineMsgListBeforeID = function(self, ID, len, callback, bCheckCoolTime)
  self:LoadMsgListBeforeID(ECSpaceMsgs.MSG_TYPE.HEADLINE, Zero_Int64, ID, len, false, callback, bCheckCoolTime)
end
def.method("userdata", "=>", ECSpaceMsgs.ECSpaceMsg, "number").FindHotMsgByID = function(self, ID)
  return self:FindMsgByID(ECSpaceMsgs.MSG_TYPE.HOT, ID, Zero_Int64)
end
def.method("userdata", "number", "function", "boolean").LoadHotMsgListBeforeID = function(self, ID, len, callback, bCheckCoolTime)
  self:LoadMsgListBeforeID(ECSpaceMsgs.MSG_TYPE.HOT, Zero_Int64, ID, len, false, callback, bCheckCoolTime)
end
def.method("number", "userdata", "=>", "table").GetAllMsgs = function(self, msgType, roleId)
  local msgs = {}
  if msgType == ECSpaceMsgs.MSG_TYPE.NORMAL then
    local data = self:GetSpaceData(roleId)
    if data then
      msgs = data.msgs
    end
  elseif msgType == ECSpaceMsgs.MSG_TYPE.HOT then
    local data = self:GetCommonSpaceData()
    if data then
      msgs = data.hotMsgs
    end
  elseif msgType == ECSpaceMsgs.MSG_TYPE.HEADLINE then
    local data = self:GetCommonSpaceData()
    if data then
      msgs = data.headlineMsgs
    end
  elseif msgType == ECSpaceMsgs.MSG_TYPE.TOPIC_HOT then
    local data = self:GetCommonSpaceData()
    if data then
      msgs = data.topicHotMsgs
    end
  end
  return msgs
end
def.method("number", "userdata", "userdata", "=>", ECSpaceMsgs.ECSpaceMsg, "number").FindMsgByID = function(self, msgType, ID, roleId)
  local msgs = self:GetAllMsgs(msgType, roleId)
  if msgs then
    for i = 1, #msgs do
      local msg = msgs[i]
      if msg.ID == ID then
        return msg, i
      end
    end
  end
  return nil, 0
end
def.method("number", "userdata", "userdata", "number", "boolean", "function", "boolean").LoadMsgListBeforeID = function(self, msgType, roleId, ID, len, bOnlySelf, callback, bCheckCoolTime)
  if len <= 0 then
    return
  end
  if self:ShowLog() then
    print("LoadMsgListBeforeID, msgType, ID, len:", msgType, ID, len)
  end
  local bRequestNew = ID == Zero_Int64
  local msgList = self:GetMsgListBeforeIDInCache(msgType, roleId, ID, len, bOnlySelf)
  if not bRequestNew and #msgList == len then
    callback(msgList)
  else
    local function _onGetStatus(data)
      if data.retcode ~= 0 then
        return
      end
      local msgList = self:GetMsgListBeforeIDInCache(msgType, roleId, ID, len, bOnlySelf)
      if callback then
        callback(msgList)
      end
    end
    if msgType == ECSpaceMsgs.MSG_TYPE.NORMAL then
      local hp = _G.GetHeroProp()
      if not hp then
        return
      end
      if hp.id == roleId and not bOnlySelf then
        self:Req_GetSelfFriendsStatus(bRequestNew, _onGetStatus, bCheckCoolTime)
      else
        self:Req_GetTargetPlayerStatus(roleId, bRequestNew, _onGetStatus, bCheckCoolTime)
      end
    elseif msgType == ECSpaceMsgs.MSG_TYPE.HOT then
      self:Req_GetHotStatus(bRequestNew, _onGetStatus, bCheckCoolTime)
    elseif msgType == ECSpaceMsgs.MSG_TYPE.HEADLINE then
      self:Req_GetHeadlineStatus(bRequestNew, _onGetStatus, bCheckCoolTime)
    elseif msgType == ECSpaceMsgs.MSG_TYPE.TOPIC_HOT then
      self:Req_GetTopicHotStatus(bRequestNew, _onGetStatus, bCheckCoolTime)
    end
  end
end
def.method("number", "userdata", "userdata", "number", "boolean", "=>", "table").GetMsgListBeforeIDInCache = function(self, msgType, roleId, ID, len, bOnlySelf)
  local data = self.m_commonSpaceData
  local t = {}
  if data and len > 0 then
    local begIdx, _ = 0, nil
    if ID ~= Zero_Int64 then
      _, begIdx = self:FindMsgByID(msgType, ID, roleId)
    end
    local msgs = self:GetAllMsgs(msgType, roleId)
    for i = begIdx + 1, #msgs do
      if not bOnlySelf or bOnlySelf and msgs[i].roleId == roleId then
        table.insert(t, msgs[i])
      end
      if #t == len then
        return t
      end
    end
  end
  return t
end
def.method("number", "userdata", "userdata", "function", "boolean", "=>", "boolean").Req_AddFavorOnMsg = function(self, msgType, roleId, msgID, callback, bCheckCoolTime)
  local hp = self:GetHostPlayerInfos()
  local levelLimit = ECSocialSpaceConfig.getAddFavorLevelLimit()
  if levelLimit > hp.level then
    Toast(textRes.SocialSpace[52]:format(levelLimit))
    return false
  end
  if self:CheckIsForbiddenSpeak() then
    return false
  end
  local msg = self:FindMsgByID(msgType, msgID, roleId)
  if not msg then
    Toast(textRes.SocialSpace[15])
    return false
  end
  if self:CheckIsRoleInBlacklist(msg.roleId) then
    return false
  end
  local params = {}
  params.momentId = msgID
  self:RequestData(REQUEST_TYPE.ADD_FAVOR_TO_STATUS, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    local hp = self:GetHostPlayerInfos()
    if hp == nil then
      return
    end
    for i = 1, #msg.favorList do
      if msg.favorList[i].id == hp.roleId then
        return
      end
    end
    msg.voteSize = msg.voteSize + 1
    msg.hasVoted = true
    local favorer = ECSpaceMsgs.ECFavorer()
    favorer.id = hp.roleId
    favorer.name = hp.name
    favorer.serverId = hp.serverId
    favorer.idphoto = hp.avatarId
    favorer.avatarFrameId = hp.avatarFrameId
    favorer.urlphoto = ""
    table.insert(msg.favorList, 1, favorer)
    callback(data)
  end, bCheckCoolTime)
  return true
end
def.method("number", "userdata", "userdata", "function", "boolean").Req_CancelFavorOnMsg = function(self, msgType, roleId, msgID, callback, bCheckCoolTime)
  if self:CheckIsForbiddenSpeak() then
    return
  end
  local msg = self:FindMsgByID(msgType, msgID, roleId)
  if not msg then
    Toast(textRes.SocialSpace[15])
    return
  end
  if self:CheckIsRoleInBlacklist(msg.roleId) then
    return
  end
  local params = {}
  params.momentId = msgID
  self:RequestData(REQUEST_TYPE.CANCEL_FAVOR_TO_STATUS, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    local hostRoleId = self:GetHostRoleId()
    for i = 1, #msg.favorList do
      if msg.favorList[i].id == hostRoleId then
        table.remove(msg.favorList, i)
        break
      end
    end
    msg.voteSize = msg.voteSize - 1
    if 0 > msg.voteSize then
      msg.voteSize = 0
    end
    msg.hasVoted = false
    callback(data)
  end, bCheckCoolTime)
end
def.method("number", "userdata", "userdata", "userdata", "function", "boolean").Req_AddFavorOnReply = function(self, msgType, roleId, msgID, replyId, callback, bCheckCoolTime)
  if self:CheckIsForbiddenSpeak() then
    return
  end
  local replyMsg, msgIdx, replyIdx = self:FindPlayerReplyMsgByID(msgType, Zero_Int64, msgID, replyId)
  if not replyMsg then
    Toast(textRes.SocialSpace[15])
    return
  end
  local params = {}
  params.momentId = msgID
  params.replyId = replyId
  self:RequestData(REQUEST_TYPE.ADD_FAVOR_TO_REPLY, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    replyMsg.hasVoted = true
    replyMsg.voteSize = replyMsg.voteSize + 1
    callback(data)
  end, bCheckCoolTime)
end
def.method("number", "userdata", "userdata", "userdata", "function", "boolean").Req_CancelFavorOnReply = function(self, msgType, roleId, msgID, replyId, callback, bCheckCoolTime)
  if self:CheckIsForbiddenSpeak() then
    return
  end
  local replyMsg, msgIdx, replyIdx = self:FindPlayerReplyMsgByID(msgType, Zero_Int64, msgID, replyId)
  if not replyMsg then
    Toast(textRes.SocialSpace[15])
    return
  end
  local params = {}
  params.momentId = msgID
  params.replyId = replyId
  self:RequestData(REQUEST_TYPE.CANCEL_FAVOR_TO_REPLY, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    replyMsg.hasVoted = false
    replyMsg.voteSize = replyMsg.voteSize - 1
    if 0 > replyMsg.voteSize then
      replyMsg.voteSize = 0
    end
    callback(data)
  end, bCheckCoolTime)
end
def.method("number", "userdata", ECSpaceMsgs.ECReplyMsg, "userdata", "function", "boolean", "=>", "boolean").Req_AddReplyOnMsg = function(self, msgType, roleId, replyMsg, msgID, callback, bCheckCoolTime)
  local hp = self:GetHostPlayerInfos()
  local levelLimit = ECSocialSpaceConfig.getReplyLevelLimit()
  if levelLimit > hp.level then
    Toast(textRes.SocialSpace[53]:format(levelLimit))
    return false
  end
  local msg = self:FindMsgByID(msgType, msgID, roleId)
  if not msg then
    Toast(textRes.SocialSpace[15])
    return false
  end
  if self:CheckIsRoleInBlacklist(msg.roleId) then
    return false
  end
  if replyMsg.replyRoleId ~= Zero_Int64 and self:CheckIsRoleInBlacklist(replyMsg.replyRoleId) then
    return false
  end
  local params = {}
  params.momentId = msgID
  params.remindList = json.encode(replyMsg.atPlayerList)
  params.content = replyMsg.strPlainMsg
  params.supplement = replyMsg.strData
  params.replyId = replyMsg.replyId == Zero_Int64 and 0 or replyMsg.replyId
  self:RequestData(REQUEST_TYPE.REPLY_STATUS, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    local msg, Idx = self:FindMsgByID(msgType, msgID, roleId)
    replyMsg.replyId = Int64.ParseString(data.replyId)
    msg.replySize = msg.replySize + 1
    table.insert(msg.replyMsgList, 1, replyMsg)
    callback(data)
  end, bCheckCoolTime)
  return true
end
def.method("userdata", "userdata", "function", "boolean").Req_DeleteSpaceMsg = function(self, roleId, msgID, callback, bCheckCoolTime)
  local msg = self:FindPlayerSpaceMsgByID(roleId, msgID)
  if not msg then
    Toast(textRes.SocialSpace[15])
    return
  end
  local params = {}
  params.momentId = msgID:tostring()
  self:RequestData(REQUEST_TYPE.DEL_STATUS, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    local spaceData = self:GetSpaceData(roleId)
    local _, Idx = self:FindPlayerSpaceMsgByID(roleId, msgID)
    table.remove(spaceData.msgs, Idx)
    callback(data)
  end, bCheckCoolTime)
end
def.method("number", "userdata", "userdata", "userdata", "function", "boolean").Req_DeleteReplyMsg = function(self, msgType, roleId, msgID, replyId, callback, bCheckCoolTime)
  local msg = self:FindPlayerReplyMsgByID(msgType, roleId, msgID, replyId)
  if not msg then
    Toast(textRes.SocialSpace[15])
    return
  end
  local params = {}
  params.momentId = msgID
  params.replyId = replyId
  self:RequestData(REQUEST_TYPE.DEL_REPLY_MSG, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    local msgs = self:GetAllMsgs(msgType, roleId)
    local msg, msgIdx, replyIdx = self:FindPlayerReplyMsgByID(msgType, roleId, msgID, replyId)
    msgs[msgIdx].replySize = msgs[msgIdx].replySize - 1
    if 0 > msgs[msgIdx].replySize then
      msgs[msgIdx].replySize = 0
    end
    table.remove(msgs[msgIdx].replyMsgList, replyIdx)
    callback(data)
  end, bCheckCoolTime)
end
def.method("userdata", "userdata", "function", "boolean").Req_GetPlayerLeaveMsgs = function(self, roleId, msgID, callback, bCheckCoolTime)
  local params = {}
  params.ownerGameId = _G.ZL_GAMEID
  params.ownerServerId = self:GetRoleServerId(roleId)
  params.ownerId = tostring(roleId)
  params.messageId = msgID == Zero_Int64 and 0 or msgID
  self:RequestData(REQUEST_TYPE.GET_PLAYER_LEAVE_MSG, params, callback, bCheckCoolTime)
end
def.method(ECSpaceMsgs.ECLeaveMsg, "function", "boolean", "=>", "boolean").Req_LeaveMsgToPlayer = function(self, msg, callback, bCheckCoolTime)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_MESSAGE_BOARD) then
    Toast(textRes.SocialSpace[45])
    return false
  end
  local levelLimit = ECSocialSpaceConfig.getLeaveMsgLevelLimit()
  local hp = self:GetHostPlayerInfos()
  if hp and levelLimit > hp.level then
    Toast(textRes.SocialSpace[54]:format(levelLimit))
    return false
  end
  if self:CheckIsForbiddenSpeak() then
    return false
  end
  if self:CheckIsRoleInBlacklist(msg.targetId) then
    return false
  end
  if msg.replyRoleId ~= Zero_Int64 and self:CheckIsRoleInBlacklist(msg.replyRoleId) then
    return false
  end
  local params = {}
  params.ownerGameId = _G.ZL_GAMEID
  params.ownerServerId = self:GetRoleServerId(msg.targetId)
  params.ownerId = tostring(msg.targetId)
  params.messageId = msgID == Zero_Int64 and 0 or msgID
  if msg.replyRoleId ~= Zero_Int64 then
    params.targetGameId = _G.ZL_GAMEID
    params.targetServerId = self:GetRoleServerId(msg.replyRoleId)
    params.targetId = tostring(msg.replyRoleId)
  end
  params.content = msg.strPlainMsg
  params.supplement = msg.strData
  params.remindList = json.encode(msg.atPlayerList)
  self:RequestData(REQUEST_TYPE.DO_LEAVE_MSG, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    local spaceData = self:GetSpaceData(msg.targetId)
    warn(spaceData, "SpaceData", tostring(msg.targetId))
    msg.ID = Int64.ParseString(data.messageId)
    local idx
    for i, v in ipairs(spaceData.leaveMsgs) do
      if msg.timestamp > v.timestamp then
        idx = i
        break
      end
    end
    if idx == nil then
      idx = #spaceData.leaveMsgs + 1
    end
    table.insert(spaceData.leaveMsgs, idx, msg)
    callback(data)
  end, bCheckCoolTime)
  return true
end
def.method("userdata", "userdata", "function", "boolean").Req_DeleteLeaveMsg = function(self, roleId, leaveMsgID, callback, bCheckCoolTime)
  local msg = self:FindPlayerLeaveMsgByID(roleId, leaveMsgID)
  if not msg then
    Toast(textRes.SocialSpace[15])
    return
  end
  local params = {}
  params.messageId = leaveMsgID
  self:RequestData(REQUEST_TYPE.DEL_LEAVE_MSG, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    local data = self:GetSpaceData(roleId)
    local _, Idx = self:FindPlayerLeaveMsgByID(roleId, leaveMsgID)
    table.remove(data.leaveMsgs, Idx)
    callback(data)
  end, bCheckCoolTime)
end
def.method("userdata", "function", "boolean").Req_GetGiftRecords = function(self, roleId, callback, bCheckCoolTime)
  local params = {}
  params.startTime = 0
  params.endTime = (_G.GetServerTime() + 1) * 1000
  params.ownerGameId = _G.ZL_GAMEID
  params.ownerServerId = self:GetRoleServerId(roleId)
  params.ownerId = tostring(roleId)
  self:RequestData(REQUEST_TYPE.GET_GIFT_RECORDS, params, callback, bCheckCoolTime)
end
def.method("userdata", "function", "boolean").Req_PutGiftRecords = function(self, roleId, callback, bCheckCoolTime)
  local params = {}
  params.startTime = 0
  params.endTime = (_G.GetServerTime() + 1) * 1000
  params.ownerGameId = _G.ZL_GAMEID
  params.ownerServerId = self:GetRoleServerId(roleId)
  params.ownerId = tostring(roleId)
  self:RequestData(REQUEST_TYPE.PUT_GIFT_RECORDS, params, callback, bCheckCoolTime)
end
def.method("userdata", "function", "boolean").Req_GetSpacePopularRecords = function(self, roleId, callback, bCheckCoolTime)
  local params = {}
  params.startTime = 0
  params.endTime = (_G.GetServerTime() + 1) * 1000
  params.ownerGameId = _G.ZL_GAMEID
  params.ownerServerId = self:GetRoleServerId(roleId)
  params.ownerId = tostring(roleId)
  self:RequestData(REQUEST_TYPE.GET_SPACE_POPULAR_RECORDS, params, callback, bCheckCoolTime)
end
def.method("function", "boolean").Req_GetHostPlayerNewMsgs = function(self, callback, bCheckCoolTime)
  self:RequestData(REQUEST_TYPE.GET_HP_NEW_MSG, {}, callback, bCheckCoolTime)
end
def.method().Req_GetHostPlayerNewMsgCount = function(self)
  self:RequestData(REQUEST_TYPE.GET_HP_NEW_MSG_COUNT, {}, function(data)
    if data.retcode ~= 0 then
      return
    end
    local count = tonumber(data.newsSize)
    if count then
      self.m_unreadCount = count
      Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.SpaceNewMsg, {
        self.m_unreadCount
      })
    end
  end, false)
end
def.method("number", "number", "string", "boolean").Req_Report = function(self, reporttype, spacereporttype, spacereportparam, bCheckCoolTime)
  local params = {}
  params.targetGameId = _G.ZL_GAMEID
  params.illegalType = reporttype
  params.targetType = spacereporttype
  params.target = spacereportparam
  self:RequestData(REQUEST_TYPE.REPORT, params, function(data)
    if tonumber(data.retcode) == 0 then
      FlashTipMan.FlashTip(StringTable.Get(15222))
    end
  end, bCheckCoolTime)
end
def.method().Req_DetectNewStatus = function(self)
  TODO("Req_DetectNewStatus")
  do return end
  local bWatch = UserData.Instance():GetRoleCfg("WatchSpaceHeadline1")
  if bWatch == nil then
    bWatch = true
  end
  if not bWatch then
    return
  end
  if not self.m_commonSpaceData then
    warn("Req_DetectNewStatus commonSpaceData is nil")
    return
  end
  TODO("Req_DetectNewStatus")
  local hotMomentId = 0
  local headMomentId = UserData.Instance():GetRoleCfg("SpaceHeadlineMsgId") or 0
  local subjectId = 0
  local hotSubjectMomentId = 0
  local params = {}
  self:RequestData(REQUEST_TYPE.DETECT_NEW_STATUS, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    if not self.m_selfData then
      return
    end
    if data.headMomentId ~= headMomentId then
      UserData.Instance():SetRoleCfg("SpaceHeadlineMsgId", data.headMomentId)
      local msg = ECSpaceMsgs.ECNewMsg()
      msg.newMsgType = ECSpaceMsgs.NEW_MSG_TYPE.HAS_NEW_HEADLINE
      msg.timestamp = _G.GetServerTime()
      msg = ECSocialSpaceMan.BuildNewMsgContent(msg)
      self.m_unreadCount = self.m_unreadCount + 1
      table.insert(self.m_selfData.clientNewMsgs, 1, msg)
    end
    local msg = SocialSpaceNewMsg.new(self.m_unreadCount)
    ECGame.EventManager:raiseEvent(nil, msg)
  end, false)
end
def.method("number", "userdata", "userdata", "function", "boolean").Req_GetStatusReplyList = function(self, msgType, roleId, msgID, callback, bCheckCoolTime)
  local msg = self:FindMsgByID(msgType, msgID, roleId)
  if not msg then
    Toast(textRes.SocialSpace[36])
    return
  end
  local function sortByTimestamp(left, right)
    if msgType == ECSpaceMsgs.MSG_TYPE.HEADLINE then
      return left.voteSize > right.voteSize
    end
    return left.timestamp > right.timestamp
  end
  local params = {}
  params.momentId = msgID
  self:RequestData(REQUEST_TYPE.GET_STATUS_REPLY_LIST, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    msg.replyMsgList = {}
    data.replyList = data.replyList or {}
    for j = 1, #data.replyList do
      local replyData = data.replyList[j]
      local reply = self:ParseECReplyMsg(replyData)
      table.insert(msg.replyMsgList, reply)
    end
    msg.replySize = #msg.replyMsgList
    table.sort(msg.replyMsgList, sortByTimestamp)
    if callback then
      callback(msg)
    end
  end, bCheckCoolTime)
end
def.method("number", "userdata", "userdata", "function", "boolean").Req_GetStatusFavorList = function(self, msgType, roleId, msgID, callback, bCheckCoolTime)
  local msg = self:FindMsgByID(msgType, msgID, roleId)
  if not msg then
    Toast(textRes.SocialSpace[15])
    return
  end
  local params = {}
  params.momentId = msgID
  self:RequestData(REQUEST_TYPE.GET_STATUS_FAVOR_LIST, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    msg.favorList = {}
    for j = 1, #data.voteRecordList do
      local data = data.voteRecordList[j]
      local favorer = self:ParseECFavorer(data)
      table.insert(msg.favorList, favorer)
    end
    msg.voteSize = #msg.favorList
    if callback then
      callback(msg)
    end
  end, bCheckCoolTime)
end
def.method("userdata", "function", "boolean").Req_GetStatusInfo = function(self, msgID, callback, bCheckCoolTime)
  if msgID == Zero_Int64 then
    return
  end
  local params = {}
  params.momentId = msgID
  self:RequestData(REQUEST_TYPE.GET_STATUS_INFO, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    local momentList = {}
    table.insert(momentList, data.moment)
    self:onGetMomentList(momentList, data.roleId)
    if callback then
      callback(data)
    end
  end, bCheckCoolTime)
end
def.method("userdata", "function", "boolean").Req_GetFriends = function(self, targetId, callback, bCheckCoolTime)
  if msgID == Zero_Int64 then
    return
  end
  local params = {}
  params.targetGameId = ZL_GAMEID
  params.targetId = targetId
  self:RequestData(REQUEST_TYPE.GET_FRIENDS, params, function(data)
  end, bCheckCoolTime)
end
def.method("userdata", "function", "boolean").Req_GetBlacklist = function(self, targetId, callback, bCheckCoolTime)
  if msgID == Zero_Int64 then
    return
  end
  local params = {}
  params.targetGameId = ZL_GAMEID
  params.targetId = targetId
  self:RequestData(REQUEST_TYPE.GET_BLACKLIST, params, function(data)
    if data.retcode == 0 then
      local hostRoleId = self:GetHostRoleId()
      if targetId == hostRoleId then
        self:onGetBlacklist(data.blacklist)
      end
    end
    if callback then
      callback(data)
    end
  end, bCheckCoolTime)
end
def.method("string", "function").Req_GetUploadFileSign = function(self, remotePath, callback)
  local params = {}
  params.filePath = remotePath
  self:RequestData(REQUEST_TYPE.GET_UPLOAD_FILE_SIGN, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    if callback then
      callback(data.sign)
    end
  end, false)
end
def.method("function").Req_GetTopic = function(self, callback)
  local params = {}
  self:RequestData(REQUEST_TYPE.GET_TOPIC, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    if not self.m_commonSpaceData then
      warn("commonSpaceData is nil")
      return
    end
    local topic = {}
    topic.id = tonumber(data.subject.subjectId)
    topic.name = data.subject.content1
    topic.picurl = data.subject.pic1
    self.m_commonSpaceData.topic = topic
    if callback then
      callback(data)
    end
  end, false)
end
def.method("userdata", "function", "boolean").Req_GetLeaveMsgInfo = function(self, leaveMsgId, callback, bCheckCoolTime)
  local params = {}
  params.messageId = leaveMsgId
  self:RequestData(REQUEST_TYPE.GET_LEAVE_MSG_INFO, params, function(data)
    if data.retcode ~= 0 then
      return
    end
    if callback then
      callback(data)
    end
  end, bCheckCoolTime)
end
def.method("function").Req_GetCosConfig = function(self, callback)
  local request = self:CreateRequest(REQUEST_TYPE.GET_COS_CONFIG)
  request:SendRequest({}, function(data)
    if data.retcode == 0 then
      if callback then
        callback(data.config)
      end
    elseif callback then
      callback(nil)
    end
  end)
end
def.method("userdata", "function", "boolean").Req_GetFocusList = function(self, roleId, callback, bCheckCoolTime)
  local params = {}
  params.targetGameId = _G.ZL_GAMEID
  params.targetId = roleId
  self:RequestData(REQUEST_TYPE.GET_FOCUS_LIST, params, function(data)
    local focusList
    if data.retcode ~= 0 then
      _G.SafeCallback(callback, focusList)
      return
    end
    focusList = {}
    for i, v in ipairs(data.friendList) do
      local focusRoleInfo = ECSpaceMsgs.ECFocusRoleInfo()
      focusRoleInfo.roleId = Int64.ParseString(v.friendRoleId)
      focusRoleInfo.status = v.status
      focusRoleInfo.createTime = tonumber(v.createTime) / 1000
      focusRoleInfo.lastUpdateTime = tonumber(v.lastUpdateTime) / 1000
      table.insert(focusList, focusRoleInfo)
    end
    _G.SafeCallback(callback, focusList)
  end, bCheckCoolTime)
end
def.method("userdata", "function").Req_AddFocus = function(self, roleId, callback)
  local params = {}
  params.targetGameId = _G.ZL_GAMEID
  params.targetId = roleId
  self:RequestData(REQUEST_TYPE.ADD_FOCUS, params, callback, false)
end
def.method("userdata", "function").Req_DelFocus = function(self, roleId, callback)
  local params = {}
  params.targetGameId = _G.ZL_GAMEID
  params.targetId = roleId
  self:RequestData(REQUEST_TYPE.DEL_FOCUS, params, callback, false)
end
def.method("userdata", "function").Req_GetRoleProfile = function(self, roleId, callback)
  local params = {}
  params.targetGameId = _G.ZL_GAMEID
  params.targetId = roleId
  self:RequestData(REQUEST_TYPE.GET_ROLE_PROFILE, params, callback, false)
end
def.method("userdata").DoGetDecorateData = function(self, roleId)
  local gp_social_space_op = net_common.gp_social_space_op
  local msg = gp_social_space_op()
  msg.op = net_common.SS_OP_STYLE_GET
  msg.content.target = roleId
  pb_helper.Send(msg)
end
def.method("userdata", "=>", "boolean").DoAddSpacePopular = function(self, roleId)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_TREAD_CIRCLE) then
    Toast(textRes.SocialSpace[45])
    return false
  end
  local levelLimit = ECSocialSpaceConfig.getAddPopularLevelLimit()
  local hp = self:GetHostPlayerInfos()
  if hp and levelLimit > hp.level then
    Toast(textRes.SocialSpace[31]:format(levelLimit))
    return false
  end
  if self:CheckIsRoleInBlacklist(roleId) then
    return false
  end
  local serverId = self:GetRoleServerId(roleId)
  SocialSpaceProtocol.CTreadFriendsCircle(roleId, serverId)
  return true
end
def.method("userdata", "=>", "boolean").TryAddSpacePopular = function(self, roleId)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_TREAD_CIRCLE) then
    return false
  end
  if not _G.IsFeatureOpen(Feature.TYPE_AUTO_TREAD) then
    return false
  end
  local levelLimit = ECSocialSpaceConfig.getAddPopularLevelLimit()
  local hp = self:GetHostPlayerInfos()
  if hp and levelLimit > hp.level then
    return false
  end
  if self:CheckIsRoleInBlacklist(roleId, "") then
    return false
  end
  if self:IsTodayTreadedRole(roleId) then
    return false
  end
  SocialSpaceProtocol.CFriendsCircleTryTread(roleId)
  return true
end
def.method("userdata", "=>", "boolean").IsTodayTreadedRole = function(self, roleId)
  local key = ECSocialSpaceMan.TREAD_ROLE_KEY_PREFIX .. tostring(roleId)
  if not LuaPlayerPrefs.HasRoleKey(key) then
    return false
  end
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local treadTime = LuaPlayerPrefs.GetRoleNumber(key)
  local curTime = _G.GetServerTime()
  local tt = AbsoluteTimer.GetServerTimeTable(treadTime)
  local ct = AbsoluteTimer.GetServerTimeTable(curTime)
  if ct.yday ~= tt.yday or ct.year ~= tt.year then
    return false
  end
  return true
end
def.method("table").onAddSpacePopularSuccess = function(self, p)
  local TRIGGER_BOX = 1
  local popAddValue = p.add_popularity_total_value
  if popAddValue > 0 then
    Toast(textRes.SocialSpace[32]:format(popAddValue))
  else
    Toast(textRes.SocialSpace[56])
  end
  local isTriggerBox = p.is_trigger_box == TRIGGER_BOX
  if isTriggerBox then
    Toast(textRes.SocialSpace[33])
  end
  local roleId = p.be_trod_role_id
  local key = ECSocialSpaceMan.TREAD_ROLE_KEY_PREFIX .. tostring(roleId)
  local curTime = _G.GetServerTime()
  LuaPlayerPrefs.SetRoleNumber(key, curTime)
  LuaPlayerPrefs.Save()
  local spaceData = self:GetSpaceData(roleId)
  if not spaceData then
    return
  end
  local baseInfo = spaceData.baseInfo
  if baseInfo == nil then
    return
  end
  if isTriggerBox then
    baseInfo.giftCount = math.max(0, baseInfo.giftCount - 1)
  end
  baseInfo.thisWeekPopular = p.popularity_week_value
  baseInfo.totalPopular = p.popularity_total_value
  Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.PopularChanged, {roleId})
end
def.method("table").SendGift = function(self, social_space_content)
  local gp_social_space_op = net_common.gp_social_space_op
  local msg = gp_social_space_op()
  msg.op = net_common.SS_OP_GIVE_GIFT
  for k, v in pairs(social_space_content) do
    msg.content[k] = v
  end
  pb_helper.Send(msg)
end
def.method("number", "number").PlaceGift = function(self, putCount, totalCost)
  local gp_social_space_op = net_common.gp_social_space_op
  local msg = gp_social_space_op()
  msg.op = net_common.SS_OP_PLACE_GIFT
  msg.content.place_gift_count = putCount
  msg.content.money_cost = totalCost
  pb_helper.Send(msg)
end
def.method("=>", "table").GetSavedDecorateData = function(self)
  return self.m_savedDecorateData or {}
end
def.method("=>", "table").GetDecorateDatas = function(self)
  return self.m_decorateDatas or {}
end
def.method("number", "number", "number").AddDecoration = function(self, type, id, expire_time)
  if not self.m_decorateDatas then
    self.m_decorateDatas = {}
  end
  if not self.m_decorateDatas[type] then
    self.m_decorateDatas[type] = {}
  end
  self.m_decorateDatas[type][id] = expire_time
end
def.method("number", "number").RemoveDecoration = function(self, type, id)
  if not self.m_decorateDatas then
    return
  end
  if not self.m_decorateDatas[type] then
    return
  end
  self.m_decorateDatas[type][id] = nil
end
def.method("number", "number", "=>", "boolean").HasDecoration = function(self, type, id)
  if not self.m_decorateDatas then
    return false
  end
  if not self.m_decorateDatas[type] then
    return false
  end
  return self.m_decorateDatas[type][id] ~= nil
end
def.method("table").onGetSocialSpaceData = function(self, p)
  local expire_time = -1
  self.m_decorateDatas = {}
  for id, v in pairs(p.own_pendant_item_cfg_id_set) do
    self:AddDecoration(DecoType.TYPE_PENDANT_ORNAMENT, id, expire_time)
  end
  for id, v in pairs(p.own_rahmen_item_cfg_id_set) do
    self:AddDecoration(DecoType.TYPE_RAHMEN_ORNAMENT, id, expire_time)
  end
  local savedData = {}
  savedData[DecoType.TYPE_PENDANT_ORNAMENT] = p.current_pendant_item_cfg_id
  savedData[DecoType.TYPE_RAHMEN_ORNAMENT] = p.current_rahmen_item_cfg_id
  for decoType, v in pairs(savedData) do
    local itemId = v
    if itemId == 0 then
      local decoTypeDisplayCfg = SocialSpaceUtils.GetDecorationTypeDisplayCfg(decoType)
      if decoTypeDisplayCfg then
        itemId = decoTypeDisplayCfg.defaultItemId
        savedData[decoType] = itemId
      end
    end
    if itemId ~= 0 then
      self.m_decorateDatas[decoType] = self.m_decorateDatas[decoType] or {}
      self.m_decorateDatas[decoType][itemId] = expire_time
    end
  end
  self.m_savedDecorateData = savedData
  if p.my_black_role_set then
    self.m_blacklistRoles = {}
    for roleId, v in pairs(p.my_black_role_set) do
      if self.m_blacklistRoles[tostring(roleId)] == nil then
        local roleInfo = ECSpaceMsgs.ECBlacklistRoleInfo()
        roleInfo.roleId = roleId
        roleInfo.status = ECSpaceMsgs.BlacklistStatus.ACTIVE
        self.m_blacklistRoles[tostring(roleId)] = roleInfo
      end
    end
  end
end
def.static(ECSpaceMsgs.ECNewMsg, "=>", ECSpaceMsgs.ECNewMsg).BuildNewMsgContent = function(newMsg)
  local NEW_MSG_TYPE = ECSpaceMsgs.NEW_MSG_TYPE
  if newMsg.newMsgType == NEW_MSG_TYPE.AT_STATUS or newMsg.newMsgType == NEW_MSG_TYPE.AT_IN_REPLY or newMsg.newMsgType == NEW_MSG_TYPE.AT_IN_LEAVE_MSG then
    newMsg.playerName = StringTable.Get(28218):format(newMsg.playerName)
  elseif newMsg.newMsgType == NEW_MSG_TYPE.REPLIED_IN_REPLY or newMsg.newMsgType == NEW_MSG_TYPE.REPLIED_IN_LEAVE_MSG then
    newMsg.strPlainMsg = textRes.SocialSpace.NewMsg[5]:format(newMsg.strPlainMsg)
  elseif newMsg.newMsgType == NEW_MSG_TYPE.REPLIED_STATUS then
    newMsg.strPlainMsg = textRes.SocialSpace.NewMsg[4]:format(newMsg.strPlainMsg)
  elseif newMsg.newMsgType == NEW_MSG_TYPE.GET_LEAVE_MSG then
    newMsg.strPlainMsg = textRes.SocialSpace.NewMsg[6]:format(newMsg.strPlainMsg)
  elseif newMsg.newMsgType == NEW_MSG_TYPE.ADDED_POPULAR then
    newMsg.strPlainMsg = textRes.SocialSpace.NewMsg[8]
  elseif newMsg.newMsgType == NEW_MSG_TYPE.GOTTEN_GIFT then
    if newMsg.roleId == Zero_Int64 then
      newMsg.playerName = textRes.SocialSpace[106]
    end
    local itemId = tonumber(newMsg.strPlainMsg) or 0
    local HtmlHelper = require("Main.Chat.HtmlHelper")
    local itemName = HtmlHelper.GetColoredItemName(itemId)
    newMsg.strPlainMsg = textRes.SocialSpace.NewMsg[9]:format(itemName, newMsg.strData)
    newMsg.strData = ""
  elseif newMsg.newMsgType == NEW_MSG_TYPE.DELETED_STATUS then
    newMsg.idphoto = ECSocialSpaceConfig.getSystemPhotoId()
    newMsg.playerName = textRes.SocialSpace[51]
    newMsg.strPlainMsg = textRes.SocialSpace.NewMsg[10]:format(newMsg.strPlainMsg)
  elseif newMsg.newMsgType == NEW_MSG_TYPE.DELETED_LEAVEMSG then
    newMsg.idphoto = ECSocialSpaceConfig.getSystemPhotoId()
    newMsg.playerName = textRes.SocialSpace[51]
    newMsg.strPlainMsg = textRes.SocialSpace.NewMsg[11]:format(newMsg.strPlainMsg)
  elseif newMsg.newMsgType == NEW_MSG_TYPE.DELETED_REPLY then
    newMsg.idphoto = ECSocialSpaceConfig.getSystemPhotoId()
    newMsg.playerName = textRes.SocialSpace[51]
    newMsg.strPlainMsg = textRes.SocialSpace.NewMsg[12]:format(newMsg.strPlainMsg)
  elseif newMsg.newMsgType == NEW_MSG_TYPE.DELETED_SIGNATURE then
    newMsg.idphoto = ECSocialSpaceConfig.getSystemPhotoId()
    newMsg.playerName = textRes.SocialSpace[51]
    newMsg.strPlainMsg = textRes.SocialSpace.NewMsg[13]:format(newMsg.strPlainMsg)
  elseif newMsg.newMsgType == NEW_MSG_TYPE.DELETED_PORTRAIT then
    newMsg.idphoto = ECSocialSpaceConfig.getSystemPhotoId()
    newMsg.playerName = textRes.SocialSpace[51]
    newMsg.strPlainMsg = textRes.SocialSpace.NewMsg[14]
  elseif newMsg.newMsgType == NEW_MSG_TYPE.HAS_NEW_HEADLINE then
    newMsg.idphoto = ECSocialSpaceConfig.getSystemPhotoId()
    newMsg.playerName = StringTable.Get(15208)
    newMsg.strPlainMsg = StringTable.Get(28266)
  end
  newMsg.strRichMsg = ECSocialSpaceMan.BuildSpaceRichContent(newMsg.strPlainMsg, newMsg.strData)
  return newMsg
end
def.static("string", "string", "=>", "string").BuildSpaceRichContent = function(plainStr, strData)
  return SocialSpaceUtils.BuildSpaceRichContent(plainStr, strData)
end
def.method("table", "table").ParseSpaceStyle = function(self, baseInfo, spaceStyle)
  local isSuccess, style = pcall(json.decode, spaceStyle.style)
  if not isSuccess or not style then
    style = {}
  end
  baseInfo.widget = style.pendant or 0
  baseInfo.photoFrame = style.rahmen or 0
  local function getDefaultValue(decoType)
    local decoTypeDisplayCfg = SocialSpaceUtils.GetDecorationTypeDisplayCfg(decoType)
    return decoTypeDisplayCfg and decoTypeDisplayCfg.defaultItemId or 0
  end
  if baseInfo.widget == 0 then
    baseInfo.widget = getDefaultValue(DecoType.TYPE_PENDANT_ORNAMENT)
  end
  if baseInfo.photoFrame == 0 then
    baseInfo.photoFrame = getDefaultValue(DecoType.TYPE_RAHMEN_ORNAMENT)
  end
end
def.method("table", "table").ParseSpaceSetting = function(self, baseInfo, spaceSetting)
  if spaceSetting.remindNews then
    baseInfo.remindNews = tonumber(spaceSetting.remindNews) == 1
  end
  if spaceSetting.commentSetting then
    baseInfo.commentType = tonumber(spaceSetting.commentSetting)
  end
  if spaceSetting.messageSetting then
    baseInfo.messageType = tonumber(spaceSetting.messageSetting)
  end
  local hostRoleId = self:GetHostRoleId()
  if baseInfo.roleId == hostRoleId then
    SocialSpaceSettingMan.SetSpaceSetting("commentSetting", baseInfo.commentType)
    SocialSpaceSettingMan.SetSpaceSetting("messageSetting", baseInfo.messageType)
  end
end
def.method("userdata", "userdata", "string", "number", "number").ShowPlayerMenu = function(self, baseObj, roleId, name, idPhoto, serverId)
  local sourceObj = baseObj
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  if serverId == 0 then
    serverId = self:GetRoleServerId(roleId)
  end
  if self:IsTheSameServerWithHost(serverId) then
    gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ReqRoleInfo(roleId, function(roleInfo)
      if _G.IsNil(sourceObj) then
        return
      end
      require("Main.Pubrole.PubroleTipsMgr").Instance():ShowTip(roleInfo, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1, {inMap = true})
    end)
  else
    do
      local pos = {
        auto = true,
        prefer = 0,
        preferY = 1
      }
      pos.sourceX = screenPos.x
      pos.sourceY = screenPos.y - widget.height / 2
      pos.sourceW = widget.width
      pos.sourceH = widget.height
      local btns = {}
      local btn = {
        name = textRes.SocialSpace[24],
        operate = function(...)
          self:EnterSpaceWithServerId(roleId, serverId, nil)
        end
      }
      table.insert(btns, btn)
      require("GUI.ButtonGroupPanel").ShowPanel(btns, pos, function(index)
        local btn = btns[index]
        btn.operate()
        return true
      end)
    end
  end
end
def.method("=>", "number").GetUnreadMsgCount = function(self)
  return self.m_unreadCount
end
def.method().NotifyUnreadMsgCount = function(self)
  Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.SpaceNewMsg, {
    self.m_unreadCount
  })
end
def.method("number").BuyTreauseChest = function(self, buyNum)
  SocialSpaceProtocol.CBuyFriendsCircleTreasureBox(buyNum)
end
def.method("table").onBuyTreauseChestSuccess = function(self, p)
  local spaceData = self:GetHostSpaceData()
  if spaceData == nil then
    return
  end
  local roleId = self:GetHostRoleId()
  spaceData.baseInfo.giftCount = p.now_treasure_box_num
  Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.TreauseChestChanged, {
    roleId,
    spaceData.baseInfo.giftCount
  })
end
def.method("table", "=>", "boolean").SaveSpaceDecorate = function(self, previewItems)
  if self.m_selfData == nil then
    return false
  end
  if table.nums(previewItems) == 0 then
    Toast(textRes.SocialSpace[67])
    return false
  end
  local decorateChanged = false
  local drecorateDatas = self:GetDecorateDatas()
  local savedDecorateData = self:GetSavedDecorateData()
  local replaceDecos = {}
  for decoType, itemId in pairs(previewItems) do
    if drecorateDatas[decoType] == nil or drecorateDatas[decoType][itemId] == nil then
      Toast(textRes.SocialSpace[66])
      return false
    end
    if savedDecorateData[decoType] ~= itemId then
      decorateChanged = true
      replaceDecos[decoType] = itemId
    end
  end
  if not decorateChanged then
    Toast(textRes.SocialSpace[68])
    return false
  end
  SocialSpaceProtocol.CReplaceFriendsCircleOrnamentItem(replaceDecos)
  return true
end
def.method("table").onSaveSpaceDecorateSuccess = function(self, p)
  self.m_savedDecorateData = self.m_savedDecorateData or {}
  for decoType, v in pairs(p.change_ornament_map) do
    self.m_savedDecorateData[decoType] = v.cut_item_cfg_id
  end
  Toast(textRes.SocialSpace[69])
  Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.SaveDecoSuccess, nil)
end
def.method("number", "number", "userdata", "string", "boolean", "number").SendGiftToRole = function(self, giftId, giftGrade, roleId, msg, isUseYuanbao, costYuanbao)
  local serverId = self:GetRoleServerId(roleId)
  SocialSpaceProtocol.CGiveFriendsCircleGift(roleId, serverId, giftId, giftGrade, msg, isUseYuanbao, costYuanbao)
end
def.method("table").onSendGiftSuccess = function(self, p)
  local itemId = p.item_cfg_id
  local grade = p.gift_grade
  local giftPopCfg = SocialSpaceUtils.GetPresentPopularCfg(itemId)
  local giftGradeCfg = SocialSpaceUtils.GetPresentGradeCfg(grade)
  if giftPopCfg and giftGradeCfg then
    local totalAddPop = giftPopCfg.addPopValue * giftGradeCfg.presentNum
    Toast(textRes.SocialSpace[105]:format(totalAddPop))
  end
  local roleId = p.receive_gift_role_id
  self:UpdateGiftAndPopular(roleId, p)
end
def.method("table").onHostReceiveGift = function(self, p)
  local roleId = self:GetHostRoleId()
  self:UpdateGiftAndPopular(roleId, p)
  local itemId = p.item_cfg_id
  local giftGrade = p.gift_grade
  local senderName = _G.GetStringFromOcts(p.active_send_gift_role_name)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local itemName = HtmlHelper.GetColoredItemName(itemId)
  local giftGradeCfg = SocialSpaceUtils.GetPresentGradeCfg(giftGrade)
  local presentNum = giftGradeCfg and giftGradeCfg.presentNum or "???"
  local content = textRes.SocialSpace[112]:format(senderName, itemName, presentNum)
  PersonalHelper.SendOut(content)
  local giveGiftCfg = SocialSpaceUtils.GetGivePresentCfg(itemId, giftGrade)
  if giveGiftCfg and giveGiftCfg.isSingleFx and (not giveGiftCfg.isBroadcastFx or not giveGiftCfg.isBroadcast) then
    warn("hey giveGiftCfg.isSingleFx")
    local fxId = giveGiftCfg.fxId
    if fxId and fxId > 0 then
      local effRes = GetEffectRes(fxId)
      if effRes then
        local name = tostring(fxId)
        require("Fx.GUIFxMan").Instance():PlayLayer(effRes.path, name, 0, 0, 1, 1, -1, false)
      end
    else
      warn(string.format("play give gift fx failed: gift fxId is %s", tostring(fxId)))
    end
  end
end
def.method("userdata", "table").UpdateGiftAndPopular = function(self, roleId, p)
  local spaceData = self:GetSpaceData(roleId)
  if not spaceData then
    return
  end
  local baseInfo = spaceData.baseInfo
  if baseInfo == nil then
    return
  end
  baseInfo.gainGiftCount = p.now_receive_gift_num
  baseInfo.thisWeekPopular = p.popularity_week_value
  baseInfo.totalPopular = p.popularity_total_value
  Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.PopularChanged, {roleId})
end
def.method("userdata").UseDecorateItem = function(self, item_uuid)
  SocialSpaceProtocol.CUseFriendsCircleOrnamentItem(item_uuid)
end
def.method("table").onUseDecorateItemSuccess = function(self, p)
  local itemId = p.add_item_cfg_id
  local decorateItemCfg = SocialSpaceUtils.GetDecorationItemCfg(itemId)
  if decorateItemCfg then
    local expire_time = -1
    local decoType = decorateItemCfg.decoType
    self:AddDecoration(decoType, itemId, expire_time)
  end
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local itemName = HtmlHelper.GetColoredItemName(itemId)
  local text = textRes.SocialSpace[70]:format(itemName)
  Toast(text)
  Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.DecorateDataChanged, nil)
end
def.method("number", "=>", "boolean").HasDecorationQueryByItemId = function(self, itemId)
  local decorateItemCfg = SocialSpaceUtils.GetDecorationItemCfg(itemId)
  if decorateItemCfg == nil then
    return false
  end
  return self:HasDecoration(decorateItemCfg.decoType, itemId)
end
def.method("userdata", "table").ReqAddRoleToBlacklist = function(self, roleId, roleContext)
  if self.m_blacklistRoles == nil then
    warn("SocialSpace: blacklist not inited")
    return
  end
  local size = #self:GetActiveBlackRoleList()
  local sizeLimit = ECSocialSpaceConfig.getBlacklistSizeLimit()
  if size >= sizeLimit then
    Toast(textRes.SocialSpace[96])
    return
  end
  local serverId
  if serverId == nil then
    serverId = self:GetRoleServerId(roleId)
  end
  SocialSpaceProtocol.CAddFriendsCircleBlacklist(roleId, serverId)
end
def.method("table").onAddToBlacklistSuccess = function(self, p)
  local roleId = p.black_role_id
  self.m_blacklistRoles = self.m_blacklistRoles or {}
  if self.m_blacklistRoles[tostring(roleId)] == nil then
    local roleInfo = ECSpaceMsgs.ECBlacklistRoleInfo()
    roleInfo.roleId = roleId
    roleInfo.status = ECSpaceMsgs.BlacklistStatus.ACTIVE
    roleInfo.lastUpdateTime = _G.GetServerTime()
    self.m_blacklistRoles[tostring(roleId)] = roleInfo
  end
  Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.BlacklistChanged, {roleId = roleId, addd = true})
  Toast(textRes.SocialSpace[91])
end
def.method("userdata").ReqRemoveRoleFromBlacklist = function(self, roleId)
  SocialSpaceProtocol.CDeleteFriendsCircleBlacklist(roleId)
end
def.method("table").onRemoveFromBlacklistSuccess = function(self, p)
  local roleId = p.black_role_id
  self.m_blacklistRoles = self.m_blacklistRoles or {}
  self.m_blacklistRoles[tostring(roleId)] = nil
  Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.BlacklistChanged, {roleId = roleId, remove = true})
  Toast(textRes.SocialSpace[95])
end
def.method("userdata", "=>", "boolean").IsRoleInBlacklist = function(self, roleId)
  if self.m_blacklistRoles == nil then
    return false
  end
  return self.m_blacklistRoles[tostring(roleId)] ~= nil
end
def.method("userdata", "=>", "boolean").IsRoleInActiveBlacklist = function(self, roleId)
  if self.m_blacklistRoles == nil then
    return false
  end
  local roleInfo = self.m_blacklistRoles[tostring(roleId)]
  if roleInfo == nil then
    return false
  end
  if bit.band(roleInfo.status, ECSpaceMsgs.BlacklistStatus.ACTIVE) ~= 0 then
    return true
  end
  return false
end
def.method("=>", "boolean").IsBlacklistInited = function(self)
  return self.m_blacklistRoles ~= nil
end
def.method("function", "boolean").ReqHostBlacklist = function(self, callback, bCheckCoolTime)
  if not self:CheckActiveSocialSpace(false) then
    return
  end
  local hostRoleId = self:GetHostRoleId()
  self:Req_GetBlacklist(hostRoleId, callback, bCheckCoolTime)
end
def.method("table").onGetBlacklist = function(self, blacklist)
  self.m_blacklistRoles = {}
  for i, v in ipairs(blacklist) do
    local roleInfo = ECSpaceMsgs.ECBlacklistRoleInfo()
    roleInfo.roleId = Int64.ParseString(v.blacklistRoleId)
    roleInfo.status = v.status
    roleInfo.lastUpdateTime = tonumber(v.lastUpdateTime) / 1000
    if v.blacklistRoleName then
      roleInfo.name = v.blacklistRoleName
      roleInfo.idphoto, roleInfo.avatarFrameId, roleInfo.urlphoto = ECSpaceMsgs.ParsePhoto(v.blacklistPhototId)
      self.m_blacklistRoles[tostring(roleInfo.roleId)] = roleInfo
    else
      warn(string.format("onGetBlacklist: roleId=%s missing roleName", tostring(v.blacklistRoleId)))
    end
  end
  Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.BlacklistChanged, {init = true})
end
def.method().LoadHostBlacklist = function(self)
  if self.m_blacklistRoles then
    return
  end
  self:ReqHostBlacklist(nil, false)
end
def.method("=>", "table").GetActiveBlackRoleList = function(self)
  if self.m_blacklistRoles == nil then
    return
  end
  local activeBlackRoleList = {}
  for _, roleInfo in pairs(self.m_blacklistRoles) do
    if bit.band(roleInfo.status, ECSpaceMsgs.BlacklistStatus.ACTIVE) ~= 0 then
      table.insert(activeBlackRoleList, roleInfo)
    end
  end
  table.sort(activeBlackRoleList, function(l, r)
    return l.lastUpdateTime > r.lastUpdateTime
  end)
  return activeBlackRoleList
end
def.method(ECSSRequestTypes.SSRequestBase).AddToCheckList = function(self, request)
  self.m_requests[request] = request
end
def.method(ECSSRequestTypes.SSRequestBase).RemoveFromCheckList = function(self, request)
  self.m_requests[request] = nil
end
def.method().OnCheckTimeout = function(self)
  if table.nums(self.m_requests) == 0 then
    return
  end
  local disposeRequets = {}
  for k, v in pairs(self.m_requests) do
    if v:CheckTimeout() then
      disposeRequets[k] = v
    end
  end
  for k, v in pairs(disposeRequets) do
    v:Dispose()
  end
end
def.method("boolean").SetSelfSpacePanelOpened = function(self, isOpen)
  self.m_isSelfSpacePanelOpened = isOpen
end
def.method("=>", SpaceData).GetHostSpaceData = function(self)
  local hostRoleId = _G.GetMyRoleID()
  return self:GetSpaceData(hostRoleId)
end
def.method("string", "=>", "string").FilterSensitiveWords = function(self, content)
  return SensitiveWordsFilter.FilterContent(content, "*")
end
def.method("number", "=>", "boolean").IsTheSameServerWithHost = function(self, serverId)
  local hp = self:GetHostPlayerInfos()
  if hp.serverId == serverId or _G.IsMergedServer(serverId) then
    return true
  else
    return false
  end
end
def.method("=>", "number").GetHostServerId = function(self)
  return Network.m_zoneid
end
def.method("=>", "string").GetHostUserId = function(self)
  return ECGame.Instance():GetUserNameWithZoneId()
end
def.method("=>", "userdata").GetHostRoleId = function(self)
  return _G.GetMyRoleID()
end
def.method("=>", "table").GetHostPlayerInfos = function(self)
  local AvatarInterface = require("Main.Avatar.AvatarInterface")
  local avatarInterface = AvatarInterface.Instance()
  local heroProp = _G.GetHeroProp()
  local hp = {}
  hp.roleId = self:GetHostRoleId()
  hp.serverId = self:GetHostServerId()
  hp.name = heroProp.name
  hp.avatarId = avatarInterface:getCurAvatarId()
  hp.avatarFrameId = avatarInterface:getCurAvatarFrameId()
  hp.level = heroProp.level
  hp.occupation = heroProp.occupation
  hp.gender = heroProp.gender
  return hp
end
def.method("userdata", "=>", "number").GetRoleServerId = function(self, roleId)
  return _G.GetRoleZoneId(roleId)
end
def.method("=>", "userdata").GetTokenTimestamp = function(self)
  return self.m_tokenTimeStamp
end
def.method("=>", "string").GetSignedToken = function(self)
  return self.m_signedMD5Token
end
def.method("=>", "boolean").ShowLog = function(self)
  return ECDebugOption.Instance().showSSlog
end
def.method("=>", "boolean").IsDebug = function(self)
  do return _G.ss_debug or false end
  return Application.isEditor
end
def.method("=>", "boolean", "string").IsUploadPictureSupported = function(self)
  if platform == _G.Platform.win then
    return true, "ok"
  end
  if _G.CUR_CODE_VERSION >= _G.COS_EX_CODE_VERSION then
    return true, "ok"
  end
  return false, textRes.SocialSpace[75]
end
def.method("=>", "boolean").CheckIsUploadPictureSupported = function(self)
  local ret, msg = self:IsUploadPictureSupported()
  if ret == false then
    Toast(msg)
  end
  return ret
end
def.method().Reset = function(self)
end
def.method().MakeFakeBaseSpaceInfo = function(self)
  local hp = _G.GetHeroProp()
  if hp == nil then
    return
  end
  if not self.m_selfData then
    local AvatarInterface = require("Main.Avatar.AvatarInterface")
    local avatarInterface = AvatarInterface.Instance()
    local baseInfo = ECSpaceMsgs.ECSpaceBaseInfo()
    baseInfo.roleId = hp.id
    baseInfo.playerName = hp.name
    baseInfo.level = hp.level
    baseInfo.gender = hp.gender
    baseInfo.prof = hp.occupation
    baseInfo.idphoto = avatarInterface:getCurAvatarId()
    baseInfo.urlphoto = ""
    baseInfo.race = 0
    baseInfo.factionName = "\230\178\161\230\156\137\229\184\174\230\180\190"
    baseInfo.signature = "\230\151\160\231\173\190\229\144\141"
    local spaceData = SpaceData()
    spaceData.baseInfo = baseInfo
    self.m_selfData = spaceData
  end
end
def.method().MakeFakeHPMsgForTest = function(self)
  if not self.m_selfData then
    self:MakeFakeBaseSpaceInfo()
  end
  local AvatarInterface = require("Main.Avatar.AvatarInterface")
  local avatarInterface = AvatarInterface.Instance()
  local hp = _G.GetHeroProp()
  local msg = ECSpaceMsgs.ECSpaceMsg()
  msg.roleId = hp.id
  msg.playerName = hp.name
  msg.idphoto = avatarInterface:getCurAvatarId()
  msg.urlphoto = ""
  msg.strPlainMsg = "<font size=19 color=#4a2c10>" .. "TestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsgTestMsg" .. "!!!!!!</font><br/>"
  msg.strRichMsg = ECSocialSpaceMan.BuildSpaceRichContent(msg.strPlainMsg, "")
  msg.strRichMsg = msg.strPlainMsg
  msg.timestamp = _G.GetServerTime()
  msg.favorList = {
    {
      id = hp.id,
      name = hp.name
    }
  }
  msg.replyMsgList = {}
  msg.msgIdClient = self.NextUnqiueID
  msg.ID = Int64.new(self.NextUnqiueID)
  local msgList = self.m_selfData.msgs
  table.insert(msgList, msg)
end
def.method().MakeFakeHPMsgForTest2 = function(self)
  local msgList = {}
  local AvatarInterface = require("Main.Avatar.AvatarInterface")
  local avatarInterface = AvatarInterface.Instance()
  local avatarId = avatarInterface:getCurAvatarId()
  local hp = _G.GetHeroProp()
  self.NextUnqiueID = self.NextUnqiueID + 1
  local rawMsg = {}
  rawMsg.momentId = tostring(self.NextUnqiueID)
  rawMsg.serverId = tostring(self:GetHostServerId())
  rawMsg.roleId = tostring(hp.id)
  rawMsg.roleName = hp.name
  rawMsg.photoId = tostring(avatarId) .. "|"
  rawMsg.content = "11111111111111111111111111111111111111111111111111111111111"
  rawMsg.supplement = ""
  rawMsg.createTime = _G.GetServerTime() * 1000
  rawMsg.voteSize = 0
  rawMsg.hasVoted = false
  rawMsg.voteRecordList = {}
  rawMsg.replyList = {}
  table.insert(msgList, rawMsg)
  self.NextUnqiueID = self.NextUnqiueID + 1
  local rawMsg = {}
  rawMsg.momentId = tostring(self.NextUnqiueID)
  rawMsg.serverId = tostring(self:GetHostServerId())
  rawMsg.roleId = tostring(hp.id)
  rawMsg.roleName = hp.name
  rawMsg.photoId = tostring(avatarId) .. "|"
  rawMsg.content = "22222222222222222222222222222"
  rawMsg.supplement = ""
  rawMsg.createTime = _G.GetServerTime() * 1000
  rawMsg.voteSize = 0
  rawMsg.hasVoted = false
  rawMsg.voteRecordList = {}
  rawMsg.replyList = {}
  table.insert(msgList, rawMsg)
  self:onGetMomentList(msgList, rawMsg.roleId)
end
def.method().MakeFakeHPMsgForTest3 = function(self)
  local msgList = {}
  local AvatarInterface = require("Main.Avatar.AvatarInterface")
  local avatarInterface = AvatarInterface.Instance()
  local avatarId = avatarInterface:getCurAvatarId()
  local hp = _G.GetHeroProp()
  self.NextUnqiueID = self.NextUnqiueID + 1
  local rawMsg = {}
  rawMsg.momentId = tostring(self.NextUnqiueID)
  rawMsg.serverId = tostring(self:GetHostServerId())
  rawMsg.roleId = tostring(hp.id)
  rawMsg.roleName = hp.name
  rawMsg.photoId = tostring(avatarId) .. "|"
  rawMsg.content = "3333333333333333333"
  rawMsg.supplement = ""
  rawMsg.createTime = _G.GetServerTime() * 1000
  rawMsg.voteSize = 0
  rawMsg.hasVoted = false
  rawMsg.voteRecordList = {}
  rawMsg.replyList = {}
  table.insert(msgList, rawMsg)
  self.NextUnqiueID = self.NextUnqiueID + 1
  local rawMsg = {}
  rawMsg.momentId = tostring(self.NextUnqiueID)
  rawMsg.serverId = tostring(self:GetHostServerId())
  rawMsg.roleId = tostring(hp.id)
  rawMsg.roleName = hp.name
  rawMsg.photoId = tostring(avatarId) .. "|"
  rawMsg.content = "4"
  rawMsg.supplement = ""
  rawMsg.createTime = _G.GetServerTime() * 1000
  rawMsg.voteSize = 1
  rawMsg.hasVoted = false
  rawMsg.voteRecordList = {}
  local voteRecord = {}
  voteRecord.momentId = rawMsg.momentId
  voteRecord.gameId = ""
  voteRecord.serverId = rawMsg.serverId
  voteRecord.roleId = rawMsg.roleId
  voteRecord.roleName = "test"
  voteRecord.status = 0
  voteRecord.createTime = rawMsg.createTime + 10000
  table.insert(rawMsg.voteRecordList, voteRecord)
  rawMsg.replyList = {}
  local replyRecord = {}
  replyRecord.replyId = "0"
  replyRecord.momentId = rawMsg.momentId
  replyRecord.content = "hello"
  replyRecord.supplement = ""
  replyRecord.replierGameId = 0
  replyRecord.replierServerid = 0
  replyRecord.replierId = "0"
  replyRecord.replierName = "0"
  replyRecord.replierUserId = "0"
  replyRecord.targetGameId = "0"
  replyRecord.targetServerId = rawMsg.serverId
  replyRecord.targetId = rawMsg.roleId
  replyRecord.targetUserId = ""
  replyRecord.targetName = rawMsg.roleName
  replyRecord.status = 0
  replyRecord.remindList = "[]"
  replyRecord.voteSize = 0
  replyRecord.createTime = rawMsg.createTime + 10000
  table.insert(rawMsg.replyList, replyRecord)
  local replyRecord = {}
  replyRecord.replyId = "1"
  replyRecord.momentId = rawMsg.momentId
  replyRecord.content = "hellox2<br/>hellox2<br/>hellox2<br/>hellox2<br/>hellox2<br/>hellox2<br/>hellox2<br/>hellox2<br/>hellox2"
  replyRecord.supplement = ""
  replyRecord.replierGameId = 0
  replyRecord.replierServerid = 0
  replyRecord.replierId = "0"
  replyRecord.replierName = "0"
  replyRecord.replierUserId = "0"
  replyRecord.targetGameId = "0"
  replyRecord.targetServerId = rawMsg.serverId
  replyRecord.targetId = rawMsg.roleId
  replyRecord.targetUserId = ""
  replyRecord.targetName = rawMsg.roleName
  replyRecord.status = 0
  replyRecord.remindList = "[]"
  replyRecord.voteSize = 0
  replyRecord.createTime = rawMsg.createTime + 10000
  table.insert(rawMsg.replyList, replyRecord)
  rawMsg.replySize = #rawMsg.replyList
  table.insert(msgList, rawMsg)
  self:onGetMomentList(msgList, rawMsg.roleId)
end
ECSocialSpaceMan.Commit()
return ECSocialSpaceMan
