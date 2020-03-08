local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local ECUIModel = require("Model.ECUIModel")
local ECFxMan = require("Fx.ECFxMan")
local ECPartComponent = require("Model.ECPartComponent")
local ECWingComponent = require("Model.ECWingComponent")
local ECFollowComponent = require("Model.ECFollowComponent")
local PetUtility = require("Main.Pet.PetUtility")
local PetUIModel = Lplus.Extend(ECUIModel, "PetUIModel")
local def = PetUIModel.define
def.field("number").m_petCfgId = 0
def.field("userdata").m_component = nil
def.field("boolean").m_canExceedBound = false
def.final("number", "userdata", "=>", PetUIModel).new = function(id, uiModel)
  local obj = PetUIModel()
  obj:Init(id)
  obj.m_component = uiModel
  return obj
end
def.override("number", "=>", "boolean").Init = function(self, id)
  ECUIModel.Init(self, id)
  self.m_petCfgId = id
  return true
end
local doCallback = function(cb, ret)
  if cb then
    cb(ret)
  end
end
def.method("function").LoadDefault = function(self, cb)
  local petCfg = PetUtility.Instance():GetPetCfg(self.m_petCfgId)
  if petCfg.templateId == 0 then
    return
  end
  self:LoadByCfg(petCfg, cb)
end
def.method("table", "function").LoadByCfg = function(self, petCfg, cb)
  local modelId = petCfg.modelId
  self.mModelId = modelId
  local modelPath = _G.GetModelPath(modelId)
  self:LoadUIModel(modelPath, function(ret)
    if ret == nil then
      doCallback(cb, nil)
      return
    end
    if not self:IsComponentReady() then
      warn("UIModel comopnent isnil!!!")
      return
    end
    self.m_component.modelGameObject = self.m_model
    if petCfg.colorId > 0 then
      local colorcfg = GetModelColorCfg(petCfg.colorId)
      self:SetColoration(colorcfg)
    else
      self:SetColoration(nil)
    end
    doCallback(cb, ret)
  end)
end
def.method("boolean").SetCanExceedBound = function(self, canExceed)
  self.m_canExceedBound = canExceed
  self:UpdateUIModelMode()
end
def.method("=>", "boolean").IsComponentReady = function(self)
  if self.m_component == nil or self.m_component.isnil then
    return false
  end
  return true
end
def.method().UpdateUIModelMode = function(self)
  if not self:IsComponentReady() then
    return
  end
  self.m_component.mCanOverflow = self.m_canExceedBound
  if self.m_canExceedBound then
    local camera = self.m_component:get_modelCamera()
    if camera then
      camera:set_orthographic(true)
    else
      warn("UpdateUIModelMode modelcamera is nil", debug.traceback())
    end
  end
end
def.method("number").SetPetMark = function(self, petMarkCfgId)
  self:SetMagicMark(petMarkCfgId)
end
return PetUIModel.Commit()
