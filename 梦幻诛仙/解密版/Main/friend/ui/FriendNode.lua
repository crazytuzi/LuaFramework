local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local FriendNode = Lplus.Extend(TabNode, "FriendNode")
local ECPanelBase = require("GUI.ECPanelBase")
local FriendUtils = require("Main.friend.FriendUtils")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ChatModule = require("Main.Chat.ChatModule")
local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
local GUIUtils = require("GUI.GUIUtils")
local SocialDlg = Lplus.ForwardDeclare("SocialDlg")
local EC = require("Types.Vector3")
local def = FriendNode.define
def.field("table").friendList = nil
def.field("table").applyList = nil
def.field("userdata").scrollCmp = nil
def.field("userdata").list = nil
def.field("userdata").listCmp = nil
def.field("number").listOffset = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.list = self.m_node:FindDirect("Scroll View_Friend/List_Friend")
  self.listCmp = self.list:GetComponent("UIScrollList")
  local GUIScrollList = self.list:GetComponent("GUIScrollList")
  if GUIScrollList == nil then
    self.list:AddComponent("GUIScrollList")
  end
  local scroll = self.m_node:FindDirect("Scroll View_Friend"):GetComponent("UIScrollView")
  ScrollList_setUpdateFunc(self.listCmp, function(item, i)
    self:FillFriendInfo(item, i)
    if scroll and not scroll.isnil then
      scroll:InvalidateBounds()
    end
  end)
  self.m_base.m_msgHandler:Touch(self.list)
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendChanged, FriendNode.OnFriendNeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendIntimacyChanged, FriendNode.OnStatusNeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendNameChanged, FriendNode.OnStatusNeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendLevelChanged, FriendNode.OnStatusNeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnAvatarChange, FriendNode.OnStatusNeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnOccupationChange, FriendNode.OnStatusNeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendOnlineChanged, FriendNode.OnStatusNeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, FriendNode.OnStatusNeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.UpdateFirendMsg, FriendNode.OnStatusNeedUpdate, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendApplyChanged, FriendNode.OnApplyNeedUpdate, self)
  ScrollList_clear(self.listCmp)
  self:UpdateApply()
  self:UpdateFriendList()
  self:RepositionList()
  self:ShowApplyList(false)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendChanged, FriendNode.OnFriendNeedUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendIntimacyChanged, FriendNode.OnStatusNeedUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendNameChanged, FriendNode.OnStatusNeedUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendLevelChanged, FriendNode.OnStatusNeedUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnAvatarChange, FriendNode.OnStatusNeedUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnOccupationChange, FriendNode.OnStatusNeedUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendOnlineChanged, FriendNode.OnStatusNeedUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, FriendNode.OnStatusNeedUpdate)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.UpdateFirendMsg, FriendNode.OnStatusNeedUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendApplyChanged, FriendNode.OnApplyNeedUpdate)
  SocialDlg.Instance():Slide(SocialDlg.SlideState.Normal)
end
def.method("table").OnStatusNeedUpdate = function(self, params)
  self:UpdateFriendList()
end
def.method("table").OnFriendNeedUpdate = function(self, params)
  self:UpdateFriendList()
end
def.method("table").OnApplyNeedUpdate = function(self)
  warn("OnApplyNeedUpdate\t")
  self:UpdateApply()
  self:UpdateFriendList()
  self:UpdateApplyList()
  self:RepositionList()
  local applyView = self.m_node:FindDirect("Panel_Apply/Content_BgApply")
  if applyView:get_activeInHierarchy() then
    self.applyList = self:GetSortedApplyList()
    local applyNum = #self.applyList
    if applyNum < 1 then
      self:ShowApplyList(false)
    end
  end
end
def.method().UpdateApply = function(self)
  local friendData = require("Main.friend.FriendData").Instance()
  local applyList = friendData:GetApplicantList()
  local applyEntrance = self.m_node:FindDirect("Scroll View_Friend/Img_BgApplyEntrance")
  if #applyList > 0 then
    applyEntrance:SetActive(true)
    local Img_ApplyIcon = applyEntrance:FindDirect("Img_ApplyEntrance/Img_ApplyIcon")
    local sprite = Img_ApplyIcon:GetComponent("UISprite")
    sprite:set_spriteName("Img_NewFriend")
    applyEntrance:FindDirect("Label_PlayerNameEntrance"):GetComponent("UILabel"):set_text(applyList[#applyList].roleName .. textRes.Friend[13])
    applyEntrance:FindDirect("Img_NewRedPiont/Label_NewRedPiont"):GetComponent("UILabel"):set_text(tostring(#applyList))
    self.listOffset = 1
  else
    self.listOffset = 0
    applyEntrance:SetActive(false)
  end
end
def.method().UpdateFriendList = function(self)
  self.friendList = self:GetSortedFriendList()
  local listNum = #self.friendList + self.listOffset
  ScrollList_setCount(self.listCmp, listNum)
  if listNum > 0 then
    self.m_node:FindDirect("Group_NoFriend"):SetActive(false)
  else
    self.m_node:FindDirect("Group_NoFriend"):SetActive(true)
  end
end
def.method("userdata", "number").FillFriendInfo = function(self, friendUI, index)
  local friendInfo = self.friendList[index - self.listOffset]
  if friendInfo == nil then
    friendUI:SetActive(false)
    return
  end
  friendUI:SetActive(true)
  local icon = friendUI:FindDirect("Img_IconHead")
  local frame = icon:FindDirect("Img_AvatarFrame")
  SetAvatarIcon(icon, friendInfo.avatarId)
  SetAvatarFrameIcon(frame, friendInfo.avatarFrameId)
  icon:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(friendInfo.roleLevel)
  local remarkNameOpen = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_FRIEND_REMARK_NAME)
  if remarkNameOpen and friendInfo.remarkName and friendInfo.remarkName ~= "" then
    friendUI:FindDirect("Label_FriendName"):GetComponent("UILabel"):set_text(friendInfo.remarkName)
  else
    friendUI:FindDirect("Label_FriendName"):GetComponent("UILabel"):set_text(friendInfo.roleName)
  end
  local occupationIconId = FriendUtils.GetOccupationIconId(friendInfo.occupationId)
  local occupationSprite = friendUI:FindDirect("Img_School"):GetComponent("UISprite")
  FriendUtils.FillIcon(occupationIconId, occupationSprite, 3)
  local genderSprite = friendUI:FindDirect("Img_Sex"):GetComponent("UISprite")
  genderSprite:set_spriteName(GUIUtils.GetGenderSprite(friendInfo.sex))
  local bOnline = require("netio.protocol.mzm.gsp.friend.FriendConsts").STATUS_ONLINE == friendInfo.onlineStatus
  if bOnline then
    friendUI:FindDirect("Img_OffLine"):SetActive(false)
    friendUI:FindDirect("Img_Cover"):SetActive(false)
  else
    friendUI:FindDirect("Img_OffLine"):SetActive(true)
    friendUI:FindDirect("Img_Cover"):SetActive(true)
  end
  local chatInfo = ChatModule.Instance():GetFriendNewOne(friendInfo.roleId)
  local timeStr = ""
  if nil ~= chatInfo and nil ~= chatInfo.time then
    local cur = os.date("*t", GetServerTime())
    local last = os.date("*t", chatInfo.time)
    if cur.day ~= last.day or cur.month ~= last.month or cur.year ~= last.year then
      timeStr = string.format("%d-%d-%d", last.year, last.month, last.day)
    else
      timeStr = os.date("%X", chatInfo.time)
    end
  end
  friendUI:FindDirect("Label_Time"):GetComponent("UILabel"):set_text(timeStr)
  local chatContent = "<p></p>"
  if chatInfo ~= nil and nil ~= chatInfo.plainHtml then
    chatContent = chatInfo.plainHtml
  end
  local quickCnt = friendUI:FindDirect("Label_WordPreview")
  local htmlCmp = quickCnt:GetComponent("NGUIHTML")
  if htmlCmp:get_html() ~= chatContent then
    quickCnt:GetComponent("NGUIHTML"):ForceHtmlText(chatContent)
  end
  local newMsgCount = ChatModule.Instance():GetChatNewCount(friendInfo.roleId)
  local newPoint = friendUI:FindDirect("Img_NewRedPiont")
  if newMsgCount > 0 then
    newPoint:SetActive(true)
    newPoint:FindDirect("Label_NewRedPiont"):GetComponent("UILabel"):set_text(newMsgCount <= 99 and newMsgCount or "99+")
  else
    newPoint:SetActive(false)
  end
  if SocialDlg.Instance().curChatId == friendInfo.roleId then
    friendUI:GetComponent("UIToggle").value = true
  else
    friendUI:GetComponent("UIToggle").value = false
  end
  self.m_base.m_msgHandler:Touch(friendUI)
end
def.method("=>", "table").GetSortedFriendList = function(self)
  local FriendConsts = require("netio.protocol.mzm.gsp.friend.FriendConsts").STATUS_ONLINE
  local friendData = require("Main.friend.FriendData").Instance()
  local allFriends = clone(friendData:GetFriendList())
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
  local function sortFriend(a, b)
    if a == b then
      return false
    end
    local aInfo = GetChatInfo(a.roleId)
    local bInfo = GetChatInfo(b.roleId)
    if aInfo.new > 0 and bInfo.new <= 0 then
      return true
    elseif aInfo.new <= 0 and bInfo.new > 0 then
      return false
    else
      if aInfo.new > 0 and bInfo.new > 0 then
        local aLastTime = aInfo.time
        local bLastTime = bInfo.time
        if aLastTime and bLastTime then
          return aLastTime > bLastTime
        end
      end
      if a.onlineStatus < b.onlineStatus then
        return true
      elseif a.onlineStatus > b.onlineStatus then
        return false
      elseif a.relationValue ~= b.relationValue then
        return a.relationValue > b.relationValue
      else
        local aName = a.roleName
        local bName = b.roleName
        if aName and bName then
          local sortTb = GameUtil.SortString({aName, bName})
          return aName == sortTb[1]
        else
          return true
        end
      end
    end
  end
  table.sort(allFriends, sortFriend)
  return allFriends
end
def.method("boolean").ShowApplyList = function(self, show)
  if show then
    local applyView = self.m_node:FindDirect("Panel_Apply")
    applyView:SetActive(true)
    self:UpdateApplyList()
  else
    local applyView = self.m_node:FindDirect("Panel_Apply")
    applyView:SetActive(false)
  end
end
def.method().UpdateApplyList = function(self)
  local applyView = self.m_node:FindDirect("Panel_Apply/Content_BgApply")
  if applyView:get_activeInHierarchy() then
    self.applyList = self:GetSortedApplyList()
    do
      local applyNum = #self.applyList
      local scroll = self.m_node:FindDirect("Panel_Apply/Content_BgApply/Scroll View_FriendApply")
      local applyList = self.m_node:FindDirect("Panel_Apply/Content_BgApply/Scroll View_FriendApply/Grid_FriendApply")
      local applyListCmp = applyList:GetComponent("UIList")
      applyListCmp:set_itemCount(applyNum)
      applyListCmp:Resize()
      GameUtil.AddGlobalLateTimer(0, true, function()
        if scroll.isnil or applyListCmp.isnil then
          return
        end
        applyListCmp:Reposition()
        scroll:GetComponent("UIScrollView"):ResetPosition()
      end)
      local items = applyListCmp:get_children()
      for i = 1, #items do
        local uiGo = items[i]
        local applyInfo = self.applyList[i]
        self:FillApplyInfo(uiGo, applyInfo, i)
        self.m_base.m_msgHandler:Touch(uiGo)
      end
    end
  end
end
def.method("userdata", "table", "number").FillApplyInfo = function(self, applyUI, applyInfo, index)
  local icon = applyUI:FindDirect(string.format("Img_IconHeadFriendApply_%d", index))
  local frame = icon:FindDirect(string.format("Img_AvatarFrame_%d", index))
  SetAvatarIcon(icon, applyInfo.avatarId)
  SetAvatarFrameIcon(frame, applyInfo.avatarFrameId)
  icon:FindDirect(string.format("Label_NumFriendApply_%d", index)):GetComponent("UILabel"):set_text(applyInfo.roleLevel)
  applyUI:FindDirect(string.format("Label_FriendApplyName_%d", index)):GetComponent("UILabel"):set_text(applyInfo.roleName)
  local occupationIconId = FriendUtils.GetOccupationIconId(applyInfo.occupationId)
  local occupationSprite = applyUI:FindDirect(string.format("Img_SchoolFriendApply_%d", index)):GetComponent("UISprite")
  FriendUtils.FillIcon(occupationIconId, occupationSprite, 3)
  local timeRemain, timeStr = FriendUtils.ComputeRemainTime(FriendUtils.GetApplyTimeMax(), applyInfo.applyTime)
  applyUI:FindDirect(string.format("Label_TimeFriendApply_%d", index)):GetComponent("UILabel"):set_text(string.format(textRes.Friend[15], timeRemain, timeStr))
  if nil ~= applyInfo.content then
    applyUI:FindDirect(string.format("Label_WordPreviewFriendApply_%d", index)):SetActive(true)
    applyUI:FindDirect(string.format("Label_WordPreviewFriendApply_%d", index)):GetComponent("UILabel"):set_text(applyInfo.content)
  else
    applyUI:FindDirect(string.format("Label_WordPreviewFriendApply_%d", index)):SetActive(false)
  end
  local coverSprite = applyUI:FindDirect(string.format("Img_CoverFriendApply_%d", index))
  local offLineSprite = applyUI:FindDirect(string.format("Img_OffLine_%d", index))
  coverSprite:SetActive(false)
  offLineSprite:SetActive(false)
end
def.method("=>", "table").GetSortedApplyList = function(self)
  local friendData = require("Main.friend.FriendData").Instance()
  local applyList = friendData:GetApplicantList()
  return applyList
end
def.method().RepositionList = function(self)
  if self.scrollCmp == nil then
    local scrollGo = self.m_node:FindDirect("Scroll View_Friend")
    self.scrollCmp = scrollGo:GetComponent("UIScrollView")
  end
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not self.scrollCmp.isnil then
      self.scrollCmp:ResetPosition()
    end
  end)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local name = clickobj.name
  if name == "Img_BgFriend" then
    local item, idx = ScrollList_getItem(clickobj)
    if item then
      local fInfo = self.friendList[idx - self.listOffset]
      if fInfo then
        local roleId = fInfo.roleId
        local roleName = fInfo.roleName
        local roleLevel = -1
        if fInfo.roleLevel and fInfo.roleLevel > 0 then
          roleLevel = fInfo.roleLevel
        end
        local occupationId = fInfo.occupationId
        local sex = fInfo.sex
        local avatarId = fInfo.avatarId or 0
        local avatarFrameId = fInfo.avatarFrameId or 0
        ChatModule.Instance():_StartPrivateChat(roleId, roleName, roleLevel, occupationId, sex, avatarId, avatarFrameId, true)
        ChatModule.Instance():ClearFriendNewCount(roleId)
      end
    end
  elseif name == "Btn_Right" then
    local item, idx = ScrollList_getItem(clickobj)
    if item then
      do
        local fInfo = self.friendList[idx - self.listOffset]
        if fInfo then
          local roleId = fInfo.roleId
          local friendData = require("Main.friend.FriendData").Instance()
          local info = friendData:GetFriendInfo(roleId)
          if info.delStatus == require("netio.protocol.mzm.gsp.RoleDeleteStatus").STATE_NORMAL then
            FriendCommonDlgManager.ApplyShowFriendCommonDlg(roleId, FriendCommonDlgManager.StateConst.Null)
          else
            require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Friend[12], textRes.Friend[73], function(sel)
              if sel == 1 then
                require("Main.friend.FriendModule").AddFriendOrDeleteFriend(fInfo.roleId, fInfo.roleName)
              end
            end, nil)
          end
        end
      end
    end
  end
end
def.override("string").onClick = function(self, id)
  if id == "Img_BgApplyEntrance" then
    self:ShowApplyList(true)
  elseif string.sub(id, 1, 22) == "Btn_FriendApplyAccept_" then
    local index = tonumber(string.sub(id, 23))
    local applyInfo = self.applyList[index]
    if applyInfo then
      require("Main.friend.FriendModule").Instance():AgreeFriendApply(applyInfo.roleId)
    end
  elseif string.sub(id, 1, 22) == "Btn_FriendApplyRefuse_" then
    local index = tonumber(string.sub(id, 23))
    local applyInfo = self.applyList[index]
    if applyInfo then
      require("Main.friend.FriendModule").Instance():RefuseFriendApply(applyInfo.roleId)
      if applyInfo.roleLevel <= FriendUtils.GetAddFriendLevel() then
        require("Main.friend.FriendModule").Instance():LeadToSetting()
      end
    end
  elseif string.sub(id, 1, 18) == "Img_BgFriendApply_" then
    local index = tonumber(string.sub(id, 19))
    local applyInfo = self.applyList[index]
    if applyInfo then
      FriendCommonDlgManager.ApplyShowFriendCommonDlg(applyInfo.roleId, FriendCommonDlgManager.StateConst.Null)
    end
  elseif id == "Btn_BackToFriend01" then
    self:ShowApplyList(false)
  end
end
FriendNode.Commit()
return FriendNode
