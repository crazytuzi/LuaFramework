local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ChatRedGiftModule = Lplus.Extend(ModuleBase, "ChatRedGiftModule")
require("Main.module.ModuleId")
local ChatRedGiftData = require("Main.ChatRedGift.ChatRedGiftData")
local ChatRedGiftUtility = require("Main.ChatRedGift.ChatRedGiftUtility")
local def = ChatRedGiftModule.define
local instance
def.field(ChatRedGiftData).chatRedgiftData = nil
def.static("=>", ChatRedGiftModule).Instance = function()
  if instance == nil then
    instance = ChatRedGiftModule()
    instance.m_moduleId = ModuleId.CHATREDGIFT
  end
  return instance
end
def.override().Init = function(self)
  self.chatRedgiftData = ChatRedGiftData.Instance()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SGetChatGiftInfoRes", ChatRedGiftModule.OnOpenRedGiftGetPanelRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SGetChatGiftListRes", ChatRedGiftModule.OnOpenGangRedGiftPanelRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SGetChatGiftRes", ChatRedGiftModule.OnGetGolfRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SSyncGetChatGiftRes", ChatRedGiftModule.OnGetRedGiftNoteRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatGiftResult", ChatRedGiftModule.OnGetErrResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SGetChatGiftLeftNumReq", ChatRedGiftModule.OnGetLeftSendRedGiftRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SSyncGetChatGiftMoreMoney", ChatRedGiftModule.OnRedGiftOverNoteRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SGetChatGiftAddBangGong", ChatRedGiftModule.OnAddBangGongRes)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ChatRedGiftModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Send_ChatRedGift, ChatRedGiftModule.OnOpenSendRedGiftPanel)
  Event.RegisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Get_ChatRedGiftProtocol, ChatRedGiftModule.OnOpenGetRedGiftPanelPro)
  Event.RegisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Get_ChatRedGift, ChatRedGiftModule.OnOpenGetRedGiftPanel)
  Event.RegisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Rank_ChatRedGift, ChatRedGiftModule.OnOpenRankRedGiftPanel)
  Event.RegisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.New_ChatRedGift, ChatRedGiftModule.OnChatRedGiftWorldTipPanel)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, ChatRedGiftModule.OnNewDay)
  require("Main.ChatRedGift.ChatSendGiftMgr").Instance():Init()
  ModuleBase.Init(self)
end
def.static("table", "table").OnLeaveWorld = function()
  if instance then
    ChatRedGiftData.Instance():Init()
  end
  require("Main.ChatRedGift.ChatSendGiftMgr").Instance():Reset()
end
def.static("table").OnRedGiftOverNoteRes = function(msg)
  local tips = ""
  tips = string.format(textRes.ChatRedGift[21], msg.sendRoleName, msg.getRoleName)
  if tips ~= "" then
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local ChatModule = require("Main.Chat.ChatModule")
    if msg.channelType == ChatMsgData.Channel.FACTION then
      ChatModule.Instance():SendNoteMsg(tips, ChatMsgData.MsgType.CHANNEL, msg.channelType)
    elseif msg.channelType == ChatMsgData.Channel.GROUP then
      warn("OnRedGiftOverNoteRes", tips)
      local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
      local SocialDlg = require("Main.friend.ui.SocialDlg")
      local msg = ChatMsgBuilder.BuildNoteMsg64(ChatMsgData.MsgType.GROUP, msg.channelId, tips)
      ChatModule.Instance().msgData:AddMsg64(msg)
      SocialDlg.Instance():AddGroupMsg(msg)
    end
  end
end
def.static("table").OnGetLeftSendRedGiftRes = function(msg)
  ChatRedGiftData.Instance():SetLeftTimes(msg.leftNum)
end
def.static("table").OnGetErrResult = function(msg)
  local SChatGiftResult = require("netio.protocol.mzm.gsp.chat.SChatGiftResult")
  Toast(textRes.ChatRedGift[22 + msg.result])
end
def.static("table").OnAddBangGongRes = function(msg)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  PersonalHelper.GetMoneyMsgByType(MoneyType.GANGCONTRIBUTE, msg.addBangGong .. "")
end
def.static("table").OnGetGolfRes = function(msg)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  PersonalHelper.GetMoneyMsgByType(msg.moneyType, msg.money .. "")
end
def.static("table").OnGetRedGiftNoteRes = function(msg)
  local tips = ""
  local myRoleId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  if myRoleId == msg.roleId and myRoleId == msg.getRoleId then
    tips = textRes.ChatRedGift[14]
  elseif myRoleId == msg.getRoleId then
    tips = string.format(textRes.ChatRedGift[15], msg.roleName)
  elseif myRoleId == msg.roleId then
    tips = string.format(textRes.ChatRedGift[16], msg.getRoleName)
  end
  if tips ~= "" then
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local ChatModule = require("Main.Chat.ChatModule")
    if msg.channelType == ChatMsgData.Channel.FACTION then
      ChatModule.Instance():SendNoteMsg(tips, ChatMsgData.MsgType.CHANNEL, msg.channelType)
    elseif msg.channelType == ChatMsgData.Channel.GROUP then
      local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
      local SocialDlg = require("Main.friend.ui.SocialDlg")
      local msg = ChatMsgBuilder.BuildNoteMsg64(ChatMsgData.MsgType.GROUP, msg.channelId, tips)
      ChatModule.Instance().msgData:AddMsg64(msg)
      SocialDlg.Instance():AddGroupMsg(msg)
    end
  end
end
def.static("table", "table").OnOpenSendRedGiftPanel = function(param, param1)
  local ChatRedGiftSendPanel = require("Main.ChatRedGift.ui.ChatRedGiftSendPanel")
  warn("OpenSendRedGiftPanel" .. param._channelSubType)
  ChatRedGiftSendPanel.Instance():ShowPanel(param._channelType, param._channelSubType, param._groupId)
end
def.static("table", "table").OnOpenGetRedGiftPanelPro = function(param, param1)
  if IsCrossingServer() then
    Toast(textRes.ChatRedGift[52])
  else
    ChatRedGiftData.Instance():AddRedGiftChannel(tostring(param.redGiftId), param.channelType, param.channelSubType)
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CGetChatGiftInfoReq").new(param.redGiftId, param.channelSubType))
  end
end
def.static("table", "table").OnOpenGetRedGiftPanel = function(param, param1)
  local ChatRedGiftOpenPanel = require("Main.ChatRedGift.ui.ChatRedGiftOpenPanel")
  ChatRedGiftOpenPanel.Instance():ShowPanel(param.redGiftInfo)
end
def.static("table", "table").OnOpenRankRedGiftPanel = function(param, param1)
  local ChatRedGiftRankPanel = require("Main.ChatRedGift.ui.ChatRedGiftRankPanel")
  ChatRedGiftRankPanel.Instance():ShowPanel(param.redGiftInfo)
end
def.static("table").OnOpenRedGiftGetPanelRes = function(_redGiftInfo)
  if not _redGiftInfo then
    return
  end
  local redGiftInfo = {}
  redGiftInfo.redGiftId = _redGiftInfo.chatGiftInfo.chatGiftId
  redGiftInfo.content = _redGiftInfo.chatGiftInfo.chatGiftStr
  redGiftInfo.roleInfo = {}
  redGiftInfo.roleInfo.roleId = _redGiftInfo.chatGiftInfo.roleId
  redGiftInfo.roleInfo.name = _redGiftInfo.chatGiftInfo.roleName
  redGiftInfo.roleInfo.level = _redGiftInfo.chatGiftInfo.roleLevel
  redGiftInfo.roleInfo.menpai = _redGiftInfo.chatGiftInfo.menpai
  redGiftInfo.roleInfo.gender = _redGiftInfo.chatGiftInfo.gender
  redGiftInfo.roleInfo.avatarId = _redGiftInfo.chatGiftInfo.avatarid
  redGiftInfo.roleInfo.avatarFrameId = _redGiftInfo.chatGiftInfo.avatar_frame_id
  redGiftInfo.memberList = _redGiftInfo.chatGiftInfo.getChatGiftInfo or {}
  redGiftInfo.maxNum = _redGiftInfo.chatGiftInfo.chatGiftNum or 0
  local redGiftConfig = ChatRedGiftData.GetChatRedGiftConfigByIndex(_redGiftInfo.chatGiftInfo.chatGiftType or -1)
  redGiftInfo.maxGold = redGiftConfig and redGiftConfig.goldnum or 0
  local channelTable = ChatRedGiftData.Instance():GetRedGiftChannel(tostring(redGiftInfo.redGiftId))
  redGiftInfo.channelType = channelTable.channelType
  redGiftInfo.channelSubType = channelTable.channelSubType
  if redGiftInfo.maxNum == #redGiftInfo.memberList or ChatRedGiftUtility.HasGetThisRedGift(redGiftInfo.memberList) then
    local ChatRedGiftRankPanel = require("Main.ChatRedGift.ui.ChatRedGiftRankPanel")
    ChatRedGiftRankPanel.Instance():ShowPanel(redGiftInfo)
  else
    local ChatRedGiftOpenPanel = require("Main.ChatRedGift.ui.ChatRedGiftOpenPanel")
    ChatRedGiftOpenPanel.Instance():ShowPanel(redGiftInfo)
  end
end
def.static("table").OnOpenGangRedGiftPanelRes = function(msg)
  if not msg then
    return
  end
  local _redGiftInfo = msg.chatgiftlist
  local tmpredGiftInfo = {}
  for i = 1, #_redGiftInfo do
    local tmp = {}
    tmp.name = _redGiftInfo[i].roleName
    tmp.redGiftId = _redGiftInfo[i].chatGiftId
    tmp.content = _redGiftInfo[i].chatGiftStr
    tmp.isCanGet = _redGiftInfo[i].isCanGet == 1
    table.insert(tmpredGiftInfo, tmp)
  end
  Event.DispatchEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.GangHistoryRedGifts, {redGiftInfo = tmpredGiftInfo})
end
def.static("table", "table").OnChatRedGiftWorldTipPanel = function(param, param1)
  ChatRedGiftData.Instance():AddNewChatRedGift(param.redGiftInfo)
  local myRoleId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  if not param.redGiftInfo.roleInfo.roleId:eq(myRoleId) then
    require("Main.ChatRedGift.ui.ChatRedGiftWorldTipPanel").Instance():ShowPanel(param.redGiftInfo)
  end
end
def.static("table", "table").OnNewDay = function(p1, p2)
  ChatRedGiftData.Instance():SetLeftTimes(constant.ChatGiftConsts.dayLimitNum)
  Event.DispatchEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Refresh_LeftRedGiftNumChange, {
    constant.ChatGiftConsts.dayLimitNum
  })
end
ChatRedGiftModule.Commit()
return ChatRedGiftModule
