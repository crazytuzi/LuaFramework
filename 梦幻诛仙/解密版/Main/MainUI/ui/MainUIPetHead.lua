local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local MainUIPetHead = Lplus.Extend(ComponentBase, "MainUIPetHead")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local GUIUtils = require("GUI.GUIUtils")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local def = MainUIPetHead.define
def.field("table").uiObjs = nil
local instance
def.static("=>", MainUIPetHead).Instance = function()
  if instance == nil then
    instance = MainUIPetHead()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
end
def.override("=>", "boolean").CanShowInFight = function(self)
  return true
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_CHANGE_TO_FIGHTING, MainUIPetHead.OnFightingPetChange)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_CHANGE_TO_RESET, MainUIPetHead.OnFightingPetChange)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LIST_UPDATE, MainUIPetHead.OnFightingPetChange)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, MainUIPetHead.OnSyncPetInfo)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, MainUIPetHead.OnSyncFightProp)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.PET_REMOVED, MainUIPetHead.OnPetOrChildRemoved)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_NOTIFY_COUNT_UPDATE, MainUIPetHead.OnPetNotifyCountUpdate)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_IN_FIGHT_SCENE_CHANGED, MainUIPetHead.OnInFightScenePetChange)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.In_Fight_Scene_Child_Change, MainUIPetHead.OnInFightSceneChildChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_CHANGE_TO_FIGHTING, MainUIPetHead.OnFightingPetChange)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_CHANGE_TO_RESET, MainUIPetHead.OnFightingPetChange)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LIST_UPDATE, MainUIPetHead.OnFightingPetChange)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, MainUIPetHead.OnSyncPetInfo)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_PROP_CHANGED, MainUIPetHead.OnSyncFightProp)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.PET_REMOVED, MainUIPetHead.OnPetOrChildRemoved)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_NOTIFY_COUNT_UPDATE, MainUIPetHead.OnPetNotifyCountUpdate)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_IN_FIGHT_SCENE_CHANGED, MainUIPetHead.OnInFightScenePetChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.In_Fight_Scene_Child_Change, MainUIPetHead.OnInFightSceneChildChange)
  self:Clear()
end
def.override().OnShow = function(self)
  self:UpdateUI()
end
def.override().OnHide = function(self)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_IconPet = self.m_node:FindDirect("Img_BgPetHead/Img_IconPet")
  self.uiObjs.Label_LvPet = self.m_node:FindDirect("Label_LvPet")
  self.uiObjs.Slider_BloodPet = self.m_node:FindDirect("Slider_BloodPet")
  self.uiObjs.uiLabel_BloodPet = self.uiObjs.Slider_BloodPet:FindDirect("Label_BloodPet"):GetComponent("UILabel")
  self.uiObjs.Slider_BluePet = self.m_node:FindDirect("Slider_BluePet")
  self.uiObjs.uiLabel_BluePet = self.uiObjs.Slider_BluePet:FindDirect("Label_BluePet"):GetComponent("UILabel")
  self.uiObjs.Slider_ExpPet = self.m_node:FindDirect("Slider_ExpPet")
  self.uiObjs.Img_Red = self.m_node.transform.parent.gameObject:FindDirect("Img_Red")
end
def.method().Clear = function(self)
  self.uiObjs = nil
end
def.override().OnEnterFight = function(self)
end
def.override().OnLeaveFight = function(self)
  self:UpdateUI()
end
def.method().UpdateUI = function(self)
  local count = gmodule.moduleMgr:GetModule(ModuleId.PET):GetNotifyCount()
  self:SetPetNotifyBadge(count)
  local pet = require("Main.Pet.Interface").GetFightingPet()
  if pet == nil then
    self:DisplayPetInfo(false)
    return
  end
  self:DisplayPetInfo(true)
  self:SetPermanentProp()
  local isAutoProgress = false
  self:UpdateVolatileProp(isAutoProgress)
end
def.method().SetPermanentProp = function(self)
  local pet = require("Main.Pet.Interface").GetFightingPet()
  if pet == nil then
    return
  end
  local petCfgData = pet:GetPetCfgData()
  local modelCfg = require("Main.Pubrole.PubroleInterface").GetModelCfg(petCfgData.modelId)
  self:SetPetHeadImage(modelCfg.headerIconId)
end
def.method("boolean").UpdateVolatileProp = function(self, isAutoProgress)
  local pet = require("Main.Pet.Interface").GetFightingPet()
  if pet == nil then
    return
  end
  self:SetPetLevel(pet.level)
  self:SetPetHPBar(pet.hp, pet.secondProp.maxHp, isAutoProgress)
  self:SetPetMPBar(pet.mp, pet.secondProp.maxMp, isAutoProgress)
  local neededExp = pet:GetLevelUpNeededExp()
  self:SetPetExpBar(pet.exp, neededExp)
end
def.static("table", "table").OnFightingPetChange = function(param1, param2)
  if instance.m_panel == nil then
    return
  end
  gmodule.moduleMgr:GetModule(ModuleId.PET):CheckNotify()
  instance:UpdateUI()
end
def.static("table", "table").OnSyncFightingPetInfo = function(param1, param2)
  if instance.m_panel == nil then
    return
  end
  local isAutoProgress = true
  instance:UpdateVolatileProp(isAutoProgress)
end
def.static("table", "table").OnSyncPetInfo = function(params)
  if instance.m_panel == nil then
    return
  end
  if instance:IsInFight() then
    return
  end
  local petId = params[1]
  local fightingPet = require("Main.Pet.Interface").GetFightingPet()
  if fightingPet and fightingPet.id == petId then
    local isAutoProgress = true
    instance:UpdateVolatileProp(isAutoProgress)
  end
end
def.static("table", "table").OnSyncFightProp = function(params)
  local self = instance
  if params.type == GameUnitType.PET or params.type == GameUnitType.CHILDREN then
    self:SetFightProp(params)
  end
end
def.method("table").SetFightProp = function(self, data)
  local unitType = data.type
  if unitType == GameUnitType.PET then
    local pet = require("Main.Pet.Interface").GetInFightScenePet()
    if pet == nil then
      return
    end
    local maxHp = data.hpmax or pet.secondProp.maxHp
    self:SetPetHPBar(data.hp, maxHp, true)
    self:SetPetMPBar(data.mp, pet.secondProp.maxMp, true)
  elseif unitType == GameUnitType.CHILDREN then
    local child = require("Main.Children.ChildrenInterface").GetInFightSceneChild()
    if child == nil then
      return
    end
    self:SetPetHPBar(data.hp, child.info.propMap[PropertyType.MAX_HP] or 1, true)
    self:SetPetMPBar(data.mp, child.info.propMap[PropertyType.MAX_MP] or 1, true)
  end
end
def.method("boolean").DisplayPetInfo = function(self, opt)
  self.m_node:FindDirect("Img_BgPetHead"):SetActive(true)
  self.m_node:FindDirect("Img_BgPetHead/Img_Empty"):SetActive(not opt)
  self.m_node:FindDirect("Label_LvPet"):SetActive(opt)
  self.m_node:FindDirect("Slider_BloodPet"):SetActive(opt)
  self.m_node:FindDirect("Slider_BluePet"):SetActive(opt)
  self.m_node:FindDirect("Slider_ExpPet"):SetActive(opt)
  if opt == false then
    local uiTexture = self.uiObjs.Img_IconPet:GetComponent("UITexture")
    uiTexture.mainTexture = nil
  end
end
def.method("number").SetPetHeadImage = function(self, petIconId)
  local uiTexture = self.uiObjs.Img_IconPet:GetComponent("UITexture")
  require("GUI.GUIUtils").FillIcon(uiTexture, petIconId)
  GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
end
def.method("number").SetPetLevel = function(self, level)
  local label_level = self.uiObjs.Label_LvPet:GetComponent("UILabel")
  label_level:set_text(level)
end
def.method("number", "number", "boolean").SetPetHPBar = function(self, hp, maxHp, isAutoProgress)
  local slider_hp = self.uiObjs.Slider_BloodPet:GetComponent("UISlider")
  self:SetSliderBar(slider_hp, hp / maxHp, isAutoProgress)
  if self:IsInFight() then
    self.uiObjs.uiLabel_BloodPet:set_text(string.format("%d/%d", hp, maxHp))
  else
    self.uiObjs.uiLabel_BloodPet:set_text("")
  end
end
def.method("number", "number", "boolean").SetPetMPBar = function(self, mp, maxMp, isAutoProgress)
  local slider_mp = self.uiObjs.Slider_BluePet:GetComponent("UISlider")
  self:SetSliderBar(slider_mp, mp / maxMp, isAutoProgress)
  if self:IsInFight() then
    self.uiObjs.uiLabel_BluePet:set_text(string.format("%d/%d", mp, maxMp))
  else
    self.uiObjs.uiLabel_BluePet:set_text("")
  end
end
def.method("number", "number").SetPetExpBar = function(self, exp, maxExp)
  local slider_Exp = self.uiObjs.Slider_ExpPet:GetComponent("UISlider")
  slider_Exp:set_sliderValue(exp / maxExp)
end
def.static("table", "table").OnPetOrChildRemoved = function(params)
  local unitId = params.unit_id
  local unitType = params.unit_type
  local self = instance
  if self.m_node == nil then
    return
  end
  if unitType == GameUnitType.PET then
    local fightingPet = require("Main.Pet.Interface").GetInFightScenePet()
    if fightingPet == nil then
      return
    end
    if unitId ~= fightingPet.id then
      return
    end
  elseif unitType == GameUnitType.CHILDREN then
    local child = require("Main.Children.ChildrenInterface").GetInFightSceneChild()
    if child == nil then
      return
    end
    if unitId ~= child:GetId() then
      return
    end
  else
    return
  end
  self:MakePetHeadGray()
end
def.static("table", "table").OnPetNotifyCountUpdate = function(params)
  local notifyCount = params[1]
  instance:SetPetNotifyBadge(notifyCount)
end
def.method().MakePetHeadGray = function(self)
  local uiTexture = self.uiObjs.Img_IconPet:GetComponent("UITexture")
  GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
end
def.method().MakePetHeadNormal = function(self)
  local uiTexture = self.uiObjs.Img_IconPet:GetComponent("UITexture")
  GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
end
def.method("number").SetPetNotifyBadge = function(self, count)
  local isShow = count > 0
  GUIUtils.SetActive(self.uiObjs.Img_Red, isShow)
end
def.static("table", "table").OnInFightScenePetChange = function(params)
  instance:SetInFightScenePetInfo()
end
def.method().SetInFightScenePetInfo = function(self)
  local pet = require("Main.Pet.Interface").GetInFightScenePet()
  if pet == nil then
    self:DisplayPetInfo(false)
    return
  end
  self:DisplayPetInfo(true)
  self:SetPetLevel(pet.level)
  local petCfgData = pet:GetPetCfgData()
  local modelCfg = require("Main.Pubrole.PubroleInterface").GetModelCfg(petCfgData.modelId)
  self:SetPetHeadImage(modelCfg.headerIconId)
end
def.static("table", "table").OnInFightSceneChildChange = function(params)
  instance:SetInFightSceneChildInfo()
end
def.method().SetInFightSceneChildInfo = function(self)
  local child = require("Main.Children.ChildrenInterface").GetInFightSceneChild()
  if child == nil then
    self:DisplayPetInfo(false)
    return
  end
  self:DisplayPetInfo(true)
  self:SetPetLevel(child.info.level or 0)
  local headIcon = require("Main.Children.ChildrenUtils").GetChildHeadIcon(child:GetCurModelId())
  self:SetPetHeadImage(headIcon)
end
MainUIPetHead.Commit()
return MainUIPetHead
