local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AircraftData = require("Main.Aircraft.data.AircraftData")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local AircraftAttrPanel = Lplus.Extend(ECPanelBase, "AircraftAttrPanel")
local def = AircraftAttrPanel.define
local instance
def.static("=>", AircraftAttrPanel).Instance = function()
  if instance == nil then
    instance = AircraftAttrPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.static().ShowPanel = function()
  if AircraftAttrPanel.Instance():IsShow() then
    AircraftAttrPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_AIRCRAFT_ATTR_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
  self:SetOutTouchDisappear()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.AttrMap = {}
  self._uiObjs.AttrMap[PropertyType.PHYATK] = self.m_panel:FindDirect("Img_Bg/Attribute_1/Label2")
  self._uiObjs.AttrMap[PropertyType.PHYDEF] = self.m_panel:FindDirect("Img_Bg/Attribute_2/Label2")
  self._uiObjs.AttrMap[PropertyType.MAGATK] = self.m_panel:FindDirect("Img_Bg/Attribute_3/Label2")
  self._uiObjs.AttrMap[PropertyType.MAGDEF] = self.m_panel:FindDirect("Img_Bg/Attribute_4/Label2")
  self._uiObjs.AttrMap[PropertyType.MAX_HP] = self.m_panel:FindDirect("Img_Bg/Attribute_5/Label2")
  self._uiObjs.AttrMap[PropertyType.SPEED] = self.m_panel:FindDirect("Img_Bg/Attribute_6/Label2")
  self._uiObjs.AttrMap[PropertyType.PHY_CRIT_LEVEL] = self.m_panel:FindDirect("Img_Bg/Attribute_7/Label2")
  self._uiObjs.AttrMap[PropertyType.PHY_CRT_DEF_LEVEL] = self.m_panel:FindDirect("Img_Bg/Attribute_8/Label2")
  self._uiObjs.AttrMap[PropertyType.MAG_CRT_LEVEL] = self.m_panel:FindDirect("Img_Bg/Attribute_9/Label2")
  self._uiObjs.AttrMap[PropertyType.MAG_CRT_DEF_LEVEL] = self.m_panel:FindDirect("Img_Bg/Attribute_10/Label2")
  self._uiObjs.AttrMap[PropertyType.SEAL_HIT] = self.m_panel:FindDirect("Img_Bg/Attribute_11/Label2")
  self._uiObjs.AttrMap[PropertyType.SEAL_RESIST] = self.m_panel:FindDirect("Img_Bg/Attribute_12/Label2")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.AttrMap) then
    local props = AircraftData.Instance():GetOwnAircraftProps()
    for propType, propLabel in pairs(self._uiObjs.AttrMap) do
      local propValue = props and props[propType]
      if not propValue or not propValue then
        propValue = 0
      end
      if propValue > 0 then
        GUIUtils.SetText(propLabel, "+" .. propValue)
      else
        GUIUtils.SetText(propLabel, 0)
      end
    end
  end
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._uiObjs = nil
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
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
  end
end
AircraftAttrPanel.Commit()
return AircraftAttrPanel
