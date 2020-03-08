local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RoomNodeBase = import(".RoomNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local ServantRoom = Lplus.Extend(RoomNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ServantRoomMgr = require("Main.Homeland.Rooms.ServantRoomMgr")
local def = ServantRoom.define
def.field("table").m_UIGOs = nil
local instance
def.static("=>", ServantRoom).Instance = function(self)
  if instance == nil then
    instance = ServantRoom()
  end
  return instance
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateRoomInfo()
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_ServantRoom_Info, ServantRoom.OnSyncRoomInfo)
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Label_LevelNumber = self.m_node:FindDirect("Label_LevelNumber")
  self.m_UIGOs.Label_SingleNumber = self.m_node:FindDirect("Label_SingleNumber")
  self.m_UIGOs.Label_CurrentNumber = self.m_node:FindDirect("Label_CurrentNumber")
end
def.override().OnHide = function(self)
  self.m_UIGOs = nil
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_ServantRoom_Info, ServantRoom.OnSyncRoomInfo)
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Img_IconBg" or id == "Img_Add" then
    self:OnAddPetBtnClick()
  elseif id == "Btn_Train" then
    self:OnServantInfoBtnClick()
  elseif id == "Btn_Upgrade" then
    self:OnUpgradeBtnClick()
  end
end
def.method().UpdateRoomInfo = function(self)
  local level = ServantRoomMgr.Instance():GetRoomLevel()
  local servantName = ServantRoomMgr.Instance():GetWorkingServantName()
  local levelText = string.format(textRes.Common[3], level)
  GUIUtils.SetText(self.m_UIGOs.Label_LevelNumber, levelText)
  local text = string.format(textRes.Homeland[6], servantName)
  GUIUtils.SetText(self.m_UIGOs.Label_CurrentNumber, text)
  local text = textRes.Homeland[56] or ""
  GUIUtils.SetText(self.m_UIGOs.Label_SingleNumber, text)
end
def.method().OnUpgradeBtnClick = function(self)
  ServantRoomMgr.Instance():UpgradeRoom()
end
def.method().OnServantInfoBtnClick = function(self)
  local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
  if not HomelandModule.Instance():CheckAuthority(HomelandModule.VisitType.Owner) then
    return
  end
  require("Main.Homeland.ui.ServantPreviewPanel").ShowPanel()
end
def.static("table", "table").OnSyncRoomInfo = function()
  instance:UpdateRoomInfo()
end
return ServantRoom.Commit()
