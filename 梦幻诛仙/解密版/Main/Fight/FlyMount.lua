local Lplus = require("Lplus")
local FlyMount = Lplus.Class("FlyMount")
local ECModel = require("Model.ECModel")
local def = FlyMount.define
local EC = require("Types.Vector3")
local FlyModule = require("Main.Fly.FlyModule")
local ECFxMan = require("Fx.ECFxMan")
def.field("string").m_respath = ""
def.field("userdata").m_asset = nil
def.field("userdata").m_model = nil
def.field("number").m_status = ModelStatus.NONE
def.field("userdata").parentNode = nil
def.field("number").layer = ClientDef_Layer.FightPlayer
def.field("boolean").isDetached = false
def.field("userdata").m_ani = nil
def.field("boolean").isShowShadow = false
def.field("table").effects = nil
def.field("number").colorId = 0
def.final("=>", FlyMount).new = function()
  local obj = FlyMount()
  return obj
end
def.method("string").Load = function(self, respath)
  self.m_status = ModelStatus.LOADING
  self.m_respath = respath
  local m, asset = GameUtil.FindResCache(respath)
  if m then
    self:OnModelLoaded(m, asset)
  else
    local function loaded(obj)
      if not obj or self.m_status == ModelStatus.DESTROY or self.parentNode == nil or self.parentNode.isnil then
        return
      end
      local m = Object.Instantiate(obj, "GameObject")
      self:OnModelLoaded(m, obj)
    end
    GameUtil.AsyncLoad(respath, loaded)
  end
end
local defaultRotation = Quaternion.Euler(EC.Vector3.new(0, 15, 0))
def.method("userdata", "userdata").OnModelLoaded = function(self, model, asset)
  if model == nil then
    return
  end
  _G.ecmodel_loaded_count = _G.ecmodel_loaded_count + 1
  model:SetActive(false)
  self.m_model = model
  self.m_asset = asset
  model:SetLayer(self.layer)
  self.m_ani = self.m_model:GetComponentInChildren("Animation")
  self.m_model.transform.parent = self.parentNode.transform
  model.localPosition = EC.Vector3.zero
  model.localScale = self.parentNode.localScale
  model.localRotation = defaultRotation
  self.m_status = ModelStatus.NORMAL
  self:ShowShadow(self.isShowShadow)
  if not model.activeSelf then
    model:SetActive(true)
  end
  if self.colorId > 0 then
    self:SetModelColor()
  end
  if self.effects then
    for k, v in pairs(self.effects) do
      if v.fx == nil then
        v.fx = self:AttachEffectToBone(k, v.bone)
      end
    end
  end
  if self.m_ani then
    self.m_ani.enabled = false
    self.m_ani:set_cullingType(0)
    self.m_ani:set_enabled(true)
  end
  self:Stand()
end
def.method().Stand = function(self)
  if self.m_ani then
    self.m_ani:Play_3(FlyModule.FlyIdleAnimation, PlayMode.StopSameLayer)
  end
end
def.method("boolean").ShowShadow = function(self, show)
  self.isShowShadow = show
  if self.m_model and not self.m_model.isnil then
    local shadowObj = self.m_model:FindDirect("characterShadow")
    if shadowObj then
      if self.isShowShadow then
        shadowObj:SetActive(true)
        local shadowPosition = shadowObj.transform.localPosition
        local shadowToPosition = EC.Vector3.new(shadowPosition.x, shadowPosition.y - 3, shadowPosition.z)
        shadowObj.transform.localPosition = shadowToPosition
      else
        shadowObj:SetActive(false)
      end
    end
  end
end
local backRotation = Quaternion.Euler(EC.Vector3.new(0, -15, 0))
def.method("boolean").SwitchToBackStance = function(self, v)
  if self.m_model and not self.m_model.isnil then
    if v then
      self.m_model.localRotation = backRotation
    else
      self.m_model.localRotation = defaultRotation
    end
  end
end
def.method().Destroy = function(self)
  if self.m_status == ModelStatus.DESTROY then
    return
  end
  self.m_status = ModelStatus.DESTROY
  _G.ecmodel_loaded_count = _G.ecmodel_loaded_count - 1
  if self.m_model and not self.m_model.isnil then
    self.m_model.localScale = EC.Vector3.one
    local flyTw = self.m_model:GetComponent("FlyFightTweener")
    if flyTw then
      Object.Destroy(flyTw)
    end
    if self.effects then
      for k, v in pairs(self.effects) do
        if v.fx then
          ECFxMan.Instance():Stop(v.fx)
        end
      end
    end
    self.m_model:Destroy()
    self.m_model = nil
  end
  self.m_ani = nil
  GameUtil.UnbindUserData(self.m_asset)
  self.m_asset = nil
  self.parentNode = nil
end
def.method("userdata").SetParent = function(self, p)
  if p then
    if self.m_model and not self.m_model.isnil then
      self.m_model.transform.parent = p.transform
    else
      self.parentNode = p
    end
  end
end
def.method("=>", "boolean").IsLoaded = function(self)
  return self.m_status == ModelStatus.NORMAL
end
def.method("=>", "boolean").IsInLoading = function(self)
  return self.m_status == ModelStatus.LOADING
end
def.method("string").AddEffect = function(self, effectResPath)
  if self.effects == nil then
    self.effects = {}
  end
  local effect_data = {bone = "Bip01"}
  self.effects[effectResPath] = effect_data
  if self:IsLoaded() then
    effect_data.fx = self:AttachEffectToBone(effectResPath, effect_data.bone)
  end
end
def.method("string", "string", "=>", "userdata").AttachEffectToBone = function(self, effectResPath, bone)
  if self.m_model == nil or self.m_model.isnil then
    return nil
  end
  local resname = effectResPath
  local position = EC.Vector3.zero
  local duration = -1
  local parent = self.m_model:FindChild(bone)
  local highres = false
  return ECFxMan.Instance():PlayAsChild(resname, parent, position, Quaternion.identity, duration, highres, self.layer)
end
def.method().SetModelColor = function(self)
  if self.m_model == nil or self.m_model.isnil then
    return
  end
  local colorcfg = GetModelColorCfg(self.colorId)
  local colorInfo = {}
  colorInfo.hair = colorcfg and colorcfg.partNum > 1 and Color.Color(colorcfg.part1_r / 255, colorcfg.part1_g / 255, colorcfg.part1_b / 255, colorcfg.part1_a / 255)
  colorInfo.clothes = colorcfg and Color.Color(colorcfg.part2_r / 255, colorcfg.part2_g / 255, colorcfg.part2_b / 255, colorcfg.part2_a / 255)
  colorInfo.other = colorcfg and colorcfg.partNum > 2 and Color.Color(colorcfg.part3_r / 255, colorcfg.part3_g / 255, colorcfg.part3_b / 255, colorcfg.part3_a / 255)
  local renderers = self.m_model:GetRenderersInChildren()
  local defaultColor = Color.Color(1, 1, 1, 0.5)
  for k, v in pairs(renderers) do
    if not v.isnil then
      if v.gameObject.name == ECModel.Name.Hair then
        v.material:SetColor("_Tint", colorInfo and colorInfo.hair or defaultColor)
      elseif v.gameObject.name == ECModel.Name.Panda then
        v.material:SetColor("_Tint", colorInfo and (colorInfo.other or colorInfo.clothes) or defaultColor)
      elseif v.gameObject.name ~= ECModel.Name.Body then
        v.material:SetColor("_Tint", colorInfo and colorInfo.clothes or defaultColor)
      end
    end
  end
end
return FlyMount.Commit()
