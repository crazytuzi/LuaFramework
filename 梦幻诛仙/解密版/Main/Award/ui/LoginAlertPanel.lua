local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local LoginAlertPanel = Lplus.Extend(ECPanelBase, "LoginAlertPanel")
local def = LoginAlertPanel.define
local instance
def.field("table").m_uiGOs = nil
def.field("table").msgGroup = nil
def.field("number").m_elapseSeconds = 0
def.field("number").m_timeId = 0
def.field("table").m_content = nil
def.static("=>", LoginAlertPanel).Instance = function()
  if instance == nil then
    instance = LoginAlertPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, content)
  if self:IsShow() then
    self:DestroyPanel()
  end
  if _G.IsCrossingServer() then
    return
  end
  self.m_elapseSeconds = textRes.LoginAlert.CountDownSeconds
  self.m_content = content
  self:CreatePanel(RESPATH.PREFAB_LOGIN_ALERT_PANEL, 0)
  self:SetDepth(GUIDEPTH.TOP)
  self:SetModal(true)
end
def.method().Init = function(self)
  local msgGroup = {}
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  for i = 1, 4 do
    local Group_Alert = Img_Bg0:FindDirect(string.format("Group_Alert_%d", i))
    local Img_Sprite = Group_Alert:FindDirect("Sprite")
    local Img_Icon = Img_Sprite:FindDirect(string.format("Img_Icon_%d", i))
    local Label_Content = Group_Alert:FindDirect("Label_Content"):GetComponent("UILabel")
    msgGroup[i] = {
      Img_Icon = Img_Sprite,
      Img_Ornament = Img_Icon,
      Label_Content = Label_Content
    }
  end
  self.msgGroup = msgGroup
  self.m_uiGOs = {}
  self.m_uiGOs.Btn_Confirm = Img_Bg0:FindDirect("Btn_Confirm")
  self.m_uiGOs.Label_Confirm = self.m_uiGOs.Btn_Confirm:FindDirect("Label")
  self.m_uiGOs.m_btnText = GUIUtils.GetUILabelTxt(self.m_uiGOs.Label_Confirm)
  if self.m_elapseSeconds > 0 then
    self.m_uiGOs.Btn_Confirm:GetComponent("UIButton").isEnabled = false
    self:UpdateBtn()
    self.m_timeId = GameUtil.AddGlobalTimer(1, false, function()
      self.m_elapseSeconds = self.m_elapseSeconds - 1
      self:UpdateBtn()
      if self.m_elapseSeconds <= 0 then
        self:StopTimer()
      end
    end)
  else
    require("Main.Award.mgr.LoginAlertMgr").Instance():MarkTodayAsShowed()
  end
end
def.override().OnCreate = function(self)
  self:Init()
  self:ShowContent(self.m_content)
end
def.override().OnDestroy = function(self)
  self:StopTimer()
  require("Main.Common.EnterWorldAlertMgr").Instance():Next()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    self:DestroyPanel()
  end
end
def.method("number", "number", "number", "string").setInfo = function(self, index, iconId, ornamentId, content)
  local Group_Alert = self.msgGroup[index]
  if Group_Alert then
    Group_Alert.Label_Content:set_text(content)
    GUIUtils.SetActive(Group_Alert.Img_Icon, iconId > 0)
    GUIUtils.SetActive(Group_Alert.Img_Ornament, ornamentId > 0)
    if ornamentId > 0 then
      GUIUtils.FillIcon(Group_Alert.Img_Ornament:GetComponent("UITexture"), ornamentId)
    end
  end
end
def.method().UpdateBtn = function(self)
  local remainSeconds = math.max(self.m_elapseSeconds, 0)
  if remainSeconds == 0 then
    self.m_uiGOs.Btn_Confirm:GetComponent("UIButton").isEnabled = true
    local text = self.m_uiGOs.m_btnText
    GUIUtils.SetText(self.m_uiGOs.Label_Confirm, text)
    require("Main.Award.mgr.LoginAlertMgr").Instance():MarkTodayAsShowed()
  else
    local remainSecondsText = string.format(textRes.LoginAlert.CountDownText, remainSeconds)
    local text = string.format("%s%s", self.m_uiGOs.m_btnText, remainSecondsText)
    GUIUtils.SetText(self.m_uiGOs.Label_Confirm, text)
  end
end
def.method().StopTimer = function(self)
  if self.m_timeId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_timeId)
    self.m_timeId = 0
  end
end
def.method("table").ShowContent = function(self, content)
  local content = content or {}
  for i = 1, 4 do
    local info = content[i]
    if info then
      self:setInfo(i, info.iconId or -1, info.ornamentId or -1, info.content or "")
    else
      self:setInfo(i, -1, -1, "")
    end
  end
end
return LoginAlertPanel.Commit()
