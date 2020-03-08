local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local GuideUtils = require("Main.Guide.GuideUtils")
local ECUIModel = require("Model.ECUIModel")
local Vector = require("Types.Vector")
local ChoosePet = Lplus.Extend(ECPanelBase, "ChoosePet")
local def = ChoosePet.define
local _instance
def.static("=>", ChoosePet).Instance = function()
  if _instance == nil then
    _instance = ChoosePet()
  end
  return _instance
end
def.field("number").petId1 = 0
def.field("number").petId2 = 0
def.field("number").selectPetId = 0
def.field("table").petModel1 = nil
def.field("table").petModel2 = nil
def.field("number").dragTarget = 0
def.field("function").callback = nil
def.static("number", "number", "function").ShowChoosePet = function(petId1, petId2, cb)
  require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
  local dlg = ChoosePet.Instance()
  dlg.petId1 = petId1
  dlg.petId2 = petId2
  dlg.callback = cb
  dlg:SetDepth(4)
  dlg:CreatePanel(RESPATH.PREFAB_CHOOSE_PET, 0)
  dlg:SetModal(true)
end
def.static().Close = function()
  local dlg = ChoosePet.Instance()
  dlg:DestroyPanel()
end
def.override().OnCreate = function(self)
  gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
  require("GUI.ECGUIMan").Instance():LockUI(false)
  self:UpdatePet()
end
def.method().UpdatePet = function(self)
  local PetUtils = require("Main.Pet.PetUtility").Instance()
  local pet1Cfg = PetUtils:GetPetCfg(self.petId1)
  local uiModel1 = self.m_panel:FindDirect("Texture_Bg1/Img_PetBg1/Model"):GetComponent("UIModel")
  if uiModel1.mCanOverflow ~= nil then
    uiModel1.mCanOverflow = true
    local camera = uiModel1:get_modelCamera()
    camera:set_orthographic(true)
  end
  local modelPath1 = GetModelPath(pet1Cfg.modelId)
  self.petModel1 = ECUIModel.new(pet1Cfg.modelId)
  self.petModel1:LoadUIModel(modelPath1, function(ret)
    self.petModel1:SetDir(180)
    self.petModel1:SetScale(1)
    self.petModel1:Play("Stand_c")
    uiModel1.modelGameObject = self.petModel1.m_model
    if pet1Cfg.colorId > 0 then
      local colorcfg = GetModelColorCfg(pet1Cfg.colorId)
      self.petModel1:SetColoration(colorcfg)
    else
      self.petModel1:SetColoration(nil)
    end
  end)
  local name1 = self.m_panel:FindDirect("Texture_Bg1/Img_PetBg1/Img_BgName/Label"):GetComponent("UILabel")
  name1:set_text(pet1Cfg.templateName)
  local pet2Cfg = PetUtils:GetPetCfg(self.petId2)
  local uiModel2 = self.m_panel:FindDirect("Texture_Bg1/Img_PetBg2/Model"):GetComponent("UIModel")
  if uiModel2.mCanOverflow ~= nil then
    uiModel2.mCanOverflow = true
    local camera = uiModel2:get_modelCamera()
    camera:set_orthographic(true)
  end
  local modelPath2 = GetModelPath(pet2Cfg.modelId)
  self.petModel2 = ECUIModel.new(pet2Cfg.modelId)
  self.petModel2:LoadUIModel(modelPath2, function(ret)
    self.petModel2:SetDir(180)
    self.petModel2:SetScale(1)
    self.petModel2:Play("Stand_c")
    uiModel2.modelGameObject = self.petModel2.m_model
    if pet2Cfg.colorId > 0 then
      local colorcfg = GetModelColorCfg(pet2Cfg.colorId)
      self.petModel2:SetColoration(colorcfg)
    else
      self.petModel2:SetColoration(nil)
    end
  end)
  local name2 = self.m_panel:FindDirect("Texture_Bg1/Img_PetBg2/Img_BgName/Label"):GetComponent("UILabel")
  name2:set_text(pet2Cfg.templateName)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    if self.selectPetId > 0 then
      self.callback(self.selectPetId)
    else
      Toast(textRes.Guide[2])
    end
  elseif id == "Img_PetBg1" then
    self.selectPetId = self.petId1
    self.petModel1:SetDir(180)
    self.petModel2:SetDir(180)
    self.petModel1:Play("Run_c")
    self.petModel2:Play("Stand_c")
  elseif id == "Img_PetBg2" then
    self.selectPetId = self.petId2
    self.petModel1:SetDir(180)
    self.petModel2:SetDir(180)
    self.petModel2:Play("Run_c")
    self.petModel1:Play("Stand_c")
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Img_PetBg1" then
    self.dragTarget = 1
  elseif id == "Img_PetBg2" then
    self.dragTarget = 2
  end
end
def.method("string").onDragEnd = function(self, id)
  self.dragTarget = 0
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.dragTarget == 1 then
    self.petModel1:SetDir(self.petModel1.m_ang - dx / 2)
  elseif self.dragTarget == 2 then
    self.petModel2:SetDir(self.petModel2.m_ang - dx / 2)
  end
end
ChoosePet.Commit()
return ChoosePet
