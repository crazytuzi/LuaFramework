local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RoomNodeBase = import(".RoomNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local MakeDrugRoom = Lplus.Extend(RoomNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local MakeDrugRoomMgr = require("Main.Homeland.Rooms.MakeDrugRoomMgr")
local def = MakeDrugRoom.define
def.field("table").m_UIGOs = nil
local instance
def.static("=>", MakeDrugRoom).Instance = function(self)
  if instance == nil then
    instance = MakeDrugRoom()
  end
  return instance
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateRoomInfo()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, MakeDrugRoom.OnEnergyChanged)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_MakeDrugRoom_Info, MakeDrugRoom.OnSyncRoomInfo)
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Label_LevelNumber = self.m_node:FindDirect("Label_LevelNumber")
  self.m_UIGOs.Label_SingleNumber = self.m_node:FindDirect("Label_SingleNumber")
  self.m_UIGOs.Label_CurrentRate = self.m_node:FindDirect("Label_CurrentRate")
end
def.override().OnHide = function(self)
  self.m_UIGOs = nil
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, MakeDrugRoom.OnEnergyChanged)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_MakeDrugRoom_Info, MakeDrugRoom.OnSyncRoomInfo)
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Img_IconBg" or id == "Img_Add" then
    self:OnAddPetBtnClick()
  elseif id == "Btn_Train" then
    self:OnMakeDrugBtnClick()
  elseif id == "Btn_Upgrade" then
    self:OnUpgradeBtnClick()
  end
end
def.method().UpdateRoomInfo = function(self)
  local level = MakeDrugRoomMgr.Instance():GetRoomLevel()
  local doubleRate = MakeDrugRoomMgr.Instance():GetDoubleRate()
  local energyInfo = MakeDrugRoomMgr.Instance():GetEnergyInfo()
  local levelText = string.format(textRes.Common[3], level)
  GUIUtils.SetText(self.m_UIGOs.Label_LevelNumber, levelText)
  local text = string.format(textRes.Homeland[4], doubleRate / 100)
  GUIUtils.SetText(self.m_UIGOs.Label_CurrentRate, text)
  local text = string.format(textRes.Homeland[5], energyInfo.cur, energyInfo.max)
  GUIUtils.SetText(self.m_UIGOs.Label_SingleNumber, text)
end
def.method().OnMakeDrugBtnClick = function(self)
  MakeDrugRoomMgr.Instance():OpenMakeDrugPanel()
end
def.method().OnUpgradeBtnClick = function(self)
  MakeDrugRoomMgr.Instance():UpgradeRoom()
end
def.static("table", "table").OnEnergyChanged = function()
  instance:UpdateRoomInfo()
end
def.static("table", "table").OnSyncRoomInfo = function()
  instance:UpdateRoomInfo()
end
return MakeDrugRoom.Commit()
