local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChannelChatPanel = Lplus.Extend(ECPanelBase, "ChannelChatPanel")
local ChatViewCtrl = require("Main.Chat.ui.ChatViewCtrl")
local InputViewCtrl = require("Main.Chat.ui.InputViewCtrl")
local GUIUtils = require("GUI.GUIUtils")
local FriendNode = require("Main.friend.ui.FriendMainDlg")
local GangModule = require("Main.Gang.GangModule")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local TeamData = require("Main.Team.TeamData")
local BattleFieldMgr = require("Main.CaptureTheFlag.mgr.BattleFieldMgr")
local TrumpetMgr = require("Main.Chat.Trumpet.TrumpetMgr")
local def = ChannelChatPanel.define
local instance
def.const("table").ChannelToTab = {
  [2] = {
    [1] = "Tab_NewGang",
    [2] = "Tab_NewGang",
    [3] = "Tab_Team",
    [4] = "Tab_Current",
    [5] = "Tab_World",
    [8] = "Tab_Live",
    [9] = "Tab_InCity",
    [11] = "Tab_Trumpet",
    [13] = "Tab_Battle",
    [14] = "Tab_Friends"
  },
  [3] = {
    [1] = "Tab_System",
    [2] = "Tab_System",
    [3] = "Tab_System",
    [4] = "Tab_System"
  }
}
def.const("table").SystemSubTypeToTab = {
  [1] = "Tab_All",
  [2] = "Tab_Sys",
  [3] = "Tab_Help",
  [4] = "Tab_Personal"
}
def.field("table").chatViewCtrl = nil
def.field("table").inputViewCtrl = nil
def.field("number").channelType = 2
def.field("number").channelSubType = 1
def.field("function").openCallback = nil
def.static("=>", ChannelChatPanel).Instance = function()
  if instance == nil then
    instance = ChannelChatPanel()
    instance.m_TrigGC = true
    instance.m_HideOnDestroy = true
  end
  return instance
end
def.static("number", "number").ShowChannelChatPanel = function(type, subType)
  local self = ChannelChatPanel.Instance()
  if type > 0 and subType > 0 then
    self.channelType = type
    self.channelSubType = subType
  end
  if self:IsShow() then
    self:BringTop()
    self:SelectTab(self.channelType, self.channelSubType, true)
    self:DoOpenCallback()
  else
    self:CreatePanel(RESPATH.PREFAB_CHANNEL_CHAT, 0)
  end
end
def.static("number", "number", "function").ShowChannelChatPanelWithCallback = function(type, subType, cb)
  local self = ChannelChatPanel.Instance()
  self.openCallback = cb
  ChannelChatPanel.ShowChannelChatPanel(type, subType)
end
def.static().CloseChannelChatPanel = function()
  local self = ChannelChatPanel.Instance()
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.method().DoOpenCallback = function(self)
  if self.openCallback then
    self.openCallback(self)
    self.openCallback = nil
  end
end
def.method().ClearOpenCallback = function(self)
  self.openCallback = nil
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, ChannelChatPanel.OnGangChange, self)
  Event.RegisterEventWithContext(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.GangCross_SyncRoleCompete, ChannelChatPanel.OnGangChange, self)
  Event.RegisterEventWithContext(ModuleId.CTF, gmodule.notifyId.CTF.EnterSingleBattle, ChannelChatPanel.OnBattleChange, self)
  Event.RegisterEventWithContext(ModuleId.CTF, gmodule.notifyId.CTF.LeaveSingleBattle, ChannelChatPanel.OnBattleChange, self)
  Event.RegisterEventWithContext(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, ChannelChatPanel.OnTeamChange, self)
  Event.RegisterEventWithContext(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_KICK_TEAM, ChannelChatPanel.OnTeamChange, self)
  Event.RegisterEventWithContext(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_CREATE_TEAM, ChannelChatPanel.OnTeamChange, self)
  Event.RegisterEventWithContext(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_TEAM_DISMISS, ChannelChatPanel.OnTeamChange, self)
  Event.RegisterEventWithContext(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, ChannelChatPanel.OnTeamChange, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.ChatSetting_Change, ChannelChatPanel.OnChatSettingChange, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.CityChatChange, ChannelChatPanel.OnJoinCityRoom, self)
  Event.RegisterEventWithContext(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.NewChatRedGift_Opened, ChannelChatPanel.OnRedGiftChange, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, ChannelChatPanel.OnReadPointChange, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailsChange, ChannelChatPanel.OnReadPointChange, self)
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.Gang_AnnouncementsChanged, ChannelChatPanel.OnReadPointChange, self)
  Event.RegisterEventWithContext(ModuleId.SWORN, gmodule.notifyId.Sworn.SWORN_VOTE_MAIL, ChannelChatPanel.OnReadPointChange, self)
  Event.RegisterEventWithContext(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ClosePanel, ChannelChatPanel.OnReadPointChange, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, ChannelChatPanel.OnReadPointChange, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.GroupChatMsgUpdate, ChannelChatPanel.OnReadPointChange, self)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ChannelChatPanel.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, ChannelChatPanel.OnAtMsgChange)
  self.chatViewCtrl = ChatViewCtrl()
  local chatNode = self.m_panel:FindDirect("Img_Bg/Group_Chat/Panel_ChatContent")
  self.chatViewCtrl:Init(self, chatNode, 16, ChannelChatPanel.oldMsgDelegate)
  self.inputViewCtrl = InputViewCtrl()
  local inputNode = self.m_panel:FindDirect("Img_Bg/Group_Chat/Group_Input")
  self.inputViewCtrl:Init(self, inputNode, ChannelChatPanel.submitDelegate, ChannelChatPanel.voiceDelegate)
  self:UpdateTab()
  self:SelectTab(self.channelType, self.channelSubType, true)
  self:UpdateSocialRedPoint()
  gmodule.moduleMgr:GetModule(ModuleId.MAINUI):SetTopBtnGroupOpposite(true)
  self.m_bCanMoveBackward = true
  self:DoOpenCallback()
end
def.override().OnDestroy = function(self)
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHANNEL_TRUMPET_CHANGE, {show = false})
  if self.inputViewCtrl then
    self.inputViewCtrl:OnDestroy()
  end
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CloseChatPanel, nil)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, ChannelChatPanel.OnGangChange)
  Event.UnregisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.GangCross_SyncRoleCompete, ChannelChatPanel.OnGangChange)
  Event.UnregisterEvent(ModuleId.CTF, gmodule.notifyId.CTF.EnterSingleBattle, ChannelChatPanel.OnBattleChange)
  Event.UnregisterEvent(ModuleId.CTF, gmodule.notifyId.CTF.LeaveSingleBattle, ChannelChatPanel.OnBattleChange)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, ChannelChatPanel.OnTeamChange)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_KICK_TEAM, ChannelChatPanel.OnTeamChange)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_CREATE_TEAM, ChannelChatPanel.OnTeamChange)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_TEAM_DISMISS, ChannelChatPanel.OnTeamChange)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, ChannelChatPanel.OnTeamChange)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.ChatSetting_Change, ChannelChatPanel.OnChatSettingChange)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CityChatChange, ChannelChatPanel.OnJoinCityRoom)
  Event.UnregisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.NewChatRedGift_Opened, ChannelChatPanel.OnRedGiftChange)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, ChannelChatPanel.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailsChange, ChannelChatPanel.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_AnnouncementsChanged, ChannelChatPanel.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.SWORN, gmodule.notifyId.Sworn.SWORN_VOTE_MAIL, ChannelChatPanel.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ClosePanel, ChannelChatPanel.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, ChannelChatPanel.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupChatMsgUpdate, ChannelChatPanel.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ChannelChatPanel.OnFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, ChannelChatPanel.OnAtMsgChange)
  gmodule.moduleMgr:GetModule(ModuleId.MAINUI):SetTopBtnGroupOpposite(false)
  self:ClearOpenCallback()
end
def.override("boolean").OnShow = function(self, show)
  if self.inputViewCtrl then
    self.inputViewCtrl:OnShow(show)
  end
  if show then
    self:UpdateContent()
  end
end
def.method().UpdateTrumpetTab = function(self)
  local TrumpetTab = self.m_panel:FindDirect("Img_Bg/Group_Tab/Tab_Trumpet")
  if not TrumpetMgr.Instance():IsOpen(false) then
    TrumpetTab:SetActive(false)
  else
    TrumpetTab:SetActive(true)
  end
end
def.static("number", "number", "=>", "table").oldMsgDelegate = function(unique, num)
  local self = ChannelChatPanel.Instance()
  local msgs = ChatMsgData.Instance():GetOldMsg(self.channelType, self.channelSubType, unique, num)
  return msgs
end
def.static("string", "=>", "boolean").submitDelegate = function(content)
  local self = ChannelChatPanel.Instance()
  return ChatModule.Instance():SendChannelMsg(content, self.channelSubType, false)
end
def.static("table").voiceDelegate = function(speechMgr)
  local self = ChannelChatPanel.Instance()
  if self.channelType == ChatMsgData.MsgType.CHANNEL then
    speechMgr:SetChannel(self.channelSubType)
  end
end
def.static("table", "table").OnReadPointChange = function(p1, p2)
  local self = ChannelChatPanel.Instance()
  self:UpdateSocialRedPoint()
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p1.feature == ModuleFunSwitchInfo.TYPE_TRUMPET and ChannelChatPanel.Instance():IsShow() then
    ChannelChatPanel.Instance():UpdateTrumpetTab()
    if false == IsFeatureOpen(ModuleFunSwitchInfo.TYPE_TRUMPET) and ChannelChatPanel.Instance().channelType == ChatMsgData.MsgType.CHANNEL and ChannelChatPanel.Instance().channelSubType == ChatMsgData.Channel.TRUMPET then
      ChannelChatPanel.Instance():SelectTab(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.CURRENT, false)
    end
  elseif p1.feature == ModuleFunSwitchInfo.TYPE_AT and ChannelChatPanel.Instance():IsShow() then
    ChannelChatPanel.Instance().chatViewCtrl:UpdateAtBtn()
    ChannelChatPanel.Instance():UpdateTabReddot()
  elseif p1.feature == ModuleFunSwitchInfo.TYPE_CHAT_FRIEND_CHANNEL and ChannelChatPanel.Instance():IsShow() then
    ChannelChatPanel.Instance():UpdateTab()
    if false == IsFeatureOpen(ModuleFunSwitchInfo.TYPE_CHAT_FRIEND_CHANNEL) and ChannelChatPanel.Instance().channelType == ChatMsgData.MsgType.CHANNEL and ChannelChatPanel.Instance().channelSubType == ChatMsgData.Channel.FRIEND then
      ChannelChatPanel.Instance():SelectTab(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.CURRENT, false)
    end
  end
end
def.method("table").OnRedGiftChange = function(self)
  self.chatViewCtrl:UpdateRedGiftTip()
end
def.method("table").OnJoinCityRoom = function(self)
  self:UpdateTab()
end
def.method("table").OnGangChange = function(self, params)
  self:UpdateTab()
  self:SelectTab(self.channelType, self.channelSubType, false)
end
def.method("table").OnBattleChange = function(self, params)
  self:UpdateTab()
  self:SelectTab(self.channelType, self.channelSubType, false)
end
def.method("table").OnTeamChange = function(self)
  if self.channelType == ChatMsgData.MsgType.CHANNEL and self.channelSubType == ChatMsgData.Channel.TEAM then
    self:UpdateContent()
  end
end
def.method("boolean").ShowAllTab = function(self, show)
  local tabs = self.m_panel:FindDirect("Img_Bg/Group_Tab")
  for k, v in pairs(ChannelChatPanel.ChannelToTab) do
    for k1, v1 in pairs(v) do
      tabs:FindDirect(v1):SetActive(show)
    end
  end
end
def.method().UpdateTab = function(self)
  local battleTab = self.m_panel:FindDirect("Img_Bg/Group_Tab/Tab_Battle")
  if BattleFieldMgr.Instance():IsInSingleBattle() then
    self:ShowAllTab(false)
    battleTab:SetActive(true)
    return
  else
    self:ShowAllTab(true)
    battleTab:SetActive(false)
  end
  local newOrGangTab = self.m_panel:FindDirect("Img_Bg/Group_Tab/Tab_NewGang/Label")
  local label = newOrGangTab:GetComponent("UILabel")
  if GangModule.Instance():HasGang() then
    label:set_text(textRes.Chat[6])
  else
    label:set_text(textRes.Chat[7])
  end
  local cityTab = self.m_panel:FindDirect("Img_Bg/Group_Tab/Tab_InCity/Label")
  local label = cityTab:GetComponent("UILabel")
  local proviceName = ChatModule.Instance():GetCurProvinceName()
  label:set_text(proviceName)
  self:UpdateTrumpetTab()
  self:UpdateFriendChannelTab()
  self:RepositionAllTabs()
end
def.method().UpdateFriendChannelTab = function(self)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local FriendChannelTab = self.m_panel:FindDirect("Img_Bg/Group_Tab/Tab_Friends")
  if not _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_CHAT_FRIEND_CHANNEL) then
    FriendChannelTab:SetActive(false)
  else
    FriendChannelTab:SetActive(true)
  end
end
def.method().RepositionAllTabs = function(self)
  local Group_Tab = self.m_panel:FindDirect("Img_Bg/Group_Tab")
  Group_Tab:GetComponent("UITable"):Reposition()
end
def.method().AutoSelectTab = function(self)
  local tabName = ChannelChatPanel.ChannelToTab[self.channelType][self.channelSubType]
  if tabName then
    local toggle = self.m_panel:FindDirect("Img_Bg/Group_Tab/" .. tabName):GetComponent("UIToggle")
    toggle:set_value(true)
  end
  if self.channelType == ChatMsgData.MsgType.SYSTEM then
    local subTabName = ChannelChatPanel.SystemSubTypeToTab[self.channelSubType]
    if subTabName then
      local subToggle = self.m_panel:FindDirect("Img_Bg/Group_Chat/Group_System/Title_SysChatBtn/" .. subTabName):GetComponent("UIToggle")
      subToggle:set_value(true)
    end
    self:ShowSystemTab(true)
    self.inputViewCtrl:ShowInputView(false)
    self:ShowTrumpetTab(false)
  else
    self:ShowSystemTab(false)
    local bTrumpet = self.channelSubType == ChatMsgData.Channel.TRUMPET
    self.inputViewCtrl:ShowInputView(not bTrumpet)
    self:ShowTrumpetTab(bTrumpet)
  end
end
def.method("number", "number", "boolean").SelectTab = function(self, type, subType, forceUpdate)
  while true do
    if BattleFieldMgr.Instance():IsInSingleBattle() then
      type = ChatMsgData.MsgType.CHANNEL
      subType = ChatMsgData.Channel.BATTLEFIELD
    elseif subType == ChatMsgData.Channel.BATTLEFIELD then
      type = ChatMsgData.MsgType.CHANNEL
      subType = ChatMsgData.Channel.WORLD
    end
    if type == ChatMsgData.MsgType.CHANNEL and (subType == ChatMsgData.Channel.FACTION or subType == ChatMsgData.Channel.NEWER) then
      if GangModule.Instance():HasGang() then
        subType = ChatMsgData.Channel.FACTION
        break
      end
      subType = ChatMsgData.Channel.NEWER
      break
    end
    if type == ChatMsgData.MsgType.CHANNEL and subType == ChatMsgData.Channel.CITY then
      ChatModule.Instance():RequestJoinCityRoom()
      break
    end
    if not forceUpdate and self.channelType == type and self.channelSubType == subType then
      return
    end
    break
  end
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.CHATCHANNEL, {subType})
  self.channelType = type
  self.channelSubType = subType
  self:AutoSelectTab()
  self:UpdateContent()
end
def.method("boolean").ShowSystemTab = function(self, show)
  local sysTab = self.m_panel:FindDirect("Img_Bg/Group_Chat/Group_System")
  sysTab:SetActive(show)
end
def.method("boolean").ShowTrumpetTab = function(self, show)
  local trumpetTab = self.m_panel:FindDirect("Img_Bg/Group_Chat/Group_Broadcast")
  trumpetTab:SetActive(show)
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHANNEL_TRUMPET_CHANGE, {show = show})
end
def.method().UpdateContent = function(self)
  if not self:IsShow() then
    return
  end
  self.chatViewCtrl:SetContext({
    channel = self.channelSubType
  })
  self.chatViewCtrl:ClearMsg()
  local msgs = ChatMsgData.Instance():GetMsg(self.channelType, self.channelSubType, self.chatViewCtrl.PAGE_COUNT)
  if #msgs > 0 then
    self.chatViewCtrl:AddMsgBatch(msgs, false)
  end
  if self:CheckCanAddTeam() then
    local teamInfos = ChatModule.Instance().teamPlatformChatMgr.teamInfos
    self.chatViewCtrl:AddTeamBatch(teamInfos)
  end
  self.chatViewCtrl:DelayResetTableAndScroll()
  self:CheckAvoidSetting()
  self.chatViewCtrl:UpdateAtBtn()
  self:UpdateTabReddot()
end
def.method("table").OnChatSettingChange = function(self, params)
  if self.m_panel and not self.m_panel.isnil then
    self:UpdateContent()
  end
end
def.method().CheckAvoidSetting = function(self)
  if self.channelType == ChatMsgData.MsgType.CHANNEL then
    local isAvoid = ChatModule.Instance():CheckAvoidSetting(self.channelSubType)
    if isAvoid then
      self.chatViewCtrl:AddChannelAvoidNotice()
    end
  end
end
def.method("table").AddMsg = function(self, msg)
  if self:CheckCanAdd(msg) then
    self.chatViewCtrl:AddMsg(msg)
  end
end
def.method("table").RefreshTeam = function(self, teams)
  if self:CheckCanAddTeam() then
    self.chatViewCtrl:RefreshTeamPlatform(teams)
  end
end
def.method("table").UpdateOneMsg = function(self, msg)
  if self:CheckCanAdd(msg) then
    self.chatViewCtrl:UpdateOneMsg(msg)
  end
end
def.method("=>", "boolean").CheckCanAddTeam = function(self)
  return self:IsShow() and self.channelType == ChatMsgData.MsgType.CHANNEL and self.channelSubType == ChatMsgData.Channel.TEAM and not TeamData.Instance():HasTeam()
end
def.method("table", "=>", "boolean").CheckCanAdd = function(self, msg)
  if self.channelType == ChatMsgData.MsgType.SYSTEM then
    return self:IsShow() and msg.type == self.channelType and (msg.id == self.channelSubType or self.channelSubType == ChatMsgData.System.ALL)
  else
    return self:IsShow() and msg.type == self.channelType and msg.id == self.channelSubType
  end
end
def.method().UpdateSocialRedPoint = function(self)
  local Img_Red = self.m_panel:FindDirect("Img_Bg/Btn_SwitchFriend/Img_Red")
  Img_Red:SetActive(false)
  local FriendData = require("Main.friend.FriendData")
  local num = #FriendData.Instance():GetApplicantList()
  if num > 0 then
    Img_Red:SetActive(true)
    return
  end
  local num = ChatModule.Instance():GetChatNewCount(nil)
  if num > 0 then
    Img_Red:SetActive(true)
    return
  end
  local GangData = require("Main.Gang.data.GangData")
  num = GangData.Instance():GetUnReadAnnoNum()
  num = num + FriendData.Instance():GetUnReadMailsNum()
  num = num + (require("Main.UpdateNotice.UpdateNoticeModule").Instance():HasRead() and 0 or 1)
  if num > 0 then
    Img_Red:SetActive(true)
    return
  end
  local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
  if RelationShipChainMgr.CanReciveGift() or RelationShipChainMgr.CanReciveFriendNumGift() then
    Img_Red:SetActive(true)
    return
  end
  num = ChatModule.Instance():GetChatNewCount(nil)
  num = num + #FriendData.Instance():GetApplicantList()
  num = num + GangData.Instance():GetUnReadAnnoNum()
  num = num + FriendData.Instance():GetUnReadMailsNum()
  num = num + (require("Main.UpdateNotice.UpdateNoticeModule").Instance():HasRead() and 0 or 1)
  if num > 0 then
    Img_Red:SetActive(true)
    return
  end
  local newGroupNum = require("Main.Group.GroupModule").Instance():GetNewJoinGroupNum()
  local unReadNum = ChatModule.Instance():GetGroupChatNewCount(nil)
  if unReadNum + newGroupNum > 0 then
    Img_Red:SetActive(true)
    return
  end
end
def.method("=>", "userdata").GetTrumpetAnchor = function(self)
  if self.channelType == ChatMsgData.MsgType.CHANNEL and self.channelSubType == ChatMsgData.Channel.TRUMPET then
    return self.m_panel:FindDirect("Img_Bg/Position_Broadcast")
  else
    return nil
  end
end
def.method("userdata", "boolean").onPressObj = function(self, clickobj, bPress)
  if self.chatViewCtrl:onPressObj(clickobj, bPress) then
  else
    self:onPress(clickobj and clickobj.name or "", bPress)
  end
end
def.method("userdata").onClickObj = function(self, obj)
  if self.chatViewCtrl:onClickObj(obj) then
  else
    self:onClick(obj.name)
  end
end
def.method("string").onClick = function(self, id)
  if self.chatViewCtrl:onClick(id) then
  elseif self.inputViewCtrl:onClick(id) then
  elseif id == "Btn_Close" then
    self:DestroyPanel()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.CHATAREASTATUS, {2})
  elseif id == "Btn_ChatSetting" then
    local ChatSetting = require("Main.Chat.ui.ChatSettingDlg")
    local settingDlg = ChatSetting()
    settingDlg:CreatePanel(RESPATH.PREFAB_CHAT_SETTING, 2)
  elseif id == "Btn_SwitchFriend" then
    local SocialDlg = require("Main.friend.ui.SocialDlg")
    SocialDlg.ShowSocialDlg(0)
    self:DestroyPanel()
  elseif id == "BtnSendTrumpet" then
    if TrumpetMgr.Instance():IsOpen(true) then
      local SendTrumpetDlg = require("Main.Chat.Trumpet.ui.SendTrumpetDlg")
      SendTrumpetDlg.ShowDlg(nil)
      self:DestroyPanel()
    end
  elseif string.sub(id, 1, 4) == "Tab_" then
    if id == "Tab_NewGang" then
      local type = ChatMsgData.MsgType.CHANNEL
      local subType
      if GangModule.Instance():HasGang() then
        subType = ChatMsgData.Channel.FACTION
      else
        subType = ChatMsgData.Channel.NEWER
      end
      self:SelectTab(type, subType, false)
    elseif id == "Tab_Team" then
      local type = ChatMsgData.MsgType.CHANNEL
      local subType = ChatMsgData.Channel.TEAM
      self:SelectTab(type, subType, false)
    elseif id == "Tab_Current" then
      local type = ChatMsgData.MsgType.CHANNEL
      local subType = ChatMsgData.Channel.CURRENT
      self:SelectTab(type, subType, false)
    elseif id == "Tab_World" then
      local type = ChatMsgData.MsgType.CHANNEL
      local subType = ChatMsgData.Channel.WORLD
      self:SelectTab(type, subType, false)
    elseif id == "Tab_System" then
      local type = ChatMsgData.MsgType.SYSTEM
      local subType = ChatMsgData.System.ALL
      self:SelectTab(type, subType, false)
    elseif id == "Tab_Live" then
      local type = ChatMsgData.MsgType.CHANNEL
      local subType = ChatMsgData.Channel.LIVE
      self:SelectTab(type, subType, false)
    elseif id == "Tab_InCity" then
      local type = ChatMsgData.MsgType.CHANNEL
      local subType = ChatMsgData.Channel.CITY
      self:SelectTab(type, subType, false)
    elseif id == "Tab_Trumpet" then
      if TrumpetMgr.Instance():IsOpen(true) then
        local type = ChatMsgData.MsgType.CHANNEL
        local subType = ChatMsgData.Channel.TRUMPET
        self:SelectTab(type, subType, false)
      end
    elseif id == "Tab_Battle" then
      local type = ChatMsgData.MsgType.CHANNEL
      local subType = ChatMsgData.Channel.BATTLEFIELD
      self:SelectTab(type, subType, false)
    elseif id == "Tab_All" then
      local type = ChatMsgData.MsgType.SYSTEM
      local subType = ChatMsgData.System.ALL
      self:SelectTab(type, subType, false)
    elseif id == "Tab_Sys" then
      local type = ChatMsgData.MsgType.SYSTEM
      local subType = ChatMsgData.System.SYS
      self:SelectTab(type, subType, false)
    elseif id == "Tab_Help" then
      local type = ChatMsgData.MsgType.SYSTEM
      local subType = ChatMsgData.System.HELP
      self:SelectTab(type, subType, false)
    elseif id == "Tab_Personal" then
      local type = ChatMsgData.MsgType.SYSTEM
      local subType = ChatMsgData.System.PERSONAL
      self:SelectTab(type, subType, false)
    elseif id == "Tab_Friends" then
      local type = ChatMsgData.MsgType.CHANNEL
      local subType = ChatMsgData.Channel.FRIEND
      self:SelectTab(type, subType, false)
    end
  end
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  if self.inputViewCtrl:onSubmit(id, ctrl) then
  end
end
def.method("string").onLongPress = function(self, id)
  if self.chatViewCtrl:onLongPress(id) then
  elseif self.inputViewCtrl:onLongPress(id) then
  end
end
def.method("string", "boolean").onPress = function(self, id, state)
  if self.inputViewCtrl:onPress(id, state) then
  end
end
def.method("string", "userdata").onDragOut = function(self, id, go)
  if self.inputViewCtrl:onDragOut(id, go) then
  end
end
def.method("string", "userdata").onDragOver = function(self, id, go)
  if self.inputViewCtrl:onDragOver(id, go) then
  end
end
def.method("string").onDragEnd = function(self, id)
  if self.chatViewCtrl:onDragEnd(id) then
  end
end
def.method("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
  if self.chatViewCtrl:onSpringFinish(id, scrollView, type, position) then
  end
end
def.static("table", "table").OnAtMsgChange = function(p1, p2)
  local self = ChannelChatPanel.Instance()
  if self:IsShow() then
    self.chatViewCtrl:UpdateAtBtn()
    self:UpdateTabReddot()
  end
end
def.method().UpdateTabReddot = function(self)
  local tabs = self.m_panel:FindDirect("Img_Bg/Group_Tab")
  local bOpen = require("Main.Chat.At.AtMgr").Instance():IsOpen(false)
  for k, v in pairs(ChannelChatPanel.ChannelToTab[2]) do
    local channelAtMsgCount = require("Main.Chat.At.data.AtData").Instance():GetChannelMsgCount(k)
    local bShowAtRed = bOpen and channelAtMsgCount > 0
    local ImgRed = tabs:FindDirect(v):FindDirect("Img_Red")
    GUIUtils.SetActive(ImgRed, bShowAtRed)
  end
end
ChannelChatPanel.Commit()
return ChannelChatPanel
