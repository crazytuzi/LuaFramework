local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local RecentNode = Lplus.Extend(TabNode, "RecentNode")
local ECPanelBase = require("GUI.ECPanelBase")
local FriendUtils = require("Main.friend.FriendUtils")
local GUIUtils = require("GUI.GUIUtils")
local ChatModule = require("Main.Chat.ChatModule")
local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local SocialDlg = Lplus.ForwardDeclare("SocialDlg")
local FriendData = require("Main.friend.FriendData")
local def = RecentNode.define
def.field("table").chatList = nil
def.field("userdata").list = nil
def.field("userdata").listCmp = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.list = self.m_node:FindDirect("Scroll View_Recent/List_Recent")
  self.listCmp = self.list:GetComponent("UIScrollList")
  local GUIScrollList = self.list:GetComponent("GUIScrollList")
  if GUIScrollList == nil then
    self.list:AddComponent("GUIScrollList")
  end
  local scroll = self.m_node:FindDirect("Scroll View_Recent"):GetComponent("UIScrollView")
  ScrollList_setUpdateFunc(self.listCmp, function(item, i)
    self:FillChatInfo(item, i)
    if scroll and not scroll.isnil then
      scroll:InvalidateBounds()
    end
  end)
  self.m_base.m_msgHandler:Touch(self.list)
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendNameChanged, RecentNode.OnNeedStatusUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendLevelChanged, RecentNode.OnNeedStatusUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnAvatarChange, RecentNode.OnNeedStatusUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnOccupationChange, RecentNode.OnNeedStatusUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendOnlineChanged, RecentNode.OnNeedStatusUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, RecentNode.OnNeedStatusUpdate, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.UpdateFirendMsg, RecentNode.OnNeedUpdate, self)
  ScrollList_clear(self.listCmp)
  self:UpdateChatList()
  self:RepositionList()
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendNameChanged, RecentNode.OnNeedStatusUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendLevelChanged, RecentNode.OnNeedStatusUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnAvatarChange, RecentNode.OnNeedStatusUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnOccupationChange, RecentNode.OnNeedStatusUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendOnlineChanged, RecentNode.OnNeedStatusUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, RecentNode.OnNeedStatusUpdate)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.UpdateFirendMsg, RecentNode.OnNeedUpdate)
  SocialDlg.Instance():Slide(SocialDlg.SlideState.Normal)
end
def.method("table").OnNeedStatusUpdate = function(self)
  self:UpdateChatList()
end
def.method("table").OnNeedUpdate = function(self, params)
  if self.list == nil or self.list.isnil then
    return
  end
  local num = #self.chatList
  self:UpdateChatList()
  local newNum = #self.chatList
  if num ~= newNum then
    self:RepositionList()
  end
end
def.method().UpdateChatList = function(self)
  self.chatList = self:GetSortedChatList()
  local listNum = #self.chatList
  ScrollList_setCount(self.listCmp, listNum)
  if listNum > 0 then
    self.m_node:FindDirect("Group_NoFriend"):SetActive(false)
  else
    self.m_node:FindDirect("Group_NoFriend"):SetActive(true)
  end
end
def.method("userdata", "number").FillChatInfo = function(self, chatUI, index)
  local chatInfo = self.chatList[index]
  if chatInfo == nil then
    chatUI:SetActive(false)
    return
  end
  chatUI:SetActive(true)
  local friendInfo = FriendData.Instance():GetFriendInfo(chatInfo.roleId)
  local remarkNameOpen = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_FRIEND_REMARK_NAME)
  local icon = chatUI:FindDirect("Img_IconHead")
  local frame = icon:FindDirect("Img_AvatarFrame")
  SetAvatarIcon(icon, chatInfo.avatarId)
  SetAvatarFrameIcon(frame, chatInfo.avatarFrameId)
  icon:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(chatInfo.roleLevel)
  chatUI:FindDirect("Label_FriendName"):GetComponent("UILabel"):set_text(remarkNameOpen and friendInfo and friendInfo.remarkName and friendInfo.remarkName ~= "" and friendInfo.remarkName or chatInfo.roleName)
  local occupationIconId = FriendUtils.GetOccupationIconId(chatInfo.occupationId)
  local occupationSprite = chatUI:FindDirect("Img_School"):GetComponent("UISprite")
  FriendUtils.FillIcon(occupationIconId, occupationSprite, 3)
  local genderSprite = chatUI:FindDirect("Img_Sex"):GetComponent("UISprite")
  genderSprite:set_spriteName(GUIUtils.GetGenderSprite(chatInfo.sex))
  local bOnline = require("netio.protocol.mzm.gsp.friend.FriendConsts").STATUS_ONLINE == chatInfo.onlineStatus
  if bOnline then
    chatUI:FindDirect("Img_OffLine"):SetActive(false)
    chatUI:FindDirect("Img_Cover"):SetActive(false)
  else
    chatUI:FindDirect("Img_OffLine"):SetActive(true)
    chatUI:FindDirect("Img_Cover"):SetActive(true)
  end
  local chatOneInfo = ChatModule.Instance():GetFriendNewOne(chatInfo.roleId)
  local timeStr = ""
  if nil ~= chatOneInfo and nil ~= chatOneInfo.time then
    local cur = os.date("*t", GetServerTime())
    local last = os.date("*t", chatOneInfo.time)
    if cur.day ~= last.day or cur.month ~= last.month or cur.year ~= last.year then
      timeStr = string.format("%d-%d-%d", last.year, last.month, last.day)
    else
      timeStr = os.date("%X", chatOneInfo.time)
    end
  end
  chatUI:FindDirect("Label_Time"):GetComponent("UILabel"):set_text(timeStr)
  local chatContent = "<p></p>"
  if chatOneInfo ~= nil and chatOneInfo.plainHtml ~= nil then
    chatContent = chatOneInfo.plainHtml
  end
  local quickCnt = chatUI:FindDirect("Label_WordPreview")
  local htmlCmp = quickCnt:GetComponent("NGUIHTML")
  if htmlCmp:get_html() ~= chatContent then
    quickCnt:GetComponent("NGUIHTML"):ForceHtmlText(chatContent)
  end
  local newMsgCount = ChatModule.Instance():GetChatNewCount(chatInfo.roleId)
  local newPoint = chatUI:FindDirect("Img_NewRedPiont")
  if newMsgCount > 0 then
    newPoint:SetActive(true)
    newPoint:FindDirect("Label_NewRedPiont"):GetComponent("UILabel"):set_text(newMsgCount <= 99 and newMsgCount or "99+")
  else
    newPoint:SetActive(false)
  end
  if SocialDlg.Instance().curChatId == chatInfo.roleId then
    chatUI:GetComponent("UIToggle").value = true
  else
    chatUI:GetComponent("UIToggle").value = false
  end
  self.m_base.m_msgHandler:Touch(chatUI)
end
def.method("=>", "table").GetSortedChatList = function(self)
  local allChat = ChatModule.Instance():GetAllPrivateChat()
  local ChatInfoCache = {}
  local function GetChatInfo(roleId)
    if ChatInfoCache[roleId:tostring()] then
      return ChatInfoCache[roleId:tostring()]
    end
    local chatInfo = {}
    chatInfo.new = ChatModule.Instance():GetChatNewCount(roleId)
    local chatNewOne = ChatModule.Instance():GetFriendNewOne(roleId)
    chatInfo.time = chatNewOne and chatNewOne.time or 0
    ChatInfoCache[roleId:tostring()] = chatInfo
    return chatInfo
  end
  local function sortChat(a, b)
    local aInfo = GetChatInfo(a.roleId)
    local bInfo = GetChatInfo(b.roleId)
    if aInfo.new > 0 and bInfo.new <= 0 then
      return true
    elseif aInfo.new <= 0 and bInfo.new > 0 then
      return false
    elseif a.onlineStatus < b.onlineStatus then
      return true
    elseif a.onlineStatus > b.onlineStatus then
      return false
    else
      return aInfo.time > bInfo.time
    end
  end
  table.sort(allChat, sortChat)
  return allChat
end
def.method().RepositionList = function(self)
  local scrollGo = self.m_node:FindDirect("Scroll View_Recent")
  local scrollCmp = scrollGo:GetComponent("UIScrollView")
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not scrollCmp.isnil then
      scrollCmp:ResetPosition()
    end
  end)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local name = clickobj.name
  if name == "Img_BgRecent" then
    local item, idx = ScrollList_getItem(clickobj)
    if item then
      local chatInfo = self.chatList[idx]
      if chatInfo then
        local roleId = chatInfo.roleId
        local roleName = chatInfo.roleName
        local roleLevel = -1
        if chatInfo.roleLevel and chatInfo.roleLevel > 0 then
          roleLevel = chatInfo.roleLevel
        end
        local occupationId = chatInfo.occupationId
        local sex = chatInfo.sex
        local avatarId = chatInfo.avatarId or 0
        local avatarFrameId = chatInfo.avatarFrameId or 0
        ChatModule.Instance():_StartPrivateChat(roleId, roleName, roleLevel, occupationId, sex, avatarId, avatarFrameId, true)
        ChatModule.Instance():ClearFriendNewCount(roleId)
      end
    end
  elseif name == "Btn_Right" then
    local item, idx = ScrollList_getItem(clickobj)
    if item then
      local chatInfo = self.chatList[idx]
      if chatInfo then
        local roleId = chatInfo.roleId
        FriendCommonDlgManager.ApplyShowFriendCommonDlg(roleId, FriendCommonDlgManager.StateConst.Null)
      end
    end
  end
end
def.override("string").onClick = function(self, id)
  if string.sub(id, 1, 10) == "Btn_Right_" then
    local index = tonumber(string.sub(id, 11))
    local chatInfo = self.chatList[index]
    if chatInfo then
      local roleId = chatInfo.roleId
      FriendCommonDlgManager.ApplyShowFriendCommonDlg(roleId, FriendCommonDlgManager.StateConst.Null)
    end
  elseif string.sub(id, 1, 13) == "Img_BgFriend_" then
    local index = tonumber(string.sub(id, 14))
    local chatInfo = self.chatList[index]
    if chatInfo then
      local roleId = chatInfo.roleId
      local roleName = chatInfo.roleName
      local roleLevel = -1
      if chatInfo.roleLevel and chatInfo.roleLevel > 0 then
        roleLevel = chatInfo.roleLevel
      end
      local occupationId = chatInfo.occupationId
      local sex = chatInfo.sex
      local avatarId = chatInfo.avatarId or 0
      local avatarFrameId = chatInfo.avatarFrameId or 0
      ChatModule.Instance():_StartPrivateChat(roleId, roleName, roleLevel, occupationId, sex, avatarId, avatarFrameId, true)
      ChatModule.Instance():ClearFriendNewCount(roleId)
    end
  end
end
RecentNode.Commit()
return RecentNode
