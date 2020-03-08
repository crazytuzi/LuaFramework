local Lplus = require("Lplus")
local CommonAssignPropSettingPanel = require("GUI.CommonAssignPropSettingPanel")
local PetAutoAssignPropSettingPanel = Lplus.Extend(CommonAssignPropSettingPanel, "PetAutoAssignPropSettingPanel")
local Base = CommonAssignPropSettingPanel
local PetMgr = require("Main.Pet.mgr.PetMgr").Instance()
local PetAssignPropMgr = require("Main.Pet.mgr.PetAssignPropMgr").Instance()
local PetData = Lplus.ForwardDeclare("PetData")
local GUIUtils = require("GUI.GUIUtils")
local PetUtility = require("Main.Pet.PetUtility")
local def = PetAutoAssignPropSettingPanel.define
def.field("userdata").petId = nil
local instance
def.static("=>", PetAutoAssignPropSettingPanel).Instance = function()
  if instance == nil then
    instance = PetAutoAssignPropSettingPanel()
  end
  return instance
end
def.method("userdata").ShowPanelEx = function(self, petId)
  self:SetActivePet(petId)
  self:ShowPanel()
end
def.method("userdata").SetActivePet = function(self, petId)
  self.petId = petId
end
def.override().OnCreate = function(self)
  local pet = PetMgr:GetPet(self.petId)
  self.scheme = pet.assignPropScheme
  Base.OnCreate(self)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SAVE_ASSIGN_PROP_PREFAB_SUCCESS, PetAutoAssignPropSettingPanel.OnSaveAssignPrefabSuccess)
end
def.override().OnDestroy = function(self)
  Base.OnDestroy(self)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SAVE_ASSIGN_PROP_PREFAB_SUCCESS, PetAutoAssignPropSettingPanel.OnSaveAssignPrefabSuccess)
  self.scheme:ResetAutoAssigning()
  self.scheme = nil
end
def.override("string").OnIncProp = function(self, propName)
  PetAssignPropMgr:IncBasePropPrefab(self.petId, propName)
  self:UpdateBaseProp()
end
def.override("string").OnDecProp = function(self, propName)
  PetAssignPropMgr:DecBasePropPrefab(self.petId, propName)
  self:UpdateBaseProp()
end
def.override().OnSettingClearButtonClicked = function(self)
  local pet = PetMgr:GetPet(self.petId)
  pet.assignPropScheme:ClearAutoAssigning()
  self:UpdateBaseProp()
end
def.override().OnSettingSaveButtonClicked = function(self)
  if not self.isEnableConfirm then
    Toast(textRes.Hero[44])
    return
  end
  PetAssignPropMgr:SaveAssignedPropPrefab(self.petId)
end
def.override().OnRecommendBtnClicked = function(self)
  local petId = self.petId
  local pet = PetMgr:GetPet(petId)
  local petCfg = pet:GetPetCfgData()
  local schemeId = petCfg.defaultAssignPointCfgId
  local defaultScheme = require("Main.Hero.HeroUtility").GetDefaultAssignPropScheme(schemeId)
  if defaultScheme == nil then
    return
  end
  local scheme = pet.assignPropScheme
  scheme:ClearAutoAssigning()
  for propName, value in pairs(defaultScheme) do
    PetAssignPropMgr:SetBasePropSetting(petId, propName, value)
  end
  self:UpdateBaseProp()
end
def.static("table", "table").OnSaveAssignPrefabSuccess = function(params, context)
  instance:DestroyPanel()
end
def.override("string", "number", "=>", "number").UpdateEnteredValue = function(self, propName, value)
  local actualValue = PetAssignPropMgr:SetBasePropSetting(self.petId, propName, value)
  self:UpdateBaseProp()
  return actualValue
end
return PetAutoAssignPropSettingPanel.Commit()
