local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RoomNodeBase = import(".RoomNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local Bedroom = Lplus.Extend(RoomNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local BedroomMgr = require("Main.Homeland.Rooms.BedroomMgr")
local def = Bedroom.define
def.field("table").m_UIGOs = nil
local instance
def.static("=>", Bedroom).Instance = function(self)
  if instance == nil then
    instance = Bedroom()
  end
  return instance
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateRoomInfo()
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Bedroom_Info, Bedroom.OnSyncRoomInfo)
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Label_LevelNumber = self.m_node:FindDirect("Label_LevelNumber")
  self.m_UIGOs.Label_SingleNumber = self.m_node:FindDirect("Label_SingleNumber")
  self.m_UIGOs.Label_TotalNumber = self.m_node:FindDirect("Label_TotalNumber")
end
def.override().OnHide = function(self)
  self.m_UIGOs = nil
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Bedroom_Info, Bedroom.OnSyncRoomInfo)
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Img_IconBg" or id == "Img_Add" then
    self:OnAddPetBtnClick()
  elseif id == "Btn_Train" then
    self:OnRecoveryBtnClick()
  elseif id == "Btn_Upgrade" then
    self:OnUpgradeBtnClick()
  end
end
def.method().UpdateRoomInfo = function(self)
  local level = BedroomMgr.Instance():GetRoomLevel()
  local recoverEffect = BedroomMgr.Instance():GetRecoveryEffectPerTimes()
  local recoverEffectLimit = BedroomMgr.Instance():GetTodayRecoveryEffectLimit()
  local levelText = string.format(textRes.Common[3], level)
  GUIUtils.SetText(self.m_UIGOs.Label_LevelNumber, levelText)
  local text = string.format(textRes.Homeland[2], tostring(recoverEffectLimit.energy), tostring(recoverEffectLimit.nutrition))
  GUIUtils.SetText(self.m_UIGOs.Label_TotalNumber, text)
  local text = string.format(textRes.Homeland[3], recoverEffect.energy, recoverEffect.nutrition)
  GUIUtils.SetText(self.m_UIGOs.Label_SingleNumber, text)
end
def.method().OnRecoveryBtnClick = function(self)
  BedroomMgr.Instance():Recovery()
end
def.method().OnUpgradeBtnClick = function(self)
  BedroomMgr.Instance():UpgradeRoom()
end
def.static("table", "table").OnSyncRoomInfo = function()
  instance:UpdateRoomInfo()
end
return Bedroom.Commit()
