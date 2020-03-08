local Lplus = require("Lplus")
local HeroModelMgr = Lplus.Class("HeroModelMgr")
local def = HeroModelMgr.define
local instance
def.static("=>", HeroModelMgr).Instance = function()
  if instance == nil then
    instance = HeroModelMgr()
  end
  return instance
end
local DEFAULT_NAME_COLOR = 701300000
def.field("table")._roleEffects = nil
def.method("boolean").OnOpenChange = function(self, bOpen)
  self:HandleEventListeners(bOpen)
  if not bOpen then
    self:Clear()
  end
end
def.method("boolean").HandleEventListeners = function(self, bRigister)
  if bRigister then
    Event.RegisterEventWithContext(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, HeroModelMgr.OnLeaveWorld, self)
    Event.RegisterEventWithContext(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_ARENA, HeroModelMgr.OnLeaveArenaMap, self)
  else
    Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, HeroModelMgr.OnLeaveWorld)
    Event.UnregisterEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_LEAVE_ARENA, HeroModelMgr.OnLeaveArenaMap)
  end
end
def.method("table").OnLeaveWorld = function(self, params)
  self:Clear()
end
def.method("table").OnLeaveArenaMap = function(self, params)
  self:RestoreHeroModel()
  self:Clear()
end
def.method().RestoreHeroModel = function(self)
  local heroModel = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if not _G.IsNil(heroModel) then
    warn("[HeroModelMgr:RecoverHeroModel] restore hero model.")
    self:RemoveAllEffects()
    if not _G.IsNil(heroModel.m_model) then
      heroModel:SetScale(Model_Default_Scale.x)
    end
    gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):RecoverRoleModel(_G.GetMyRoleID())
    local function onModelLoaded()
      heroModel:SetVisible(true)
      local nameColor = GetColorData(DEFAULT_NAME_COLOR)
      heroModel:SetName("", nameColor)
      heroModel:SetPate()
      if heroModel:IsBallCooldowning() then
        heroModel:DestroyBallCooldownPate()
      end
      heroModel.checkAlpha = true
      heroModel:CloseAlpha()
    end
    if heroModel:IsInLoading() then
      heroModel:AddOnLoadCallback("aagr_restore", onModelLoaded)
    else
      onModelLoaded()
    end
  else
    warn("[ERROR][HeroModelMgr:RecoverHeroModel] heroModel nil.")
  end
end
def.method().Clear = function(self)
  self._roleEffects = nil
end
def.method("userdata", "string", "userdata").TryAddEffect = function(self, roleId, path, effect)
  if roleId and Int64.eq(roleId, _G.GetMyRoleID()) then
    self:AddEffect(path, effect)
  end
end
def.method("string", "userdata").AddEffect = function(self, path, effect)
  if nil == self._roleEffects then
    self._roleEffects = {}
  end
  if effect then
    self._roleEffects[path] = effect
  else
    self._roleEffects[path] = 0
  end
end
def.method("userdata", "string").TryRemoveEffect = function(self, roleId, path)
  if roleId and Int64.eq(roleId, _G.GetMyRoleID()) then
    self:RemoveEffect(path)
  end
end
def.method("string").RemoveEffect = function(self, path)
  if nil == self._roleEffects then
    return
  end
  self._roleEffects[path] = nil
end
def.method().RemoveAllEffects = function(self)
  if nil == self._roleEffects then
    return
  end
  local heroModel = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if not _G.IsNil(heroModel) then
    for path, effect in pairs(self._roleEffects) do
      warn("[HeroModelMgr:RemoveAllEffects] remove effect:", path)
      heroModel:StopChildEffect(path)
    end
  end
  self._roleEffects = nil
end
HeroModelMgr.Commit()
return HeroModelMgr
