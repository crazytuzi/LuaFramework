local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local ECRide = require("Model.ECRide")
local ECUIModel = require("Model.ECUIModel")
local EC = require("Types.Vector3")
local ECFxMan = require("Fx.ECFxMan")
local MountsUtils = require("Main.Mounts.MountsUtils")
local MountsUIModel = Lplus.Extend(ECUIModel, "MountsUIModel")
local def = MountsUIModel.define
def.field("number").mountsCfgId = 0
def.field("userdata").m_component = nil
def.field("boolean").m_canExceedBound = false
def.field("table").effects = nil
def.final("number", "userdata", "=>", MountsUIModel).new = function(id, uiModel)
  local obj = MountsUIModel()
  obj:Init(id)
  obj.m_component = uiModel
  obj.effects = {}
  return obj
end
def.override("number", "=>", "boolean").Init = function(self, id)
  ECUIModel.Init(self, id)
  self.mountsCfgId = id
  return true
end
local doCallback = function(cb, ret)
  if cb then
    cb(ret)
  end
end
def.method("function").LoadDefault = function(self, cb)
  local mountsCfg = MountsUtils.GetMountsCfgById(self.mountsCfgId)
  if mountsCfg == nil then
    warn("No Mounts Cfg Data")
    return
  end
  self:LoadByCfg(mountsCfg, cb)
end
def.method("table", "function").LoadByCfg = function(self, mountsCfg, cb)
  local modelId = mountsCfg.mountsModelId
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
    doCallback(cb, ret)
  end)
end
def.method("boolean").SetCanExceedBound = function(self, canExceed)
  self.m_canExceedBound = canExceed
  self:UpdateUIModelModel()
end
def.method("=>", "boolean").IsComponentReady = function(self)
  if self.m_component == nil or self.m_component.isnil then
    return false
  end
  return true
end
def.method().UpdateUIModelModel = function(self)
  if not self:IsComponentReady() then
    return
  end
  self.m_component.mCanOverflow = self.m_canExceedBound
  if self.m_canExceedBound then
    local camera = self.m_component:get_modelCamera()
    if camera then
      camera:set_orthographic(true)
    end
  end
end
def.method("number").SetMountsColor = function(self, colorId)
  if self.m_model and not self.m_model.isnil then
    local mountColorCfg = MountsUtils.GetMountsDyeColrByColorId(self.mountsCfgId, colorId)
    if mountColorCfg then
      local mountColor = GetModelColorCfg(mountColorCfg.modelColorId)
      if mountColor then
        self:SetColoration(mountColor)
      end
    end
  end
end
def.method("number").SetMountsRank = function(self, rank)
  if self.m_model and not self.m_model.isnil then
    local mountsOrnamentCfg = MountsUtils.GetMountsRankOrnamentCfg(self.mountsCfgId, rank) or {}
    if mountsOrnamentCfg then
      for k, v in pairs(mountsOrnamentCfg) do
        local ornament = self.m_model:FindDirect(k)
        if ornament then
          ornament:SetActive(v)
        end
      end
      do
        local boneEffects = MountsUtils.GetMountsRankBoneEffectsCfg(self.mountsCfgId, rank) or {}
        self:ClearEffect()
        GameUtil.AddGlobalTimer(0.5, true, function()
          if not self:IsDestroyed() then
            for k, v in pairs(boneEffects) do
              self:AddBoneEffect(v)
            end
          end
        end)
      end
    end
  end
end
def.method("number").AddBoneEffect = function(self, boneEffectId)
  local boneEffect = GetBoneAddEffect(boneEffectId)
  if boneEffect ~= nil then
    local FXModule = require("Main.FX.FXModule")
    for k, v in ipairs(boneEffect.boneaddeffect) do
      local effres = GetEffectRes(v.effect)
      local bone = v.bone
      local position = EC.Vector3.zero
      local rotation = Quaternion.identity
      local duration = -1
      local parent = self.m_model:FindChild(bone)
      local highres = false
      local effect = ECFxMan.Instance():PlayAsChild(effres.path, parent, position, rotation, duration, highres, self.defaultLayer)
      if effect then
        effect:SetLayer(self.defaultLayer)
        effect:GetComponent("FxOne"):set_Stable(true)
        FXModule.Instance():AddManagedFx(effect)
        table.insert(self.effects, effect)
      end
    end
  end
end
def.method().ClearEffect = function(self)
  for k, v in pairs(self.effects) do
    ECFxMan.Instance():Stop(v)
  end
  self.effects = {}
end
def.override().Destroy = function(self)
  self:ClearEffect()
  ECUIModel.Destroy(self)
end
return MountsUIModel.Commit()
