local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AircraftData = require("Main.Aircraft.data.AircraftData")
local AircraftUtils = require("Main.Aircraft.AircraftUtils")
local AircraftUIModel = require("Main.Aircraft.ui.AircraftUIModel")
local ECUIModel = require("Model.ECUIModel")
local AircraftGetPanel = Lplus.Extend(ECPanelBase, "AircraftGetPanel")
local def = AircraftGetPanel.define
local instance
def.static("=>", AircraftGetPanel).Instance = function()
  if instance == nil then
    instance = AircraftGetPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table")._aircraftCfg = nil
def.field(ECUIModel)._aircraftModel = nil
def.static("number").ShowPanel = function(aircraftId)
  if not AircraftGetPanel.Instance():_InitData(aircraftId) then
    if AircraftGetPanel.Instance():IsShow() then
      AircraftGetPanel.Instance():DestroyPanel()
    end
    return
  end
  if AircraftGetPanel.Instance():IsShow() then
    AircraftGetPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_AIRCRAFT_GET_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Middle = self.m_panel:FindDirect("Img_Bg0/Label_Middle")
  self._uiObjs.WingModel = self.m_panel:FindDirect("Img_Bg0/WingModel")
end
def.method("number", "=>", "boolean")._InitData = function(self, aircraftId)
  self._aircraftCfg = AircraftData.Instance():GetAircraftCfg(aircraftId)
  if self._aircraftCfg then
    return true
  else
    return false
  end
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:_DestroyModel()
  self:FillAircraftModel()
  self:ShowAircraftAttr()
end
def.method().FillAircraftModel = function(self)
  local colorId = AircraftData.Instance():GetAircraftColor(self._aircraftCfg.id)
  self._aircraftModel = AircraftUIModel.new(self._aircraftCfg.id, colorId, self._uiObjs.WingModel:GetComponent("UIModel"))
  self._aircraftModel:LoadWithCB(nil)
end
def.method().ShowAircraftAttr = function(self)
  local attrStr = AircraftUtils.GetAircraftAttrString(self._aircraftCfg)
  attrStr = textRes.Aircraft.AIRCRAFT_ATTR_TITLE .. "\n" .. attrStr
  GUIUtils.SetText(self._uiObjs.Label_Middle, attrStr)
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self:_DestroyModel()
  self._aircraftCfg = nil
  self._uiObjs = nil
end
def.method()._DestroyModel = function(self)
  if not _G.IsNil(self._aircraftModel) then
    self._aircraftModel:Destroy()
    self._aircraftModel = nil
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Confirm" then
    self:OnBtn_Close()
  end
end
def.method().OnBtn_Close = function(self)
  local aircraftId = self._aircraftCfg.id
  self:DestroyPanel()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if AircraftData.Instance():GetCurrentAircraftId() <= 0 and aircraftId > 0 then
      local AircraftProtocols = require("Main.Aircraft.AircraftProtocols")
      AircraftProtocols.SendCPutOnAircraft(aircraftId)
    end
    require("Main.Aircraft.AircraftInterface").OpenAircraftPanel(aircraftId)
  end)
end
AircraftGetPanel.Commit()
return AircraftGetPanel
