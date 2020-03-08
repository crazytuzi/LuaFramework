local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIZhuXianJianZhen = Lplus.Extend(ECPanelBase, "UIZhuXianJianZhen")
local GUIUtils = require("GUI.GUIUtils")
local def = UIZhuXianJianZhen.define
local instance
def.field("table")._uiGOs = nil
def.field("number")._timerCountdown = 0
def.field("number")._iTimeCount = 0
def.field("number")._iDuration = 0
def.field("string")._strTitle = ""
def.field("string")._strContent = ""
def.field("table")._timeoutCallback = nil
def.static("=>", UIZhuXianJianZhen).Instance = function()
  if instance == nil then
    instance = UIZhuXianJianZhen()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiGOs = self._uiGOs or {}
  self:InitUI()
  self:UpdateTitle()
  self:UpdateContent()
end
def.override("boolean").OnShow = function(self, s)
  if s and self._iDuration <= 0 then
    self:HidePanel()
  end
end
def.method().InitUI = function(self)
  local lblContent = self.m_panel:FindDirect("Img _Bg0/Group_Note/Scrollview_Note/Drag_Tips")
  local btnConfirm = self.m_panel:FindDirect("Img _Bg0/Btn_ConFirm")
  local lblConfirm = btnConfirm:FindDirect("Label_ConFirm")
  local lblTitle = self.m_panel:FindDirect("Img _Bg0/Img_BgTitle1/Label")
  self._uiGOs.lblTitle = lblTitle
  self._uiGOs.lblContent = lblContent
  self._uiGOs.btnConfirm = btnConfirm
  self._iTimeCount = 0
  GUIUtils.SetText(lblConfirm, textRes.Soaring.ZhuXianJianZhen[7]:format(self._iDuration - self._iTimeCount))
  self._timerCountdown = GameUtil.AddGlobalTimer(1, false, function()
    self._iTimeCount = self._iTimeCount + 1
    if self._iTimeCount > self._iDuration and self._timerCountdown ~= 0 then
      GameUtil.RemoveGlobalTimer(self._timerCountdown)
      self._timerCountdown = 0
      if self._timeoutCallback ~= nil then
        self._timeoutCallback:ShowPanel()
      end
      self:HidePanel()
    end
    GUIUtils.SetText(lblConfirm, textRes.Soaring.ZhuXianJianZhen[7]:format(self._iDuration - self._iTimeCount))
  end)
end
def.override().OnDestroy = function(self)
  if self._uiGOs ~= nil then
    self._uiGOs = nil
  end
  if self._timerCountdown ~= nil and self._timerCountdown ~= 0 then
    GameUtil.RemoveGlobalTimer(self._timerCountdown)
    self._timerCountdown = 0
  end
  self._iTimeCount = 0
  self._strTitle = ""
  self._strContent = ""
  self._timeoutCallback = nil
  self._iDuration = 0
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_UI_ZHUXIANJIANZHEN, 0)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.method().UpdateUI = function(self)
  self:UpdateTitle()
  self:UpdateContent()
end
def.method().UpdateTitle = function(self)
  local lblTitle = self._uiGOs.lblTitle
  self._strTitle = self._strTitle or ""
  GUIUtils.SetText(lblTitle, self._strTitle)
end
def.method().UpdateContent = function(self)
  local lblContent = self._uiGOs.lblContent
  self._strContent = self._strContent or ""
  GUIUtils.SetText(lblContent, self._strContent)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
  elseif id == "Btn_ConFirm" then
  end
end
def.method("number").SetDuration = function(self, iTime)
  self._iDuration = iTime
end
def.method("string").SetTitle = function(self, str)
  self._strTitle = str
end
def.method("string").SetContent = function(self, str)
  self._strContent = str
end
def.method("table").SetTimeoutCallback = function(self, func)
  self._timeoutCallback = func
end
return UIZhuXianJianZhen.Commit()
