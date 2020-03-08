local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local SocialDlg = Lplus.Extend(ECPanelBase, "SocialDlg")
local EC = require("Types.Vector3")
local GangModule = require("Main.Gang.GangModule")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local FriendUtils = require("Main.friend.FriendUtils")
local RecentNode = require("Main.friend.ui.RecentNode")
local FriendNode = require("Main.friend.ui.FriendNode")
local MailNode = require("Main.friend.ui.MailNode")
local FriendConsts = require("netio.protocol.mzm.gsp.friend.FriendConsts")
local GangData = require("Main.Gang.data.GangData")
local FriendData = require("Main.friend.FriendData")
local PrivateChatViewCtrl = require("Main.Chat.ui.PrivateChatViewCtrl")
local InputViewCtrl = require("Main.Chat.ui.InputViewCtrl")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local GroupNode = require("Main.Group.ui.GroupNode")
local GroupChatViewCtrl = require("Main.Chat.ui.GroupChatViewCtrl")
local def = SocialDlg.define
local instance
def.const("table").NodeId = {
  Recent = 1,
  Friend = 2,
  Mail = 3,
  Group = 4
}
def.const("table").Tabs = {
  [1] = "Tab_Recent",
  ["Tab_Recent"] = 1,
  [2] = "Tab_Friend",
  ["Tab_Friend"] = 2,
  [3] = "Tab_Mail",
  ["Tab_Mail"] = 3,
  [4] = "Tab_Group",
  ["Tab_Group"] = 4
}
def.const("table").SlideState = {
  Normal = 1,
  ChatRight = 2,
  ChatLeft = 3
}
def.field("table").nodes = nil
def.field("number").curNode = 1
def.field("table").searchFriendList = nil
def.field("userdata").curChatId = nil
def.field("string").curName = ""
def.field("table").chatViewCtrl = nil
def.field("table").inputViewCtrl = nil
def.field("number").slideTo = 1
def.field("number").slideState = 1
def.field("userdata").m_GroupId = nil
def.field("boolean").m_IsWaitingGroupBasicInfo = false
def.field("table").m_GroupChatViewCtrl = nil
def.field("table").m_GroupInputViewCtrl = nil
def.field("string").cacheContent = ""
def.field("function").openCallback = nil
def.static("=>", SocialDlg).Instance = function()
  if instance == nil then
    instance = SocialDlg()
    instance.m_TrigGC = true
    instance.m_HideOnDestroy = true
  end
  return instance
end
def.static("number").ShowSocialDlg = function(node)
  local socialPanel = SocialDlg.Instance()
  if node > 0 then
    socialPanel.curNode = node
  end
  socialPanel.slideTo = SocialDlg.SlideState.Normal
  if socialPanel.m_panel then
    socialPanel:BringTop()
    socialPanel:UpdatePanel()
    if socialPanel.openCallback then
      socialPanel.openCallback(socialPanel)
      socialPanel.openCallback = nil
    end
  else
    socialPanel:CreatePanel(RESPATH.PREFAB_SOCIAL, 0)
  end
end
def.static("number", "function").ShowSocialDlgWithCallback = function(node, cb)
  local socialPanel = SocialDlg.Instance()
  socialPanel.openCallback = cb
  SocialDlg.ShowSocialDlg(node)
end
def.static("userdata").ShowGroupChat = function(groupId)
  if nil == groupId then
    return
  end
  local self = SocialDlg.Instance()
  self.m_GroupId = groupId
  local autoCollapse = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ChatWithFriendShrinkUI).isEnabled
  if autoCollapse then
    self.slideTo = SocialDlg.SlideState.ChatLeft
  else
    self.slideTo = SocialDlg.SlideState.ChatRight
  end
  if self.m_panel and not self.m_panel.isnil then
    self:SwitchTo(SocialDlg.NodeId.Group)
    self:UpdateChat()
    self:Slide(self.slideTo)
    if self.openCallback then
      self.openCallback(self)
      self.openCallback = nil
    end
  else
    self.curNode = SocialDlg.NodeId.Group
    self:CreatePanel(RESPATH.PREFAB_SOCIAL, 0)
  end
end
def.static("userdata", "function").ShowGroupChatWithCallback = function(groupId, cb)
  SocialDlg.Instance().openCallback = cb
  SocialDlg.ShowGroupChat(groupId)
end
def.static("userdata", "string", "boolean").ShowPrivateChat = function(roleId, roleName, fromInner)
  if roleId == nil then
    return
  end
  local socialPanel = SocialDlg.Instance()
  local autoCollapse = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ChatWithFriendShrinkUI).isEnabled
  if autoCollapse then
    socialPanel.slideTo = SocialDlg.SlideState.ChatLeft
  else
    socialPanel.slideTo = SocialDlg.SlideState.ChatRight
  end
  if socialPanel.m_panel then
    if not fromInner and socialPanel.curNode ~= SocialDlg.NodeId.Recent then
      socialPanel:SwitchTo(SocialDlg.NodeId.Recent)
    end
    socialPanel.curChatId = roleId
    socialPanel.curName = roleName
    socialPanel:UpdateChat()
    socialPanel:Slide(socialPanel.slideTo)
  else
    socialPanel.curChatId = roleId
    socialPanel.curName = roleName
    socialPanel.curNode = SocialDlg.NodeId.Recent
    socialPanel:CreatePanel(RESPATH.PREFAB_SOCIAL, 0)
  end
end
def.static().CloseSocialDlg = function()
  local self = SocialDlg.Instance()
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.method().ActiveAll = function(self)
  self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend"):SetActive(true)
  self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat"):SetActive(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, SocialDlg.OnReadPointChange)
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailsChange, SocialDlg.OnReadPointChange)
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_GrcFriendRecommend, SocialDlg.OnRecommendFriendChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_AnnouncementsChanged, SocialDlg.OnReadPointChange)
  Event.RegisterEvent(ModuleId.SWORN, gmodule.notifyId.Sworn.SWORN_VOTE_MAIL, SocialDlg.OnReadPointChange)
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ClosePanel, SocialDlg.OnReadPointChange)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendAdd, SocialDlg.OnFriendNeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendNameChanged, SocialDlg.OnChatNameChange, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.Cache_Name_Change, SocialDlg.OnChatNameChange, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendAdd, SocialDlg.OnSAddFriendSucc, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_BasicInfo_Inited, SocialDlg.OnGroupBasicInfoInited, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, SocialDlg.OnReadPointChange, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.GroupChatMsgUpdate, SocialDlg.OnReadPointChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_LeaveGroup, SocialDlg.OnLeaveGroup, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Kick, SocialDlg.OnMemberKick, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_AnnounceMent_Changed, SocialDlg.OnGroupAnnounceMentChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_Name_Changed, SocialDlg.OnGroupNameChange, self)
  Event.RegisterEventWithContext(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.NewChatRedGift_Opened, SocialDlg.OnRedGiftChange, self)
  Event.RegisterEventWithContext(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostCreate, SocialDlg.OnMaillInfoPanelCreate, self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, SocialDlg.OnFeatureOpenChange, self)
  Event.RegisterEventWithContext(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, SocialDlg.OnMasterTaskInfoChange, self)
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.SpaceNewMsg, SocialDlg.OnReadPointChange, self)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, SocialDlg.OnAtMsgChange)
  self:ActiveAll()
  self.nodes = {}
  local recentNode = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Content/Content_Recent")
  self.nodes[SocialDlg.NodeId.Recent] = RecentNode()
  self.nodes[SocialDlg.NodeId.Recent]:Init(self, recentNode)
  local friendNode = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Content/Content_Friend")
  self.nodes[SocialDlg.NodeId.Friend] = FriendNode()
  self.nodes[SocialDlg.NodeId.Friend]:Init(self, friendNode)
  local mailNode = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Content/Content_Mail")
  self.nodes[SocialDlg.NodeId.Mail] = MailNode()
  self.nodes[SocialDlg.NodeId.Mail]:Init(self, mailNode)
  local groupNode = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Content/Content_Group")
  self.nodes[SocialDlg.NodeId.Group] = GroupNode()
  self.nodes[SocialDlg.NodeId.Group]:Init(self, groupNode)
  self:HandleSwitch()
  self.chatViewCtrl = PrivateChatViewCtrl()
  local chatNode = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Img_BgChat/Panel_ChatContent")
  self.chatViewCtrl:Init(self, chatNode, 16, SocialDlg.oldMsgDelegate)
  self.inputViewCtrl = InputViewCtrl()
  local inputNode = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Img_BgChat/Img_BgChatInput")
  self.inputViewCtrl:Init(self, inputNode, SocialDlg.submitDelegate, SocialDlg.voiceDelegate)
  self.m_GroupChatViewCtrl = GroupChatViewCtrl()
  local chatNode = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Img_BgChat/Panel_ChatContent")
  self.m_GroupChatViewCtrl:Init(self, chatNode, 16, SocialDlg.GetGroupOldMsgDelegate)
  self.m_GroupInputViewCtrl = InputViewCtrl()
  local inputNode = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Img_BgChat/Img_BgChatInput")
  self.m_GroupInputViewCtrl:Init(self, inputNode, SocialDlg.SendGroupChatMsgDelegate, SocialDlg.GroupVoiceDelegate)
  self:UpdatePanel()
  self:UpdateChat()
  self:Slide(self.slideTo)
  gmodule.moduleMgr:GetModule(ModuleId.MAINUI):SetTopBtnGroupOpposite(true)
  self.m_bCanMoveBackward = true
  if self.openCallback then
    self.openCallback(self)
    self.openCallback = nil
  end
end
def.method().HandleSwitch = function(self)
  local Group_Tab = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Tab")
  local groupTab = Group_Tab:FindDirect("Tab_Group")
  if _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP) then
    groupTab:SetActive(true)
  else
    groupTab:SetActive(false)
  end
  local tab = Group_Tab:FindDirect("Btn_PVPTeam")
  if require("Main.Corps.CorpsInterface").IsOpen() then
    tab:SetActive(true)
  else
    tab:SetActive(false)
  end
  local tab = Group_Tab:FindDirect("Btn_COF")
  local isOpen = require("Main.SocialSpace.SocialSpaceModule").Instance():IsFeatureOpen()
  GUIUtils.SetActive(tab, isOpen)
end
def.override("boolean").OnShow = function(self, show)
  if self.inputViewCtrl then
    self.inputViewCtrl:OnShow(show)
  end
end
def.static("number", "number", "=>", "table").GetGroupOldMsgDelegate = function(unique, num)
  local self = SocialDlg.Instance()
  if nil == self.m_GroupId then
    warn("[SocialDlg:GetGroupOldMsgDelegate] nil == m_GroupId, return {}.")
    return {}
  end
  local msgs = ChatMsgData.Instance():GetOldMsg64(ChatMsgData.MsgType.GROUP, self.m_GroupId, unique, num)
  return msgs
end
def.static("string", "=>", "boolean").SendGroupChatMsgDelegate = function(content)
  warn("~~~~~~~~SendGroupChatMsgDelegate~~~~~~~~~~~~")
  local self = SocialDlg.Instance()
  ChatModule.Instance():SendGroupChatMsg(self.m_GroupId, content, false)
  return true
end
def.static("table").GroupVoiceDelegate = function(speechMgr)
  local self = SocialDlg.Instance()
  speechMgr:SetGroup(self.m_GroupId)
end
def.static("table", "table").OnReadPointChange = function(p1, p2)
  instance:UpdateTabRedPoint()
end
def.static("table", "table").OnRecommendFriendChange = function(p1, p2)
  instance:UpdateAddFriendRed()
end
def.static("number", "number", "=>", "table").oldMsgDelegate = function(unique, num)
  local msgs = ChatMsgData.Instance():GetOldMsg64(ChatMsgData.MsgType.FRIEND, SocialDlg.Instance().curChatId, unique, num)
  ChatModule.Instance():UpdateFriendLevelInChat(SocialDlg.Instance().curChatId, msgs)
  return msgs
end
def.static("string", "=>", "boolean").submitDelegate = function(content)
  local self = SocialDlg.Instance()
  ChatModule.Instance():SendPrivateMsg(self.curChatId, content, false)
  return true
end
def.static("table").voiceDelegate = function(speechMgr)
  local self = SocialDlg.Instance()
  speechMgr:SetRole(self.curChatId)
end
def.method("table").OnSAddFriendSucc = function(self, params)
  if self.m_panel and not self.m_panel.isnil and self.curChatId then
    local addRoleId = params[1]
    if addRoleId:eq(self.curChatId) then
      self:UpdateContent()
    end
  end
end
def.method("table").OnChatNameChange = function(self, params)
  local roleId = params.roleId
  if roleId == self.curChatId then
    if params.roleName then
      self.curName = roleName
    end
    self:UpdateTitle()
  end
end
def.method("table").OnLeaveGroup = function(self, params)
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  if nil == self.m_GroupId then
    return
  end
  local groupId = params.groupId
  if nil == groupId then
    return
  end
  if not self.m_GroupId:eq(groupId) then
    return
  end
  self:CloseGroupChat()
end
def.method("table").OnMemberKick = function(self, params)
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  if nil == self.m_GroupId then
    return
  end
  local groupId = params.groupId
  if nil == groupId then
    return
  end
  if self.m_GroupId:eq(groupId) then
    self:UpdateTitle()
  end
end
def.method("table").OnGroupAnnounceMentChange = function(self, params)
  if nil == self.m_panel or self.m_panel.isnil then
    return
  end
  if nil == self.m_GroupId then
    return
  end
  local groupId = params.groupId
  if nil == groupId then
    return
  end
  if not self.m_GroupId:eq(groupId) then
    return
  end
  self.m_GroupChatViewCtrl:SetAnnounceMent(params.newAnnounceMent)
  self.m_GroupChatViewCtrl:ShowAnnounceMent(true)
end
def.method("table").OnGroupNameChange = function(self, params)
  if nil == self.m_panel or self.m_panel.isnil then
    return
  end
  if nil == self.m_GroupId then
    return
  end
  local groupId = params.groupId
  if nil == groupId then
    return
  end
  if not self.m_GroupId:eq(groupId) then
    return
  end
  self:UpdateTitle()
end
def.method("table").OnRedGiftChange = function(self)
  if self.m_GroupChatViewCtrl then
    self.m_GroupChatViewCtrl:UpdateRedGiftTip()
  end
end
def.method("table").OnGroupBasicInfoInited = function(self, params)
  if self.m_panel and not self.m_panel.isnil and self.curNode == SocialDlg.NodeId.Group and self.m_IsWaitingGroupBasicInfo then
    self.m_IsWaitingGroupBasicInfo = false
    self.nodes[self.curNode]:Show()
  end
end
def.method("table").OnMaillInfoPanelCreate = function(self, params)
  local panelName = params[1]
  warn("OnMaillInfoPanelCreate", panelName)
  if panelName == "panel_mail" then
    self:BringTop()
  end
end
def.static("table", "table").OnFeatureOpenChange = function(context, params)
  local self = context
  if self ~= nil then
    local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
    if params.feature == ModuleFunSwitchInfo.TYPE_SHITU_TASK then
      self:UpdateYouyuanPoint()
    elseif params.feature == ModuleFunSwitchInfo.TYPE_AT then
      self:UpdateGroupRedPoint()
    elseif params.feature == ModuleFunSwitchInfo.TYPE_RECOMMEND_QQ_WECHAT_FRIEND then
      self:UpdateAddFriendRed()
    end
  end
end
def.static("table", "table").OnMasterTaskInfoChange = function(context, params)
  local self = context
  if self ~= nil then
    self:UpdateYouyuanPoint()
  end
end
def.static("table", "table").OnAtMsgChange = function(p1, p2)
  local self = SocialDlg.Instance()
  if self:IsShow() then
    if self.m_GroupId then
      self.m_GroupChatViewCtrl:UpdateAtBtn()
    end
    self:UpdateGroupRedPoint()
  end
end
def.override().OnDestroy = function(self)
  self.nodes[self.curNode]:Hide()
  self.curChatId = nil
  self.curName = ""
  self.m_GroupId = nil
  self.m_IsWaitingGroupBasicInfo = false
  self.slideState = SocialDlg.SlideState.Normal
  if self.inputViewCtrl then
    self.inputViewCtrl:OnDestroy()
  end
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendAdd, SocialDlg.OnSAddFriendSucc)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendNameChanged, SocialDlg.OnChatNameChange)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Cache_Name_Change, SocialDlg.OnChatNameChange)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendAdd, SocialDlg.OnFriendNeedUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, SocialDlg.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_GrcFriendRecommend, SocialDlg.OnRecommendFriendChange)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailsChange, SocialDlg.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_AnnouncementsChanged, SocialDlg.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.SWORN, gmodule.notifyId.Sworn.SWORN_VOTE_MAIL, SocialDlg.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ClosePanel, SocialDlg.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_BasicInfo_Inited, SocialDlg.OnGroupBasicInfoInited)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, SocialDlg.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupChatMsgUpdate, SocialDlg.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_LeaveGroup, SocialDlg.OnLeaveGroup)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Kick, SocialDlg.OnMemberKick)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Name_Changed, SocialDlg.OnGroupNameChange)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_AnnounceMent_Changed, SocialDlg.OnGroupAnnounceMentChange)
  Event.UnregisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.NewChatRedGift_Opened, SocialDlg.OnRedGiftChange)
  Event.UnregisterEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostCreate, SocialDlg.OnMaillInfoPanelCreate)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, SocialDlg.OnFeatureOpenChange)
  Event.UnregisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, SocialDlg.OnMasterTaskInfoChange)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.SpaceNewMsg, SocialDlg.OnReadPointChange)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, SocialDlg.OnAtMsgChange)
  gmodule.moduleMgr:GetModule(ModuleId.MAINUI):SetTopBtnGroupOpposite(false)
  self.openCallback = nil
  ChatModule.Instance():SaveChat(false)
end
def.method("table").OnFriendNeedUpdate = function(self, params)
  self:DelRoleForSearchFriend(params[1])
end
def.method().UpdateTitle = function(self)
  if self.curChatId ~= nil then
    local friendInfo = require("Main.friend.FriendData").Instance():GetFriendInfo(self.curChatId)
    local name = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Img_BgChat/Title_FriendChatBtn/Label_ChatName")
    local remarkNameOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_FRIEND_REMARK_NAME)
    if remarkNameOpen and friendInfo and friendInfo.remarkName and friendInfo.remarkName ~= "" then
      name:GetComponent("UILabel"):set_text(string.format("%s(%s)", friendInfo.remarkName, self.curName))
    else
      name:GetComponent("UILabel"):set_text(self.curName)
    end
    self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Img_BgChat/Title_FriendChatBtn/Btn_OpenGroup"):SetActive(false)
  elseif nil ~= self.m_GroupId then
    local GroupModule = require("Main.Group.GroupModule")
    local GroupUtils = require("Main.Group.GroupUtils")
    local basicInfo = GroupModule.Instance():GetGroupBasicInfo(self.m_GroupId)
    if basicInfo then
      local groupName = basicInfo.groupName
      local maxMemberNum = GroupUtils.GetGroupMaxMemberNum()
      local curMemberNum = GroupModule.Instance():GetGroupMemberNum(basicInfo.groupId)
      local nameLabel = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Img_BgChat/Title_FriendChatBtn/Label_ChatName")
      nameLabel:GetComponent("UILabel"):set_text(string.format("%s(%d/%d)", groupName, curMemberNum, maxMemberNum))
    end
    self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Img_BgChat/Title_FriendChatBtn/Btn_OpenGroup"):SetActive(true)
  end
end
def.method().UpdateContent = function(self)
  if self.curChatId then
    self.chatViewCtrl:ClearMsg()
    self.chatViewCtrl:ShowNew(false)
    self.chatViewCtrl:ShowAnnounceMent(false)
    local msgs = ChatMsgData.Instance():GetMsg64(ChatMsgData.MsgType.FRIEND, self.curChatId, self.chatViewCtrl.PAGE_COUNT)
    if #msgs > 0 then
      require("Main.Chat.ChatModule").Instance():UpdateFriendLevelInChat(self.curChatId, msgs)
      self.chatViewCtrl:AddMsgBatch(msgs, false)
    end
    local friend = require("Main.friend.FriendData").Instance():GetFriendInfo(self.curChatId)
    if not friend then
      self.chatViewCtrl:AddStangerNotice()
    end
    self.chatViewCtrl:DelayResetTableAndScroll()
  elseif self.m_GroupId then
    self.m_GroupChatViewCtrl:ClearMsg()
    self.m_GroupChatViewCtrl:ShowNew(false)
    local msgs = ChatMsgData.Instance():GetMsg64(ChatMsgData.MsgType.GROUP, self.m_GroupId, self.m_GroupChatViewCtrl.PAGE_COUNT)
    if #msgs > 0 then
      self.m_GroupChatViewCtrl:AddMsgBatch(msgs, false)
    end
    self.m_GroupChatViewCtrl:DelayResetTableAndScroll()
    self.m_GroupChatViewCtrl:UpdateAtBtn()
    GameUtil.AddGlobalLateTimer(0.01, true, function()
      if nil == self.m_panel or self.m_panel.isnil then
        return
      end
      if nil == self.m_GroupId then
        return
      end
      local groupInfo = require("Main.Group.GroupModule").Instance():GetGroupBasicInfo(self.m_GroupId)
      if groupInfo == nil then
        return
      end
      local announcement = groupInfo.announcement
      if announcement and "" ~= announcement then
        self.m_GroupChatViewCtrl:SetAnnounceMent(announcement)
        self.m_GroupChatViewCtrl:ShowAnnounceMent(true)
      else
        self.m_GroupChatViewCtrl:ShowAnnounceMent(false)
      end
      self.m_GroupChatViewCtrl:UpdateRedGiftTip()
    end)
  end
end
def.method("userdata", "=>", "boolean").CanAddGroupMsg = function(self, groupId)
  if nil == groupId then
    return false
  end
  if nil == self.m_GroupId then
    return false
  end
  return self:IsShow() and self.m_GroupId:eq(groupId)
end
def.method("table").AddGroupMsg = function(self, msg)
  if self:CanAddGroupMsg(msg.id) then
    self.m_GroupChatViewCtrl:AddMsg(msg)
  end
end
def.method().ClearGroupMsg = function(self)
  self.m_GroupChatViewCtrl:ClearMsg()
  ChatMsgData.Instance():ClearMsg64(ChatMsgData.MsgType.GROUP, self.m_GroupId)
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupChatMsgUpdate, {
    groupId = self.m_GroupId,
    newCount = 0
  })
end
def.method("userdata", "=>", "boolean").CheckCanAdd = function(self, roleId)
  return self:IsShow() and self.curChatId == roleId
end
def.method().ClearFriendMsg = function(self)
  self.chatViewCtrl:ClearMsg()
  ChatMsgData.Instance():ClearMsg64(ChatMsgData.MsgType.FRIEND, self.curChatId)
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.UpdateFirendMsg, {
    roleId = self.curChatId,
    new = -1
  })
end
def.method("table").AddMsg = function(self, msg)
  if self:CheckCanAdd(msg.id) then
    self.chatViewCtrl:AddMsg(msg)
  end
end
def.method("=>", "userdata").GetCurGroupId = function(self)
  return self.m_GroupId
end
def.method("table").UpdateOneGroupMsg = function(self, msg)
  if self:CanAddGroupMsg(msg.id) then
    self.m_GroupChatViewCtrl:UpdateOneMsg(msg)
  end
end
def.method("table").UpdateOneMsg = function(self, msg)
  if self:CheckCanAdd(msg.id) then
    self.chatViewCtrl:UpdateOneMsg(msg)
  end
end
def.method().UpdateChat = function(self)
  self:UpdateTitle()
  self:UpdateContent()
end
def.method().UpdatePanel = function(self)
  self:CloseSearchFriend()
  self:SwitchTo(self.curNode)
  self:UpdateTabRedPoint()
end
def.method("number").Slide = function(self, st)
  local chatTween = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg"):GetComponent("TweenPosition")
  local friendTween = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend"):GetComponent("TweenPosition")
  local friendPanel = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend"):GetComponent("UIPanel")
  if self.slideState == SocialDlg.SlideState.Normal then
    if st == SocialDlg.SlideState.ChatLeft then
      friendTween:PlayReverse()
    elseif st == SocialDlg.SlideState.ChatRight then
      chatTween:PlayForward()
    end
  elseif self.slideState == SocialDlg.SlideState.ChatLeft then
    if st == SocialDlg.SlideState.Normal then
      friendTween:PlayForward()
      friendPanel:Refresh()
    elseif st == SocialDlg.SlideState.ChatRight then
      friendTween:PlayForward()
      friendPanel:Refresh()
      chatTween:PlayForward()
    end
  elseif self.slideState == SocialDlg.SlideState.ChatRight then
    if st == SocialDlg.SlideState.ChatLeft then
      friendTween:PlayReverse()
      chatTween:PlayReverse()
    elseif st == SocialDlg.SlideState.Normal then
      chatTween:PlayReverse()
    end
  end
  self.slideState = st
  local btnExpand = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Img_BgChat/Title_FriendChatBtn/Btn_Expand")
  local btnCollapse = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Img_BgChat/Title_FriendChatBtn/Btn_Collapse")
  local btnBack = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Img_BgChat/Title_FriendChatBtn/Btn_ChatBack")
  local Btn_SwitchChat = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Btn_SwitchChat")
  local Btn_SwitchWorldChat = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Btn_SwitchWorldChat")
  if self.slideState == SocialDlg.SlideState.ChatRight then
    btnExpand:SetActive(false)
    btnCollapse:SetActive(true)
    btnBack:SetActive(false)
    Btn_SwitchChat:SetActive(false)
    Btn_SwitchWorldChat:SetActive(true)
  elseif self.slideState == SocialDlg.SlideState.ChatLeft then
    btnCollapse:SetActive(false)
    local autoCollapse = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ChatWithFriendShrinkUI).isEnabled
    btnExpand:SetActive(not autoCollapse)
    btnBack:SetActive(autoCollapse)
    Btn_SwitchChat:SetActive(false)
    Btn_SwitchWorldChat:SetActive(true)
  else
    btnExpand:SetActive(false)
    btnCollapse:SetActive(false)
    btnBack:SetActive(false)
    Btn_SwitchChat:SetActive(true)
    Btn_SwitchWorldChat:SetActive(false)
  end
end
def.method("number").SwitchTo = function(self, nodeId)
  local oldNodeId = self.curNode
  self.curNode = 0
  for k, v in pairs(self.nodes) do
    if nodeId == k then
      if nodeId == SocialDlg.NodeId.Group then
        local GroupModule = require("Main.Group.GroupModule")
        if GroupModule.Instance():IsInitedBasicAllGroup() then
          v:Show()
        else
          local protocolMgr = require("Main.Group.GroupProtocolMgr")
          protocolMgr.SetWaitForBasicInfo(true)
          self.m_IsWaitingGroupBasicInfo = true
          protocolMgr.CGroupBasicInfoReq()
        end
      else
        v:Show()
      end
      self.curNode = nodeId
    else
      v:Hide()
    end
  end
  self:ClearChatInfo(oldNodeId)
  self:UpdateTab()
end
def.method("number").ClearChatInfo = function(self, oldNodeId)
  if oldNodeId == self.curNode then
    return
  end
  self.m_GroupId = nil
  self.curChatId = nil
  self.curName = ""
end
def.method().UpdateTab = function(self)
  local tabName = SocialDlg.Tabs[self.curNode]
  if tabName then
    local tabUI = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Tab/" .. tabName)
    local tabToggle = tabUI:GetComponent("UIToggle")
    tabToggle:set_value(true)
  end
end
def.method().UpdateTabRedPoint = function(self)
  self:UpdateRecentRedPoint()
  self:UpdateFriendRedPoint()
  self:UpdateMailRedPoint()
  self:UpdateRankFriendRedPoint()
  self:UpdatePrivateRedPoint()
  self:UpdateGroupRedPoint()
  self:UpdateYouyuanPoint()
  self:UpdateSocialSpacePoint()
  self:UpdateAddFriendRed()
end
def.method().UpdateGroupRedPoint = function(self)
  local newGroupNum = require("Main.Group.GroupModule").Instance():GetNewJoinGroupNum()
  local unReadNum = ChatModule.Instance():GetGroupChatNewCount(nil)
  local redImg = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Tab/Tab_Group/Img_Red")
  if unReadNum + newGroupNum > 0 then
    redImg:SetActive(true)
  else
    redImg:SetActive(false)
  end
end
def.method().UpdateRecentRedPoint = function(self)
  local num = ChatModule.Instance():GetChatNewCount(nil)
  local red = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Tab/Tab_Recent/Img_Red")
  if num > 0 then
    red:SetActive(true)
  else
    red:SetActive(false)
  end
end
def.method().UpdateFriendRedPoint = function(self)
  local num = #FriendData.Instance():GetApplicantList()
  local red = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Tab/Tab_Friend/Img_Red")
  if num > 0 then
    red:SetActive(true)
  else
    red:SetActive(false)
  end
end
def.method().UpdateMailRedPoint = function(self)
  local num = GangData.Instance():GetUnReadAnnoNum()
  num = num + FriendData.Instance():GetUnReadMailsNum()
  num = num + (require("Main.UpdateNotice.UpdateNoticeModule").Instance():HasRead() and 0 or 1)
  local red = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Tab/Tab_Mail/Img_Red")
  if num > 0 then
    red:SetActive(true)
  else
    red:SetActive(false)
  end
end
def.method().UpdateRankFriendRedPoint = function(self)
  GUIUtils.SetActive(self.m_panel:FindDirect("Img_BgFriend/Group_Tab/Btn_Friend"), not GameUtil.IsEvaluation() and _G.LoginPlatform ~= MSDK_LOGIN_PLATFORM.GUEST)
  local imgRedGO = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Tab/Btn_Friend/Img_Red")
  GUIUtils.SetActive(imgRedGO, RelationShipChainMgr.CanReciveGift() or RelationShipChainMgr.CanReciveFriendNumGift())
end
def.method().UpdatePrivateRedPoint = function(self)
  local num = ChatModule.Instance():GetChatNewCount(nil)
  num = num + #FriendData.Instance():GetApplicantList()
  num = num + GangData.Instance():GetUnReadAnnoNum()
  num = num + FriendData.Instance():GetUnReadMailsNum()
  num = num + (require("Main.UpdateNotice.UpdateNoticeModule").Instance():HasRead() and 0 or 1)
  local redGo = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Img_BgChat/Title_FriendChatBtn/Btn_Expand/Img_RedPiont")
  local redNum = redGo:FindDirect("Label_Number")
  local redGo2 = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Chat/Img_Bg/Img_BgChat/Title_FriendChatBtn/Btn_ChatBack/Img_RedPiont")
  local redNum2 = redGo2:FindDirect("Label_Number")
  if num > 0 then
    redGo:SetActive(true)
    redNum:GetComponent("UILabel"):set_text(num > 100 and "99+" or num)
    redGo2:SetActive(true)
    redNum2:GetComponent("UILabel"):set_text(num > 100 and "99+" or num)
  else
    redGo:SetActive(false)
    redGo2:SetActive(false)
  end
end
def.method().UpdateAddFriendRed = function(self)
  local red = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Tab/Btn_AddFriend/Img_NewRedPiont")
  if red then
    local FriendModule = require("Main.friend.FriendModule")
    local hasGrcFriend = FriendModule.Instance():HaveGrcFriend()
    if hasGrcFriend then
      red:SetActive(true)
    else
      red:SetActive(false)
    end
  end
end
def.method().UpdateYouyuanPoint = function(self)
  local InteractMgr = require("Main.Shitu.interact.InteractMgr")
  local red = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Tab/Btn_Space/Img_Red")
  if InteractMgr.Instance():IsFeatrueTaskOpen(false) then
    GUIUtils.SetActive(red, InteractMgr.Instance():NeedReddot())
  else
    GUIUtils.SetActive(red, false)
  end
end
def.method().UpdateSocialSpacePoint = function(self)
  local SocialSpaceModule = require("Main.SocialSpace.SocialSpaceModule")
  local red = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Tab/Btn_COF/Img_Red")
  local unreadNum = SocialSpaceModule.Instance():GetSelfSpaceUnreadMsgNum()
  GUIUtils.SetActive(red, unreadNum > 0)
end
def.method("table").SetSearchFriend = function(self, searchRes)
  self.searchFriendList = searchRes
  local num = #self.searchFriendList
  local scroll = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Content/Content_Search/Scroll View")
  local searchList = scroll:FindDirect("SearchFriendList")
  local searchListCmp = searchList:GetComponent("UIList")
  searchListCmp:set_itemCount(num)
  searchListCmp:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not searchListCmp.isnil then
      searchListCmp:Reposition()
    end
  end)
  local items = searchListCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local searchInfo = self.searchFriendList[i]
    self:FillSearchInfo(uiGo, searchInfo, i)
    self.m_msgHandler:Touch(uiGo)
  end
  self:RescrollSearchList()
end
def.method("userdata").DelRoleForSearchFriend = function(self, _roleid)
  if not self.m_panel or self.m_panel.isnil or not self.searchFriendList then
    return
  end
  local HeroUtils = require("Main.Hero.HeroUtility").Instance()
  local roleId = tostring(HeroUtils:RoleIDToDisplayID(_roleid))
  local index = 0
  for i, info in ipairs(self.searchFriendList) do
    local infoRoleId = tostring(HeroUtils:RoleIDToDisplayID(info.roleId))
    if infoRoleId == roleId then
      index = i
      break
    end
  end
  if index > 0 then
    local resultTable = {}
    for i, info in ipairs(self.searchFriendList) do
      if i ~= index then
        table.insert(resultTable, info)
      end
    end
    self:SetSearchFriend(resultTable)
  end
end
def.method("userdata", "table", "number").FillSearchInfo = function(self, searchUI, searchInfo, index)
  local nameLabel = searchUI:FindDirect(string.format("Label_SearchFriendName_%d", index))
  local nameLabelCmp = nameLabel:GetComponent("UILabel")
  local roleIdLabel = searchUI:FindDirect(string.format("Label_SearchFriendID_%d", index))
  local roleIdLabelCmp = roleIdLabel:GetComponent("UILabel")
  local roleHead = searchUI:FindDirect(string.format("Img_SearchFriendIconHead_%d", index))
  local frame = roleHead:FindDirect(string.format("Img_AvatarFrame_%d", index))
  local occupationSprite = nameLabel:FindDirect(string.format("Img_SearchFriendSchool_%d", index)):GetComponent("UISprite")
  local recommendSprite = searchUI:FindDirect(string.format("Img_TuiJian_%d", index))
  local levelLabel = searchUI:FindDirect(string.format("Img_SearchFriendIconHead_%d/Label_SearchHead_%d", index, index)):GetComponent("UILabel")
  local coverSprite = searchUI:FindDirect(string.format("Img_SearchFriendCover_%d", index))
  local AddBtn = searchUI:FindDirect(string.format("Btn_Add_Search_%d", index))
  local offline = searchUI:FindDirect(string.format("Img_LiXian_%d", index))
  local qqRec = searchUI:FindDirect(string.format("Img_QQ_%d", index))
  local wxRec = searchUI:FindDirect(string.format("Img_WeChat_%d", index))
  local nickNameLbl = searchUI:FindDirect(string.format("Label_NickName_%d", index))
  recommendSprite:SetActive(searchInfo.isRecommend)
  coverSprite:SetActive(searchInfo.onlineStatus ~= FriendConsts.STATUS_ONLINE)
  nameLabelCmp:set_text(searchInfo.roleName)
  local displayId = require("Main.Hero.HeroUtility").Instance():RoleIDToDisplayID(searchInfo.roleId)
  roleIdLabelCmp:set_text(tostring(displayId))
  levelLabel:set_text(searchInfo.roleLevel)
  local occupationIconId = FriendUtils.GetOccupationIconId(searchInfo.occupationId)
  FriendUtils.FillIcon(occupationIconId, occupationSprite, 3)
  SetAvatarIcon(roleHead, searchInfo.avatarId)
  SetAvatarFrameIcon(frame, searchInfo.avatarFrameId)
  local genderSprite = nameLabel:FindDirect(string.format("Img_SearchFriendSex_%d", index)):GetComponent("UISprite")
  genderSprite:set_spriteName(GUIUtils.GetGenderSprite(searchInfo.sex))
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
      wxRec:SetActive(false)
      offline:SetActive(not searchInfo.isOnline)
      qqRec:SetActive(searchInfo.isGrcFriend)
    elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
      qqRec:SetActive(false)
      offline:SetActive(not searchInfo.isOnline)
      wxRec:SetActive(searchInfo.isGrcFriend)
    else
      offline:SetActive(false)
      wxRec:SetActive(false)
      qqRec:SetActive(false)
    end
  elseif sdktype == ClientCfg.SDKTYPE.UNISDK then
    offline:SetActive(false)
    qqRec:SetActive(false)
    wxRec:SetActive(false)
  end
  if searchInfo.isGrcFriend then
    nickNameLbl:SetActive(true)
    local grcInfo = RelationShipChainMgr.SearchFriendData(searchInfo.roleId)
    local grcName = ""
    if grcInfo then
      grcName = GetStringFromOcts(grcInfo.nickname) or ""
      if Strlen(grcName) > 6 then
        grcName = StrSub(grcName, 1, 6) .. "..."
      end
    end
    nickNameLbl:GetComponent("UILabel"):set_text(grcName)
  else
    nickNameLbl:SetActive(false)
  end
  if searchInfo.isGrcFriend then
    nameLabel.localPosition = EC.Vector3.new(-75, 25, 0)
    roleIdLabel.localPosition = EC.Vector3.new(-32.4, -4, 0)
  else
    nameLabel.localPosition = EC.Vector3.new(-75, 14, 0)
    roleIdLabel.localPosition = EC.Vector3.new(-32.4, -14, 0)
  end
end
def.method().ShowSearchFriend = function(self)
  local FriendModule = require("Main.friend.FriendModule")
  local searchContent = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Content/Content_Search")
  searchContent:SetActive(true)
  FriendModule.Instance():RequestRecommend()
  self:ClearSearchList()
  self:Slide(SocialDlg.SlideState.Normal)
  require("Main.friend.ui.MailInfoPanel").CloseMailInfo()
end
def.method().ClearSearchList = function(self)
  local searchList = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Content/Content_Search/Scroll View/SearchFriendList")
  local searchListCmp = searchList:GetComponent("UIList")
  searchListCmp:set_itemCount(0)
  searchListCmp:Resize()
end
def.method().CloseSearchFriend = function(self)
  local searchContent = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Content/Content_Search")
  searchContent:SetActive(false)
end
def.method().RescrollSearchList = function(self)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    local scroll = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Content/Content_Search/Scroll View")
    local scrollCmp = scroll:GetComponent("UIScrollView")
    scrollCmp:ResetPosition()
  end)
end
def.method("number").ReadMail = function(self, mailIndex)
  if not self:IsShow() or self.curNode ~= SocialDlg.NodeId.Mail then
    return
  end
  self.nodes[SocialDlg.NodeId.Mail]:ReadMailByMailIndex(mailIndex)
end
def.method().SearchFriend = function(self)
  local input = self.m_panel:FindDirect("Widget_Ruler/SubPanel_Friend/Img_BgFriend/Group_Content/Content_Search/Img_BgSearch/Img_BgSearchShort/Img_BgSearchInput/Label_DefaultSearch")
  local searchName = input:GetComponent("UIInput"):get_value()
  local roleId = require("Main.Hero.Interface").GetHeroProp().id
  roleId = require("Main.Hero.HeroUtility").Instance():RoleIDToDisplayID(roleId)
  roleId = tostring(roleId)
  local roleName = require("Main.Hero.Interface").GetHeroProp().name
  if searchName == roleId or searchName == roleName then
    Toast(textRes.Friend[60])
    return
  end
  if SensitiveWordsFilter.ContainsSensitiveWord(searchName) then
    Toast(textRes.Friend[69])
    return
  end
  self:ClearSearchList()
  self:CSearch(searchName)
end
def.method("string").CSearch = function(self, inputCnt)
  if CheckCrossServerAndToast() then
    return
  end
  local sendSearch = ""
  local displayId = tonumber(inputCnt)
  if nil ~= displayId then
    local roleId = require("Main.Hero.Interface").DisplayIDToRoleID(Int64.new(displayId))
    sendSearch = Int64.tostring(roleId)
  else
    sendSearch = inputCnt
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.friend.CFindPlayer").new(sendSearch))
end
def.method().ClosePrivate = function(self)
  self.curName = ""
  self.curChatId = nil
  self:Slide(SocialDlg.SlideState.Normal)
end
def.method().CloseGroupChat = function(self)
  Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Close_Chat, {
    groupId = self.m_GroupId
  })
  self.m_GroupId = nil
  self.m_GroupChatViewCtrl:ShowAnnounceMent(false)
  self:Slide(SocialDlg.SlideState.Normal)
end
def.method("string").onClick = function(self, id)
  print("SocialDlg onClick", id)
  if self.curChatId and self.chatViewCtrl:onClick(id) then
  elseif self.curChatId and self.inputViewCtrl:onClick(id) then
  elseif self.m_GroupId and self.m_GroupChatViewCtrl:onClick(id) then
  elseif self.m_GroupId and self.m_GroupInputViewCtrl:onClick(id) then
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_CloseChat" then
    if self.curChatId and "" ~= self.curName then
      self:ClosePrivate()
    elseif self.m_GroupId then
      self:CloseGroupChat()
    end
  elseif id == "Btn_FriendClear" then
    if self.curChatId and "" ~= self.curName then
      self:ClearFriendMsg()
    elseif self.m_GroupId then
      self:ClearGroupMsg()
    end
  elseif id == "Btn_Expand" then
    self:Slide(SocialDlg.SlideState.ChatRight)
  elseif id == "Btn_ChatBack" then
    self:Slide(SocialDlg.SlideState.Normal)
  elseif id == "Btn_Collapse" then
    self:Slide(SocialDlg.SlideState.ChatLeft)
  elseif "Btn_OpenGroup" == id then
    if self.m_GroupId then
      local GroupSocialPanel = require("Main.Group.ui.GroupSocialPanel")
      GroupSocialPanel.Instance():ShowPanel(self.m_GroupId)
    end
  elseif string.find(id, "npc_") then
    local npcId = tonumber(string.sub(id, 5))
    if npcId > 0 then
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
      self:DestroyPanel()
      require("Main.friend.ui.SocialDlg").CloseSocialDlg()
    end
  elseif string.sub(id, 1, 4) == "Tab_" then
    local nodeId = SocialDlg.Tabs[id]
    if nodeId and nodeId ~= self.curNode then
      self:SwitchTo(nodeId)
    end
  elseif id == "Btn_KongJian" then
    local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
    local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
    if not FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_LBS) then
      Toast(textRes.Common[55])
      return
    end
    local LBSPanel = require("Main.MainUI.ui.LBSPanel")
    LBSPanel.Instance():ShowPanel()
    GameUtil.AddGlobalLateTimer(0.5, true, function()
      require("ProxySDK.ECMSDK").GetNearbyPersonInfo()
    end)
  elseif id == "Btn_Friend" then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_RANK_FRIEND_CLICK, nil)
  elseif id == "Btn_AddFriend" then
    require("Main.friend.FriendModule").Instance():SetGrcFriend(false)
    self:ShowSearchFriend()
  elseif id == "Img_Search" then
    self:SearchFriend()
  elseif id == "Btn_Cancel02" then
    self:CloseSearchFriend()
  elseif string.sub(id, 1, 15) == "Btn_Add_Search_" then
    local index = tonumber(string.sub(id, 16))
    local searchInfo = self.searchFriendList[index]
    if searchInfo then
      require("Main.friend.FriendModule").Instance():RequestAddFriendToServer(searchInfo.roleId)
    end
  elseif id == "Btn_Space" then
    local myHero = require("Main.Hero.HeroModule").Instance()
    local heroProp = myHero:GetHeroProp()
    local myRoleId = heroProp.id
    local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
    PersonalInfoInterface.Instance():CheckPersonalInfo(myRoleId, "")
  elseif id == "Btn_PVPTeam" then
    require("Main.Corps.CorpsInterface").OpenCorpsManage()
    self:DestroyPanel()
  elseif id == "Btn_COF" then
    require("Main.SocialSpace.SocialSpaceModule").Instance():EnterSelfSpace()
  elseif id == "Btn_SwitchChat" or id == "Btn_SwitchWorldChat" then
    self:DestroyPanel()
    require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(0, 0)
  else
    self.nodes[self.curNode]:onClick(id)
  end
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  if self.curChatId and self.inputViewCtrl:onSubmit(id, ctrl) then
  elseif self.m_GroupId and self.m_GroupInputViewCtrl:onSubmit(id, ctrl) then
  else
    self.nodes[self.curNode]:onSubmit(id, ctrl)
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if self.curChatId and self.chatViewCtrl:onClickObj(clickobj) then
  elseif self.m_GroupId and self.m_GroupChatViewCtrl:onClickObj(clickobj) then
  else
    self.nodes[self.curNode]:onClickObj(clickobj)
    self:onClick(id)
  end
end
def.method("userdata", "boolean").onPressObj = function(self, clickobj, bPress)
  if self.curChatId and self.chatViewCtrl:onPressObj(clickobj, bPress) then
  elseif self.m_GroupId and self.m_GroupChatViewCtrl:onPressObj(clickobj, bPress) then
  else
    self:onPress(clickobj and clickobj.name or "", bPress)
  end
end
def.method("string").onLongPress = function(self, id)
  if self.curChatId and self.chatViewCtrl:onLongPress(id) then
  elseif self.curChatId and self.inputViewCtrl:onLongPress(id) then
  elseif self.m_GroupId and self.m_GroupChatViewCtrl:onLongPress(id) then
  elseif self.m_GroupId and self.m_GroupInputViewCtrl:onLongPress(id) then
  else
    self.nodes[self.curNode]:onLongPress(id)
  end
end
def.method("string", "boolean").onPress = function(self, id, state)
  if self.curChatId and self.inputViewCtrl:onPress(id, state) then
  elseif self.m_GroupId and self.m_GroupInputViewCtrl:onPress(id, state) then
  else
    self.nodes[self.curNode]:onPress(id, state)
  end
end
def.method("string", "userdata").onDragOut = function(self, id, go)
  if self.curChatId and self.inputViewCtrl:onDragOut(id, go) then
  elseif self.m_GroupId and self.m_GroupInputViewCtrl:onDragOut(id, go) then
  else
    self.nodes[self.curNode]:onDragOut(id, go)
  end
end
def.method("string", "userdata").onDragOver = function(self, id, go)
  if self.curChatId and self.inputViewCtrl:onDragOver(id, go) then
  elseif self.m_GroupId and self.m_GroupInputViewCtrl:onDragOver(id, go) then
  else
    self.nodes[self.curNode]:onDragOver(id, go)
  end
end
def.method("string").onDragStart = function(self, id)
  self.nodes[self.curNode]:onDragStart(id)
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  self.nodes[self.curNode]:onDrag(id, dx, dy)
end
def.method("string").onDragEnd = function(self, id)
  if self.curChatId and self.chatViewCtrl:onDragEnd(id) then
  elseif self.m_GroupId and self.m_GroupChatViewCtrl:onDragEnd(id) then
  else
    self.nodes[self.curNode]:onDragEnd(id)
  end
end
def.method("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
  if self.curChatId and self.chatViewCtrl:onSpringFinish(id, scrollView, type, position) then
  elseif self.m_GroupId and self.m_GroupChatViewCtrl:onSpringFinish(id, scrollView, type, position) then
  else
    self.nodes[self.curNode]:onSpringFinish(id, scrollView, type, position)
  end
end
SocialDlg.Commit()
return SocialDlg
