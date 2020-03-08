local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RoomNodeBase = import(".RoomNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local Kitchen = Lplus.Extend(RoomNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local KitchenMgr = require("Main.Homeland.Rooms.KitchenMgr")
local def = Kitchen.define
def.field("table").m_UIGOs = nil
local instance
def.static("=>", Kitchen).Instance = function(self)
  if instance == nil then
    instance = Kitchen()
  end
  return instance
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateRoomInfo()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, Kitchen.OnEnergyChanged)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Kitchen_Info, Kitchen.OnSyncRoomInfo)
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Label_LevelNumber = self.m_node:FindDirect("Label_LevelNumber")
  self.m_UIGOs.Label_SingleNumber = self.m_node:FindDirect("Label_SingleNumber")
  self.m_UIGOs.Label_CurrentRate = self.m_node:FindDirect("Label_CurrentRate")
end
def.override().OnHide = function(self)
  self.m_UIGOs = nil
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, Kitchen.OnEnergyChanged)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Kitchen_Info, Kitchen.OnSyncRoomInfo)
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Img_IconBg" or id == "Img_Add" then
    self:OnAddPetBtnClick()
  elseif id == "Btn_Train" then
    self:OnCookingBtnClick()
  elseif id == "Btn_Upgrade" then
    self:OnUpgradeBtnClick()
  end
end
def.method().UpdateRoomInfo = function(self)
  local level = KitchenMgr.Instance():GetRoomLevel()
  local doubleRate = KitchenMgr.Instance():GetDoubleRate()
  local energyInfo = KitchenMgr.Instance():GetEnergyInfo()
  local levelText = string.format(textRes.Common[3], level)
  GUIUtils.SetText(self.m_UIGOs.Label_LevelNumber, levelText)
  local text = string.format(textRes.Homeland[4], doubleRate / 100)
  GUIUtils.SetText(self.m_UIGOs.Label_CurrentRate, text)
  local text = string.format(textRes.Homeland[5], energyInfo.cur, energyInfo.max)
  GUIUtils.SetText(self.m_UIGOs.Label_SingleNumber, text)
end
def.method().OnCookingBtnClick = function(self)
  KitchenMgr.Instance():OpenCookingPanel()
end
def.method().OnUpgradeBtnClick = function(self)
  KitchenMgr.Instance():UpgradeRoom()
end
def.static("table", "table").OnEnergyChanged = function()
  instance:UpdateRoomInfo()
end
def.static("table", "table").OnSyncRoomInfo = function()
  instance:UpdateRoomInfo()
end
return Kitchen.Commit()
