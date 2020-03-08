local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECModel = require("Model.ECModel")
local WingUtils = require("Main.Wing.WingUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ECFxMan = require("Fx.ECFxMan")
local ECWingComponent = Lplus.Class("ECWingComponent")
ECWingComponent.WING_BONE_NAME = "HH_Wing"
local def = ECWingComponent.define
def.const("string").WING_TAG = "WING"
def.field("table").m_charModel = nil
def.field("table").m_wing = nil
def.field("number").m_wingId = 0
def.field("number").m_dyeId = 0
def.field("table").m_effects = nil
def.field("userdata").parentNode = nil
def.field("number").defaultLayer = 1
def.field("boolean").isDead = false
def.field("boolean").m_visible = true
def.static("table", "=>", ECWingComponent).new = function(model)
  local wing = ECWingComponent()
  wing.m_charModel = model
  wing.defaultLayer = model.defaultLayer
  wing.m_effects = {}
  return wing
end
def.method("number").Update = function(self, ticks)
  if self.m_wing then
    self.m_wing:Update(ticks)
  end
end
def.method("string", "table", "string").OnLoadPartObj = function(self, id, model, addToPart)
  if self.m_charModel == nil or self.m_charModel.m_model == nil then
    self:DestroyModel()
    return
  end
  local ret = self.m_charModel:AttachModel(id, model, addToPart)
  if not ret then
    self:DestroyModel()
    return
  end
  self:PlayAction()
end
def.method().PlayAction = function(self)
  if self.isDead then
    self:Death()
  elseif self.m_charModel:tryget("movePath") and self.m_charModel.movePath then
    self:Run()
    self:PlayStandEffect()
  else
    self:Stand()
    self:PlayStandEffect()
  end
end
def.method().ResetAction = function(self)
  if self.m_wing then
    self.m_wing:ResetAction()
  end
end
def.method("boolean").SetVisible = function(self, v)
  self.m_visible = v
  if self.m_wing then
    self.m_wing:SetVisible(v)
    if v then
      self:Stand()
    end
  end
end
def.method("table").SetCharModel = function(self, model)
  self.m_charModel = model
  self.parentNode = nil
end
def.method("=>", "boolean").IsMainModelLoaded = function(self)
  if self.m_charModel == nil then
    return false
  end
  return self.m_charModel:IsObjLoaded()
end
def.method().StopStandEffect = function(self)
  for k, v in ipairs(self.m_effects) do
    ECFxMan.Instance():Stop(v)
  end
  self.m_effects = {}
end
def.method().PlayStandEffect = function(self)
  if self.m_wing == nil or self.m_wing.m_model == nil or self.m_wing.m_model.isnil then
    return
  end
  local wingsViewCfg = WingUtils.GetWingViewCfg(self.m_wingId)
  if wingsViewCfg.effectId <= 0 then
    return
  end
  local boneEffect = GetBoneAddEffect(wingsViewCfg.effectId)
  if boneEffect ~= nil then
    for k, v in ipairs(boneEffect.boneaddeffect) do
      local effres = GetEffectRes(v.effect)
      local bone = v.bone
      local position = EC.Vector3.zero
      local rotation = Quaternion.identity
      local duration = -1
      local parent = self.m_wing.m_model:FindChild(bone)
      local highres = false
      local effect = ECFxMan.Instance():PlayAsChild(effres.path, parent, position, rotation, duration, highres, self.defaultLayer)
      if effect then
        effect:SetLayer(self.defaultLayer)
        effect:GetComponent("FxOne"):set_Stable(true)
        local FXModule = require("Main.FX.FXModule")
        FXModule.Instance():AddManagedFx(effect)
        table.insert(self.m_effects, effect)
      end
    end
  end
end
def.method().PlayDeadEffect = function(self)
  if self.m_wing == nil or self.m_wing.m_model == nil or self.m_wing.m_model.isnil then
    return
  end
  local wingsViewCfg = WingUtils.GetWingViewCfg(self.m_wingId)
  local effectId = wingsViewCfg.dieEffectId
  local resname = GetEffectRes(effectId).path
  local position = EC.Vector3.zero
  local rotation = Quaternion.identity
  local duration = 3
  local parent = self.m_charModel.m_model:FindChild(ECWingComponent.WING_BONE_NAME)
  local highres = false
  local deathEffect = ECFxMan.Instance():PlayAsChild(resname, parent, position, rotation, duration, highres, self.defaultLayer)
  deathEffect:SetLayer(self.defaultLayer)
end
def.method("number").SetColor = function(self, colorId)
  self.m_dyeId = colorId
  if self.m_wing then
    local colorCfg
    if self.m_dyeId > 0 then
      colorCfg = GetModelColorCfg(self.m_dyeId)
    end
    self.m_wing:SetColoration(colorCfg)
  end
end
def.method().LoadResBase = function(self)
  local wingsViewCfg = WingUtils.GetWingViewCfg(self.m_wingId)
  if wingsViewCfg == nil then
    return
  end
  local resname = GetModelPath(wingsViewCfg.modelId)
  local ECModel = require("Model.ECModel")
  local model = ECModel.new(self.m_wingId)
  model.parentNode = self.parentNode
  model.defaultLayer = self.defaultLayer
  if self.m_wing then
    self.m_wing:Destroy()
  end
  self.m_wing = model
  local function onLoadObj(obj)
    if obj == nil then
      print("Wing is Nil !")
      self.m_wing = nils
      return
    end
    if self.m_charModel == nil or self.m_charModel:IsDestroyed() then
      return
    end
    obj:SetActive(self.m_charModel.m_visible and self.m_charModel.showModel)
    self:OnLoadPartObj(ECWingComponent.WING_TAG, obj, ECWingComponent.WING_BONE_NAME)
    if not self.m_wing then
      return
    end
    self.m_wing.m_bUncache = true
    self:SetColor(self.m_dyeId)
    self:SetVisible(self.m_visible and not self.isDead)
    if self.m_charModel.m_IsAlpha then
      self:SetAlpha(0.55)
    else
      self:CloseAlpha()
    end
  end
  model:Load(resname, onLoadObj)
end
def.method("number", "number").LoadRes = function(self, id, dyeId)
  if id == self.m_wingId and dyeId == self.m_dyeId then
    if self.m_wing == nil and self.m_wingId > 0 then
      self:ReLoadRes()
    end
    return
  end
  self:Destroy()
  self.m_wingId = id
  self.m_dyeId = dyeId
  self:ReLoadRes()
end
def.method().ReLoadRes = function(self)
  if self:IsMainModelLoaded() == false then
    if self.m_charModel and self.m_charModel:IsInLoading() then
      self.m_charModel:AddOnLoadCallback("Wing", function()
        self:LoadResBase()
      end)
    end
    return
  end
  self:LoadResBase()
end
def.method(ECModel, "=>", "boolean").AttachToModel = function(self, model)
  self.m_charModel = model
  local ret = false
  if self.m_wing then
    ret = self.m_charModel:AttachModel(ECWingComponent.WING_TAG, self.m_wing, ECWingComponent.WING_BONE_NAME)
  else
    ret = self.m_wingId > 0
    if ret then
      self:ReLoadRes()
    end
  end
  if not ret then
    self:DestroyModel()
  end
  return ret
end
def.method().Detach = function(self)
  if self.m_charModel == nil then
    return
  end
  if self.m_wing and self.m_wing.m_model then
    self.m_charModel:Detach(ECWingComponent.WING_TAG)
    self.m_charModel.m_model.localScale = EC.Vector3.one
  end
  self.m_charModel = nil
end
def.method().DestroyModel = function(self)
  if self.m_charModel and self.m_charModel:IsInLoading() then
    self.m_charModel:RemoveOnLoadCallback("Wing")
  end
  if self.m_wing then
    self:StopStandEffect()
    local model = self.m_charModel and self.m_charModel:Detach(ECWingComponent.WING_TAG)
    if model then
      model:Destroy()
      model = nil
    else
      self.m_wing:Destroy()
    end
    self.m_wing = nil
  end
end
def.method().Destroy = function(self)
  self:DestroyModel()
  self.m_wingId = 0
end
def.method("number").SetAlpha = function(self, alphaValue)
  if self.m_wing and self.m_wing.m_model and not self.m_wing.m_model.isnil and self.m_wing.m_renderers then
    local rs = self.m_wing.m_renderers
    for k, v in pairs(rs) do
      if v and not v.isnil then
        local mat = v.material
        mat:SetFloat("_Transparent", alphaValue)
      else
        break
      end
    end
  end
end
def.method("number").SetLayer = function(self, layer)
  if self.m_wing then
    self.m_wing:SetLayer(layer)
    self.defaultLayer = layer
  end
end
def.method("number").ChangeAlpha = function(self, alphaValue)
  if self.m_wing and self.m_wing.m_model and not self.m_wing.m_model.isnil then
    self.m_wing:ChangeAlpha(alphaValue)
  end
end
def.method().CloseAlpha = function(self)
  if self.m_wing and self.m_wing.m_model and not self.m_wing.m_model.isnil and self.m_wing.m_renderers then
    local rs = self.m_wing.m_renderers
    for k, v in pairs(rs) do
      if v and not v.isnil then
        local mat = v.material
        mat:SetFloat("_Transparent", 1)
      else
        break
      end
    end
  end
end
def.method().Stand = function(self)
  if self.m_wing and not self.m_wing:IsPlaying(WingUtils.Animation.STAND) then
    self.m_wing:CrossFade(WingUtils.Animation.STAND, 0.15)
  end
end
def.method().Run = function(self)
  if self.m_wing then
    self.m_wing:CrossFade(WingUtils.Animation.RUN, 0.15)
  end
end
def.method().Attack = function(self)
  if self.m_wing and self.m_wing:HasAnimClip(WingUtils.Animation.ATTACK) then
    self.m_wing:Play(WingUtils.Animation.ATTACK)
  end
end
def.method().Death = function(self)
  self.isDead = true
  if self.m_wing then
    self:PlayDeadEffect()
    if not self.m_wing:IsPlaying(WingUtils.Animation.DEATH) and self.m_wing:HasAnimClip(WingUtils.Animation.DEATH) then
      self.m_wing:PlayAnim(WingUtils.Animation.DEATH, function()
        self.m_wing:SetActive(false)
      end)
    else
      self.m_wing:SetActive(false)
    end
  end
end
def.method().Born = function(self)
  self.isDead = false
  if self.m_wing then
    self.m_wing:SetActive(true)
    self:Stand()
  end
end
def.method().Defend = function(self)
  if self.m_wing and self.m_wing:HasAnimClip(WingUtils.Animation.DEFEND) then
    self.m_wing:Play(WingUtils.Animation.DEFEND)
  end
end
ECWingComponent.Commit()
return ECWingComponent
