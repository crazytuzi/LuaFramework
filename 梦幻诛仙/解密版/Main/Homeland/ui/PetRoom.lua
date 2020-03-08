local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RoomNodeBase = import(".RoomNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local PetRoom = Lplus.Extend(RoomNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local PetRoomMgr = require("Main.Homeland.Rooms.PetRoomMgr")
local def = PetRoom.define
def.field("table").m_UIGOs = nil
def.field("table").m_selPet = nil
local instance
def.static("=>", PetRoom).Instance = function(self)
  if instance == nil then
    instance = PetRoom()
  end
  return instance
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateRoomInfo()
  self:SetPetInfo(nil)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_PetRoom_Info, PetRoom.OnSyncRoomInfo)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetRoom.OnSyncPetInfo)
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Label_LevelNumber = self.m_node:FindDirect("Label_LevelNumber")
  self.m_UIGOs.Label_Times = self.m_node:FindDirect("Label_Times")
  self.m_UIGOs.Group_ChoosePet = self.m_node:FindDirect("Group_ChoosePet")
  self.m_UIGOs.Label_Name = self.m_UIGOs.Group_ChoosePet:FindDirect("Label_Name")
  self.m_UIGOs.Label_Type = self.m_UIGOs.Group_ChoosePet:FindDirect("Label_Type")
  self.m_UIGOs.Label_Level = self.m_UIGOs.Group_ChoosePet:FindDirect("Label_Level")
  self.m_UIGOs.Img_IconBg = self.m_UIGOs.Group_ChoosePet:FindDirect("Img_IconBg")
  self.m_UIGOs.Img_Kuang = self.m_UIGOs.Img_IconBg:FindDirect("Img_Kuang")
  self.m_UIGOs.Img_Add = self.m_UIGOs.Img_IconBg:FindDirect("Img_Add")
  self.m_UIGOs.Img_HeadIcon = self.m_UIGOs.Img_IconBg:FindDirect("Img_HeadIcon")
end
def.override().OnHide = function(self)
  self.m_UIGOs = nil
  self.m_selPet = nil
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_PetRoom_Info, PetRoom.OnSyncRoomInfo)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetRoom.OnSyncPetInfo)
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Img_IconBg" or id == "Img_Add" then
    self:OnAddPetBtnClick()
  elseif id == "Btn_Train" then
    self:OnTrainPetBtnClick()
  elseif id == "Btn_Upgrade" then
    self:OnUpgradeBtnClick()
  end
end
def.method().UpdateRoomInfo = function(self)
  local level = PetRoomMgr.Instance():GetRoomLevel()
  local levelText = string.format(textRes.Common[3], level)
  GUIUtils.SetText(self.m_UIGOs.Label_LevelNumber, levelText)
  local remainTimes = PetRoomMgr.Instance():GetRemainTrainingTimes()
  local text = string.format(textRes.Homeland[1], tostring(remainTimes))
  GUIUtils.SetText(self.m_UIGOs.Label_Times, text)
end
def.method("table").SetSelectedPet = function(self, pet)
  self.m_selPet = pet
  self:SetPetInfo(pet)
end
def.method("table").SetPetInfo = function(self, pet)
  local hasPetInfo = pet ~= nil
  GUIUtils.SetActive(self.m_UIGOs.Label_Name, hasPetInfo)
  GUIUtils.SetActive(self.m_UIGOs.Label_Type, hasPetInfo)
  GUIUtils.SetActive(self.m_UIGOs.Label_Level, hasPetInfo)
  GUIUtils.SetActive(self.m_UIGOs.Img_HeadIcon, hasPetInfo)
  GUIUtils.SetActive(self.m_UIGOs.Img_Add, not hasPetInfo)
  if pet == nil then
    return
  end
  local petCfg = pet:GetPetCfgData()
  GUIUtils.SetText(self.m_UIGOs.Label_Name, pet.name)
  local levelText = string.format(textRes.Common[3], pet.level)
  GUIUtils.SetText(self.m_UIGOs.Label_Level, levelText)
  local petTypeText = textRes.Pet.Type[petCfg.type]
  GUIUtils.SetText(self.m_UIGOs.Label_Type, petTypeText)
  local iconId = pet:GetHeadIconId()
  GUIUtils.SetTexture(self.m_UIGOs.Img_HeadIcon, iconId)
end
def.method().UpdatePetInfo = function(self)
  self:SetPetInfo(self.m_selPet)
end
def.method().OnAddPetBtnClick = function(self)
  local petList = PetRoomMgr.Instance():GetPetList()
  require("Main.Pet.ui.PetSelectPanel").Instance():ShowPanel(petList, "", function(index, pet, userParams)
    if self.m_UIGOs == nil then
      return
    end
    self:SetSelectedPet(pet)
  end, nil)
end
def.method().OnTrainPetBtnClick = function(self)
  if self.m_selPet == nil then
    Toast(textRes.Homeland[7])
    return
  end
  PetRoomMgr.Instance():TrainPet(self.m_selPet.id)
end
def.method().OnUpgradeBtnClick = function(self)
  PetRoomMgr.Instance():UpgradeRoom()
end
def.static("table", "table").OnSyncRoomInfo = function()
  instance:UpdateRoomInfo()
end
def.static("table", "table").OnSyncPetInfo = function()
  instance:UpdatePetInfo()
end
return PetRoom.Commit()
