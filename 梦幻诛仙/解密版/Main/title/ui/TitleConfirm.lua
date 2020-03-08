local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local TitleConfirm = Lplus.Extend(ECPanelBase, "TitleConfirm")
local def = TitleConfirm.define
local _instance
local TitleInterface = require("Main.title.TitleInterface")
local titleInterface = TitleInterface.Instance()
def.static("=>", TitleConfirm).Instance = function()
  if _instance == nil then
    _instance = TitleConfirm()
    _instance:Init()
  end
  return _instance
end
def.field("table")._currAppellationCfg = nil
def.field("table")._targetAppellationCfg = nil
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method("number", "number").ShowDlg = function(self, currAppellation, targetAppellation)
  self._currAppellationCfg = TitleInterface.GetAppellationCfg(currAppellation)
  self._targetAppellationCfg = TitleInterface.GetAppellationCfg(targetAppellation)
  if self.m_panel == nil or self.m_panel.isnil then
    print("TitleConfirm.CreatePanel()")
    self:CreatePanel(RESPATH.PREFAB_UI_TITLE_CONFIRM, 2)
    self:SetOutTouchDisappear()
  end
  if self:IsShow() then
    self:_Fill()
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
  self._currAppellationCfg = nil
  self._targetAppellationCfg = nil
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:_Fill()
  else
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Yes" then
    local CChangePropertyReq = require("netio.protocol.mzm.gsp.title.CChangePropertyReq").new(self._targetAppellationCfg.id)
    gmodule.network.sendProtocol(CChangePropertyReq)
  end
  self:HideDlg()
end
def.method()._Fill = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Label2 = Img_Bg:FindDirect("Group_Info1/Label2")
  local strProperty = ""
  for k, v in pairs(self._currAppellationCfg.properties) do
    local PropNameCfg = GetCommonPropNameCfg(v.propertyID)
    if strProperty ~= "" then
      strProperty = strProperty .. "\n"
    end
    strProperty = strProperty .. string.format("%s +%d", PropNameCfg.propName, v.value)
  end
  if strProperty == "" then
    strProperty = textRes.Title[4]
  end
  Label2:GetComponent("UILabel"):set_text(strProperty)
  local Label2 = Img_Bg:FindDirect("Group_Info2/Label2")
  local strProperty = ""
  for k, v in pairs(self._targetAppellationCfg.properties) do
    local PropNameCfg = GetCommonPropNameCfg(v.propertyID)
    if strProperty ~= "" then
      strProperty = strProperty .. "\n"
    end
    strProperty = strProperty .. string.format("%s +%d", PropNameCfg.propName, v.value)
  end
  if strProperty == "" then
    strProperty = textRes.Title[4]
  end
  Label2:GetComponent("UILabel"):set_text(strProperty)
end
TitleConfirm.Commit()
return TitleConfirm
