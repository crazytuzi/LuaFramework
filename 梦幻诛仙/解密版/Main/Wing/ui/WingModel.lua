local Lplus = require("Lplus")
local WingModel = Lplus.Class("WingModel")
local EC = require("Types.Vector3")
local WingUtils = require("Main.Wing.WingUtils")
local ECUIModel = require("Model.ECUIModel")
local ECFxMan = require("Fx.ECFxMan")
local FXModule = require("Main.FX.FXModule")
local def = WingModel.define
def.field("number").outlookId = 0
def.field("number").wingDyeId = 0
def.field("table").model = nil
def.field("table").effects = nil
def.method("number", "number", "function").Create = function(self, outlookId, wingDyeId, callback)
  if self.outlookId == outlookId and self.wingDyeId == wingDyeId then
    if self.model then
      self.model:Play("Stand_c")
    end
    return
  end
  self.effects = {}
  self.outlookId = outlookId
  self.wingDyeId = wingDyeId
  if self.model then
    warn("self.model", outlookId)
    self.model:Destroy()
    self.model = nil
  end
  local wingViewCfg = WingUtils.GetWingViewCfg(self.outlookId)
  local wingModelId = wingViewCfg.modelId
  local modelPath = GetModelPath(wingModelId)
  self.model = ECUIModel.new(wingModelId)
  self.model.m_bUncache = true
  self.model:LoadUIModel(modelPath, function(ret)
    if self.model == nil or self.model.m_model == nil or self.model.m_model.isnil then
      return
    end
    self.model:SetDir(0)
    self.model:SetScale(1)
    self.model:SetPos(0, 0)
    if 0 < self.wingDyeId then
      local colorCfg = GetModelColorCfg(self.wingDyeId)
      self.model:SetColoration(colorCfg)
    end
    self:PlayStandEffect()
    if callback then
      callback()
    end
  end)
end
def.method().Stand = function(self)
  if self.model then
    self.model:Play("Stand_c")
  end
end
def.method().PlayStandEffect = function(self)
  if self.model == nil or self.model.m_model == nil or self.model.m_model.isnil then
    return
  end
  local wingViewCfg = WingUtils.GetWingViewCfg(self.outlookId)
  if wingViewCfg.effectId <= 0 then
    return
  end
  local boneEffect = GetBoneAddEffect(wingViewCfg.effectId)
  if boneEffect ~= nil then
    for k, v in ipairs(boneEffect.boneaddeffect) do
      local effres = GetEffectRes(v.effect)
      local bone = v.bone
      local position = EC.Vector3.zero
      local rotation = Quaternion.identity
      local duration = -1
      local parent = self.model.m_model:FindChild(bone)
      local highres = false
      local effect = ECFxMan.Instance():PlayAsChild(effres.path, parent, position, rotation, duration, highres, self.model.defaultLayer)
      if effect then
        effect:GetComponent("FxOne"):set_Stable(true)
        FXModule.Instance():AddManagedFx(effect)
        table.insert(self.effects, effect)
      end
    end
  end
end
def.method().Destroy = function(self)
  if self.effects then
    for k, v in ipairs(self.effects) do
      ECFxMan.Instance():Stop(v)
      Object.Destroy(v)
    end
    self.effects = {}
  end
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
  self.outlookId = 0
  self.wingDyeId = 0
end
def.method("=>", "userdata").GetModelGameObject = function(self)
  if self.model and self.model.m_model and not self.model.m_model.isnil then
    return self.model.m_model
  else
    return nil
  end
end
def.method("=>", "number").GetDir = function(self)
  if self.model then
    return self.model:GetDir()
  else
    return -1
  end
end
def.method("number").SetDir = function(self, dir)
  if self.model then
    self.model:SetDir(dir)
  end
end
WingModel.Commit()
return WingModel
