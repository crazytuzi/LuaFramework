local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local ECUIModel = require("Model.ECUIModel")
local RobotPetUIModel = Lplus.Extend(ECUIModel, "RobotPetUIModel")
local def = RobotPetUIModel.define
def.field("number")._monsterCfgId = 0
def.field("userdata")._component = nil
def.field("boolean")._canExceedBound = false
def.final("number", "userdata", "=>", RobotPetUIModel).new = function(id, uiModel)
  local obj = RobotPetUIModel()
  obj:Init(id)
  obj._component = uiModel
  return obj
end
def.override("number", "=>", "boolean").Init = function(self, id)
  ECUIModel.Init(self, id)
  self._monsterCfgId = id
  return true
end
local doCallback = function(cb, ret)
  if cb then
    cb(ret)
  end
end
def.method("function").LoadDefault = function(self, cb)
  local monsterCfg = require("Main.Pet.Interface").GetMonsterCfg(self._monsterCfgId)
  if monsterCfg == nil then
    return
  end
  self:LoadByCfg(monsterCfg, cb)
end
def.method("table", "function").LoadByCfg = function(self, monsterCfg, cb)
  local modelId = monsterCfg.monsterModelId
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
    self._component.modelGameObject = self.m_model
    if monsterCfg.colorId > 0 then
      local colorcfg = GetModelColorCfg(monsterCfg.colorId)
      self:SetColoration(colorcfg)
    else
      self:SetColoration(nil)
    end
    doCallback(cb, ret)
  end)
end
def.method("boolean").SetCanExceedBound = function(self, canExceed)
  self._canExceedBound = canExceed
  self:UpdateUIModelMode()
end
def.method("=>", "boolean").IsComponentReady = function(self)
  if self._component == nil or self._component.isnil then
    return false
  end
  return true
end
def.method().UpdateUIModelMode = function(self)
  if not self:IsComponentReady() then
    return
  end
  self._component.mCanOverflow = self._canExceedBound
  if self._canExceedBound then
    local camera = self._component:get_modelCamera()
    if camera then
      camera:set_orthographic(true)
    else
      warn("UpdateUIModelMode modelcamera is nil", debug.traceback())
    end
  end
end
return RobotPetUIModel.Commit()
