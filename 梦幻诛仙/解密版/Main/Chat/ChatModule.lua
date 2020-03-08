local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ChatModule = Lplus.Extend(ModuleBase, "ChatModule")
require("Main.module.ModuleId")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local ChatInputDlg = require("Main.Chat.ui.ChatInputDlg")
local ChatUtils = require("Main.Chat.ChatUtils")
local ChatMemo = require("Main.Chat.ChatMemo")
local SpeechMgr = require("Main.Chat.SpeechMgr")
local ECSoundMan = require("Sound.ECSoundMan")
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local TeamPlatformChatMgr = require("Main.Chat.TeamPlatformChatMgr")
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local ChannelChatPanel = require("Main.Chat.ui.ChannelChatPanel")
local json = require("Utility.json")
local Octets = require("netio.Octets")
local TrumpetQueue = require("Main.Chat.Trumpet.data.TrumpetQueue")
local TrumpetMgr = require("Main.Chat.Trumpet.TrumpetMgr")
local AtMgr = require("Main.Chat.At.AtMgr")
local def = ChatModule.define
local instance
def.field("userdata").roleIdBackUp = nil
def.field("boolean").crossServerBackUp = false
def.field("number").province = -1
def.field("table").ChatRoleInfoCache = nil
def.field("table").friendNewCount = nil
def.field(TeamPlatformChatMgr).teamPlatformChatMgr = nil
def.field("table").ChatLimit = nil
def.field("number").helpTimer = 0
def.const("string").CHATRECORD = "CHATRECORD"
def.const("string").CHATSETTING = "CHATSETTING"
def.const("string").CHATNEW = "CHATNEW"
def.const("string").SAVEPATH = "chatrecord"
def.const("string").GROUPMSGPATH = "groupchatmsgs"
def.const("string").PRIVATECHATSOUND = RESPATH.SOUND_CHAT
def.const("table").SettingEnum = {
  AUTOAUDIOGANG = 1,
  AUTOAUDIOTEAM = 2,
  AUTOAUDIOMAP = 3,
  AUTOAUDIOWORLD = 4,
  AVOIDGANG = 5,
  AVOIDTEAM = 6,
  AVOIDMAP = 7,
  AVOIDWORLD = 8
}
def.field("table").SettingMap = function()
  return {
    [ChatModule.SettingEnum.AUTOAUDIOGANG] = 1,
    [ChatModule.SettingEnum.AUTOAUDIOTEAM] = 1,
    [ChatModule.SettingEnum.AUTOAUDIOMAP] = 1,
    [ChatModule.SettingEnum.AUTOAUDIOWORLD] = 0,
    [ChatModule.SettingEnum.AVOIDGANG] = 0,
    [ChatModule.SettingEnum.AVOIDTEAM] = 0,
    [ChatModule.SettingEnum.AVOIDMAP] = 0,
    [ChatModule.SettingEnum.AVOIDWORLD] = 0
  }
end
def.const("string").QUICKCHATMAP = "QUICKCHAT"
def.field("table").QuickChatMap = nil
def.field("table").m_GroupNewChatCount = nil
def.field("table").m_GroupNewAtCount = nil
def.static("=>", ChatModule).Instance = function()
  if instance == nil then
    instance = ChatModule()
    instance.m_moduleId = ModuleId.CHAT
    instance.friendNewCount = {}
    instance.ChatLimit = {}
    instance.teamPlatformChatMgr = TeamPlatformChatMgr()
    instance.ChatRoleInfoCache = {}
    instance.m_GroupNewChatCount = {}
    instance.m_GroupNewAtCount = {}
  end
  return instance
end
def.field(ChatMsgData).msgData = nil
def.const("number").SAVEINTERVAL = 64
def.field("boolean").friendChatDirty = false
def.field("boolean").groupChatDirty = false
def.field("number").friendSaveTime = 0
def.field("number").groupSaveTime = 0
def.override().Init = function(self)
  HtmlHelper.LoadCfg()
  self:LoadChatSetting()
  self.teamPlatformChatMgr:Init()
  local ChannelType = require("consts.mzm.gsp.chat.confbean.ChannelType")
  local sercetRate = DynamicData.GetRecord(CFG_PATH.DATA_CHAT_CONST, "secretTypeTimeRet"):GetIntValue("value") / 10000
  for k, v in pairs(ChannelType) do
    local record = DynamicData.GetRecord(CFG_PATH.DATA_CHANEL_CFG, v)
    if record then
      self.ChatLimit[v] = {
        levelLimit = record:GetIntValue("levelMin"),
        timeLag = record:GetIntValue("timeLag"),
        sceretLag = record:GetIntValue("timeLag") * sercetRate,
        energyConsume = record:GetIntValue("energyConsume"),
        lastTime = 0,
        lastSercetTime = 0
      }
    end
  end
  self.msgData = ChatMsgData.Instance()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatToAnchor", ChatModule.OnFansChat)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInAnchor", ChatModule.OnLiveChat)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInRoom", ChatModule.OnCityChat)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInWorld", ChatModule.OnWorldChat)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInMap", ChatModule.OnMapChat)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInSingleBattleCamp", ChatModule.OnSingleBattleChat)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInFaction", ChatModule.OnNewFactionChat)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInNewer", ChatModule.OnNewerChat)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInTeam", ChatModule.OnTeamChat)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInFriend", ChatModule.OnFriendChat)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInActivity", ChatModule.OnActivityChat)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatToSomeOne", ChatModule.OnPrivateChat)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SSendFail", ChatModule.OnSendFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SPacketInChatInfo", ChatModule.OnInfoPack)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatNormalResult", ChatModule.OnNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SJoinChatRoomRsp", ChatModule.OnJoinCityRoom)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInTrumpet", ChatModule.OnSChatInTrumpet)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SSynOfflineChatContents", ChatModule.OnHistoryMsg)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInGroup", ChatModule.OnGroupChat)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SPacketFaBaoInChatInfo", ChatModule.OnSFabaoChatInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bulletin.SSystemInfo", ChatModule.OnServerInfo)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_CHAT_CLICK, ChatModule._onShow)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, ChatModule._onEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ChatModule.onLeaveWorld)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CMD_CLICK_CHAT, ChatModule._onTeamClickChat)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, ChatModule._onGangChange)
  Event.RegisterEvent(ModuleId.SYSTEM_SETTING, gmodule.notifyId.SystemSetting.SETTING_CHANGED, ChatModule._onVoiceSettingChange)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.TeamPlatform_Change, ChatModule._onTeamPlatformChange)
  ModuleBase.Init(self)
  require("Main.Chat.ui.DlgAction").Instance()
  require("Main.Chat.ScreenBulletMgr").Instance():Init()
  require("Main.Chat.Trumpet.TrumpetMgr").Instance():Init()
  require("Main.Chat.GreetingCard.GreetingCardMgr").Instance():Init()
  require("Main.Chat.ChatBubble.ChatBubbleMgr").Instance():Init()
  require("Main.Chat.WordsEmoj.WordsEmojMgr").Instance():Init()
  AtMgr.Instance():Init()
end
def.static("table", "table").onLeaveWorld = function(p1, p2)
  local reason = p1.reason
  if reason == require("Main.Login.LoginModule").LeaveWorldReason.RECONNECT then
    instance:OnResetData(true)
  else
    instance:OnResetData(false)
  end
  require("Main.Chat.GreetingCard.GreetingCardMgr").Instance():Reset()
end
def.method("boolean").OnResetData = function(self, reconnect)
  if not self.crossServerBackUp then
    self:SaveChat(true)
  end
  self.friendChatDirty = false
  self.groupChatDirty = false
  self.friendSaveTime = 0
  self.groupSaveTime = 0
  self.friendNewCount = {}
  self.m_GroupNewChatCount = {}
  self.m_GroupNewAtCount = {}
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  if reconnect then
    self.msgData:Clear()
  else
    self.msgData:Init()
    mainUIChat:ClearMsgData()
  end
  self.teamPlatformChatMgr:Reset()
  ChatMemo.Instance():Clear()
  GameUtil.RemoveGlobalTimer(self.helpTimer)
  local ChannelType = require("consts.mzm.gsp.chat.confbean.ChannelType")
  for k, v in pairs(ChannelType) do
    if self.ChatLimit[v] ~= nil then
      self.ChatLimit[v].lastTime = 0
    end
  end
  self.roleIdBackUp = nil
  self.crossServerBackUp = false
  if not reconnect then
    self.province = -1
  end
  require("Main.Chat.SpeechMgr").Instance():CancelSpeech()
end
def.static("table", "table")._onEnterWorld = function(params, context)
  local LoginModule = require("Main.Login.LoginModule")
  if params.enterType ~= LoginModule.EnterWorldType.RECONNECT then
    instance.province = -1
  end
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  if params.enterType ~= LoginModule.EnterWorldType.RECONNECT then
    instance.msgData:Init()
    mainUIChat:ClearMsgData()
  else
    instance.msgData:Clear()
  end
  instance.crossServerBackUp = IsCrossingServer()
  instance.roleIdBackUp = GetMyRoleID()
  instance.helpTimer = GameUtil.AddGlobalTimer(ChatUtils.GetHelpTipsInterval(), false, function()
    local tip = GetRandomTip()
    instance:SendSystemMsg(ChatMsgData.System.HELP, HtmlHelper.Style.Help, {content = tip})
  end)
  instance:UpdateVoiceVolume()
  SpeechMgr.Instance():Init()
  if not instance.crossServerBackUp then
    instance:LoadFriendChat()
    instance:LoadGroupChat()
    instance:GetOutLineChat()
    if params.enterType ~= LoginModule.EnterWorldType.RECONNECT then
      instance:GetHistroyFactionChat()
    end
  end
end
def.static("table").OnServerInfo = function(p)
  local msg = ChatMsgBuilder.BuildSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.System, {
    text = p.info
  })
  instance.msgData:AddMsg(msg)
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  mainUIChat:AddMsg(msg)
  ChannelChatPanel.Instance():AddMsg(msg)
  require("GUI.ScrollNotice").Notice(string.format("[ffff00]%s[-]", p.info))
end
def.static("table", "table")._onShow = function(params, context)
  ChannelChatPanel.ShowChannelChatPanel(-1, -1)
end
def.static("table", "table")._onVoiceSettingChange = function(params)
  local id = params[1]
  if id == SystemSettingModule.SystemSetting.VoiceSound then
    instance:UpdateVoiceVolume()
  end
end
def.static("table", "table")._onTeamPlatformChange = function(p1, p2)
  local teams = p1
  ChannelChatPanel.Instance():RefreshTeam(teams)
end
def.method().UpdateVoiceVolume = function(self)
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.VoiceSound)
  local volume = setting.mute and 0 or setting.volume
  SpeechMgr.Instance():SetVoiceVolume(volume)
end
def.static("table", "table")._onGangChange = function(params, context)
end
def.static("table", "table")._onTeamClickChat = function(params, context)
  instance:StartPrivateChat3(params[1], params[2], params[5], params[3], params[4], params[6], params[7])
end
def.static("table").OnWorldChat = function(p)
  if ChatModule.Instance():HandleChannelSceret(p, ChatMsgData.Channel.WORLD) then
    return
  end
  if FriendModule.Instance():IsInShieldList(p.chatContent.roleId) then
    return
  end
  if instance.SettingMap[ChatModule.SettingEnum.AVOIDWORLD] > 0 then
    return
  end
  local msg = ChatMsgBuilder.BuildChannelMsg(p, ChatMsgData.Channel.WORLD)
  instance.msgData:AddMsg(msg)
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  mainUIChat:AddMsg(msg)
  ChannelChatPanel.Instance():AddMsg(msg)
  if p.chatContent.contentType == ChatConsts.CONTENT_YY and 0 < instance.SettingMap[ChatModule.SettingEnum.AUTOAUDIOWORLD] then
    SpeechMgr.Instance():PlayInQueue(msg.fileId, msg.second)
  end
end
def.static("table").OnLiveChat = function(p)
  if ChatModule.Instance():HandleChannelSceret(p, ChatMsgData.Channel.LIVE) then
    return
  end
  if require("ProxySDK.ECApollo").IsSpeaker(1) then
    return
  end
  if FriendModule.Instance():IsInShieldList(p.chatContent.roleId) then
    return
  end
  local msg = ChatMsgBuilder.BuildChannelMsg(p, ChatMsgData.Channel.LIVE)
  instance.msgData:AddMsg(msg)
  ChannelChatPanel.Instance():AddMsg(msg)
end
def.static("table").OnFansChat = function(p)
  if ChatModule.Instance():HandleChannelSceret(p, ChatMsgData.Channel.LIVE) then
    return
  end
  if p.chatContent == nil then
    return
  end
  local chatContent = require("netio.protocol.mzm.gsp.chat.ChatContent").new()
  Octets.unmarshalBean(p.chatContent, chatContent)
  p.chatContent = chatContent
  if FriendModule.Instance():IsInShieldList(p.chatContent.roleId) then
    return
  end
  local msg = ChatMsgBuilder.BuildChannelMsg(p, ChatMsgData.Channel.LIVE)
  instance.msgData:AddMsg(msg)
  ChannelChatPanel.Instance():AddMsg(msg)
end
def.static("table").OnCityChat = function(p)
  p.chatContent = p.content
  if ChatModule.Instance():HandleChannelSceret(p, ChatMsgData.Channel.CITY) then
    return
  end
  if FriendModule.Instance():IsInShieldList(p.chatContent.roleId) then
    return
  end
  local msg = ChatMsgBuilder.BuildChannelMsg(p, ChatMsgData.Channel.CITY)
  instance.msgData:AddMsg(msg)
  ChannelChatPanel.Instance():AddMsg(msg)
end
def.static("table").OnMapChat = function(p)
  local ret = ChatModule.Instance():HandleChannelSceret(p, ChatMsgData.Channel.CURRENT)
  if ret then
    if ret.translate then
      local params = {
        roleId = ret.translate.roleId,
        content = require("Main.Chat.HtmlHelper").ConvertPopChat(ret.translate.plainHtml)
      }
      ChatModule.GetBubbleResource(ret.translate.chatBubbleCfgId or 0, params)
      Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.PopChat, params)
    end
    return
  end
  if FriendModule.Instance():IsInShieldList(p.chatContent.roleId) then
    return
  end
  if 0 < instance.SettingMap[ChatModule.SettingEnum.AVOIDMAP] then
    return
  end
  local msg = ChatMsgBuilder.BuildChannelMsg(p, ChatMsgData.Channel.CURRENT)
  instance.msgData:AddMsg(msg)
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  mainUIChat:AddMsg(msg)
  ChannelChatPanel.Instance():AddMsg(msg)
  if msg.text == nil or msg.text ~= textRes.Chat[73] then
    local params = {
      roleId = msg.roleId,
      content = require("Main.Chat.HtmlHelper").ConvertPopChat(msg.plainHtml)
    }
    ChatModule.GetBubbleResource(msg.bubbleId or 0, params)
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.PopChat, params)
  end
  if p.chatContent.contentType == ChatConsts.CONTENT_YY and 0 < instance.SettingMap[ChatModule.SettingEnum.AUTOAUDIOMAP] then
    SpeechMgr.Instance():PlayInQueue(msg.fileId, msg.second)
  end
end
def.static("table").OnSingleBattleChat = function(p)
  local ret = ChatModule.Instance():HandleChannelSceret(p, ChatMsgData.Channel.BATTLEFIELD)
  if ret then
    if ret.translate then
      local params = {
        roleId = ret.translate.roleId,
        content = require("Main.Chat.HtmlHelper").ConvertPopChat(ret.translate.plainHtml)
      }
      ChatModule.GetBubbleResource(ret.translate.chatBubbleCfgId or 0, params)
      Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.PopChat, params)
    end
    return
  end
  if FriendModule.Instance():IsInShieldList(p.chatContent.roleId) then
    return
  end
  local msg = ChatMsgBuilder.BuildChannelMsg(p, ChatMsgData.Channel.BATTLEFIELD)
  instance.msgData:AddMsg(msg)
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  mainUIChat:AddMsg(msg)
  ChannelChatPanel.Instance():AddMsg(msg)
end
def.static("table").OnNewFactionChat = function(p)
  ChatModule.OnFactionChat(p, false)
end
def.static("table").OnHistoryFactionChat = function(p)
  ChatModule.OnFactionChat(p, true)
end
def.static("table", "boolean").OnFactionChat = function(p, bHistory)
  if ChatModule.Instance():HandleChannelSceret(p, ChatMsgData.Channel.FACTION) then
    return
  end
  if FriendModule.Instance():IsInShieldList(p.chatContent.roleId) then
    return
  end
  if instance.SettingMap[ChatModule.SettingEnum.AVOIDGANG] > 0 then
    return
  end
  local msg = ChatMsgBuilder.BuildChannelMsg(p, ChatMsgData.Channel.FACTION)
  instance.msgData:AddMsg(msg)
  if not bHistory then
    AtMgr.Instance():CheckMsgAtMe(ChatConsts.CHANNEL_FACTION, p.chatContent, msg)
  end
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  mainUIChat:AddMsg(msg)
  ChannelChatPanel.Instance():AddMsg(msg)
  if p.chatContent.contentType == ChatConsts.CONTENT_YY and 0 < instance.SettingMap[ChatModule.SettingEnum.AUTOAUDIOGANG] then
    SpeechMgr.Instance():PlayInQueue(msg.fileId, msg.second)
  end
end
def.static("table").OnNewerChat = function(p)
  if ChatModule.Instance():HandleChannelSceret(p, ChatMsgData.Channel.NEWER) then
    return
  end
  if FriendModule.Instance():IsInShieldList(p.chatContent.roleId) then
    return
  end
  if instance.SettingMap[ChatModule.SettingEnum.AVOIDGANG] > 0 then
    return
  end
  local msg = ChatMsgBuilder.BuildChannelMsg(p, ChatMsgData.Channel.NEWER)
  instance.msgData:AddMsg(msg)
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  mainUIChat:AddMsg(msg)
  ChannelChatPanel.Instance():AddMsg(msg)
  if p.chatContent.contentType == ChatConsts.CONTENT_YY and 0 < instance.SettingMap[ChatModule.SettingEnum.AUTOAUDIOGANG] then
    SpeechMgr.Instance():PlayInQueue(msg.fileId, msg.second)
  end
end
def.static("table").OnSChatInTrumpet = function(p)
  if TrumpetMgr.Instance():IsOpen(false) then
    if ChatModule.Instance():HandleChannelSceret(p, ChatMsgData.Channel.TRUMPET) then
      return
    end
    local msg = ChatMsgBuilder.BuildChannelMsg(p, ChatMsgData.Channel.TRUMPET)
    instance.msgData:AddMsg(msg)
    TrumpetQueue.Instance():Push(p.trumpet_cfg_id, msg)
    local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
    mainUIChat:AddMsg(msg)
    ChannelChatPanel.Instance():AddMsg(msg)
  else
    warn("[ChatModule:OnSChatInTrumpet] Trumpet not open!")
  end
end
def.static("table").OnTeamChat = function(p)
  local ret = ChatModule.Instance():HandleChannelSceret(p, ChatMsgData.Channel.TEAM)
  if ret then
    if ret.translate then
      local params = {
        roleId = ret.translate.roleId,
        content = require("Main.Chat.HtmlHelper").ConvertPopChat(ret.translate.plainHtml)
      }
      ChatModule.GetBubbleResource(ret.translate.chatBubbleCfgId or 0, params)
      Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.PopChat, params)
    end
    return
  end
  if FriendModule.Instance():IsInShieldList(p.chatContent.roleId) then
    return
  end
  if 0 < instance.SettingMap[ChatModule.SettingEnum.AVOIDTEAM] then
    return
  end
  local msg = ChatMsgBuilder.BuildChannelMsg(p, ChatMsgData.Channel.TEAM)
  instance.msgData:AddMsg(msg)
  AtMgr.Instance():CheckMsgAtMe(ChatConsts.CHANNEL_TEAM, p.chatContent, msg)
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  mainUIChat:AddMsg(msg)
  ChannelChatPanel.Instance():AddMsg(msg)
  if msg.text == nil or msg.text ~= textRes.Chat[73] then
    local params = {
      roleId = msg.roleId,
      content = require("Main.Chat.HtmlHelper").ConvertPopChat(msg.plainHtml)
    }
    ChatModule.GetBubbleResource(msg.bubbleId or 0, params)
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.PopChat, params)
  end
  if p.chatContent.contentType == ChatConsts.CONTENT_YY and 0 < instance.SettingMap[ChatModule.SettingEnum.AUTOAUDIOTEAM] then
    SpeechMgr.Instance():PlayInQueue(msg.fileId, msg.second)
  end
end
def.static("table").OnFriendChat = function(p)
  warn("OnFriendChat")
  if ChatModule.Instance():HandleChannelSceret(p, ChatMsgData.Channel.FRIEND) then
    return
  end
  if FriendModule.Instance():IsInShieldList(p.chatContent.roleId) then
    return
  end
  local msg = ChatMsgBuilder.BuildChannelMsg(p, ChatMsgData.Channel.FRIEND)
  instance.msgData:AddMsg(msg)
  AtMgr.Instance():CheckMsgAtMe(ChatConsts.CHANNEL_FRIEND, p.chatContent, msg)
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  mainUIChat:AddMsg(msg)
  ChannelChatPanel.Instance():AddMsg(msg)
end
def.static("number", "table").GetBubbleResource = function(bubbleId, params)
  local ChatBubbleMgr = require("Main.Chat.ChatBubble.ChatBubbleMgr")
  if ChatBubbleMgr.IsFeatureOpen() then
    local bubbleCfg = ChatBubbleMgr.GetBubbleCfgById(bubbleId)
    if bubbleCfg then
      params.bubbleName = bubbleCfg.sceneResource
      params.arrowName = bubbleCfg.arrowResource
    end
  end
end
def.static("table").OnActivityChat = function(p)
  if ChatModule.Instance():HandleChannelSceret(p, ChatMsgData.Channel.ACTIVITY) then
    return
  end
  if FriendModule.Instance():IsInShieldList(p.chatContent.roleId) then
    return
  end
  if instance.SettingMap[ChatModule.SettingEnum.AVOIDMAP] > 0 then
    return
  end
  local msg = ChatMsgBuilder.BuildChannelMsg(p, ChatMsgData.Channel.ACTIVITY)
  instance.msgData:AddMsg(msg)
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  mainUIChat:AddMsg(msg)
  ChannelChatPanel.Instance():AddMsg(msg)
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.PopChat, {
    roleId = msg.roleId,
    content = require("Main.Chat.HtmlHelper").ConvertPopChat(msg.plainHtml)
  })
end
def.static("table").OnGroupChat = function(p)
  local groupId = p.groupid
  if nil == groupId then
    return
  end
  ChatModule.Instance().groupChatDirty = true
  ChatModule.Instance():SaveChat(false)
  local self = ChatModule.Instance()
  if self:HandleGroupSecret(p, groupId) then
    return
  end
  local msg = ChatMsgBuilder.BuildGroupMsg(p)
  self.msgData:AddMsg64(msg)
  local bAtMsg = AtMgr.Instance():CheckMsgAtMe(ChatConsts.CHANNEL_GROUP, p.content, msg)
  local SocialDlg = require("Main.friend.ui.SocialDlg")
  if SocialDlg.Instance():CanAddGroupMsg(msg.id) then
    warn("can add group msg ~~~~~~~~~~ ")
    SocialDlg.Instance():AddGroupMsg(msg)
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupChatMsgUpdate, {
      groupId = msg.id,
      newCount = 0
    })
  else
    local k = msg.id:tostring()
    if nil == self.m_GroupNewChatCount[k] then
      self.m_GroupNewChatCount[k] = 0
    end
    if nil == self.m_GroupNewAtCount[k] then
      self.m_GroupNewAtCount[k] = 0
    end
    if not msg.roleId:eq(GetMyRoleID()) then
      self.m_GroupNewChatCount[k] = self.m_GroupNewChatCount[k] + 1
      if bAtMsg then
        self.m_GroupNewAtCount[k] = self.m_GroupNewAtCount[k] + 1
      end
      Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupChatMsgUpdate, {
        groupId = msg.id,
        newCount = self.m_GroupNewChatCount[k]
      })
    end
    Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
      FriendModule.Instance():GetAllFriendCount()
    })
  end
  ChatModule.Instance().groupChatDirty = true
  ChatModule.Instance():SaveChat(false)
end
def.static("table").OnPrivateChat = function(p)
  ChatModule.Instance().friendChatDirty = true
  ChatModule.Instance():SaveChat(false)
  if ChatModule.Instance():HandlePrivateSceret(p) then
    return
  end
  if FriendModule.Instance():IsInShieldList(p.chatContent.roleId) then
    return
  end
  local msg = ChatMsgBuilder.BuildFriendMsg(p)
  instance.msgData:AddMsg64(msg)
  ChatModule.Instance().friendChatDirty = true
  ChatModule.Instance():SaveChat(false)
  if instance.ChatRoleInfoCache[tostring(msg.roleId)] then
    local cache = instance.ChatRoleInfoCache[tostring(msg.roleId)]
    if cache.roleName ~= msg.roleName then
      Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Cache_Name_Change, {
        roleId = msg.roleId,
        roleName = msg.roleName
      })
    end
    cache.roleName = msg.roleName
    if msg.level > 0 then
      cache.roleLevel = msg.level
    end
    if 0 < msg.occupationId then
      cache.occupationId = msg.occupationId
    end
    if 0 < msg.gender then
      cache.sex = msg.gender
    end
    if 0 < msg.avatarId then
      cache.avatarId = msg.avatarId
    end
    if 0 < msg.avatarFrameId then
      cache.avatarFrameId = msg.avatarFrameId
    end
  else
    local cache = {}
    cache.roleName = msg.roleName
    cache.roleLevel = msg.level
    cache.occupationId = msg.occupationId
    cache.sex = msg.gender
    cache.avatarId = msg.avatarId
    cache.avatarFrameId = msg.avatarFrameId
    instance.ChatRoleInfoCache[tostring(msg.roleId)] = cache
  end
  local SocialDlg = require("Main.friend.ui.SocialDlg")
  if not SocialDlg.Instance():CheckCanAdd(msg.id) then
    if instance.friendNewCount[msg.id:tostring()] == nil then
      instance.friendNewCount[msg.id:tostring()] = 0
    end
    if msg.roleId ~= GetMyRoleID() then
      instance.friendNewCount[msg.id:tostring()] = instance.friendNewCount[msg.id:tostring()] + 1
      Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
        FriendModule.Instance():GetAllFriendCount()
      })
    end
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.UpdateFirendMsg, {
      roleId = msg.roleId,
      new = instance:GetChatNewCount(msg.roleId)
    })
  else
    GameUtil.AddGlobalTimer(0.1, true, function()
      Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.UpdateFirendMsg, {
        roleId = msg.id,
        new = 0
      })
    end)
  end
  SocialDlg.Instance():AddMsg(msg)
  if msg.roleId ~= GetMyRoleID() then
    ECSoundMan.Instance():Play2DInterruptSound(ChatModule.PRIVATECHATSOUND)
  end
end
def.static("table").OnHistoryMsg = function(p)
  local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
  if p.channel_type == ChatConsts.CHANNEL_FACTION then
    local gangInfo = require("Main.Gang.data.GangData").Instance():GetGangBasicInfo()
    if gangInfo.gangId and gangInfo.gangId == p.ownerid then
      for k, v in ipairs(p.contents) do
        local SChatInFaction = require("netio.protocol.mzm.gsp.chat.SChatInFaction")
        local protocol = _G.UnmarshalBean(SChatInFaction, v)
        ChatModule.OnHistoryFactionChat(protocol)
      end
      if #p.contents > 0 then
        ChatModule.Instance():SendNoteMsg(textRes.Chat[76], ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
      end
    end
  end
end
def.static("table").OnJoinCityRoom = function(p)
  if p.retcode == 0 then
    ChatModule.Instance().province = p.province
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CityChatChange, nil)
    local cityName = ChatModule.Instance():GetCurProvinceName()
    Toast(string.format(textRes.Chat[66], cityName))
  else
    if p.retcode == -1 then
      local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
      PersonalInfoInterface.Instance():CheckPersonalInfo(GetMyRoleID(), "")
    end
    ChatModule.Instance().province = -1
    local str = textRes.Chat.JoinRoomErr[p.retcode]
    warn("JoinRoomErr", p.retcode)
    if str then
      Toast(str)
    end
  end
end
def.static("table").OnSendFail = function(p)
  local reason = p.reason
  local str = textRes.Chat.error[reason]
  if str then
    Toast(str)
  end
end
def.static("table").OnNormalResult = function(p)
  if p.result == p.CUT_VIGOR_SUC then
    local energy = p.args[1]
    local num = tonumber(energy)
    if num and num > 0 then
      Toast(string.format(textRes.Chat[31], energy))
    end
  elseif IsCrossingServer() then
    local err = textRes.Chat.CrossServerResult[p.result]
    if err then
      Toast(err)
    end
  else
    local err = textRes.Chat.NormalResult[p.result]
    if err then
      Toast(err)
    end
  end
end
def.static("table").OnInfoPack = function(p)
  local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
  if p.packettype == ChatConst.CONTENT_PACKET_BAG then
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    local source = require("Main.Hero.HeroModule").Instance().roleId == p.checkedroleid and ItemTipsMgr.Source.ChatSelf or ItemTipsMgr.Source.ChatOther
    local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
    local iteminfo = UnmarshalBean(ItemInfo, p.checkInfo)
    if iteminfo then
      ItemTipsMgr.Instance():ShowTips(iteminfo, 0, 0, source, 0, 0, 0, 0, 0)
    end
  elseif p.packettype == ChatConst.CONTENT_PACKET_PET then
    local PetData = require("Main.Pet.data.PetData")
    local pd = PetData()
    local PetInfo = require("netio.protocol.mzm.gsp.pet.PetInfo")
    local petinfo = UnmarshalBean(PetInfo, p.checkInfo)
    if petinfo then
      pd:RawSet(petinfo)
      require("Main.Pet.ui.PetInfoPanel").Instance():ShowPanel(pd)
    end
  elseif p.packettype == ChatConst.CONTENT_PACKET_MOUNTS then
    local MountsInfo = require("netio.protocol.mzm.gsp.mounts.MountsInfo")
    local mountsInfo = UnmarshalBean(MountsInfo, p.checkInfo)
    if mountsInfo then
      require("Main.Mounts.MountsModule").ShowMountsInfo(mountsInfo)
    end
  end
end
def.method("userdata", "string", "number", "number", "number", "number").SetChatRoleCache = function(self, roleId, name, level, occupation, gender, avatarId)
  self:SetChatRoleCache2(roleId, name, level, occupation, gender, avatarId, 0)
end
def.method("userdata", "string", "number", "number", "number", "number", "number").SetChatRoleCache2 = function(self, roleId, name, level, occupation, gender, avatarId, avatarFrameId)
  if instance.ChatRoleInfoCache[tostring(roleId)] then
    local cache = instance.ChatRoleInfoCache[tostring(roleId)]
    if name ~= "" then
      cache.roleName = name
    end
    if level > 0 then
      cache.roleLevel = level
    end
    if occupation > 0 then
      cache.occupationId = occupation
    end
    if gender > 0 then
      cache.sex = gender
    end
    if avatarId > 0 then
      cache.avatarId = avatarId
    end
    if avatarFrameId > 0 then
      cache.avatarFrameId = avatarFrameId
    end
  else
    local cache = {}
    cache.roleName = name
    cache.roleLevel = level
    cache.occupationId = occupation
    cache.sex = gender
    cache.avatarId = avatarId
    cache.avatarFrameId = avatarFrameId
    instance.ChatRoleInfoCache[tostring(roleId)] = cache
  end
end
def.method("table", "number", "=>", "table").HandleChannelSceret = function(self, rawMsg, channel)
  if rawMsg.chatContent.contentType == ChatConsts.CONTENT_NULL then
    local content = ChatMsgBuilder.Unmarshal(rawMsg.chatContent.content)
    local result = json.decode(content)
    if result.translate then
      do
        local fileId = result.fileId
        if result.text == nil then
          result.text = ""
        end
        result.text = ChatMsgBuilder.CustomFilter(result.text)
        result.text = (result.text == "" or result.text == " ") and textRes.Chat[23] or result.text
        local text = result.text
        local msgs = self.msgData.msgData[ChatMsgData.MsgType.CHANNEL][channel]
        if msgs then
          local find, index = msgs:SearchOne(function(m)
            return m.fileId == fileId
          end)
          if find then
            find.text = text
            find.mainHtml = HtmlHelper.ConvertYYJsonMain(find)
            find.plainHtml = HtmlHelper.ConvertYYJsonChat(find, false)
            ChannelChatPanel.Instance():UpdateOneMsg(find)
            local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
            mainUIChat:UpdateOneMsg(find)
            return {translate = find}
          end
        end
      end
    end
    return {}
  else
    return nil
  end
end
def.method("table", "userdata", "=>", "boolean").HandleGroupSecret = function(self, rawMsg, groupId)
  if rawMsg.content.contentType == ChatConsts.CONTENT_NULL then
    local content = ChatMsgBuilder.Unmarshal(rawMsg.content.content)
    local result = json.decode(content)
    if result.translate then
      do
        local fileId = result.fileId
        if result.text == nil then
          result.text = ""
        end
        result.text = ChatMsgBuilder.CustomFilter(result.text)
        result.text = (result.text == "" or result.text == " ") and textRes.Chat[23] or result.text
        local text = result.text
        local msgs = self.msgData.msgData[ChatMsgData.MsgType.GROUP][groupId:tostring()]
        if msgs then
          local find, index = msgs:SearchOne(function(m)
            return m.fileId == fileId
          end)
          if find then
            find.text = text
            find.plainHtml = HtmlHelper.ConvertYYJsonChat(find, false)
            find.mainHtml = find.plainHtml
            local SocialDlg = require("Main.friend.ui.SocialDlg")
            SocialDlg.Instance():UpdateOneGroupMsg(find)
          end
        end
      end
    end
    return true
  else
    return false
  end
end
def.method("table", "=>", "boolean").HandlePrivateSceret = function(self, rawMsg)
  if rawMsg.chatContent.contentType == ChatConsts.CONTENT_NULL then
    local content = ChatMsgBuilder.Unmarshal(rawMsg.chatContent.content)
    local result = json.decode(content)
    if result.translate then
      do
        local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
        local roleId
        if heroProp.id == rawMsg.listenerId then
          roleId = rawMsg.senderId
        else
          roleId = rawMsg.listenerId
        end
        local fileId = result.fileId
        if result.text == nil then
          result.text = ""
        end
        result.text = ChatMsgBuilder.CustomFilter(result.text)
        result.text = (result.text == "" or result.text == " ") and textRes.Chat[23] or result.text
        local text = result.text
        local msgs = self.msgData.msgData[ChatMsgData.MsgType.FRIEND][roleId:tostring()]
        if msgs then
          local find, index = msgs:SearchOne(function(m)
            return m.fileId == fileId
          end)
          if find then
            find.text = text
            find.plainHtml = HtmlHelper.ConvertYYJsonChat(find, false)
            find.mainHtml = find.plainHtml
            local SocialDlg = require("Main.friend.ui.SocialDlg")
            SocialDlg.Instance():UpdateOneMsg(find)
          end
        end
      end
    end
    return true
  else
    return false
  end
end
def.method().RequestJoinCityRoom = function(self)
  warn("RequestJoinCityRoom", self.province)
  if self.province < 0 then
    if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHAT_ROOM) then
      Toast(textRes.Chat[70])
      return
    end
    local p = require("netio.protocol.mzm.gsp.chat.CJoinChatRoomReq").new()
    gmodule.network.sendProtocol(p)
    self.province = 0
    Toast(textRes.Chat[62])
    GameUtil.AddGlobalTimer(8, true, function()
      if self.province == 0 then
        self.province = -1
        Toast(textRes.Chat[69])
      end
    end)
  else
    if self.province == 0 then
      Toast(textRes.Chat[63])
    else
    end
  end
end
def.method("=>", "string").GetCurProvinceName = function(self)
  if self.province > 0 then
    local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
    local provinceCfg = PersonalInfoInterface.GetPersonalOptionCfg(self.province)
    if provinceCfg then
      return provinceCfg.content
    else
      return textRes.Chat[65]
    end
  else
    return textRes.Chat[64]
  end
end
def.static("table").OnSFabaoChatInfo = function(p)
  if nil == p then
    return
  end
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local myRoleId = require("Main.Hero.HeroModule").Instance().roleId
  local roleId = p.checkedroleid
  local fabaoInfo = p.iteminfo
  local source = myRoleId == roleId and ItemTipsMgr.Source.ChatSelf or ItemTipsMgr.Source.ChatOther
  if fabaoInfo then
    ItemTipsMgr.Instance():ShowTips(fabaoInfo, 0, 0, source, 0, 0, 0, 0, 0)
  end
end
def.method("string").RequestFabaoPackInfo = function(self, id)
  local strs = string.split(id, "_")
  local roleId = Int64.new(strs[2])
  local fabaoUuid = Int64.new(strs[3])
  local p = require("netio.protocol.mzm.gsp.chat.CPacketFaBaoInChat").new(roleId, fabaoUuid)
  gmodule.network.sendProtocol(p)
end
def.method("string").RequestFabaoLingQiPackInfo = function(self, id)
  local strs = string.split(id, "_")
  local roleId = Int64.new(strs[2])
  local classId = tonumber(strs[3])
  require("Main.FabaoSpirit.FabaoSpiritInterface").ShowRoleLQTips(roleId, classId)
end
def.method("string").RequestInfoPack = function(self, id)
  if string.find(id, "item_") then
    local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
    local strs = string.split(id, "_")
    local PackInfo = require("netio.protocol.mzm.gsp.chat.PacketInfo").new(Int64.new(strs[3]))
    local CPacketInChat = require("netio.protocol.mzm.gsp.chat.CPacketInChat").new(Int64.new(strs[2]), ChatConst.CONTENT_PACKET_BAG, PackInfo)
    gmodule.network.sendProtocol(CPacketInChat)
  elseif string.find(id, "wing_") then
    local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
    local strs = string.split(id, "_")
    local wingId = tonumber(strs[2])
    local roleId = Int64.new(strs[3])
    require("Main.Wing.WingInterface").CheckWing(roleId, wingId)
  elseif string.find(id, "aircraft_") then
    local strs = string.split(id, "_")
    local aircraftId = tonumber(strs[2])
    local roleId = Int64.new(strs[3])
    require("Main.Aircraft.AircraftInterface").CheckChatAircraft(roleId, aircraftId)
  elseif string.find(id, "pet_") then
    local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
    local strs = string.split(id, "_")
    local PackInfo = require("netio.protocol.mzm.gsp.chat.PacketInfo").new(Int64.new(strs[3]))
    local CPacketInChat = require("netio.protocol.mzm.gsp.chat.CPacketInChat").new(Int64.new(strs[2]), ChatConst.CONTENT_PACKET_PET, PackInfo)
    gmodule.network.sendProtocol(CPacketInChat)
  elseif string.find(id, "task_") then
    local index = tonumber(string.sub(id, 6))
    if index ~= nil then
      local TaskTips = require("Main.task.ui.TaskTips")
      TaskTips.Instance():ShowDlg(index)
    end
  elseif string.find(id, "fashion_") then
    local fashionType = tonumber(string.sub(id, 9))
    require("Main.Fashion.FashionModule").ShowFashionTips(fashionType)
  elseif string.sub(id, 1, 5) == "zone_" then
    local strs = string.split(id, "_")
    local roleId = Int64.new(strs[2])
    local url = strs[3]
    local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
    PersonalInfoInterface.Instance():CheckPersonalInfo(roleId, url)
  elseif string.sub(id, 1, 7) == "mounts_" then
    local strs = string.split(id, "_")
    local roleId = Int64.new(strs[2])
    local mountsId = Int64.new(strs[3])
    local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
    local PackInfo = require("netio.protocol.mzm.gsp.chat.PacketInfo").new(mountsId)
    local CPacketInChat = require("netio.protocol.mzm.gsp.chat.CPacketInChat").new(roleId, ChatConst.CONTENT_PACKET_MOUNTS, PackInfo)
    gmodule.network.sendProtocol(CPacketInChat)
  end
end
def.method("userdata", "string", "number", "number", "number", "number", "number").StartPrivateChat3 = function(self, roleId, roleName, lv, menpai, sex, avatarId, avatarFrameId)
  self:_StartPrivateChat(roleId, roleName, lv, menpai, sex, avatarId, avatarFrameId, false)
end
def.method("userdata", "string", "number", "number", "number", "number").StartPrivateChat2 = function(self, roleId, roleName, lv, menpai, sex, avatarId)
  warn("Obsolete: Use StartPrivateChat3 instead")
  self:_StartPrivateChat(roleId, roleName, lv, menpai, sex, avatarId, 0, false)
end
def.method("userdata", "string", "number", "number", "number").StartPrivateChat = function(self, roleId, roleName, lv, menpai, sex)
  warn("Obsolete: Use StartPrivateChat3 instead")
  self:_StartPrivateChat(roleId, roleName, lv, menpai, sex, 0, 0, false)
end
def.method("userdata", "string", "number", "number", "number", "number", "number", "boolean")._StartPrivateChat = function(self, roleId, roleName, lv, menpai, sex, avatarId, avatarFrameId, fromInner)
  if self.ChatRoleInfoCache[tostring(roleId)] then
    local cache = self.ChatRoleInfoCache[tostring(roleId)]
    if cache.roleName ~= roleName then
      Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Cache_Name_Change, {roleId = roleId, roleName = roleName})
      cache.roleName = roleName
    end
    if lv > 0 then
      cache.roleLevel = lv
    end
    if menpai > 0 then
      cache.occupationId = menpai
    end
    if sex > 0 then
      cache.sex = sex
    end
    if avatarId > 0 then
      cache.avatarId = avatarId
    end
    if avatarFrameId > 0 then
      cache.avatarFrameId = avatarFrameId
    end
  else
    local cache = {}
    cache.roleName = roleName
    cache.roleLevel = lv
    cache.occupationId = menpai
    cache.sex = sex
    cache.avatarId = avatarId
    cache.avatarFrameId = avatarFrameId
    self.ChatRoleInfoCache[tostring(roleId)] = cache
  end
  self.msgData:InitMsg64(ChatMsgData.MsgType.FRIEND, roleId)
  require("Main.friend.ui.SocialDlg").ShowPrivateChat(roleId, roleName, fromInner)
  require("Main.friend.FriendModule").UpdateFriendChange()
end
def.method("userdata", "table").UpdateFriendLevelInChat = function(self, chatId, msg)
  if self.ChatRoleInfoCache[tostring(chatId)] then
    local cache = self.ChatRoleInfoCache[tostring(chatId)]
    if not cache then
      return
    end
    local cacheLevel = cache.roleLevel
    local cacheOccupation = cache.occupationId
    local cacheAvatarId = cache.avatarId
    local cacheAvatarFrameId = cache.avatarFrameId
    if msg and cacheLevel then
      local myLv = require("Main.Hero.Interface").GetHeroProp().level
      for k, v in pairs(msg) do
        if chatId == v.roleId then
          v.level = cacheLevel
        else
          v.level = myLv
        end
      end
    end
    if msg and cacheOccupation then
      local myOccupation = require("Main.Hero.Interface").GetHeroProp().occupation
      for k, v in pairs(msg) do
        if chatId == v.roleId then
          v.occupationId = cacheOccupation
        else
          v.occupationId = myOccupation
        end
      end
    end
    if msg and cacheAvatarId then
      local myAvatar = require("Main.Avatar.AvatarInterface").Instance():getCurAvatarId()
      for k, v in pairs(msg) do
        if chatId == v.roleId then
          v.avatarId = cacheAvatarId
        else
          v.avatarId = myAvatar
        end
      end
    end
    if msg and cacheAvatarFrameId then
      local avatarFrameId = require("Main.Avatar.AvatarInterface").Instance():getCurAvatarFrameId()
      for k, v in pairs(msg) do
        if chatId == v.roleId then
          v.avatarFrameId = cacheAvatarFrameId
        else
          v.avatarFrameId = avatarFrameId
        end
      end
    end
  end
end
def.method("userdata").ShowGroupChatPanel = function(self, groupId)
  if nil == groupId then
    return
  end
  local SocialDlg = require("Main.friend.ui.SocialDlg")
  SocialDlg.ShowGroupChat(groupId)
end
def.method("userdata", "=>", "number").GetGroupChatNewCount = function(self, groupId)
  local GroupModule = require("Main.Group.GroupModule")
  local AtData = require("Main.Chat.At.data.AtData")
  local count = 0
  if nil == groupId then
    for k, v in pairs(self.m_GroupNewChatCount) do
      local isShield = GroupModule.Instance():GetMessageShildState(Int64.new(k))
      if not isShield then
        count = count + v
      end
    end
    if AtMgr.Instance():IsOpen(false) then
      for k, v in pairs(self.m_GroupNewAtCount) do
        local isShield = GroupModule.Instance():GetMessageShildState(Int64.new(k))
        if not isShield then
          count = count - v
        else
        end
      end
      count = count + AtData.Instance():GetGroupAtMsgCount()
    else
    end
  else
    local groupShieldState = GroupModule.Instance():GetMessageShildState(groupId)
    if not groupShieldState then
      local key = groupId:tostring()
      if self.m_GroupNewChatCount[key] then
        count = self.m_GroupNewChatCount[key]
      end
      if AtMgr.Instance():IsOpen(false) then
        if self.m_GroupNewAtCount[key] then
          count = count - self.m_GroupNewAtCount[key]
        end
        local orgAtData = AtData.Instance():GetOrgAtMsg(ChatConsts.CHANNEL_GROUP, groupId)
        local atMsgCount = orgAtData and orgAtData:GetMsgCount() or 0
        if atMsgCount > 0 then
          count = count + atMsgCount
        end
      end
    end
  end
  return count
end
def.method("userdata", "=>", "number").GetChatNewCount = function(self, roleId)
  local ret = 0
  if roleId == nil then
    for k, v in pairs(self.friendNewCount) do
      ret = ret + v
    end
  elseif self.friendNewCount[roleId:tostring()] ~= nil then
    ret = self.friendNewCount[roleId:tostring()]
  end
  return ret
end
def.method("=>", "number").GetFriendNewCount = function(self)
  local FriendData = require("Main.friend.FriendData")
  local ret = 0
  for k, v in pairs(self.friendNewCount) do
    if FriendData.Instance():GetFriendInfo(Int64.new(k)) then
      ret = ret + v
    end
  end
  return ret
end
def.method("userdata", "=>", "table").GetGroupNewOne = function(self, groupId)
  if nil == groupId then
    return nil
  end
  return self.msgData:GetOneNewMsg64(ChatMsgData.MsgType.GROUP, groupId)
end
def.method("userdata").ClearGroupNewCount = function(self, groupId)
  if nil == groupId then
    self.m_GroupNewChatCount = {}
    self.m_GroupNewAtCount = {}
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, {})
  else
    local key = groupId:tostring()
    local newCount = self.m_GroupNewChatCount[key]
    if newCount and newCount > 0 then
      self.m_GroupNewChatCount[key] = nil
    end
    local newAtCount = self.m_GroupNewAtCount[key]
    if newAtCount and newAtCount > 0 then
      self.m_GroupNewAtCount[key] = nil
    end
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, {groupId = groupId})
  end
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
    FriendModule.Instance():GetAllFriendCount()
  })
end
def.method("userdata", "=>", "table").GetFriendNewOne = function(self, roleId)
  return self.msgData:GetOneNewMsg64(ChatMsgData.MsgType.FRIEND, roleId)
end
def.method("userdata").ClearFriendNewCount = function(self, roleId)
  if roleId == nil then
    self.friendNewCount = {}
    Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
      FriendModule.Instance():GetAllFriendCount()
    })
  else
    local friendNewCount = self.friendNewCount[roleId:tostring()]
    if friendNewCount and friendNewCount > 0 then
      self.friendNewCount[roleId:tostring()] = nil
      Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
        FriendModule.Instance():GetAllFriendCount()
      })
    end
  end
end
def.method("number", "number", "table").SendSystemMsg = function(self, id, style, content)
  local inShowInMainUIChat = false
  if id ~= ChatMsgData.System.SYS and id ~= ChatMsgData.System.PERSONAL then
    inShowInMainUIChat = true
  end
  self:SendSystemMsgEx(id, style, content, inShowInMainUIChat)
end
def.method("number", "number", "table", "boolean").SendSystemMsgEx = function(self, id, style, content, inShowInMainUIChat)
  local msg = ChatMsgBuilder.BuildSystemMsg(id, style, content)
  instance.msgData:AddMsg(msg)
  if inShowInMainUIChat then
    local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
    mainUIChat:AddMsg(msg)
  end
  ChannelChatPanel.Instance():AddMsg(msg)
end
def.method("string", "number", "number").SendNoteMsg = function(self, content, type, id)
  local msg = ChatMsgBuilder.BuildNoteMsg(type, id, content)
  instance.msgData:AddMsg(msg)
  if msg.type == ChatMsgData.MsgType.SYSTEM then
  else
    local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
    mainUIChat:AddMsg(msg)
  end
  ChannelChatPanel.Instance():AddMsg(msg)
end
def.method("number", "=>", "number").CanChat = function(self, type)
  return os.time() - self.ChatLimit[type].lastTime - self.ChatLimit[type].timeLag
end
def.method("number").ReCount = function(self, type)
  self.ChatLimit[type].lastTime = os.time()
end
def.method("string", "number", "boolean", "=>", "boolean").SendChannelMsg = function(self, content, type, voice)
  local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
  if type == ChatConst.CHANNEL_CHAT_ROOM and not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHAT_ROOM) then
    Toast(textRes.Chat[70])
    return false
  end
  if type == ChatConst.CHANNEL_ANCHOR then
    if not require("ProxySDK.ECApollo").IsJoinRoom() then
      Toast(textRes.Chat[44])
      return false
    end
    if voice then
      Toast(textRes.Chat[38])
      return false
    end
  end
  local ltime = self:CanChat(type)
  if ltime <= 0 then
    Toast(string.format(textRes.Chat[18], ltime == 0 and 1 or 0 - ltime))
    return false
  end
  local level = require("Main.Hero.Interface").GetHeroProp().level
  if level < self.ChatLimit[type].levelLimit then
    Toast(string.format(textRes.Chat[17], self.ChatLimit[type].levelLimit))
    return false
  end
  if ChatConst.CHANNEL_TEAM == type then
    local TeamData = require("Main.Team.TeamData")
    if TeamData.Instance():HasTeam() == false then
      Toast(textRes.Chat[5])
      return false
    end
  elseif ChatConst.CHANNEL_FRIEND == type then
    local friends = FriendModule.Instance():GetFriends()
    if #friends == 0 then
      Toast(textRes.Chat[92])
      return false
    end
  elseif ChatConst.CHANNEL_FACTION == type then
    if not require("Main.Gang.GangModule").Instance():HasGang() then
      Toast(textRes.Chat[61])
      return false
    end
  elseif ChatConst.CHANNEL_CHAT_ROOM == type and 0 >= self.province then
    Toast(textRes.Chat[67])
    return false
  end
  local myVigorNum = require("Main.Hero.Interface").GetHeroProp().energy
  if myVigorNum < self.ChatLimit[type].energyConsume then
    Toast(textRes.Chat.error[23])
    return false
  end
  if ChatConst.CHANNEL_FACTION == type then
    local myRoleId = require("Main.Hero.HeroModule").Instance().roleId
    local leftTime = require("Main.Gang.GangModule").Instance():GetRemainForbiddenTime(myRoleId)
    if leftTime > 0 then
      local timeStr = ""
      if leftTime < 60 then
        timeStr = string.format(textRes.Chat[15], leftTime)
      else
        timeStr = string.format(textRes.Chat[16], math.floor(leftTime / 60))
      end
      Toast(string.format(textRes.Gang[163], timeStr))
      return false
    end
  end
  local chatContent = require("netio.Octets").rawFromString(content)
  local contentType = ChatConst.CONTENT_NORMAL
  if voice then
    contentType = ChatConst.CONTENT_YY
  end
  if ChatConst.CHANNEL_NEWER == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInNewer").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_FACTION == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInFaction").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_TEAM == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInTeam").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_FRIEND == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInFriend").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_CURRENT == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInMap").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_SINGLE_BATTLE__CAMP == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInSingleBattleCamp").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_WORLD == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInWorld").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_ACTIVITY == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInActivity").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_ANCHOR == type then
    local roomType = require("ProxySDK.ECApollo").GetCurrentRoomType()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInAnchor").new(roomType, contentType, chatContent))
  elseif ChatConst.CHANNEL_CHAT_ROOM == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInRoomReq").new(contentType, chatContent))
  end
  self:ReCount(type)
  return true
end
def.method("userdata", "string", "boolean").SendGroupChatMsg = function(self, groupId, content, voice)
  warn("~~~~~~~SendGroupChatMsg~~~~~~~~~~", groupId, voice)
  if groupId then
    local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
    local chatContent = require("netio.Octets").rawFromString(content)
    local contentType = ChatConst.CONTENT_NORMAL
    if voice then
      contentType = ChatConst.CONTENT_YY
    end
    local p = require("netio.protocol.mzm.gsp.chat.CChatInGroupReq").new(groupId, contentType, chatContent)
    gmodule.network.sendProtocol(p)
  end
end
def.method("userdata", "string", "boolean").SendPrivateMsg = function(self, roleId, content, voice)
  if roleId then
    local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
    local chatContent = require("netio.Octets").rawFromString(content)
    local contentType = ChatConst.CONTENT_NORMAL
    if voice then
      contentType = ChatConst.CONTENT_YY
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatToSomeOne").new(roleId, contentType, chatContent))
  end
end
def.method("userdata", "string").SendGroupSecrect = function(self, groupId, content)
  if nil == groupId then
    return
  end
  local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
  local chatContent = require("netio.Octets").rawFromString(content)
  local contentType = ChatConst.CONTENT_NULL
  local p = require("netio.protocol.mzm.gsp.chat.CChatInGroupReq").new(groupId, contentType, chatContent)
  gmodule.network.sendProtocol(p)
end
def.method("number", "=>", "number").CanSendSceret = function(self, type)
  warn("self.ChatLimit[type].sceretLag", self.ChatLimit[type].sceretLag)
  return os.time() - self.ChatLimit[type].lastSercetTime - self.ChatLimit[type].sceretLag
end
def.method("number").ReCountSceret = function(self, type)
  self.ChatLimit[type].lastSercetTime = os.time()
end
def.method("string", "number", "=>", "number").SendChannelSecret = function(self, content, type)
  local ltime = self:CanSendSceret(type)
  if ltime < 0 then
    return ltime * -1
  end
  local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
  local chatContent = require("netio.Octets").rawFromString(content)
  local contentType = ChatConst.CONTENT_NULL
  warn("SendChannelSecret", content, type)
  if ChatConst.CHANNEL_NEWER == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInNewer").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_FACTION == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInFaction").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_TEAM == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInTeam").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_FRIEND == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInFriend").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_CURRENT == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInMap").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_WORLD == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInWorld").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_ACTIVITY == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInActivity").new(contentType, chatContent))
  elseif ChatConst.CHANNEL_ANCHOR == type then
    local roomType = require("ProxySDK.ECApollo").GetCurrentRoomType()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInAnchor").new(roomType, contentType, chatContent))
  elseif ChatConst.CHANNEL_CHAT_ROOM == type then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInRoomReq").new(contentType, chatContent))
  end
  self:ReCountSceret(type)
  return 0
end
def.method("userdata", "string").SendPrivateSecret = function(self, roleId, content)
  if roleId then
    local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
    local chatContent = require("netio.Octets").rawFromString(content)
    local contentType = ChatConst.CONTENT_NULL
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatToSomeOne").new(roleId, contentType, chatContent))
  end
end
def.method().SaveChatPreset = function(self)
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  if self.QuickChatMap == nil then
    PlayerPref.DeleteAccountKey(ChatModule.QUICKCHATMAP)
  else
    PlayerPref.SetAccountTable(ChatModule.QUICKCHATMAP, self.QuickChatMap)
  end
  PlayerPref.Save()
end
def.method("=>", "table").LoadChatPreset = function(self)
  if self.QuickChatMap then
    return self.QuickChatMap
  end
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  if PlayerPref.HasAccountKey(ChatModule.QUICKCHATMAP) then
    self.QuickChatMap = PlayerPref.GetAccountTable(ChatModule.QUICKCHATMAP)
  else
    self.QuickChatMap = ChatUtils.GetChatPreset()
  end
  return self.QuickChatMap
end
def.method().LoadChatSetting = function(self)
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  if PlayerPref.HasGlobalKey(ChatModule.CHATSETTING) then
    local chatSetting = PlayerPref.GetGlobalTable(ChatModule.CHATSETTING)
    if chatSetting ~= nil then
      for k, v in pairs(chatSetting) do
        self.SettingMap[k] = v
      end
    end
  end
end
def.method().SaveChatSetting = function(self)
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  if self.SettingMap ~= nil then
    PlayerPref.SetGlobalTable(ChatModule.CHATSETTING, self.SettingMap)
  end
  PlayerPref.Save()
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.ChatSetting_Change, nil)
end
def.method("boolean").SaveChat = function(self, force)
  if force then
    self:SaveFriendChat()
    self:SaveGroupChat()
  else
    if self.friendChatDirty and os.time() - self.friendSaveTime > ChatModule.SAVEINTERVAL then
      warn("save friend Chat")
      self:SaveFriendChat()
      self.friendChatDirty = false
      self.friendSaveTime = os.time()
    end
    if self.groupChatDirty and os.time() - self.groupSaveTime > ChatModule.SAVEINTERVAL then
      self:SaveGroupChat()
      self.groupChatDirty = false
      self.groupSaveTime = os.time()
    end
  end
end
def.method().SaveGroupChat = function(self)
  if nil == self.msgData then
    return
  end
  local GroupModule = require("Main.Group.GroupModule")
  local groupChatMsgs = self.msgData.msgData[ChatMsgData.MsgType.GROUP]
  local chatMsgMap = {}
  local newCountMap = {}
  local newAtCountMap = {}
  for k, v in pairs(groupChatMsgs) do
    local groupId = Int64.new(k)
    if GroupModule.Instance():IsGroupExist(groupId) then
      local newCount = self.m_GroupNewChatCount[k]
      if newCount and newCount > 0 then
        newCountMap[k] = newCount
      end
      local newAtCount = self.m_GroupNewAtCount[k]
      if newAtCount and newAtCount > 0 then
        newAtCountMap[k] = newAtCount
      end
      local saveMsgs = {}
      local msgList = v:GetListReverse(-1)
      for k1, v1 in pairs(msgList) do
        if not v1.delete then
          local msg = ChatMsgBuilder.FriendMsgToLocalMsg(v1)
          if msg then
            table.insert(saveMsgs, msg)
          end
        end
      end
      chatMsgMap[k] = saveMsgs
    end
  end
  local tobeSaved = {
    msg = chatMsgMap,
    new = newCountMap,
    newAt = newAtCountMap
  }
  local myRoleId = self.roleIdBackUp
  if myRoleId then
    local roleIdString = string.format(myRoleId:tostring())
    local configPath = string.format("%s/%s/%s.lua", Application.persistentDataPath, ChatModule.GROUPMSGPATH, roleIdString)
    GameUtil.CreateDirectoryForFile(configPath)
    require("Main.Common.LuaTableWriter").SaveTable(ChatModule.CHATRECORD, configPath, tobeSaved)
  end
end
def.method().SaveFriendChat = function(self)
  if self.msgData == nil then
    return
  end
  local FriendData = require("Main.friend.FriendData")
  local friendMsg = self.msgData.msgData[ChatMsgData.MsgType.FRIEND]
  local saveMsg = {}
  local newMsg = {}
  for k, v in pairs(friendMsg) do
    local friend = FriendData.Instance():GetFriendInfo(Int64.new(k))
    if friend then
      local msgList = v:GetListReverse(-1)
      for k1, v1 in ipairs(msgList) do
        if not v1.delete then
          local msg = ChatMsgBuilder.FriendMsgToLocalMsg(v1)
          if msg then
            table.insert(saveMsg, msg)
          end
        end
      end
      local newCount = self.friendNewCount[k]
      if newCount and newCount > 0 and #msgList > 0 then
        newMsg[k] = newCount
      end
    end
  end
  local toBeSaved = {msg = saveMsg, new = newMsg}
  local myRoleId = self.roleIdBackUp
  if myRoleId then
    local roleIdString = myRoleId:tostring()
    local configPath = string.format("%s/%s/%s.lua", Application.persistentDataPath, ChatModule.SAVEPATH, roleIdString)
    GameUtil.CreateDirectoryForFile(configPath)
    require("Main.Common.LuaTableWriter").SaveTable(ChatModule.CHATRECORD, configPath, toBeSaved)
  end
end
def.method().LoadGroupChat = function(self)
  local myRoleId = GetMyRoleID()
  if nil == myRoleId then
    return
  end
  local roleIdString = myRoleId:tostring()
  local configPath = string.format("%s/%s/%s.lua", Application.persistentDataPath, ChatModule.GROUPMSGPATH, roleIdString)
  warn("configPath", configPath)
  local chunk, errorMsg = loadfile(configPath)
  if chunk then
    local record = chunk()
    if not record then
      Debug.LogWarning("Load Chat msg fail\n", errorMsg, chunk)
      return
    end
    local msgs = record.msg
    local newCounts = record.new
    local newAtCounts = record.newAt
    if msgs then
      for k, v in pairs(msgs) do
        for _, v1 in pairs(v) do
          local msg = ChatMsgBuilder.LocalMsgToFriendMsg(v1)
          if msg.plainHtml then
            self.msgData:AddMsg64(msg)
          end
        end
      end
    end
    if newAtCounts then
      for k, v in pairs(newAtCounts) do
        self.m_GroupNewAtCount[k] = v
      end
    end
    if newCounts then
      local hasNew = false
      for k, v in pairs(newCounts) do
        hasNew = true
        self.m_GroupNewChatCount[k] = v
      end
      if hasNew then
        Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
          FriendModule.Instance():GetAllFriendCount()
        })
      end
    end
  else
    Debug.LogWarning("Can't find group Chat msg record, will create it when first save chat record")
  end
end
def.method().LoadFriendChat = function(self)
  local myRoleId = GetMyRoleID()
  if myRoleId then
    local roleIdString = myRoleId:tostring()
    local configPath = string.format("%s/%s/%s.lua", Application.persistentDataPath, ChatModule.SAVEPATH, roleIdString)
    local chunk, errorMsg = loadfile(configPath)
    if chunk then
      local record = chunk()
      if not record then
        warn("Load Chat msg fail\n", errorMsg, chunk)
        return
      end
      local msgs = record.msg
      local new = record.new
      if msgs then
        for k, v in ipairs(msgs) do
          local msg = ChatMsgBuilder.LocalMsgToFriendMsg(v)
          self.msgData:AddMsg64(msg)
        end
      end
      if new then
        local FriendData = require("Main.friend.FriendData")
        local hasNew = false
        for k, v in pairs(new) do
          local f = FriendData.Instance():GetFriendInfo(Int64.new(k))
          if f then
            hasNew = true
            self.friendNewCount[k] = v
          end
        end
        if hasNew then
          Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
            FriendModule.Instance():GetAllFriendCount()
          })
        end
      end
      print("Load Chat Record")
    else
      print("Can't find Chat msg record, will create it when first save chat record")
    end
  end
end
def.method().GetOutLineChat = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CGetOutLineMsgReq").new())
end
def.method().GetHistroyFactionChat = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CGetOfflineChatContentsReq").new(require("netio.protocol.mzm.gsp.chat.ChatConsts").CHANNEL_FACTION))
end
def.method("=>", "table").GetAllPrivateChat = function(self)
  local friendMsg = self.msgData.msgData[ChatMsgData.MsgType.FRIEND]
  local ret = {}
  for k, v in pairs(friendMsg) do
    local roleId = Int64.new(k)
    local person = self:GeneratePrivatePerson(roleId)
    if person ~= nil then
      table.insert(ret, person)
    end
  end
  return ret
end
def.method("userdata", "=>", "table").GeneratePrivatePerson = function(self, roleId)
  local FriendData = require("Main.friend.FriendData")
  local friend = FriendData.Instance():GetFriendInfo(roleId)
  if friend then
    return friend
  elseif self.ChatRoleInfoCache[tostring(roleId)] then
    local stranger = {}
    local cache = self.ChatRoleInfoCache[tostring(roleId)]
    stranger.roleId = roleId
    stranger.roleName = cache.roleName or textRes.Friend[42]
    stranger.roleLevel = cache.roleLevel or 0
    stranger.occupationId = cache.occupationId or 1
    stranger.sex = cache.sex or 1
    stranger.avatarId = cache.avatarId or 0
    stranger.avatarFrameId = cache.avatarFrameId or 0
    stranger.onlineStatus = 1
    stranger.relationValue = 0
    stranger.teamMemCount = 0
    stranger.delStatus = 3
    return stranger
  else
    return nil
  end
end
def.method("=>", "table").GetStrangerChat = function(self)
  local friendMsg = self.msgData.msgData[ChatMsgData.MsgType.FRIEND]
  local ret = {}
  for k, v in pairs(friendMsg) do
    local roleId = Int64.new(k)
    local stranger = self:GenerateStranger(roleId)
    if stranger ~= nil then
      table.insert(ret, stranger)
    end
  end
  return ret
end
def.method("userdata", "=>", "table").GenerateStranger = function(self, roleId)
  local FriendData = require("Main.friend.FriendData")
  local friend = FriendData.Instance():GetFriendInfo(roleId)
  local stranger
  if friend == nil and self.ChatRoleInfoCache[tostring(roleId)] then
    stranger = {}
    local cache = self.ChatRoleInfoCache[tostring(roleId)]
    stranger.roleId = roleId
    stranger.roleName = cache.roleName or textRes.Friend[42]
    stranger.roleLevel = cache.roleLevel or 0
    stranger.occupationId = cache.occupationId or 1
    stranger.sex = cache.sex or 1
    stranger.avatarId = cache.avatarId or 0
    stranger.avatarFrameId = cache.avatarFrameId or 0
    stranger.onlineStatus = 0
    stranger.relationValue = 0
    stranger.teamMemCount = 0
    stranger.delStatus = 3
  end
  return stranger
end
def.method("string", "=>", "userdata").SearchRoleIdByNameFromCache = function(self, name)
  for k, v in pairs(self.ChatRoleInfoCache) do
    if v.roleName == name then
      return Int64.new(k)
    end
  end
  return nil
end
def.method("string", "string", "string", "string", "number", "boolean").SendWroldQuestionNotice = function(self, mainChatRoleName, mainChatText, plainChatRoleName, plainChatText, plainCharRoleIconId, isSendToSystemChanel)
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  local chatPanel = ChannelChatPanel.Instance()
  local worldMsg = ChatMsgBuilder.BuildWorldQuestionNotice(mainChatRoleName, mainChatText, plainChatRoleName, plainChatText, plainCharRoleIconId)
  self.msgData:AddMsg(worldMsg)
  mainUIChat:AddMsg(worldMsg)
  chatPanel:AddMsg(worldMsg)
  if isSendToSystemChanel then
    local systemMsg = ChatMsgBuilder.BuildSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.System, {text = mainChatText})
    instance.msgData:AddMsg(systemMsg)
    chatPanel:AddMsg(systemMsg)
  end
end
def.method("string", "string", "string", "number").SendWroldQuestion = function(self, questionContent, mainChatTips, plainChatRoleName, plainCharRoleIconId)
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  local chatPanel = ChannelChatPanel.Instance()
  local worldMsg = ChatMsgBuilder.BuildWorldQuestionMsg(questionContent, mainChatTips, plainChatRoleName, plainCharRoleIconId)
  self.msgData:AddMsg(worldMsg)
  mainUIChat:AddMsg(worldMsg)
  chatPanel:AddMsg(worldMsg)
  local systemMsg = ChatMsgBuilder.BuildWorldQuestionSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.System, {question = questionContent, tips = mainChatTips})
  instance.msgData:AddMsg(systemMsg)
  chatPanel:AddMsg(systemMsg)
end
def.method("table").SendTeamPlatformMsg = function(self, msg)
  local mainUIChat = require("Main.MainUI.ui.MainUIChat").Instance()
  local chatPanel = ChannelChatPanel.Instance()
  local msg = ChatMsgBuilder.BuildTeamPlatformMsg(msg)
  self.msgData:AddMsg(msg)
  mainUIChat:AddMsg(msg)
  chatPanel:AddMsg(msg)
end
local AvoidSetMap = {
  [ChatMsgData.Channel.NEWER] = function()
    return ChatModule.SettingEnum.AVOIDGANG
  end,
  [ChatMsgData.Channel.FACTION] = function()
    return ChatModule.SettingEnum.AVOIDGANG
  end,
  [ChatMsgData.Channel.TEAM] = function()
    return ChatModule.SettingEnum.AVOIDTEAM
  end,
  [ChatMsgData.Channel.WORLD] = function()
    return ChatModule.SettingEnum.AVOIDWORLD
  end,
  [ChatMsgData.Channel.LIVE] = function()
    return ChatModule.SettingEnum.AVOIDLIVE
  end,
  [ChatMsgData.Channel.CURRENT] = function()
    return ChatModule.SettingEnum.AVOIDMAP
  end
}
def.method("number", "=>", "boolean").CheckAvoidSetting = function(self, subType)
  local f = AvoidSetMap[subType]
  if not f then
    return false
  end
  local enumNode = f()
  if not enumNode then
    return false
  end
  local isAvoid = self.SettingMap[enumNode]
  if not isAvoid then
    return false
  end
  return isAvoid == 1 and true or false
end
def.method("number", "=>", "number").GetSettingEnum = function(self, subType)
  local f = AvoidSetMap[subType]
  if f then
    return f() or 0
  else
    return 0
  end
end
def.method("number", "string").ShareMyPersonalInfoToChannel = function(self, channel, portraitUrl)
  local bp = require("Main.Hero.Interface").GetBasicHeroProp()
  local roleId = bp.id
  local roleName = bp.name
  local url = portraitUrl ~= "" and portraitUrl or "local"
  local content = string.format("{z:%s,%s,%s}", roleName, roleId:tostring(), url)
  local ret = self:SendChannelMsg(content, channel, false)
  if ret then
    Toast(textRes.Chat[72])
  end
end
ChatModule.Commit()
return ChatModule
