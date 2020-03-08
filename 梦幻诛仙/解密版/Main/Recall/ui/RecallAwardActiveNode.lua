local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local GUIUtils = require("GUI.GUIUtils")
local RecallUtils = require("Main.Recall.RecallUtils")
local RecallData = require("Main.Recall.data.RecallData")
local RecallProtocols = require("Main.Recall.RecallProtocols")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local RecallAwardActiveNode = Lplus.Extend(TabNode, "RecallAwardActiveNode")
local def = RecallAwardActiveNode.define
local instance
def.static("=>", RecallAwardActiveNode).Instance = function()
  if instance == nil then
    instance = RecallAwardActiveNode()
  end
  return instance
end
local UPDATE_INTERVAL = 1
def.field("boolean")._bInited = false
def.field("table")._uiObjs = nil
def.field("table")._bindedFriendList = nil
def.field("table")._headTextureList = nil
def.field("number")._bindTimerID = 0
def.field("number")._bindCountdown = 0
def.method("number", "userdata").Update = function(self, tabIdx, tab)
  if not self:IsUnlock() then
    GUIUtils.SetActive(tab, false)
    GUIUtils.SetActive(self.m_node, false)
    if self.isShow then
      self:Hide()
    end
  else
    GUIUtils.SetActive(tab, true)
    local GetRecallAwardNode = require("Main.RelationShipChain.ui.GetRecallAwardNode")
    if tabIdx == GetRecallAwardNode.TAB.ACTIVE then
      RecallProtocols.SendCGetBindVitalityInfoReq()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self:Show()
      end)
    elseif self.isShow then
      self:Hide()
    end
  end
end
def.method("=>", "boolean").IsUnlock = function(self)
  local RecallModule = require("Main.Recall.RecallModule")
  local bFeatrueOpen = RecallModule.Instance():IsOpen(false) and RecallModule.Instance():IsBindActiveOpen(false)
  local bCanBindFriend = RecallData.Instance():CanBindRecallFriend()
  local bindedFriendCount = RecallData.Instance():GetBindedFriendActiveCount()
  if not bFeatrueOpen or not bCanBindFriend and not (bindedFriendCount > 0) then
    return false
  else
    return true
  end
end
def.override().OnShow = function(self)
  self:InitUI()
  self:_HandleEventListeners(true)
  self:_UpdateUI()
end
def.method().InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Bind_Title = self.m_node:FindDirect("Title/Label")
  self._uiObjs.Label_Bind_Time = self.m_node:FindDirect("Title/Label_Time")
  self._uiObjs.Btn_Bound = self.m_node:FindDirect("Title/Btn_Bound")
  self._uiObjs.Scroll_View = self.m_node:FindDirect("Days/Scroll View")
  self._uiObjs.uiScrollView = self._uiObjs.Scroll_View:GetComponent("UIScrollView")
  self._uiObjs.List_Day = self._uiObjs.Scroll_View:FindDirect("List_Day")
  self._uiObjs.uiList = self._uiObjs.List_Day:GetComponent("UIList")
  self._bInited = true
end
def.method()._UpdateUI = function(self)
  self:UpdateFriendList()
  self:ShowBindCountdown()
end
def.override().OnHide = function(self)
  self:_ClearBindTimer()
  self:_HandleEventListeners(false)
  if self._bInited then
    self:Reset()
    self._bInited = false
  end
end
def.method().Reset = function(self)
  if _G.IsNil(self._uiObjs) then
    return
  end
  self:ClearFriendList()
  self._bindedFriendList = nil
  self._uiObjs = nil
end
def.method().UpdateFriendList = function(self)
  self:ClearFriendList()
  self._bindedFriendList = RecallData.Instance():GetBindedFriendActiveList()
  local friendCount = self._bindedFriendList and #self._bindedFriendList or 0
  self._headTextureList = {}
  if friendCount > 0 then
    self._uiObjs.uiList.itemCount = friendCount
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
    for idx, friendActiveInfo in ipairs(self._bindedFriendList) do
      self:ShowActiveInfo(idx, friendActiveInfo)
    end
  else
  end
end
def.method("number", "table").ShowActiveInfo = function(self, idx, friendActiveInfo)
  local listItem = self._uiObjs.uiList.children[idx]
  if nil == listItem then
    warn("[ERROR][RecallAwardActiveNode:ShowActiveInfo] listItem nil at idx:", idx)
    return
  end
  if nil == friendActiveInfo then
    warn("[ERROR][RecallAwardActiveNode:ShowActiveInfo] friendActiveInfo nil at idx:", idx)
    return
  end
  local heroActiveInfo = RecallData.Instance():GetHeroActiveInfo()
  local bindDay = friendActiveInfo:GetBindDay()
  local Label_Day = listItem:FindDirect("Label_Day")
  GUIUtils.SetText(Label_Day, string.format(textRes.Recall.BIND_DAY_COUNT, bindDay))
  local Btn_Box = listItem:FindDirect("Btn_Box")
  local Img_Get = listItem:FindDirect("Img_Get")
  if friendActiveInfo:IsAwardFetched() then
    GUIUtils.SetActive(Btn_Box, false)
    GUIUtils.SetActive(Img_Get, true)
    GUIUtils.SetLightEffect(Btn_Box, GUIUtils.Light.None)
  else
    GUIUtils.SetActive(Btn_Box, true)
    GUIUtils.SetActive(Img_Get, false)
    if friendActiveInfo:CanFetchAward() then
      GUIUtils.SetLightEffect(Btn_Box, GUIUtils.Light.Round)
    else
      GUIUtils.SetLightEffect(Btn_Box, GUIUtils.Light.None)
    end
  end
  local leftActiveInfo, rightActiveInfo
  if friendActiveInfo:IsCaller() then
    leftActiveInfo = friendActiveInfo
    rightActiveInfo = heroActiveInfo
  else
    leftActiveInfo = heroActiveInfo
    rightActiveInfo = friendActiveInfo
  end
  local leftGroup = listItem:FindDirect("Player_Left")
  local rightGroup = listItem:FindDirect("Player_Right")
  self:ShowRoleInfo(leftGroup, leftActiveInfo)
  self:ShowRoleInfo(rightGroup, rightActiveInfo)
end
def.method("userdata", "table").ShowRoleInfo = function(self, roleGroup, roleActiveInfo)
  if nil == roleGroup then
    warn("[ERROR][RecallAwardActiveNode:ShowRoleInfo] roleGroup nil.")
    return
  end
  if nil == roleActiveInfo then
    warn("[ERROR][RecallAwardActiveNode:ShowRoleInfo] roleActiveInfo nil at idx:", idx)
    return
  end
  local Img_Head = roleGroup:FindDirect("Img_BgIconGroup/Texture_IconGroup")
  local headURL = RecallUtils.ProcessHeadImgURL(roleActiveInfo:GetFigureUrl())
  GUIUtils.FillTextureFromURL(Img_Head, headURL, function(tex2d)
    if self._headTextureList then
      table.insert(self._headTextureList, tex2d)
    end
  end)
  local Label_NickName = roleGroup:FindDirect("Label_FriendName")
  GUIUtils.SetText(Label_NickName, roleActiveInfo:GetNickName())
  local Img_Sex = roleGroup:FindDirect("Img_Sex")
  GUIUtils.SetSprite(Img_Sex, GUIUtils.GetGenderSprite(roleActiveInfo:GetGender()))
  local Img_School = roleGroup:FindDirect("Img_SchoolIcon")
  GUIUtils.SetSprite(Img_School, GUIUtils.GetOccupationSmallIcon(roleActiveInfo:GetOccpId()))
  local Label_Lv = roleGroup:FindDirect("Label_Lv")
  GUIUtils.SetText(Label_Lv, string.format(textRes.Common[3], roleActiveInfo:GetLevel()))
  local Label_RoleName = roleGroup:FindDirect("Label_CharactorName")
  GUIUtils.SetText(Label_RoleName, roleActiveInfo:GetRoleName())
  local Label_ServerName = roleGroup:FindDirect("Label_ServerName")
  local serverCfg = require("Main.Login.ServerListMgr").Instance():GetServerCfg(roleActiveInfo:GetZoneId())
  local serverName = serverCfg and serverCfg.name or ""
  GUIUtils.SetText(Label_ServerName, serverName)
  local Label_Activity = roleGroup:FindDirect("Label_Activity")
  local Slider_Unlock = roleGroup:FindDirect("Slider_Unlock")
  local awardActive = RecallUtils.GetConst("BIND_VITALITY")
  local curActive = math.min(roleActiveInfo:GetActive(), awardActive)
  GUIUtils.SetText(Label_Activity, string.format(textRes.Recall.BIND_ACTIVE, curActive, awardActive))
  GUIUtils.SetProgress(Slider_Unlock, GUIUtils.COTYPE.SLIDER, curActive / awardActive)
end
def.method().ClearFriendList = function(self)
  if self._headTextureList and #self._headTextureList > 0 then
    for _, headTexture in pairs(self._headTextureList) do
      if headTexture ~= nil then
        headTexture:Destroy()
      end
    end
    self._headTextureList = nil
  end
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.uiList) then
    self._uiObjs.uiList.itemCount = 0
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
  end
end
def.method().ShowBindCountdown = function(self)
  self:_ClearBindTimer()
  if RecallData.Instance():CanBindRecallFriend() then
    GUIUtils.SetActive(self._uiObjs.Label_Bind_Title, true)
    GUIUtils.SetActive(self._uiObjs.Label_Bind_Time, true)
    GUIUtils.SetActive(self._uiObjs.Btn_Bound, true)
    GUIUtils.SetLightEffect(self._uiObjs.Btn_Bound, GUIUtils.Light.Square)
    self._bindCountdown = RecallData.Instance():GetLeftBindTime()
    self:_ShowTime()
    self._bindTimerID = GameUtil.AddGlobalTimer(UPDATE_INTERVAL, false, function()
      self:_UpdateCountdown()
    end)
  else
    GUIUtils.SetLightEffect(self._uiObjs.Btn_Bound, GUIUtils.Light.None)
    GUIUtils.SetActive(self._uiObjs.Label_Bind_Title, false)
    GUIUtils.SetActive(self._uiObjs.Label_Bind_Time, false)
    GUIUtils.SetActive(self._uiObjs.Btn_Bound, false)
    self._bindCountdown = 0
  end
end
def.method()._ShowTime = function(self)
  local hour = math.floor(self._bindCountdown / 3600)
  local min = math.floor((self._bindCountdown - 3600 * hour) / 60)
  local sec = self._bindCountdown % 60
  local timeStr = string.format(textRes.Recall.BIND_COUNTDOWN_FORMAT, hour, min, sec)
  GUIUtils.SetText(self._uiObjs.Label_Bind_Time, timeStr)
end
def.method()._UpdateCountdown = function(self)
  self._bindCountdown = self._bindCountdown - 1
  if self._bindCountdown >= 0 then
    self:_ShowTime()
  else
    self:_ClearBindTimer()
    GUIUtils.SetLightEffect(self._uiObjs.Btn_Bound, GUIUtils.Light.None)
    GUIUtils.SetActive(self._uiObjs.Label_Bind_Title, false)
    GUIUtils.SetActive(self._uiObjs.Label_Bind_Time, false)
    GUIUtils.SetActive(self._uiObjs.Btn_Bound, false)
  end
end
def.method()._ClearBindTimer = function(self)
  if self._bindTimerID > 0 then
    GameUtil.RemoveGlobalTimer(self._bindTimerID)
    self._bindTimerID = 0
  end
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Infor" then
    self:OnBtn_Help(id)
  elseif id == "Btn_Bound" then
    self:OnBtn_Bound(id)
  elseif id == "Btn_Box" then
    self:OnBtn_Box(clickObj)
  end
end
def.method("string").OnBtn_Help = function(self, id)
end
def.method("string").OnBtn_Bound = function(self, id)
  require("Main.Recall.ui.BindPanel").ShowPanel()
end
def.method("userdata").OnBtn_Box = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  if parent then
    local togglePrefix = "item_"
    local id = parent.name
    local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
    local friendActiveInfo = self._bindedFriendList and self._bindedFriendList[index]
    if friendActiveInfo then
      if friendActiveInfo:CanFetchAward() then
        RecallProtocols.SendCGetBindRewardReq(friendActiveInfo:GetOpenId(), not friendActiveInfo:IsCaller())
      else
        local bindDay = friendActiveInfo:GetBindDay()
        local activeAwardCfg = RecallData.Instance():GetActiveAwardCfg(bindDay)
        if activeAwardCfg then
          local awardId = friendActiveInfo:IsCaller() and activeAwardCfg.backAward or activeAwardCfg.recallAward
          RecallUtils.ShowActiveAwardTip(awardId, clickObj)
        else
          Toast(string.format(textRes.Recall.BIND_DAY_AWARD_NIL, bindDay))
          warn("[ERROR][RecallAwardActiveNode:OnBtn_Box] activeAwardCfg nil at bindDay:", bindDay)
        end
      end
    else
      warn("[ERROR][RecallAwardActiveNode:OnBtn_Box] friendActiveInfo nil for index:", index)
    end
  else
    warn("[ERROR][RecallAwardActiveNode:OnBtn_Box] parent nil for clickObj:", clickObj and clickObj.name)
  end
end
def.method("boolean")._HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, RecallAwardActiveNode.OnActiveChange)
    eventFunc(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, RecallAwardActiveNode.OnBindChange)
  end
end
def.static("table", "table").OnActiveChange = function(params, context)
  warn("[RecallAwardActiveNode:OnActiveChange] Update FriendList.")
  local self = instance
  self:UpdateFriendList()
end
def.static("table", "table").OnBindChange = function(params, context)
  local self = instance
  if not RecallData.Instance():CanBindRecallFriend() then
    warn("[RecallAwardActiveNode:OnBindChange] hide bind btn.")
    GUIUtils.SetLightEffect(self._uiObjs.Btn_Bound, GUIUtils.Light.None)
    GUIUtils.SetActive(self._uiObjs.Label_Bind_Title, false)
    GUIUtils.SetActive(self._uiObjs.Label_Bind_Time, false)
    GUIUtils.SetActive(self._uiObjs.Btn_Bound, false)
  else
    warn("[RecallAwardActiveNode:OnBindChange] have unbinded friends.")
  end
end
return RecallAwardActiveNode.Commit()
