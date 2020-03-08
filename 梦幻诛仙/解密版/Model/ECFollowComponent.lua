local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ECFxMan = require("Fx.ECFxMan")
local ECFollowComponent = Lplus.Class("ECFollowComponent")
local def = ECFollowComponent.define
def.field("table").m_charModel = nil
def.field("table").m_follow = nil
def.field("number").m_followId = 0
def.field("userdata").m_effect = nil
def.field("table").m_effects = nil
def.field("userdata").parentNode = nil
def.field("number").defaultLayer = 1
def.static("table", "=>", ECFollowComponent).new = function(model)
  local inst = ECFollowComponent()
  inst.m_charModel = model
  inst.defaultLayer = model.defaultLayer
  inst.parentNode = model.parentNode
  inst.m_effects = {}
  return inst
end
def.method("table").OnLoadPartObj = function(self, model)
  if self.m_charModel == nil or self.m_charModel.m_model == nil or self.m_charModel.m_model.isnil or self.m_charModel:IsDestroyed() then
    self:Destroy()
    return
  end
  local trans = self.m_charModel.m_model:FindDirect().transform
  local offset = EC.Vector3.new(0.6, 1.8, 0)
  local speed = 0.2
  model.m_bUncache = true
  local followTarget = model.m_model:GetComponent("FollowTargetComponent")
  if followTarget == nil then
    followTarget = model.m_model:AddComponent("FollowTargetComponent")
  end
  followTarget:set_Target(trans)
  followTarget:set_Offset(offset)
  followTarget:set_FollowSpeed(speed)
  followTarget:set_Name("follow")
  followTarget:Reset()
  if self.m_charModel:tryget("IsInState") and self.m_charModel:IsInState(RoleState.FLY) then
    local flyScale = 1.5
    model.m_model.localScale = EC.Vector3.new(flyScale, flyScale, flyScale)
  end
  self:Stand()
  self:PlayStandEffect()
end
def.method().StopFollow = function(self)
  if self.m_follow == nil or _G.IsNil(self.m_follow.m_model) then
    return
  end
  local follow_s = self.m_follow.m_model:GetComponent("FollowTargetComponent")
  if follow_s then
    follow_s.enabled = false
  end
end
def.method("table").ResetCharModel = function(self, model)
  if model == nil then
    return
  end
  self.m_charModel = model
  if self.m_follow == nil or _G.IsNil(self.m_follow.m_model) then
    if self.m_followId > 0 then
      self:ReLoadRes()
    end
  else
    local follow_s = self.m_follow.m_model:GetComponent("FollowTargetComponent")
    if follow_s then
      follow_s:set_Target(self.m_charModel.m_model:FindDirect().transform)
      follow_s.enabled = true
    end
  end
end
def.method("boolean").SetVisible = function(self, v)
  if self.m_follow then
    self.m_follow:SetVisible(v)
    if v then
      self:Stand()
    end
  end
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
    Object.Destroy(v)
  end
  self.m_effects = {}
end
def.method().PlayStandEffect = function(self)
  if self.m_follow == nil or self.m_follow.m_model == nil or self.m_follow.m_model.isnil then
    return
  end
  local effectId = 0
  if self:IsLingqi() then
    local fabaoCfg = require("Main.FabaoSpirit.FabaoSpiritUtils").GetFabaoLQCfg(self.m_followId)
    effectId = fabaoCfg.boneEffectId
  else
    local fabaoCfg = ItemUtils.GetFabaoItem(self.m_followId)
    effectId = fabaoCfg.boneEffectId
  end
  if effectId <= 0 then
    return
  end
  local boneEffect = GetBoneAddEffect(effectId)
  if boneEffect ~= nil then
    for k, v in ipairs(boneEffect.boneaddeffect) do
      local effres = GetEffectRes(v.effect)
      local bone = v.bone
      print(effres.path, bone)
      local position = EC.Vector3.zero
      local rotation = Quaternion.identity
      local duration = -1
      local parent = self.m_follow.m_model:FindChild(bone)
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
def.method().PlayShifaEffect = function(self)
  if self.m_follow == nil or self.m_follow.m_model == nil or self.m_follow.m_model.isnil then
    return
  end
  local effectId = 0
  if self:IsLingqi() then
    local fabaoCfg = require("Main.FabaoSpirit.FabaoSpiritUtils").GetFabaoLQCfg(self.m_followId)
    effectId = fabaoCfg.magicEffectId
  else
    local fabaoCfg = ItemUtils.GetFabaoItem(self.m_followId)
    effectId = fabaoCfg.magicEffectId
  end
  if effectId > 0 then
    local resname = GetEffectRes(effectId).path
    local position = EC.Vector3.zero
    local rotation = Quaternion.identity
    local duration = -1
    local parent = self.m_follow.m_model
    local highres = false
    ECFxMan.Instance():PlayAsChild(resname, parent, position, rotation, duration, highres, self.defaultLayer)
  end
end
def.method("=>", "boolean").IsLingqi = function(self)
  return self.m_followId >= 391100000 and self.m_followId <= 391199999
end
def.method().LoadResBase = function(self)
  if self.m_charModel == nil or self.m_charModel:IsDestroyed() then
    return
  end
  if self.m_follow then
    self.m_follow:Destroy()
  end
  local fabaoCfg
  if self:IsLingqi() then
    fabaoCfg = require("Main.FabaoSpirit.FabaoSpiritUtils").GetFabaoLQCfg(self.m_followId)
  else
    fabaoCfg = ItemUtils.GetFabaoItem(self.m_followId)
  end
  if fabaoCfg == nil then
    return
  end
  local resname = GetModelPath(fabaoCfg.modelId)
  local ECModel = require("Model.ECModel")
  local model = ECModel.new(self.m_followId)
  model.parentNode = self.parentNode
  model.defaultLayer = self.defaultLayer
  self.m_follow = model
  local function onLoadObj(obj)
    if obj == nil then
      print("Follow is Nil !")
      self.m_follow = nil
      return
    end
    if self.m_charModel:IsDestroyed() then
      self:Destroy()
      return
    end
    obj:SetActive(self.m_charModel.m_visible and self.m_charModel.showModel)
    self:OnLoadPartObj(obj)
    if self.m_charModel.m_IsAlpha then
      self:SetAlpha(0.55)
    else
      self:CloseAlpha()
    end
  end
  model:Load(resname, onLoadObj)
end
def.method("number").LoadRes = function(self, id)
  if self.m_followId == id then
    if self.m_follow == nil and self.m_followId > 0 then
      self:ReLoadRes()
    end
    return
  end
  self:Destroy()
  self.m_followId = id
  self:ReLoadRes()
end
def.method().ReLoadRes = function(self)
  if self:IsMainModelLoaded() == false then
    if self.m_charModel then
      self.m_charModel:AddOnLoadCallback("Fabao", function()
        self:LoadResBase()
      end)
    end
  else
    self:LoadResBase()
  end
end
def.method().Destroy = function(self)
  if self.m_charModel and self.m_charModel:IsInLoading() then
    self.m_charModel:RemoveOnLoadCallback("Fabao")
  end
  if self.m_follow then
    self:StopStandEffect()
    self.m_follow:Destroy()
    self.m_follow = nil
  end
  self.m_followId = 0
end
def.method("number").SetLayer = function(self, layer)
  if self.m_follow then
    self.m_follow:SetLayer(layer)
    self.defaultLayer = layer
  end
end
def.method().FlyUp = function(self)
  if self.m_follow and self.m_follow.m_model and not self.m_follow.m_model.isnil then
    local skyScale = 1.5
    local upTime = 0.5
    ScaleGameObjectTween.TweenGameObjectScale(self.m_follow.m_model, self.m_follow.m_model.transform.localScale, EC.Vector3.new(skyScale, skyScale, skyScale), upTime)
  end
end
def.method().FlyDown = function(self)
  if self.m_follow and self.m_follow.m_model and not self.m_follow.m_model.isnil then
    local skyScale = 1.5
    local downTime = 0.5
    ScaleGameObjectTween.TweenGameObjectScale(self.m_follow.m_model, self.m_follow.m_model.transform.localScale, EC.Vector3.one, downTime)
  end
end
def.method("number").SetAlpha = function(self, alphaValue)
  if self.m_follow then
    self.m_follow:SetAlpha(alphaValue)
  end
end
def.method("number").ChangeAlpha = function(self, alphaValue)
  if self.m_follow then
    self.m_follow:ChangeAlpha(alphaValue)
  end
end
def.method().CloseAlpha = function(self)
  if self.m_follow then
    self.m_follow:CloseAlpha()
  end
end
def.method().Reset = function(self)
  if self.m_follow and self.m_follow.m_model and not self.m_follow.m_model.isnil then
    local followTarget = self.m_follow.m_model:GetComponent("FollowTargetComponent")
    if followTarget then
      followTarget:Reset()
    end
  end
end
def.method().Stand = function(self)
  if self.m_follow then
    self.m_follow:Play(FabaoUtils.Animation.STAND)
  end
end
def.method().Death = function(self)
  if self.m_follow then
    self.m_follow:SetActive(false)
  end
end
def.method().Born = function(self)
  if self.m_follow then
    self.m_follow:SetActive(true)
  end
  self:Stand()
end
ECFollowComponent.Commit()
return ECFollowComponent
