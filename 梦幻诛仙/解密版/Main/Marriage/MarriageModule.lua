local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
require("Main.module.ModuleId")
local MarriageModule = Lplus.Extend(ModuleBase, "MarriageModule")
local MarriageConsts = require("netio.protocol.mzm.gsp.marriage.MarriageConsts")
local MarriageUtils = require("Main.Marriage.MarriageUtils")
local MarriageLevelCostType = require("consts.mzm.gsp.marriage.confbean.MarriageLevelCostType")
local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local AnnouncementTip = require("GUI.AnnouncementTip")
local ChatModule = require("Main.Chat.ChatModule")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local MultiWeddingMgr = require("Main.Marriage.MultiWeddingMgr")
local def = MarriageModule.define
local _instance
def.static("=>", MarriageModule).Instance = function()
  if _instance == nil then
    _instance = MarriageModule()
    _instance.m_moduleId = ModuleId.MARRIAGE
  end
  return _instance
end
def.field("userdata").forceDivorceRoleId = nil
def.field("table").mateInfo = nil
def.field("number").curAppellation = 0
def.field("table").confirmDlg = nil
def.field("number").marryTime = -1
def.field("table").friendMarryCache = nil
def.field("table").friendRedPacketCache = nil
def.field("userdata").redPacketRoleId = nil
def.field("string").redPacketName = ""
def.field("table").paradePosReqList = nil
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SSynMarriageInfo", MarriageModule.OnSyncMarriageInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SMarryRes", MarriageModule.OnProposal)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SAgreeOrCancelMarriage", MarriageModule.OnProposalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SAgreeOrCancelMarriageErrorRes", MarriageModule.OnProposalError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SBroadCastAllMarriage", MarriageModule.OnMarriageBroadCast)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SSendMarriageMsgToFriend", MarriageModule.OnFriendGotMarried)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SSendMarriageMsgSucceed", MarriageModule.OnTellFriendSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SFriendSendGift", MarriageModule.OnFriendRedPacket)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SSendGiftToFriendRes", MarriageModule.OnSendFriendRedPacket)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SDivorceRes", MarriageModule.OnDivorce)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SAgreeOrRefuseDivorce", MarriageModule.OnDivorceResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SForceDivorceRes", MarriageModule.OnForceDicorceResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SForceDivorceSucRes", MarriageModule.OnForceDivorceFinish)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SCancelForceDivorceSuc", MarriageModule.OnCancelForceDivorce)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SSChangeMarriageTitleRes", MarriageModule.OnCoupleAppellationChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SMarriageNormalResult", MarriageModule.OnNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SCanSendGiftToFriend", MarriageModule.OnCanSendRedPacket)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SMarraigeParadePostion", MarriageModule.OnSMarraigeParadePostion)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, MarriageModule.OnMoonFatherService)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, MarriageModule.onMainUIReady)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  MultiWeddingMgr.Instance():Init()
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  self.mateInfo = nil
  self.forceDivorceRoleId = nil
  self.curAppellation = 0
  self.confirmDlg = nil
  self.marryTime = -1
  self.friendMarryCache = nil
  self.friendRedPacketCache = nil
  self.redPacketRoleId = nil
  self.redPacketName = ""
  self.paradePosReqList = nil
  MultiWeddingMgr.Instance():Reset()
end
def.static("table").OnSyncMarriageInfo = function(p)
  local self = MarriageModule.Instance()
  self.mateInfo = {}
  self.mateInfo.mateId = p.roleinfo.roleid
  self.mateInfo.mateName = p.roleinfo.roleName
  self.forceDivorceRoleId = p.roleid ~= Int64.new(0) and p.roleid or nil
  self.curAppellation = p.marriageTitleid
  self.marryTime = p.marrryTimeSec
end
def.static("table").OnProposal = function(p)
  local myRoleId = GetMyRoleID()
  local sessionId = p.sessionid
  if p.roleid == myRoleId then
    require("Main.Marriage.ui.MarryAsk").ShowMarryAsk(textRes.Marriage[3], constant.CMarriageConsts.refuseMarriageSec, 1, function(select)
      if select == 0 then
        MarriageModule.Instance():C2SReplyToProposal(false, sessionId)
      end
    end)
  else
    local levelCfg = MarriageUtils.GetMarriageLevel(p.level)
    if levelCfg and p.roleName and p.roleid then
      local ask = string.format(textRes.Marriage[4], p.roleName, levelCfg.marriageName)
      require("Main.Marriage.ui.MarryAsk").ShowMarryAsk(ask, constant.CMarriageConsts.refuseMarriageSec, 2, function(select)
        if select == 1 then
          MarriageModule.Instance():C2SReplyToProposal(true, sessionId)
        elseif select == 0 then
          MarriageModule.Instance():C2SReplyToProposal(false, sessionId)
        end
      end)
    end
  end
end
def.static("table").OnProposalResult = function(p)
  if p.operator == MarriageConsts.AGREE_MARRIAGE then
    Toast(textRes.Marriage[6])
    require("Main.Marriage.ui.MarryAsk").Close()
    Event.DispatchEvent(ModuleId.MARRIAGE, gmodule.notifyId.Marriage.Marry, nil)
  elseif p.operator == MarriageConsts.CANCEL_MARRIAGE then
    Toast(string.format(textRes.Marriage[5], p.roleName))
    require("Main.Marriage.ui.MarryAsk").Close()
  end
end
def.static("table").OnProposalError = function(p)
  require("Main.Marriage.ui.MarryAsk").Close()
  local formatStr = textRes.Marriage.ProposalError[p.error]
  if formatStr == nil then
    warn("SAgreeOrCancelMarriageErrorRes not handle:", p.error)
    return
  end
  local text = string.format(formatStr, unpack(p.args))
  Toast(text)
end
def.static("table").OnMarriageBroadCast = function(p)
  local manId = p.roleidA
  local manName = p.roleidAName
  local womanId = p.roleidB
  local womanName = p.roleidBName
  local count = p.marriageCounter
  local level = p.level
  local levelCfg = MarriageUtils.GetMarriageLevel(level)
  local roleId = require("Main.Hero.HeroModule").Instance().roleId
  if manId == roleId or womanId == roleId then
    require("Main.WeddingTour.ui.ShareWeddingPanel").Instance():SetData({
      name1 = manName,
      name2 = womanName,
      index = count
    })
  end
  local str = string.format(textRes.AnnounceMent[56], manName, womanName, levelCfg.marriageName, count)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
  warn("BroadCast Marriage:", manName, womanName, levelCfg.isToAll, levelCfg.effectid, levelCfg.lastTime)
  if levelCfg.isToAll then
    local myRoleId = GetMyRoleID()
    local noticeStr = string.format(textRes.AnnounceMent[54], manName, womanName, levelCfg.marriageName, count)
    local NoticeType = require("consts.mzm.gsp.function.confbean.NoticeType")
    require("GUI.InteractiveAnnouncementTip").AnnounceWithModuleIdAndDuration(noticeStr, NoticeType.MARRIAGE, levelCfg.lastTime)
    if levelCfg.effectid ~= 0 then
      local effRes = GetEffectRes(levelCfg.effectid)
      require("Fx.GUIFxMan").Instance():Play(effRes.path, "marry", 0, 0, -1, false)
    end
  else
    AnnouncementTip.Announce(str)
  end
end
def.static("table").OnFriendGotMarried = function(p)
  if not IsEnteredWorld() then
    warn("Cache:OnFriendGotMarried")
    if MarriageModule.Instance().friendMarryCache == nil then
      MarriageModule.Instance().friendMarryCache = {}
    end
    table.insert(MarriageModule.Instance().friendMarryCache, p)
    return
  end
  warn("OnFriendGotMarried", p.roleid)
  local senderId = p.roleid
  local lvcfg = MarriageUtils.GetMarriageLevel(p.level)
  if lvcfg == nil then
    return
  end
  local receiverId = GetMyRoleID()
  local friendInfo = require("Main.friend.FriendData").Instance():GetFriendInfo(senderId)
  if friendInfo == nil then
    return
  end
  local roleName = friendInfo.roleName
  local gender = friendInfo.sex
  local occupationId = friendInfo.occupationId
  local avatarId = friendInfo.avatarId
  local avatarFrameId = friendInfo.avatarFrameId
  local level = friendInfo.roleLevel
  local vipLevel = 0
  local modelId = 0
  local badge = {}
  local contentType = require("netio.protocol.mzm.gsp.chat.ChatConsts").CONTENT_NORMAL
  local str = string.format(textRes.Marriage[19], p.roleidAName, p.roleidBName, lvcfg.marriageName, senderId:tostring(), senderId:tostring())
  local content = require("netio.Octets").rawFromString(str)
  MarriageModule.Instance():SendFakeFriendMsg(senderId, receiverId, senderId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, p.timeSec, avatarId, avatarFrameId)
end
def.static("table").OnTellFriendSuccess = function(p)
  warn("OnTellFriendSuccess")
  local lvcfg = MarriageUtils.GetMarriageLevel(p.level)
  if lvcfg == nil then
    return
  end
  local friends = require("Main.friend.FriendData").Instance():GetFriendList()
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  for k, v in ipairs(friends) do
    warn("tell Friend,", k)
    local friendInfo = v
    if friendInfo.roleId ~= p.roleid then
      local senderId = GetMyRoleID()
      local receiverId = friendInfo.roleId
      local roleName = heroProp.name
      local gender = heroProp.gender
      local occupationId = heroProp.occupation
      local avatarId = require("Main.Avatar.AvatarInterface").Instance():getCurAvatarId()
      local avatarFrameId = require("Main.Avatar.AvatarInterface").Instance():getCurAvatarFrameId()
      local level = heroProp.level
      local vipLevel = 0
      local modelId = 0
      local badge = {}
      local contentType = require("netio.protocol.mzm.gsp.chat.ChatConsts").CONTENT_NORMAL
      local str = string.format(textRes.Marriage[19], roleName, p.roleidName, lvcfg.marriageName, senderId:tostring(), senderId:tostring())
      local content = require("netio.Octets").rawFromString(str)
      MarriageModule.Instance():SendFakeFriendMsg(senderId, receiverId, senderId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, p.timeSec, avatarId, avatarFrameId)
    end
  end
end
def.static("table").OnFriendRedPacket = function(p)
  if not IsEnteredWorld() then
    warn("Cache:OnFriendRedPacket")
    if MarriageModule.Instance().friendRedPacketCache == nil then
      MarriageModule.Instance().friendRedPacketCache = {}
    end
    table.insert(MarriageModule.Instance().friendRedPacketCache, p)
    return
  end
  warn("OnFriendRedPacket", senderId)
  local senderId = p.roleid
  local redCfg = MarriageUtils.GetRedPacket(p.giftid)
  if redCfg == nil then
    return
  end
  local receiverId = GetMyRoleID()
  local friendInfo = require("Main.friend.FriendData").Instance():GetFriendInfo(senderId)
  if friendInfo == nil then
    return
  end
  local roleName = friendInfo.roleName
  local gender = friendInfo.sex
  local occupationId = friendInfo.occupationId
  local avatarId = friendInfo.avatarId
  local avatarFrameId = friendInfo.avatarFrameId
  local level = friendInfo.roleLevel
  local vipLevel = 0
  local modelId = 0
  local badge = {}
  local contentType = require("netio.protocol.mzm.gsp.chat.ChatConsts").CONTENT_NORMAL
  local moneyNum = redCfg.moneyNum
  local moneyName = textRes.Marriage.MoneyType[redCfg.moneyType]
  local str = string.format(textRes.Marriage[20], moneyNum, moneyName)
  local content = require("netio.Octets").rawFromString(str)
  MarriageModule.Instance():SendFakeFriendMsg(senderId, receiverId, senderId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, p.timeSec, avatarId, avatarFrameId)
  local toastStr = string.format(textRes.Marriage[22], roleName, moneyNum, moneyName)
  Toast(toastStr)
end
def.static("table").OnSendFriendRedPacket = function(p)
  Toast(textRes.Marriage[21])
  local senderId = GetMyRoleID()
  local redCfg = MarriageUtils.GetRedPacket(p.giftid)
  if redCfg == nil then
    return
  end
  local receiverId = p.roleid
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local roleName = heroProp.name
  local gender = heroProp.gender
  local occupationId = heroProp.occupation
  local avatarId = require("Main.Avatar.AvatarInterface").Instance():getCurAvatarId()
  local avatarFrameId = require("Main.Avatar.AvatarInterface").Instance():getCurAvatarFrameId()
  local level = heroProp.level
  local vipLevel = 0
  local modelId = 0
  local badge = {}
  local contentType = require("netio.protocol.mzm.gsp.chat.ChatConsts").CONTENT_NORMAL
  local moneyNum = redCfg.moneyNum
  local moneyName = textRes.Marriage.MoneyType[redCfg.moneyType]
  local str = string.format(textRes.Marriage[20], moneyNum, moneyName)
  local content = require("netio.Octets").rawFromString(str)
  MarriageModule.Instance():SendFakeFriendMsg(senderId, receiverId, senderId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, p.timeSec, avatarId, avatarFrameId)
end
def.static("table").OnDivorce = function(p)
  local self = MarriageModule.Instance()
  local sessionId = p.sessionid
  if MarriageModule.Instance().mateInfo and MarriageModule.Instance().mateInfo.mateName then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    self.confirmDlg = CommonConfirmDlg.ShowConfirmCoundDown(textRes.Marriage[7], string.format(textRes.Marriage[8], MarriageModule.Instance().mateInfo.mateName, constant.CMarriageConsts.divorceSilver), "", "", 0, constant.CMarriageConsts.refuseMarriageSec, function(select)
      if select == 1 then
        MarriageModule.Instance():C2SReplyToDealDivorce(true, sessionId)
      elseif select == 0 then
        MarriageModule.Instance():C2SReplyToDealDivorce(false, sessionId)
      end
      self.confirmDlg = nil
    end, nil)
  end
end
def.static("table").OnDivorceResult = function(p)
  local myRoleId = GetMyRoleID()
  local self = MarriageModule.Instance()
  if p.operator == MarriageConsts.AGREE_DIVROCE then
    Toast(textRes.Marriage[9])
    MarriageModule.Instance().mateInfo = nil
    MarriageModule.Instance().forceDivorceRoleId = nil
    MarriageModule.Instance().curAppellation = 0
    MarriageModule.Instance().marryTime = -1
    Event.DispatchEvent(ModuleId.MARRIAGE, gmodule.notifyId.Marriage.Divorce, nil)
  elseif p.operator == MarriageConsts.REFUSE_DIVORCE then
    if self.confirmDlg then
      self.confirmDlg:DestroyPanel()
    end
    if myRoleId ~= p.roleid and MarriageModule.Instance().mateInfo and MarriageModule.Instance().mateInfo.mateName then
      Toast(string.format(textRes.Marriage[10], MarriageModule.Instance().mateInfo.mateName))
    end
  end
end
def.static("table").OnForceDicorceResult = function(p)
  warn("OnForceDicorceResult")
  MarriageModule.Instance().forceDivorceRoleId = GetMyRoleID()
  Toast(textRes.Marriage[16])
end
def.static("table").OnCancelForceDivorce = function(p)
  warn("OnCancelForceDivorce")
  MarriageModule.Instance().forceDivorceRoleId = nil
  Toast(textRes.Marriage[17])
end
def.static("table").OnForceDivorceFinish = function(p)
  warn("OnForceDivorceFinish")
  if MarriageModule.Instance().mateInfo and MarriageModule.Instance().mateInfo.mateName then
    Toast(string.format(textRes.Marriage[15], MarriageModule.Instance().mateInfo.mateName))
  end
  MarriageModule.Instance().mateInfo = nil
  MarriageModule.Instance().forceDivorceRoleId = nil
  MarriageModule.Instance().curAppellation = 0
  MarriageModule.Instance().marryTime = -1
  Event.DispatchEvent(ModuleId.MARRIAGE, gmodule.notifyId.Marriage.Divorce, nil)
end
def.static("table").OnCoupleAppellationChange = function(p)
  local self = MarriageModule.Instance()
  local appellation = p.marriageTitleCfgid
  self.curAppellation = appellation
  Toast(textRes.Marriage[18])
end
def.static("table").OnCanSendRedPacket = function(p)
  warn("OnCanSendRedPacket", p.ret)
  local roleId = p.friendid
  local ret = p.ret
  if ret == p.SUC then
    if roleId == MarriageModule.Instance().redPacketRoleId then
      local redPackets = MarriageUtils.GetRedPackets()
      local data = {}
      for k, v in ipairs(redPackets) do
        local info = {}
        info.id = v.id
        info.name = v.giftName
        info.money = v.moneyType
        info.number = v.moneyNum
        table.insert(data, info)
      end
      require("Main.Marriage.ui.RedPacket").ShowRedPacket(data, roleId, MarriageModule.Instance().redPacketName)
    end
  elseif ret == p.ALREADY_SEND then
    Toast(textRes.Marriage[47])
  elseif ret == p.OUT_OF_DATE then
    Toast(textRes.Marriage[48])
  elseif ret == p.NOT_IN_MARRIAGE then
    Toast(textRes.Marriage[48])
  end
end
def.static("table").OnSMarraigeParadePostion = function(p)
  local location = p.location
  print("OnSMarraigeParadePostion location.x, location.y", location.x, location.y)
  if _instance.paradePosReqList == nil then
    return
  end
  for i, v in ipairs(_instance.paradePosReqList) do
    v(location, p.paradecfgid)
  end
  _instance.paradePosReqList = nil
end
def.static("table").OnNormalResult = function(p)
  local tip = textRes.Marriage.Error[p.result]
  if tip then
    if p.result == p.MARRY_REQ_NOT_SINGLE then
      local name = p.args[1]
      if name then
        Toast(string.format(tip, name))
      end
    elseif p.result == p.DIVORCE_REQUST_SILVER_NOT_ENOUGH then
      local name = p.args[1]
      if name then
        Toast(string.format(tip, name))
      end
    else
      Toast(tip)
    end
  end
end
def.static("table", "table").OnMoonFatherService = function(p1, p2)
  local npcId = p1[2]
  local serviceId = p1[1]
  local NPCServiceConst = require("Main.npc.NPCServiceConst")
  if NPCServiceConst.Proposal == serviceId then
    _instance:RegisterMarriage()
  elseif NPCServiceConst.ChangeCoupleTitle == serviceId then
    _instance:ModifyAppellation()
  elseif NPCServiceConst.DealDivorce == serviceId then
    _instance:DivorceAgreement()
  elseif NPCServiceConst.ForceDivorce == serviceId then
    _instance:DivorceForce()
  elseif NPCServiceConst.CancelDivorce == serviceId then
    _instance:CancelDivorceForce()
  end
end
def.static("table", "table").onMainUIReady = function(p1, p2)
  if MarriageModule.Instance().mateInfo then
    local mateId = MarriageModule.Instance().mateInfo.mateId
    local online = require("Main.friend.FriendModule").Instance():IsFriendOnline(mateId)
    if online then
      local gender = require("Main.Hero.Interface").GetBasicHeroProp().gender
      Toast(string.format(textRes.Marriage[38], textRes.Marriage.SelfGender2MateAppellation[gender], MarriageModule.Instance().mateInfo.mateName))
    end
  end
  if MarriageModule.Instance().friendMarryCache then
    warn("Release friendMarryCache")
    for k, v in ipairs(MarriageModule.Instance().friendMarryCache) do
      MarriageModule.OnFriendGotMarried(v)
    end
  end
  MarriageModule.Instance().friendMarryCache = nil
  if MarriageModule.Instance().friendRedPacketCache then
    warn("Release friendRedPacketCache")
    for k, v in ipairs(MarriageModule.Instance().friendRedPacketCache) do
      MarriageModule.OnFriendRedPacket(v)
    end
  end
  MarriageModule.Instance().friendRedPacketCache = nil
end
def.method("number", "boolean").C2SMarry = function(self, mode, yb)
  local CMarryReq = require("netio.protocol.mzm.gsp.marriage.CMarryReq")
  local yuanbao = yb and CMarryReq.USE_YUANBAO_REPLACE_ITEM or CMarryReq.UNUSE_YUANBAO
  warn("C2SMarry", mode, yuanbao)
  local cmarry = CMarryReq.new(mode, yuanbao)
  gmodule.network.sendProtocol(cmarry)
end
def.method().C2SDealDivorce = function(self)
  local cdealdivroce = require("netio.protocol.mzm.gsp.marriage.CDivorceReq").new()
  gmodule.network.sendProtocol(cdealdivroce)
end
def.method().C2SForceDivorce = function(self)
  local cforceDivorce = require("netio.protocol.mzm.gsp.marriage.CForceDivorce").new()
  gmodule.network.sendProtocol(cforceDivorce)
end
def.method().C2SCancelForceDivorce = function(self)
  local ccancelForceDivorce = require("netio.protocol.mzm.gsp.marriage.CCancelForceDivorce").new()
  gmodule.network.sendProtocol(ccancelForceDivorce)
end
def.method("boolean", "userdata").C2SReplyToProposal = function(self, agree, sessionId)
  local CAgreeOrCancelMarriage = require("netio.protocol.mzm.gsp.marriage.CAgreeOrCancelMarriage")
  if agree then
    local agree = CAgreeOrCancelMarriage.new(MarriageConsts.AGREE_MARRIAGE, sessionId)
    gmodule.network.sendProtocol(agree)
  else
    local cancel = CAgreeOrCancelMarriage.new(MarriageConsts.CANCEL_MARRIAGE, sessionId)
    gmodule.network.sendProtocol(cancel)
  end
end
def.method("boolean", "userdata").C2SReplyToDealDivorce = function(self, agree, sessionId)
  local CAgreeOrRefuseDivorce = require("netio.protocol.mzm.gsp.marriage.CAgreeOrRefuseDivorce")
  if agree then
    local agree = CAgreeOrRefuseDivorce.new(MarriageConsts.AGREE_DIVROCE, sessionId)
    gmodule.network.sendProtocol(agree)
  else
    local cancel = CAgreeOrRefuseDivorce.new(MarriageConsts.REFUSE_DIVORCE, sessionId)
    gmodule.network.sendProtocol(cancel)
  end
end
def.method("number").C2SChangeCoupleAppellation = function(self, appellation)
  local change = require("netio.protocol.mzm.gsp.marriage.CChangeMarriageTitleReq").new(appellation)
  gmodule.network.sendProtocol(change)
end
def.method("userdata").C2SJoinWedding = function(self, roleId)
  if roleId ~= GetMyRoleID() then
    local join = require("netio.protocol.mzm.gsp.marriage.CTransforToMarriage").new(roleId)
    gmodule.network.sendProtocol(join)
  else
    Toast(textRes.Marriage[49])
  end
end
def.method("userdata", "number").C2SSendRedPacket = function(self, roleId, giftId)
  local redPacket = require("netio.protocol.mzm.gsp.marriage.CSendGiftToFriend").new(roleId, giftId)
  gmodule.network.sendProtocol(redPacket)
end
def.method("userdata").C2SCanSendRedPacketTo = function(self, roleId)
  local canSend = require("netio.protocol.mzm.gsp.marriage.CCanSendGiftToFriend").new(roleId)
  gmodule.network.sendProtocol(canSend)
end
def.method().C2SMarraigeParadePostion = function(self)
  local canSend = require("netio.protocol.mzm.gsp.marriage.CMarraigeParadePostion").new()
  gmodule.network.sendProtocol(canSend)
end
def.method("userdata", "userdata", "userdata", "string", "number", "number", "number", "number", "number", "table", "number", "userdata", "number", "number", "number").SendFakeFriendMsg = function(self, senderId, receiverId, roleId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, time, avatarId, avatarFrameId)
  local SChatToSomeOne = require("netio.protocol.mzm.gsp.chat.SChatToSomeOne")
  local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
  local myRoleId = GetMyRoleID()
  local chatCnt = ChatContent.new(roleId, roleName, gender, occupationId, avatarId, avatarFrameId, level, vipLevel, modelId, badge, contentType, content, 0, Int64.new(time) * 1000)
  local chatPrivate = SChatToSomeOne.new(chatCnt, senderId, receiverId)
  require("Main.Chat.ChatModule").OnPrivateChat(chatPrivate)
end
def.method().RegisterMarriage = function(self)
  local weddingNow = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):IsPlayingWedding()
  if weddingNow then
    Toast(textRes.Marriage[51])
    return
  end
  if self.mateInfo then
    Toast(textRes.Marriage[25])
    return
  end
  local teamData = require("Main.Team.TeamData")
  if teamData.Instance():HasLeavingMember() then
    Toast(textRes.Marriage[23])
    return
  end
  if teamData.Instance():GetMemberCount() ~= 2 then
    Toast(textRes.Marriage[23])
    return
  end
  local allMember = teamData.Instance():GetAllTeamMembers()
  if allMember[1].gender == allMember[2].gender then
    Toast(textRes.Marriage[23])
    return
  end
  if allMember[1].level < constant.CMarriageConsts.needLevel and allMember[2].level < constant.CMarriageConsts.needLevel then
    Toast(string.format(textRes.Marriage[44], constant.CMarriageConsts.needLevel, allMember[1].name, allMember[2].name))
    return
  end
  if allMember[1].level < constant.CMarriageConsts.needLevel then
    Toast(string.format(textRes.Marriage[26], constant.CMarriageConsts.needLevel, allMember[1].name))
    return
  end
  if allMember[2].level < constant.CMarriageConsts.needLevel then
    Toast(string.format(textRes.Marriage[26], constant.CMarriageConsts.needLevel, allMember[2].name))
    return
  end
  local friendInfo = require("Main.friend.FriendData").Instance():GetFriendInfo(allMember[2].roleid)
  if friendInfo == nil or friendInfo.relationValue < constant.CMarriageConsts.friendValue then
    Toast(string.format(textRes.Marriage[24], constant.CMarriageConsts.friendValue))
    return
  end
  local MallUtility = require("Main.Mall.MallUtility")
  local levels = MarriageUtils.GetMarriageLevels()
  local data = {}
  for k, v in ipairs(levels) do
    local cfg = {}
    cfg.id = v.id
    cfg.name = v.marriageName
    cfg.itemOrMoney = v.itemOrMoney
    if cfg.itemOrMoney == MarriageLevelCostType.Money then
      cfg.money = v.moneyType
      cfg.number = v.moneyNum
    elseif cfg.itemOrMoney == MarriageLevelCostType.Item then
      cfg.item = v.itemid
      cfg.number = v.itemNum
      local yuanbao = MallUtility.GetPriceByItemId(cfg.item)
      cfg.yuanbao = yuanbao and yuanbao > 0 and yuanbao or nil
    end
    table.insert(data, cfg)
  end
  require("Main.Marriage.ui.WeddingMode").ShowModelSelect(data)
end
def.method().ModifyAppellation = function(self)
  if self.mateInfo == nil then
    Toast(textRes.Marriage[31])
    return
  end
  local teamData = require("Main.Team.TeamData")
  if teamData.Instance():HasLeavingMember() then
    Toast(textRes.Marriage[32])
    return
  end
  if teamData.Instance():GetMemberCount() ~= 2 then
    Toast(textRes.Marriage[32])
    return
  end
  local allMember = teamData.Instance():GetAllTeamMembers()
  if allMember[2].roleid ~= self.mateInfo.mateId then
    Toast(textRes.Marriage[32])
    return
  end
  local titles = MarriageUtils.GetCoupleTitles()
  local manName = "XXX"
  local womanName = "XXX"
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if heroProp then
    local gender = heroProp.gender
    warn("getder", gender)
    if gender == GenderEnum.MALE then
      manName = heroProp.name
      womanName = self.mateInfo and self.mateInfo.mateName and self.mateInfo.mateName or "XXX"
    elseif gender == GenderEnum.FEMALE then
      manName = self.mateInfo and self.mateInfo.mateName and self.mateInfo.mateName or "XXX"
      womanName = heroProp.name
    end
  end
  local data = {}
  for k, v in ipairs(titles) do
    local cfg = {}
    cfg.id = v.id
    cfg.name = v.titleName
    cfg.money = v.moneyType
    cfg.number = v.moneyNum
    cfg.husband = MarriageUtils.CombineTitle(v.manTitle, womanName)
    cfg.wife = MarriageUtils.CombineTitle(v.womenTitle, manName)
    if v.id == self.curAppellation then
      cfg.own = true
    end
    table.insert(data, cfg)
  end
  require("Main.Marriage.ui.MarryAppellation").ShowCoupleTitle(data)
end
def.method("userdata", "string").SendRedPacket = function(self, roleId, roleName)
  warn("SendRedPacket", roleId, roleName, GetMyRoleID())
  if GetMyRoleID() ~= roleId then
    self.redPacketRoleId = roleId
    self.redPacketName = roleName
    self:C2SCanSendRedPacketTo(roleId)
  else
    Toast(textRes.Marriage[50])
  end
end
def.method("=>", "boolean").CheckCanSignUpWedding = function(self)
  if self.mateInfo == nil then
    Toast(textRes.Marriage[31])
    return false
  end
  local teamData = require("Main.Team.TeamData")
  if not teamData.Instance():HasTeam() then
    Toast(textRes.Marriage[102])
    return false
  end
  if not teamData.Instance():MeIsCaptain() then
    Toast(textRes.Marriage[105])
    return false
  end
  if teamData.Instance():HasLeavingMember() then
    Toast(textRes.Marriage[102])
    return false
  end
  if teamData.Instance():GetMemberCount() ~= 2 then
    Toast(textRes.Marriage[102])
    return false
  end
  local allMember = teamData.Instance():GetAllTeamMembers()
  if allMember[2].roleid ~= self.mateInfo.mateId then
    Toast(textRes.Marriage[102])
    return false
  end
  if self.forceDivorceRoleId then
    Toast(textRes.Marriage[103])
    return false
  end
  return true
end
def.method().DivorceAgreement = function(self)
  if self.mateInfo == nil then
    Toast(textRes.Marriage[31])
    return
  end
  local teamData = require("Main.Team.TeamData")
  if teamData.Instance():HasLeavingMember() then
    Toast(textRes.Marriage[33])
    return
  end
  if teamData.Instance():GetMemberCount() ~= 2 then
    Toast(textRes.Marriage[33])
    return
  end
  local allMember = teamData.Instance():GetAllTeamMembers()
  if allMember[2].roleid ~= self.mateInfo.mateId then
    Toast(textRes.Marriage[33])
    return
  end
  local leftTime = self:CheckDivorceTime()
  if leftTime > 0 then
    local leftStr = self:Second2DayHour(leftTime)
    local allStr = self:Second2DayHour(constant.CMarriageConsts.canDivorceAfterMarriageHour * 3600)
    Toast(string.format(textRes.Marriage[39], allStr, leftStr))
    return
  end
  if MarriageModule.Instance().mateInfo and MarriageModule.Instance().mateInfo.mateName then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    self.confirmDlg = CommonConfirmDlg.ShowConfirmCoundDown(textRes.Marriage[7], string.format(textRes.Marriage[8], MarriageModule.Instance().mateInfo.mateName, constant.CMarriageConsts.divorceSilver), "", "", 0, constant.CMarriageConsts.refuseMarriageSec, function(select)
      if select == 1 then
        local ItemModule = require("Main.Item.ItemModule")
        local silver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
        if silver < Int64.new(constant.CMarriageConsts.divorceSilver) then
          Toast(textRes.Marriage[30])
        else
          self:C2SDealDivorce()
        end
      elseif select == 0 then
      end
      self.confirmDlg = nil
    end, nil)
  end
end
def.method().DivorceForce = function(self)
  local leftTime = self:CheckDivorceTime()
  if leftTime > 0 then
    local leftStr = self:Second2DayHour(leftTime)
    local allStr = self:Second2DayHour(constant.CMarriageConsts.canDivorceAfterMarriageHour * 3600)
    Toast(string.format(textRes.Marriage[39], allStr, leftStr))
    return
  end
  if MarriageModule.Instance().mateInfo and MarriageModule.Instance().mateInfo.mateName then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm(textRes.Marriage[11], string.format(textRes.Marriage[12], MarriageModule.Instance().mateInfo.mateName, constant.CMarriageConsts.forceDivorceSilver), function(select)
      if select == 1 then
        local ItemModule = require("Main.Item.ItemModule")
        local count = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
        if count < Int64.new(constant.CMarriageConsts.forceDivorceSilver) then
          Toast(textRes.Marriage[30])
          return
        end
        self:C2SForceDivorce()
      end
    end, nil)
  end
end
def.method().CancelDivorceForce = function(self)
  if self.mateInfo == nil then
    Toast(textRes.Marriage[31])
    return
  end
  if MarriageModule.Instance().mateInfo and MarriageModule.Instance().mateInfo.mateName then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm(textRes.Marriage[13], textRes.Marriage[14], function(select)
      if select == 1 then
        self:C2SCancelForceDivorce()
      end
    end, nil)
  end
end
def.method("=>", "table").GetMarriageSkills = function(self)
  local mateInfo = MarriageModule.Instance().mateInfo
  if mateInfo and mateInfo.mateId then
    local friendInfo = require("Main.friend.FriendData").Instance():GetFriendInfo(mateInfo.mateId)
    if friendInfo then
      local curFriendValue = friendInfo.relationValue
      local skillsCfg = MarriageUtils.GetMarriageSkills()
      local skills = {}
      for k, v in ipairs(skillsCfg) do
        if curFriendValue >= v.needFriendValue then
          local level = math.floor((curFriendValue - v.factorA) / v.factorB)
          table.insert(skills, {
            skillId = v.skillId,
            level = level
          })
        end
      end
      return skills
    end
  end
  return {}
end
def.method().ShowCoupleSkill = function(self)
  local SkillUtility = require("Main.Skill.SkillUtility")
  local skillsCfg = MarriageUtils.GetMarriageSkills()
  local skills = {}
  for k, v in ipairs(skillsCfg) do
    local skillCfg = SkillUtility.GetSkillCfg(v.skillId)
    if skillCfg then
      local cfg = {}
      cfg.name = skillCfg.name
      cfg.icon = skillCfg.iconId
      cfg.desc = skillCfg.description
      table.insert(skills, cfg)
    end
  end
  require("Main.Marriage.ui.MarrySkill").ShowMarrySkills(skills)
end
def.method("=>", "number").CheckDivorceTime = function(self)
  if self.marryTime < 0 then
    return -1
  end
  local divorceNeedTime = constant.CMarriageConsts.canDivorceAfterMarriageHour * 3600
  local curTime = GetServerTime()
  return divorceNeedTime - (curTime - self.marryTime)
end
def.method("number", "=>", "string").Second2DayHour = function(self, sec)
  local hour = math.ceil(sec / 3600)
  local day = math.floor(hour / 24)
  local leftHour = hour % 24
  local dayStr = day > 0 and string.format(textRes.Marriage[52], day) or ""
  local hourStr = leftHour > 0 and string.format(textRes.Marriage[53], leftHour) or ""
  return dayStr .. hourStr
end
def.method("function").ReqParadePosition = function(self, callback)
  if self.paradePosReqList == nil then
    self.paradePosReqList = {callback}
    self:C2SMarraigeParadePostion()
  else
    table.insert(self.paradePosReqList, callback)
  end
end
MarriageModule.Commit()
return MarriageModule
