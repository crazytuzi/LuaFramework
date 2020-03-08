local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ActiveTip = Lplus.Extend(ECPanelBase, "ActiveTip")
local def = ActiveTip.define
local instance
def.field("table").m_uiGOs = nil
def.field("table").msgGroup = nil
def.field("number").m_elapseSeconds = 0
def.field("number").m_timeId = 0
def.field("table").m_content = nil
def.static("=>", ActiveTip).Instance = function()
  if instance == nil then
    instance = ActiveTip()
  end
  return instance
end
def.method("table").ShowPanel = function(self, content)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_elapseSeconds = textRes.activity.ActiveAlert.CountDownSeconds
  self.m_content = content
  self:CreatePanel(RESPATH.PREFAB_UI_ACTIVE_TIP, 0)
  self:SetDepth(GUIDEPTH.TOP)
  self:SetModal(true)
end
def.method().Init = function(self)
  local msgGroup = {}
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  for i = 1, 2 do
    local Group_Alert = Img_Bg0:FindDirect(string.format("Group_Alert_%d", i))
    local Label_Content = Group_Alert:FindDirect("Label"):GetComponent("UILabel")
    msgGroup[i] = {Label_Content = Label_Content}
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
  end
end
def.override().OnCreate = function(self)
  self:Init()
  self:ShowContent(self.m_content)
end
def.override().OnDestroy = function(self)
  self:StopTimer()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    self:DestroyPanel()
  end
end
def.method("number", "string", "string").setInfo = function(self, index, name, content)
  local Group_Alert = self.msgGroup[index]
  if Group_Alert then
    Group_Alert.Label_Content:set_text(content)
  end
end
def.method().UpdateBtn = function(self)
  local remainSeconds = math.max(self.m_elapseSeconds, 0)
  if remainSeconds == 0 then
    self.m_uiGOs.Btn_Confirm:GetComponent("UIButton").isEnabled = true
    local text = self.m_uiGOs.m_btnText
    GUIUtils.SetText(self.m_uiGOs.Label_Confirm, text)
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
  for i = 1, 2 do
    local info = content[i]
    if info then
      self:setInfo(i, info.name, info.content)
    else
      self:setInfo(i, "", "")
    end
  end
end
return ActiveTip.Commit()
