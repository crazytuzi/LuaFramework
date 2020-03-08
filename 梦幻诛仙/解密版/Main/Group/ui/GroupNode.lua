local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TabNode = require("GUI.TabNode")
local GUIUtils = require("GUI.GUIUtils")
local GroupModule = require("Main.Group.GroupModule")
local SocialDlg = Lplus.ForwardDeclare("SocialDlg")
local GroupUtils = require("Main.Group.GroupUtils")
local protocolMgr = require("Main.Group.GroupProtocolMgr")
local GroupNode = Lplus.Extend(TabNode, "GroupNode")
local def = GroupNode.define
def.field("table").m_CurGroupList = nil
def.field("userdata").m_ChatGroupId = nil
def.field("userdata").m_WaitingChatGroupId = nil
def.field("userdata").m_MenuGroupId = nil
def.field("table").m_UIObjs = nil
def.field("number").m_Timer = 0
def.field("boolean").m_IsWaitingBasicInfo = false
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_JoinGroup, GroupNode.OnGroupNumChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_LeaveGroup, GroupNode.OnGroupNumChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_Name_Changed, GroupNode.OnGroupInfoChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Invite, GroupNode.OnGroupInfoChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Kick, GroupNode.OnGroupInfoChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Quit, GroupNode.OnGroupInfoChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_MemberInfo_Inited, GroupNode.OnGroupInfoInited, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, GroupNode.OnGroupInfoChange, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.GroupChatMsgUpdate, GroupNode.OnGroupNumChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_BasicInfo_Inited, GroupNode.OnGroupBasicInfoInited, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_Close_Chat, GroupNode.OnGroupCloseChat, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, GroupNode.OnGroupInfoChange, self)
  self:InitUI()
  self:UpdateData()
  self:SortGroupList()
  self:UpdateUI()
  local updateTime = GroupUtils.GetClientUpdateTime()
  self.m_Timer = GameUtil.AddGlobalTimer(updateTime, false, function()
    if self.m_node and not self.m_node.isnil and self.m_node:get_activeInHierarchy() and not self.m_IsWaitingBasicInfo then
      self.m_IsWaitingBasicInfo = true
      protocolMgr.SetWaitForBasicInfo(true)
      protocolMgr.CGroupBasicInfoReq()
    end
  end)
end
def.method("table").OnGroupBasicInfoInited = function(self, params)
  if nil == self.m_node or self.m_node.isnil then
    return
  end
  if not self.m_node:get_activeInHierarchy() then
    return
  end
  if self.m_IsWaitingBasicInfo then
    self.m_IsWaitingBasicInfo = false
    local count = 0
    for k, v in pairs(params.groupIds) do
      count = count + 1
    end
    if count < 1 then
      return
    end
    for k, v in pairs(params.groupIds) do
      self:UpdateSingleData(v)
      self:UpdateItemObj(v)
    end
  end
end
def.method("table").OnGroupInfoInited = function(self, params)
  if nil == self.m_node or self.m_node.isnil then
    return
  end
  if not self.m_node:get_activeInHierarchy() then
    return
  end
  local groupId = params.groupId
  if nil == groupId then
    return
  end
  if self.m_WaitingChatGroupId then
    if not self.m_WaitingChatGroupId:eq(groupId) then
      return
    end
    local ChatModule = require("Main.Chat.ChatModule")
    ChatModule.Instance():ShowGroupChatPanel(self.m_WaitingChatGroupId)
    GroupModule.Instance():RemoveNewJoinGroup(self.m_WaitingChatGroupId)
    ChatModule.Instance():ClearGroupNewCount(self.m_WaitingChatGroupId)
    self.m_ChatGroupId = self.m_WaitingChatGroupId
    self.m_WaitingChatGroupId = nil
  elseif self.m_MenuGroupId then
    if not self.m_MenuGroupId:eq(groupId) then
      return
    end
    local GroupMenuPanel = require("Main.Group.ui.GroupMenuPanel")
    GroupMenuPanel.Instance():ShowPanel(self.m_MenuGroupId)
    GroupModule.Instance():RemoveNewJoinGroup(self.m_MenuGroupId)
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, {
      groupId = self.m_MenuGroupId
    })
    local FriendModule = require("Main.friend.FriendModule")
    Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
      FriendModule.Instance():GetAllFriendCount()
    })
    self.m_MenuGroupId = nil
  end
  self:UpdateSingleData(groupId)
  self:UpdateItemObj(groupId)
end
def.method("table").OnGroupNumChange = function(self, params)
  if nil == self.m_node or self.m_node.isnil then
    return
  end
  if not self.m_node:get_activeInHierarchy() then
    return
  end
  local groupId = params.groupId
  if nil == groupId then
    return
  end
  self:UpdateData()
  self:SortGroupList()
  self:UpdateUI()
end
def.method("table").OnGroupInfoChange = function(self, params)
  if nil == self.m_node or self.m_node.isnil then
    return
  end
  if not self.m_node:get_activeInHierarchy() then
    return
  end
  local groupId = params and params.groupId
  if groupId then
    self:UpdateSingleData(groupId)
    self:UpdateItemObj(groupId)
  else
    for k, v in pairs(self.m_CurGroupList) do
      self:UpdateSingleData(v.groupId)
      self:UpdateItemObj(v.groupId)
    end
  end
end
def.method("userdata").UpdateItemObj = function(self, groupId)
  if nil == groupId then
    return
  end
  local index = -1
  for k, v in pairs(self.m_CurGroupList) do
    if v.groupId:eq(groupId) then
      index = k
      break
    end
  end
  if -1 == index then
    return
  end
  local uiScrollList = self.m_UIObjs.GroupScrollView:FindDirect("List_Group"):GetComponent("UIScrollList")
  if nil == uiScrollList then
    return
  end
  local itemObj = ScrollList_getItem(uiScrollList, index)
  if nil == itemObj or itemObj.isnil then
    return
  end
  self:FillGroupItem(itemObj, index)
end
def.method("table").OnGroupCloseChat = function(self, params)
  if nil == self.m_node or self.m_node.isnil then
    return
  end
  if not self.m_node:get_activeInHierarchy() then
    return
  end
  local groupId = params.groupId
  if nil == groupId then
    return
  end
  if self.m_ChatGroupId and self.m_ChatGroupId:eq(groupId) then
    self.m_ChatGroupId = nil
  end
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_LeaveGroup, GroupNode.OnGroupNumChange)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_JoinGroup, GroupNode.OnGroupNumChange)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Name_Changed, GroupNode.OnGroupInfoChange)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Invite, GroupNode.OnGroupInfoChange)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Kick, GroupNode.OnGroupInfoChange)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Quit, GroupNode.OnGroupInfoChange)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_MemberInfo_Inited, GroupNode.OnGroupInfoInited)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, GroupNode.OnGroupInfoChange)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupChatMsgUpdate, GroupNode.OnGroupNumChange)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_BasicInfo_Inited, GroupNode.OnGroupBasicInfoInited)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Close_Chat, GroupNode.OnGroupCloseChat)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, GroupNode.OnGroupInfoChange)
  self.m_CurGroupList = nil
  self.m_WaitingChatGroupId = nil
  self.m_ChatGroupId = nil
  self.m_MenuGroupId = nil
  self.m_UIObjs = nil
  if 0 ~= self.m_Timer then
    GameUtil.RemoveGlobalTimer(self.m_Timer)
    self.m_Timer = 0
  end
  self.m_IsWaitingBasicInfo = false
  SocialDlg.Instance():Slide(SocialDlg.SlideState.Normal)
end
def.method().InitUI = function(self)
  self.m_UIObjs = {}
  self.m_UIObjs.GroupScrollView = self.m_node:FindDirect("Scroll View_Friend")
  self.m_UIObjs.NoGroup = self.m_node:FindDirect("Group_NoGroup")
end
def.method("userdata").UpdateSingleData = function(self, targetGroupId)
  if nil == targetGroupId then
    return
  end
  local targetData
  for k, v in pairs(self.m_CurGroupList) do
    if targetGroupId == v.groupId then
      targetData = v
      break
    end
  end
  if nil == targetData then
    return
  end
  local groupBasicInfo = GroupModule.Instance():GetGroupBasicInfo(targetGroupId)
  if nil == groupBasicInfo then
    return
  end
  for k, v in pairs(groupBasicInfo) do
    targetData[k] = v
  end
end
def.method().UpdateData = function(self)
  self.m_CurGroupList = GroupModule.Instance():GetBasicGroupList()
end
def.method().SortGroupList = function(self)
  if nil == self.m_CurGroupList then
    return
  end
  local ChatModule = require("Main.Chat.ChatModule")
  local function sortFunc(a, b)
    local groupId1 = a.groupId
    local groupId2 = b.groupId
    local newChatCount1 = ChatModule.Instance():GetGroupChatNewCount(groupId1) or 0
    local newChatCount2 = ChatModule.Instance():GetGroupChatNewCount(groupId2) or 0
    if 0 == newChatCount1 and newChatCount2 > 0 then
      return false
    elseif 0 == newChatCount2 and newChatCount1 > 0 then
      return true
    elseif 0 == newChatCount1 and 0 == newChatCount2 then
      return a.createTime > b.createTime
    else
      local newChat1 = ChatModule.Instance():GetGroupNewOne(a.groupId)
      local newChat2 = ChatModule.Instance():GetGroupNewOne(b.groupId)
      if newChat1 and newChat2 then
        local chattime1 = newChat1.time or 0
        local cahttime2 = newChat2.time or 0
        return chattime1 > cahttime2
      else
        return true
      end
    end
  end
  table.sort(self.m_CurGroupList, sortFunc)
end
def.method().UpdateUI = function(self)
  if nil == self.m_UIObjs or nil == self.m_CurGroupList then
    return
  end
  local redImg = self.m_node:FindDirect("Img_CreateGroup/Img_NewRedPiont")
  if redImg then
    redImg:SetActive(false)
  end
  local curGroupNum = #self.m_CurGroupList
  if curGroupNum > 0 then
    self.m_UIObjs.GroupScrollView:SetActive(true)
    self.m_UIObjs.NoGroup:SetActive(false)
    self:UpdateGroupList()
  else
    self.m_UIObjs.GroupScrollView:SetActive(false)
    self.m_UIObjs.NoGroup:SetActive(true)
  end
end
def.method().UpdateGroupList = function(self)
  if nil == self.m_UIObjs or nil == self.m_CurGroupList then
    return
  end
  local scrollListObj = self.m_UIObjs.GroupScrollView:FindDirect("List_Group")
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(uiScrollList, function(item, index)
    self:FillGroupItem(item, index)
  end)
  ScrollList_setCount(uiScrollList, #self.m_CurGroupList)
  self.m_base.m_msgHandler:Touch(scrollListObj)
end
def.method("userdata", "number").FillGroupItem = function(self, itemObj, index)
  if nil == itemObj or itemObj.isnil then
    return
  end
  local groupInfo = self.m_CurGroupList[index]
  if nil == groupInfo then
    return
  end
  local groupId = groupInfo.groupId
  local isGroupMaster = GroupModule.Instance():IsGroupMaster(groupId)
  local leaderNameLabel = itemObj:FindDirect("Label_LeaderName")
  local memberNameLabel = itemObj:FindDirect("Label_MemberName")
  if isGroupMaster then
    leaderNameLabel:SetActive(true)
    memberNameLabel:SetActive(false)
    leaderNameLabel:GetComponent("UILabel"):set_text(groupInfo.groupName)
  else
    leaderNameLabel:SetActive(false)
    memberNameLabel:SetActive(true)
    memberNameLabel:GetComponent("UILabel"):set_text(groupInfo.groupName)
  end
  local ChatModule = require("Main.Chat.ChatModule")
  local previewLabel = itemObj:FindDirect("Label_WordPreview")
  local newContent = ChatModule.Instance():GetGroupNewOne(groupId)
  local chatContent = "<p></p>"
  if newContent and newContent.plainHtml then
    chatContent = newContent.plainHtml
  end
  local html = previewLabel:GetComponent("NGUIHTML")
  if html:get_html() ~= chatContent then
    html:ForceHtmlText(chatContent)
  end
  local isNewGroup = GroupModule.Instance():IsNewJoinGroup(groupId)
  local newCount = ChatModule.Instance():GetGroupChatNewCount(groupId)
  local newRedImg = itemObj:FindDirect("Img_NewRedPiont")
  if newCount > 0 then
    newRedImg:SetActive(true)
    local countLabel = itemObj:FindDirect("Img_NewRedPiont/Label_NewRedPiont")
    countLabel:GetComponent("UILabel"):set_text(newCount >= 100 and "99+" or newCount)
    countLabel:SetActive(true)
  elseif isNewGroup then
    newRedImg:SetActive(true)
    local countLabel = itemObj:FindDirect("Img_NewRedPiont/Label_NewRedPiont")
    countLabel:SetActive(false)
  else
    newRedImg:SetActive(false)
  end
  if self.m_ChatGroupId then
    local uiToggle = itemObj:GetComponent("UIToggle")
    if self.m_ChatGroupId:eq(groupId) then
      uiToggle:set_value(true)
    else
      uiToggle:set_value(false)
    end
  end
  self:FillGroupHeadIcon(itemObj, groupId)
end
def.method("userdata", "userdata").FillGroupHeadIcon = function(self, itemObj, groupId)
  local headIconGroup = itemObj:FindDirect("Group_Member")
  local headIconInfos = GroupModule.Instance():GetGroupHeadIconInfo(groupId)
  local sprites = {}
  sprites[1] = headIconGroup:FindDirect("Img_Member3/Img_IconHead")
  sprites[2] = headIconGroup:FindDirect("Img_Member4/Img_IconHead")
  sprites[3] = headIconGroup:FindDirect("Img_Member2/Img_IconHead")
  sprites[4] = headIconGroup:FindDirect("Img_Member1/Img_IconHead")
  local defaults = {}
  defaults[1] = headIconGroup:FindDirect("Img_Member3/Img_HeadSM")
  defaults[2] = headIconGroup:FindDirect("Img_Member4/Img_HeadSM")
  defaults[3] = headIconGroup:FindDirect("Img_Member2/Img_HeadSM")
  defaults[4] = headIconGroup:FindDirect("Img_Member1/Img_HeadSM")
  for i = 1, 4 do
    local IconInfo = headIconInfos[i]
    if IconInfo then
      sprites[i]:SetActive(true)
      SetAvatarIcon(sprites[i], IconInfo.avatarId)
      defaults[i]:SetActive(false)
    else
      sprites[i]:SetActive(false)
      defaults[i]:SetActive(true)
    end
  end
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Right" == id then
    self:OnClickRightOperateBtn(clickObj)
  elseif string.sub(id, 1, #"Img_BgGroup") == "Img_BgGroup" then
    self:OnClickGroupBtn(clickObj)
  elseif "Img_CreateGroup" == id then
    self:OnClickCreateGroup()
  end
end
def.method().OnClickCreateGroup = function(self)
  if CheckCrossServerAndToast() then
    return
  end
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local heroLevel = heroProp.level
  local limitLevel = GroupUtils.GetGroupCreateLevel()
  if heroLevel < limitLevel then
    Toast(string.format(textRes.Group[6], limitLevel))
    return
  end
  local maxGroupNum = GroupUtils.GetCurGroupLimitNum()
  local myGroupNum = GroupModule.Instance():GetMyCreateGroupNum()
  if maxGroupNum <= myGroupNum then
    Toast(string.format(textRes.Group[5], maxGroupNum))
    return
  end
  local GroupCreatePanel = require("Main.Group.ui.GroupCreatePanel")
  GroupCreatePanel.Instance():ShowPanel()
end
def.method("userdata").OnClickRightOperateBtn = function(self, clickObj)
  local parentObj = clickObj.parent
  if string.sub(parentObj.name, 1, #"Img_BgGroup") ~= "Img_BgGroup" then
    return
  end
  local itemObj, index = ScrollList_getItem(parentObj)
  if nil == itemObj or itemObj.isnil then
    return
  end
  local groupInfo = self.m_CurGroupList[index]
  if nil == groupInfo then
    return
  end
  local isInited = groupInfo.isInited
  if isInited then
    local GroupMenuPanel = require("Main.Group.ui.GroupMenuPanel")
    GroupMenuPanel.Instance():ShowPanel(groupInfo.groupId)
    GroupModule.Instance():RemoveNewJoinGroup(groupInfo.groupId)
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, {
      groupId = groupInfo.groupId
    })
    local FriendModule = require("Main.friend.FriendModule")
    Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
      FriendModule.Instance():GetAllFriendCount()
    })
  else
    self.m_MenuGroupId = groupInfo.groupId
    protocolMgr.SetWaitForSingleInfo(true)
    protocolMgr.CSingleGroupInfoReq(groupInfo.groupId, groupInfo.groupVersion)
  end
end
def.method("userdata").OnClickGroupBtn = function(self, clickObj)
  local itemObj, index = ScrollList_getItem(clickObj)
  if nil == itemObj or itemObj.isnil then
    return
  end
  local groupBasicInfo = self.m_CurGroupList[index]
  if nil == groupBasicInfo then
    return
  end
  itemObj:GetComponent("UIToggle"):set_value(true)
  local isInited = groupBasicInfo.isInited
  self.m_WaitingChatGroupId = groupBasicInfo.groupId
  if isInited then
    self.m_WaitingChatGroupId = nil
    self.m_ChatGroupId = groupBasicInfo.groupId
    local ChatModule = require("Main.Chat.ChatModule")
    ChatModule.Instance():ShowGroupChatPanel(self.m_ChatGroupId)
    GroupModule.Instance():RemoveNewJoinGroup(self.m_ChatGroupId)
    ChatModule.Instance():ClearGroupNewCount(self.m_ChatGroupId)
  else
    protocolMgr.SetWaitForSingleInfo(true)
    protocolMgr.CSingleGroupInfoReq(groupBasicInfo.groupId, groupBasicInfo.groupVersion)
  end
end
GroupNode.Commit()
return GroupNode
