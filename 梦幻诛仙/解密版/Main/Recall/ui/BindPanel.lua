local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local RecallUtils = require("Main.Recall.RecallUtils")
local RecallData = require("Main.Recall.data.RecallData")
local RecallProtocols = require("Main.Recall.RecallProtocols")
local BindPanel = Lplus.Extend(ECPanelBase, "BindPanel")
local def = BindPanel.define
local instance
def.static("=>", BindPanel).Instance = function()
  if instance == nil then
    instance = BindPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table")._bindFriendList = nil
def.field("table")._headTextureList = nil
def.static().ShowPanel = function()
  if not require("Main.Recall.RecallModule").Instance():IsOpen(true) then
    if BindPanel.Instance():IsShow() then
      BindPanel.Instance():DestroyPanel()
    end
    return
  end
  if BindPanel.Instance():IsShow() then
    BindPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_RECALL_BIND_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Scroll_View = self.m_panel:FindDirect("Img_Bg0/Friends/Scroll View")
  self._uiObjs.uiScrollView = self._uiObjs.Scroll_View:GetComponent("UIScrollView")
  self._uiObjs.List_Friend = self._uiObjs.Scroll_View:FindDirect("List_Friend")
  self._uiObjs.uiList = self._uiObjs.List_Friend:GetComponent("UIList")
end
def.method()._InitData = function(self)
  self._bindFriendList = RecallData.Instance():GetUnbindedRecallHeroFriendList()
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:_InitData()
  self:ShowBindFriendList()
end
def.override().OnDestroy = function(self)
  self:_Reset()
  require("Main.Common.EnterWorldAlertMgr").Instance():Next()
end
def.method()._Reset = function(self)
  self:_ClearList()
  self._bindFriendList = nil
  self._uiObjs = nil
end
def.method("=>", "number").GetBindFriendCount = function(self)
  return self._bindFriendList and #self._bindFriendList or 0
end
def.method().ShowBindFriendList = function(self)
  self:_ClearList()
  local friendCount = self:GetBindFriendCount()
  self._headTextureList = {}
  if friendCount > 0 then
    self._uiObjs.uiList.itemCount = friendCount
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
    for idx, bindFriendInfo in ipairs(self._bindFriendList) do
      self:ShowFriendInfo(idx, bindFriendInfo)
    end
  else
  end
end
def.method("number", "table").ShowFriendInfo = function(self, idx, bindFriendInfo)
  local listItem = self._uiObjs.uiList.children[idx]
  if nil == listItem then
    warn("[ERROR][BindPanel:ShowFriendInfo] listItem nil at idx:", idx)
    return
  end
  if nil == bindFriendInfo then
    warn("[ERROR][BindPanel:ShowFriendInfo] bindFriendInfo nil at idx:", idx)
    return
  end
  local Img_Head = listItem:FindDirect("Img_BgIconGroup/Texture_IconGroup")
  local headURL = RecallUtils.ProcessHeadImgURL(bindFriendInfo:GetFigureUrl())
  GUIUtils.FillTextureFromURL(Img_Head, headURL, function(tex2d)
    if self._headTextureList then
      table.insert(self._headTextureList, tex2d)
    end
  end)
  local Label_Name = listItem:FindDirect("Label_FriendName")
  GUIUtils.SetText(Label_Name, bindFriendInfo:GetNickName())
  local Img_Sex = listItem:FindDirect("Img_Sex")
  GUIUtils.SetSprite(Img_Sex, GUIUtils.GetGenderSprite(bindFriendInfo:GetGender()))
  local Img_School = listItem:FindDirect("Img_SchoolIcon")
  GUIUtils.SetSprite(Img_School, GUIUtils.GetOccupationSmallIcon(bindFriendInfo:GetOccpId()))
  local Label_Lv = listItem:FindDirect("Label_Lv")
  GUIUtils.SetText(Label_Lv, string.format(textRes.Common[3], bindFriendInfo:GetLevel()))
  local Label_CallBackTime = listItem:FindDirect("Label_CallBackTime")
  GUIUtils.SetText(Label_CallBackTime, string.format(textRes.Recall.BIND_FRIEND_RECALL_COUNT, bindFriendInfo:GetRecallCount()))
  local Label_RoleName = listItem:FindDirect("Label_CharactorName")
  GUIUtils.SetText(Label_RoleName, bindFriendInfo:GetRoleName())
  local Label_ServerName = listItem:FindDirect("Label_ServerName")
  local serverCfg = require("Main.Login.ServerListMgr").Instance():GetServerCfg(bindFriendInfo:GetZoneId())
  local serverName = serverCfg and serverCfg.name or ""
  GUIUtils.SetText(Label_ServerName, serverName)
  local Label_LastDay = listItem:FindDirect("Label_LastDay")
  local loginDayInterval = RecallUtils.GetPastDayBy24(bindFriendInfo:GetLastLoginTime())
  local lastLoginStr = textRes.Recall.BIND_FRIEND_LAST_LOGIN
  if loginDayInterval > 0 then
    lastLoginStr = string.format(lastLoginStr, string.format(textRes.Recall.BIND_FRIEND_LAST_LOGIN_DAY, loginDayInterval))
  else
    lastLoginStr = string.format(lastLoginStr, textRes.Recall.BIND_FRIEND_LAST_LOGIN_TODAY)
  end
  GUIUtils.SetText(Label_LastDay, lastLoginStr)
end
def.method()._ClearList = function(self)
  if self._headTextureList and #self._headTextureList > 0 then
    for _, headTexture in pairs(self._headTextureList) do
      if headTexture ~= nil then
        headTexture:Destroy()
      end
    end
    self._headTextureList = nil
  end
  self._uiObjs.uiList.itemCount = 0
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close(clickObj)
  elseif id == "Btn_Invite" then
    self:OnBtn_Invite(clickObj)
  end
end
def.method("userdata").OnBtn_Close = function(self, clickObj)
  if RecallData.Instance():CanBindRecallFriend() then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Recall.BIND_FRIEND_CONFIRM_TITLE, textRes.Recall.BIND_FRIEND_CONFIRM_CONTENT, function(id, tag)
      if id == 1 then
        self:DestroyPanel()
      end
    end, nil)
  else
    self:DestroyPanel()
  end
end
def.method("userdata").OnBtn_Invite = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  if parent then
    local id = parent.name
    local togglePrefix = "item_"
    local idx = tonumber(string.sub(id, string.len(togglePrefix) + 1))
    local bindFriendInfo = self._bindFriendList and self._bindFriendList[idx]
    if bindFriendInfo then
      RecallProtocols.SendCBindFriendReq(bindFriendInfo:GetOpenId())
    else
      warn("[ERROR][BindPanel:OnBtn_Invite] bindFriendInfo nil at idx:", idx)
    end
  end
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, BindPanel.OnRecallHeroInfoChange)
  end
end
def.static("table", "table").OnRecallHeroInfoChange = function(param, context)
  local self = BindPanel.Instance()
  if self:IsShow() then
    self:UpdateUI()
  end
end
BindPanel.Commit()
return BindPanel
