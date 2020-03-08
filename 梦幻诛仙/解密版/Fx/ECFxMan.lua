local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECGame = Lplus.ForwardDeclare("ECGame")
local SceneChangeEvent = require("Event.SceneChangeEvent")
local ECObject = Lplus.ForwardDeclare("ECObject")
local ECFxMan = Lplus.Class("ECFxMan")
local def = ECFxMan.define
local s_man
local s_allfx = {}
def.field("userdata").SpecialFxHolder = nil
def.field("userdata").mFlyRoot = nil
def.field("userdata").mFlyUnusedRoot = nil
def.field("boolean").HideAllGFX = false
def.field("number").TickTimer = 0
def.field("number").CurLodLevel = 10
def.field("boolean").IsInNationWar = false
def.field("userdata").SelectedFx = nil
def.field("boolean").mIsLowLevel = false
local curFrameCount = 0
local lastFPSTime = 0
local fpsTables = {}
local function OnEnterScene(event)
  ECFxMan.Instance():ResetLODLevel()
end
def.static("=>", ECFxMan).Instance = function()
  if not s_man then
    s_man = ECFxMan()
    local cacheman = FxCacheMan.Instance
    cacheman.maxFxCount = max_fx_count
    cacheman.maxUnusedFxCount = 48
    warn("max effect Count =", max_fx_count)
    warn("max effect unused Count =", cacheman.maxUnusedFxCount)
    FxCacheMan.HighLodLevel = 10
    FxCacheMan.MidLodLevel = 5
    FxCacheMan.SetMaxLodCostLevelCount(1, 0, 40)
    FxCacheMan.SetMaxLodCostLevelCount(1, 1, 30)
    FxCacheMan.SetMaxLodCostLevelCount(1, 2, 20)
    FxCacheMan.SetMaxLodCostLevelCount(0, 0, 40)
    FxCacheMan.SetMaxLodCostLevelCount(0, 1, 30)
    FxCacheMan.SetMaxLodCostLevelCount(0, 2, 20)
    s_man.SpecialFxHolder = GameObject.GameObject("SpecialFxs")
    s_man.mFlyRoot = GameObject.GameObject("FlyRoot")
    s_man.mFlyUnusedRoot = GameObject.GameObject("FlyUnusedRoot")
    s_man.mFlyUnusedRoot:SetActive(false)
    s_man:ResetLODLevel()
    ECGame.EventManager:addHandler(SceneChangeEvent, function(sender, event)
      OnEnterScene(event)
    end)
    curFrameCount = Time.frameCount
    lastFPSTime = Time.time
    s_man.TickTimer = GameUtil.AddGlobalTimer(1, false, function()
      s_man:UpdateLODLevel()
    end)
  end
  return s_man
end
def.method("string", "table", "userdata", "number", "boolean", "number", "=>", "userdata").Play = function(self, resName, pos, rotation, lifetime, needHighLod, layer)
  if self.HideAllGFX then
    return nil
  end
  local fx = GameUtil.RequestFx(resName, 1)
  if fx then
    local fxone = fx:GetComponent("FxOne")
    fx.position = pos
    fx.rotation = rotation
    fxone:Play2(lifetime, needHighLod)
    if layer < 0 then
      layer = ClientDef_Layer.Player
    end
    fx:SetLayer(layer)
  end
  if not fx then
    print("failed to get fx:", resName)
  end
  return fx
end
def.method(ECObject, "string", "userdata", "table", "userdata", "number", "boolean", "number", "=>", "userdata").PlayAsChildOnECObject = function(self, ecobj, resName, parent, localpos, localrot, lifetime, needHighLod, layer)
  if self.HideAllGFX then
    return nil
  end
  local fx = GameUtil.RequestFx(resName, 1)
  if fx then
    fx.parent = parent
    fx.localPosition = localpos
    fx.localRotation = localrot
    fx.localScale = EC.Vector3.one
    if layer < 0 then
      layer = ClientDef_Layer.Player
    end
    fx:SetLayer(layer)
    local fxone = fx:GetComponent("FxOne")
    fxone:Play2(lifetime, needHighLod)
    ecobj:AddFxOne(fxone)
  end
  return fx
end
def.method("string", "userdata", "table", "userdata", "number", "boolean", "number", "=>", "userdata").PlayAsChild = function(self, resName, parent, localpos, localrot, lifetime, needHighLod, layer)
  if self.HideAllGFX then
    return nil
  end
  if parent == nil or parent.isnil then
    return nil
  end
  local fx = GameUtil.RequestFx(resName, 1)
  if fx then
    fx.parent = parent
    fx.localPosition = localpos
    fx.localRotation = localrot
    fx.localScale = EC.Vector3.one
    local fxone = fx:GetComponent("FxOne")
    fxone:Play2(lifetime, needHighLod)
    if layer < 0 then
      layer = ClientDef_Layer.Player
    end
    fx:SetLayer(layer)
  end
  return fx
end
def.method("string", "table", "dynamic", "function", "number", "number", "number", "boolean", "number").Fly = function(self, resName, pos, dest, cb, speed, duration, tolerance, needHighLod, layer)
  if self.HideAllGFX then
    return
  end
  if type(dest) ~= "userdata" and type(dest) ~= "table" then
    return
  end
  if layer < 0 then
    layer = ClientDef_Layer.Player
  end
  local fx = self:Play(resName, pos, Quaternion.identity, 100, needHighLod, layer)
  if fx then
    fx:SetLayer(layer)
  end
  local go, fly
  if 0 < self.mFlyUnusedRoot.childCount then
    go = self.mFlyUnusedRoot:GetChild(0)
    go:SetActive(true)
    fly = go:GetComponent("LinearMotor")
  else
    go = GameObject.GameObject("fly")
    fly = go:AddComponent("LinearMotor")
  end
  go.parent = self.mFlyRoot
  go.position = pos
  go.localRotation = Quaternion.identity
  go.localScale = EC.Vector3.one
  fx.parent = go
  fx.localPosition = EC.Vector3.zero
  fx.localScale = EC.Vector3.one
  fly:Fly(pos, dest, speed, duration, tolerance, function(go, timeout)
    if cb then
      cb(go, dest, resName)
    end
    go.parent = self.mFlyUnusedRoot
    go:SetActive(false)
  end)
end
def.method("userdata").Stop = function(self, gfxobj)
  if gfxobj ~= nil and not gfxobj.isnil then
    local fxone = gfxobj:GetComponent("FxOne")
    if fxone ~= nil then
      fxone:Stop()
    end
  end
end
def.method().Init = function(self)
end
def.method("boolean").RenderHide = function(self, hide)
  for i, fx in ipairs(s_allfx) do
    if fx then
      if not fx.isnil then
        fx:RenderHide(hide)
      else
        s_allfx[i] = false
      end
    end
  end
  FxCacheMan.Instance.RenderHide = hide
end
def.method("userdata").KeepForTest = function(self, fx)
  for i, fx in ipairs(s_allfx) do
    if not fx or fx.isnil then
      s_allfx[i] = fx
      return
    end
  end
  s_allfx[#s_allfx + 1] = fx
end
def.method().Release = function(self)
  self.SpecialFxHolder = nil
  self.mFlyRoot = nil
  self.mFlyUnusedRoot = nil
  GameUtil.RemoveGlobalTimer(self.TickTimer)
  self.TickTimer = 0
end
def.method().UpdateLODLevel = function(self)
  local n = Time.frameCount - curFrameCount
  local dt = Time.time - lastFPSTime
  fpsTables[#fpsTables + 1] = n / dt
  curFrameCount = Time.frameCount
  lastFPSTime = Time.time
  local fpscount = #fpsTables
  if fpscount == 15 then
    local total = 0
    for i, v in ipairs(fpsTables) do
      total = total + fpsTables[i]
    end
    local fps = total / fpscount
    if fps < 15 then
      if self.CurLodLevel == 10 then
        self.CurLodLevel = 5
      end
    elseif self.CurLodLevel == 5 then
      self.CurLodLevel = 10
    end
    FxCacheMan.lodLevel = self.CurLodLevel
    fpsTables = {}
  end
end
def.method().ResetLODLevel = function(self)
  self.CurLodLevel = 10
  FxCacheMan.lodLevel = 10
end
def.method("string", "number", "number", "=>", "userdata").PlayEffectAt2DWorldPos = function(self, respath, x, y)
  return self:PlayEffectAt2DPos(respath, x, world_height - y)
end
def.method("string", "number", "number", "=>", "userdata").PlayEffectAt2DPos = function(self, respath, x, y)
  local _3dpos = Map2DPosTo3D(x, y)
  return self:Play(respath, _3dpos, Quaternion.identity, -1, false, -1)
end
def.method("string", "number", "number", "number", "number", "=>", "userdata").PlayEffectAt2DPosWithRotationAndHeight = function(self, respath, x, y, dir, height)
  local _3dpos = Map2DPosTo3D(x, y)
  _3dpos.y = height
  local rotation = Quaternion.Euler(EC.Vector3.new(0, dir, 0))
  return self:Play(respath, _3dpos, rotation, -1, false, -1)
end
ECFxMan.Commit()
return ECFxMan
