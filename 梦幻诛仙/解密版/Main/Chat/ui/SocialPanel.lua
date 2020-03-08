local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local SocialPanel = Lplus.Extend(ECPanelBase, "SocialPanel")
local ChatNode = require("Main.Chat.ui.ChatNode")
local FriendNode = require("Main.friend.ui.FriendMainDlg")
local GangModule = require("Main.Gang.GangModule")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local def = SocialPanel.define
local instance
def.const("table").NodeId = {CHATNODE = 1, FRIENDNODE = 2}
def.field("table").nodes = nil
def.field("number").curNode = 0
def.field("number").state = 0
def.field("table").subState = nil
def.const("table").StateConst = {
  Last = 0,
  Friend = 1,
  Chat = 2,
  System = 3,
  Current = 4,
  World = 5,
  Team = 6,
  Faction = 7,
  Newer = 8,
  Activity = 9,
  All = 10,
  Sys = 11,
  Help = 12,
  Personal = 13,
  FriendList = 14,
  FriendChat = 15
}
def.static("=>", SocialPanel).Instance = function()
  if instance == nil then
    instance = SocialPanel()
    instance.m_TrigGC = true
    instance.m_HideOnDestroy = true
    instance.state = SocialPanel.StateConst.Friend
    instance.subState = {}
    instance.subState[SocialPanel.StateConst.Friend] = SocialPanel.StateConst.FriendList
    instance.subState[SocialPanel.StateConst.System] = SocialPanel.StateConst.All
    local hasGang = GangModule.Instance():HasGang()
    if hasGang then
      instance.subState[SocialPanel.StateConst.Chat] = SocialPanel.StateConst.Faction
    else
      instance.subState[SocialPanel.StateConst.Chat] = SocialPanel.StateConst.Newer
    end
  end
  return instance
end
def.method().Clear = function(self)
  self.nodes = nil
  self.curNode = 0
  self.state = 0
  self.subState = nil
  self.state = SocialPanel.StateConst.Friend
  self.subState = {}
  self.subState[SocialPanel.StateConst.Friend] = SocialPanel.StateConst.FriendList
  self.subState[SocialPanel.StateConst.System] = SocialPanel.StateConst.All
  local hasGang = GangModule.Instance():HasGang()
  if hasGang then
    self.subState[SocialPanel.StateConst.Chat] = SocialPanel.StateConst.Faction
  else
    self.subState[SocialPanel.StateConst.Chat] = SocialPanel.StateConst.Newer
  end
end
def.static("number").ShowSocialPanel = function(st)
  local socialPanel = SocialPanel.Instance()
  if st ~= SocialPanel.StateConst.Last then
    local state = socialPanel:StateSubToMain(st)
    socialPanel.state = state
    socialPanel.subState[state] = st
  end
  if socialPanel.m_panel then
    socialPanel:UpdatePanel()
  else
    socialPanel:CreatePanel(RESPATH.PREFAB_FRIEND_MAIN_PANEL, 0)
  end
end
def.static().CloseSocialPanel = function()
  local self = SocialPanel.Instance()
  if self:IsShow() then
    if self.curNode == SocialPanel.NodeId.FRIENDNODE then
      self.nodes[self.curNode]:onClick("Btn_Close")
    end
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  self.nodes = {}
  local chatNode = self.m_panel:FindDirect("Img_BgFriend/Img_BgChat")
  self.nodes[SocialPanel.NodeId.CHATNODE] = ChatNode()
  self.nodes[SocialPanel.NodeId.CHATNODE]:Init(self, chatNode)
  local friendNode = self.m_panel:FindDirect("Img_BgFriend/Widget_Friend")
  self.nodes[SocialPanel.NodeId.FRIENDNODE] = FriendNode()
  self.nodes[SocialPanel.NodeId.FRIENDNODE]:Init(self, friendNode)
  self:NewerOrGang()
  self:UpdatePanel()
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, SocialPanel.OnFriendMsg)
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailsChange, SocialPanel.OnFriendMsg)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_AnnouncementsChanged, SocialPanel.OnFriendMsg)
  SocialPanel.OnFriendMsg(nil, nil)
  print("socialPanel OnCreate")
end
def.method().UpdatePanel = function(self)
  print("state", self.state)
  if self.state == SocialPanel.StateConst.Chat then
    if self.subState[SocialPanel.StateConst.Chat] == SocialPanel.StateConst.Current then
      self:SwitchTo(SocialPanel.NodeId.CHATNODE)
      local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_Chat"):GetComponent("UIToggle")
      toggle:set_value(true)
      self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(self.subState[SocialPanel.StateConst.Chat])
    elseif self.subState[SocialPanel.StateConst.Chat] == SocialPanel.StateConst.World then
      self:SwitchTo(SocialPanel.NodeId.CHATNODE)
      local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_Chat"):GetComponent("UIToggle")
      toggle:set_value(true)
      self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(self.subState[SocialPanel.StateConst.Chat])
    elseif self.subState[SocialPanel.StateConst.Chat] == SocialPanel.StateConst.Team then
      self:SwitchTo(SocialPanel.NodeId.CHATNODE)
      local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_Chat"):GetComponent("UIToggle")
      toggle:set_value(true)
      self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(self.subState[SocialPanel.StateConst.Chat])
    elseif self.subState[SocialPanel.StateConst.Chat] == SocialPanel.StateConst.Faction then
      self:SwitchTo(SocialPanel.NodeId.CHATNODE)
      local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_Chat"):GetComponent("UIToggle")
      toggle:set_value(true)
      self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(self.subState[SocialPanel.StateConst.Chat])
    elseif self.subState[SocialPanel.StateConst.Chat] == SocialPanel.StateConst.Newer then
      self:SwitchTo(SocialPanel.NodeId.CHATNODE)
      local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_Chat"):GetComponent("UIToggle")
      toggle:set_value(true)
      self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(self.subState[SocialPanel.StateConst.Chat])
    elseif self.subState[SocialPanel.StateConst.Chat] == SocialPanel.StateConst.Activity then
      self:SwitchTo(SocialPanel.NodeId.CHATNODE)
      local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_Chat"):GetComponent("UIToggle")
      toggle:set_value(true)
      self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(self.subState[SocialPanel.StateConst.Chat])
    end
  elseif self.state == SocialPanel.StateConst.Friend then
    if self.subState[SocialPanel.StateConst.Friend] == SocialPanel.StateConst.FriendList then
      self:SwitchTo(SocialPanel.NodeId.FRIENDNODE)
      local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_Friend"):GetComponent("UIToggle")
      toggle:set_value(true)
    elseif self.subState[SocialPanel.StateConst.Friend] == SocialPanel.StateConst.FriendChat then
      self:SwitchTo(SocialPanel.NodeId.CHATNODE)
      local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_Friend"):GetComponent("UIToggle")
      toggle:set_value(true)
      self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(SocialPanel.StateConst.FriendChat)
      ChatModule.Instance():ClearFriendNewCount(ChatModule.Instance().curChatId)
      require("Main.friend.FriendModule").UpdateFriendChange()
    end
  elseif self.state == SocialPanel.StateConst.System then
    if self.subState[SocialPanel.StateConst.System] == SocialPanel.StateConst.All then
      self:SwitchTo(SocialPanel.NodeId.CHATNODE)
      local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_System"):GetComponent("UIToggle")
      toggle:set_value(true)
      self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(self.subState[SocialPanel.StateConst.System])
    elseif self.subState[SocialPanel.StateConst.System] == SocialPanel.StateConst.Sys then
      self:SwitchTo(SocialPanel.NodeId.CHATNODE)
      local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_System"):GetComponent("UIToggle")
      toggle:set_value(true)
      self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(self.subState[SocialPanel.StateConst.System])
    elseif self.subState[SocialPanel.StateConst.System] == SocialPanel.StateConst.Help then
      self:SwitchTo(SocialPanel.NodeId.CHATNODE)
      local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_System"):GetComponent("UIToggle")
      toggle:set_value(true)
      self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(self.subState[SocialPanel.StateConst.System])
    elseif self.subState[SocialPanel.StateConst.System] == SocialPanel.StateConst.Personal then
      self:SwitchTo(SocialPanel.NodeId.CHATNODE)
      local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_System"):GetComponent("UIToggle")
      toggle:set_value(true)
      self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(self.subState[SocialPanel.StateConst.System])
    end
  end
end
def.static("table", "table").OnFriendMsg = function(p1, p2)
  local unReadFriend = require("Main.friend.FriendModule").Instance():GetAllFriendCount() or 0
  local unReadMail = require("Main.friend.FriendData").Instance():GetUnReadMailsNum() or 0
  local unReadGang = require("Main.Gang.data.GangData").Instance():GetUnReadAnnoNum() or 0
  local unReadReleaseNote = require("Main.UpdateNotice.UpdateNoticeModule").Instance():HasRead() and 0 or 1
  SocialPanel.Instance():SetFriendNew(unReadFriend + unReadMail + unReadGang + unReadReleaseNote)
  if SocialPanel.Instance().m_panel ~= nil and SocialPanel.NodeId.CHATNODE == SocialPanel.Instance().curNode then
    SocialPanel.Instance().nodes[SocialPanel.NodeId.CHATNODE]:SetNewMsgCount(unReadFriend)
  end
end
def.method("number").SetFriendNew = function(self, count)
  if self.m_panel and not self.m_panel.isnil then
    local red = self.m_panel:FindDirect("Img_BgFriend/Tap_Friend/Img_Red01")
    local redLabel = red:FindDirect("Label_Num"):GetComponent("UILabel")
    local num = require("Main.friend.FriendModule").Instance():GetAllFriendCount() or 0
    if count > 0 then
      red:SetActive(true)
      redLabel:set_text(tostring(count))
    else
      red:SetActive(false)
    end
  end
end
def.override().OnDestroy = function(self)
  self.nodes[SocialPanel.NodeId.FRIENDNODE]:Clear()
  self.nodes[self.curNode]:Hide()
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, SocialPanel.OnFriendMsg)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailsChange, SocialPanel.OnFriendMsg)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_AnnouncementsChanged, SocialPanel.OnFriendMsg)
end
def.method("number").SwitchTo = function(self, nodeId)
  self.curNode = 0
  for k, v in pairs(self.nodes) do
    print("nodeId", nodeId)
    if nodeId == k then
      v:Show()
      self.curNode = nodeId
    else
      v:Hide()
    end
  end
end
def.method().NewerOrGang = function(self)
  if self.subState[SocialPanel.StateConst.Chat] == SocialPanel.StateConst.Newer or self.subState[SocialPanel.StateConst.Chat] == SocialPanel.StateConst.Faction then
    local hasGang = GangModule.Instance():HasGang()
    if hasGang then
      self.subState[SocialPanel.StateConst.Chat] = SocialPanel.StateConst.Faction
    else
      self.subState[SocialPanel.StateConst.Chat] = SocialPanel.StateConst.Newer
    end
  end
end
def.method("number", "=>", "number").StateSubToMain = function(self, subState)
  if subState == SocialPanel.StateConst.Current or subState == SocialPanel.StateConst.World or subState == SocialPanel.StateConst.Team or subState == SocialPanel.StateConst.Faction or subState == SocialPanel.StateConst.Newer or subState == SocialPanel.StateConst.Activity then
    return SocialPanel.StateConst.Chat
  elseif subState == SocialPanel.StateConst.All or subState == SocialPanel.StateConst.Sys or subState == SocialPanel.StateConst.Help or subState == SocialPanel.StateConst.Personal then
    return SocialPanel.StateConst.System
  elseif subState == SocialPanel.StateConst.FriendChat or subState == SocialPanel.StateConst.FriendList then
    return SocialPanel.StateConst.Friend
  end
end
def.method("string").onClick = function(self, id)
  print("Friend onClick", id)
  if id == "Btn_Close" then
    if self.curNode == SocialPanel.NodeId.FRIENDNODE then
      self.nodes[self.curNode]:onClick(id)
    end
    self:DestroyPanel()
  elseif id == "Tap_Friend" then
    ChatModule.Instance().curChatId = Int64.new(0)
    ChatModule.Instance().curChatName = ""
    self:SwitchTo(SocialPanel.NodeId.FRIENDNODE)
  elseif id == "Tap_Chat" then
    ChatModule.Instance().curChatId = Int64.new(0)
    ChatModule.Instance().curChatName = ""
    self:SwitchTo(SocialPanel.NodeId.CHATNODE)
    print("TAP_CHAT", self.subState[SocialPanel.StateConst.Chat])
    self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(self.subState[SocialPanel.StateConst.Chat])
  elseif id == "Tap_System" then
    ChatModule.Instance().curChatId = Int64.new(0)
    ChatModule.Instance().curChatName = ""
    self:SwitchTo(SocialPanel.NodeId.CHATNODE)
    self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(self.subState[SocialPanel.StateConst.System])
  else
    self.nodes[self.curNode]:onClick(id)
  end
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  self.nodes[self.curNode]:onSubmit(id, ctrl)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  self.nodes[SocialPanel.NodeId.CHATNODE]:ClearMsgOperation()
  self:onClick(id)
  self.nodes[self.curNode]:onClickObj(clickobj)
end
def.method("string").onLongPress = function(self, id)
  self.nodes[SocialPanel.NodeId.CHATNODE]:ClearMsgOperation()
  self.nodes[self.curNode]:onLongPress(id)
end
def.method("string", "boolean").onPress = function(self, id, state)
  self.nodes[self.curNode]:onPress(id, state)
end
def.method("string", "userdata").onDragOut = function(self, id, go)
  self.nodes[self.curNode]:onDragOut(id, go)
end
def.method("string", "userdata").onDragOver = function(self, id, go)
  self.nodes[self.curNode]:onDragOver(id, go)
end
def.method("string").onDragStart = function(self, id)
  self.nodes[self.curNode]:onDragStart(id)
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  self.nodes[self.curNode]:onDrag(id, dx, dy)
end
def.method("string").onDragEnd = function(self, id)
  self.nodes[self.curNode]:onDragEnd(id)
end
def.method("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
  self.nodes[self.curNode]:onSpringFinish(id, scrollView, type, position)
end
def.method().ShowFriendChat = function(self)
  self:SwitchTo(SocialPanel.NodeId.CHATNODE)
  self.nodes[SocialPanel.NodeId.CHATNODE]:SwitchState(SocialPanel.StateConst.FriendChat)
  local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_Friend"):GetComponent("UIToggle")
  toggle:set_value(true)
end
def.method().UpdateChatMsg = function(self)
  if self.m_panel ~= nil and SocialPanel.NodeId.CHATNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.CHATNODE]:UpdateMsg()
  end
end
def.method("table").AddMsg = function(self, msg)
  if self.m_panel ~= nil and SocialPanel.NodeId.CHATNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.CHATNODE]:AddMsg(msg)
  end
end
def.method("table").ShowSearchResult = function(self, p)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:ShowSearchResult(p)
  end
end
def.method().UpdateFriendList = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and (SocialPanel.NodeId.FRIENDNODE == self.curNode or SocialPanel.NodeId.CHATNODE == self.curNode) then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:UpdateFriendList()
  end
end
def.method().CheckNewApply = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:CheckNewApply()
  end
end
def.method().UpdateAddFriendDlg = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and (SocialPanel.NodeId.FRIENDNODE == self.curNode or SocialPanel.NodeId.CHATNODE == self.curNode) then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:UpdateAddFriendDlg()
  end
end
def.method().ShowApplicants = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:ShowApplicants()
  end
end
def.method().onGetNewApplicant = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:onGetNewApplicant()
  end
end
def.method().ShowShieldList = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    SocialPanel.ShowSocialPanel(SocialPanel.StateConst.FriendList)
    SocialPanel.Instance():Show(false)
    GameUtil.AddGlobalTimer(0.5, true, function()
      self.nodes[SocialPanel.NodeId.FRIENDNODE]:ShowShieldList()
      SocialPanel.Instance():Show(true)
    end)
  else
    self:SwitchTo(SocialPanel.NodeId.FRIENDNODE)
    local toggle = self.m_panel:FindDirect("Img_BgFriend/Tap_Friend"):GetComponent("UIToggle")
    toggle:set_value(true)
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:ShowShieldList()
  end
end
def.method("table").UpdateRecommendFriendList = function(self, recommendList)
  if self.m_panel and false == self.m_panel.isnil and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:OnUpdateRecommendFriendList(recommendList)
  end
end
def.method("table").UpdateAfterAddRecommendFriend = function(self, friendInfo)
  if self.m_panel and false == self.m_panel.isnil and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:OnUpdateAfterAddRecommendFriend(friendInfo)
  end
end
def.method("string", "string").AddInfoPack = function(self, name, cipher)
  if self.m_panel ~= nil and SocialPanel.NodeId.CHATNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.CHATNODE]:AddInfoPack(name, cipher)
  end
end
def.method("string").AddChatContent = function(self, content)
  if self.m_panel ~= nil and SocialPanel.NodeId.CHATNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.CHATNODE]:AddChatContent(content)
  end
end
def.method("string", "boolean").SendChatContent = function(self, content, record)
  if self.m_panel ~= nil and SocialPanel.NodeId.CHATNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.CHATNODE]:SubmitContent2(content, record)
  end
end
def.method("boolean").SubmitChatContent = function(self, record)
  if self.m_panel ~= nil and SocialPanel.NodeId.CHATNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.CHATNODE]:SubmitContent(record)
  end
end
def.method().DeletChatContent = function(self)
  if self.m_panel ~= nil and SocialPanel.NodeId.CHATNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.CHATNODE]:DeleteCharactor()
  end
end
def.method().UpdateChangeMsg = function(self)
  self:NewerOrGang()
  if self.m_panel ~= nil and SocialPanel.NodeId.CHATNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.CHATNODE]:UpdateMsg()
  end
end
def.method().FocusOnInput = function(self)
  if self.m_panel ~= nil and SocialPanel.NodeId.CHATNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.CHATNODE]:FocusOnInput()
  end
end
def.method().UpdateUnReadMailsLabel = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:UpdateUnReadMailsLabel()
  end
end
def.method("=>", "number").GetMailInfoIndex = function(self, num)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() then
    if SocialPanel.NodeId.FRIENDNODE == self.curNode then
      return self.nodes[SocialPanel.NodeId.FRIENDNODE]:GetMailInfoIndex()
    else
      return 0
    end
  else
    return 0
  end
end
def.method().ShowMailsList = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:ShowMailsList()
  end
end
def.method().UpdateMailRemainTime = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:UpdateMailRemainTime()
  end
end
def.method("number").SetMailInfoIndex = function(self, num)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:SetMailInfoIndex(num)
  end
end
def.method("number").SelectMailByMailIndex = function(self, num)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:SelectMailByMailIndex(num)
  end
end
def.method().UpdateAutoButtonLabel = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:UpdateAutoButtonLabel()
  end
end
def.method().UpdateMailReadPointAttach = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:UpdateMailReadPointAttach()
  end
end
def.method().SucceedAttach = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:SucceedAttach()
  end
end
def.method().SucceedRead = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:SucceedRead()
  end
end
def.method("number").OnAnnouncementsChanged = function(self, num)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() and SocialPanel.NodeId.FRIENDNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.FRIENDNODE]:OnAnnouncementsChanged(num)
  end
end
def.method("table").RefreshTeam = function(self, data)
  if self.m_panel ~= nil and SocialPanel.NodeId.CHATNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.CHATNODE]:RefreshTeamPlatform(data)
  end
end
def.method().RefreshPrivateChatName = function(self)
  if self.m_panel ~= nil and SocialPanel.NodeId.CHATNODE == self.curNode then
    self.nodes[SocialPanel.NodeId.CHATNODE]:SetPrivateChatTitle()
  end
end
SocialPanel.Commit()
return SocialPanel
