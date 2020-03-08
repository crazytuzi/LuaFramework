local Lplus = require("Lplus")
local PetSoulData = require("Main.Pet.soul.data.PetSoulData")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local PetSoulProtocols
local PetSoulMgr = Lplus.Class("PetSoulMgr")
local def = PetSoulMgr.define
local instance
def.static("=>", PetSoulMgr).Instance = function()
  if instance == nil then
    instance = PetSoulMgr()
  end
  return instance
end
local EFFECT_DURATION = 4
def.field("userdata")._exchangeEffect = nil
def.field("number")._effectTimerID = 0
def.method().Init = function(self)
  PetSoulProtocols = require("Main.Pet.soul.PetSoulProtocols")
  PetSoulProtocols.RegisterProtocols()
  PetSoulData.Instance():Init()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, PetSoulMgr._OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetSoulMgr._OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_Pet_Soul, PetSoulMgr._OnUseItem)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, PetSoulMgr.OnClickMapFindpath)
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  local result = true
  if false == self:IsFeatureOpen(bToast) then
    result = false
  elseif false == self:IsConditionSatisfied(bToast) then
    result = false
  end
  return result
end
def.method("boolean", "=>", "boolean").IsFeatureOpen = function(self, bToast)
  local result = true
  if false == _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_PET_SOUL) then
    result = false
    if bToast then
      Toast(textRes.Pet.Soul.FEATRUE_IDIP_NOT_OPEN)
    end
  end
  return result
end
def.method("boolean", "=>", "boolean").IsConditionSatisfied = function(self, bToast)
  local result = true
  local PetUtility = require("Main.Pet.PetUtility")
  local openLevel = PetUtility.Instance():GetPetConstants("PET_SOUL_OPEN_ROLE_LEVEL")
  if openLevel > _G.GetHeroProp().level then
    result = false
    if bToast then
      Toast(string.format(textRes.Pet.Soul.LOW_LEVEL, openLevel))
    end
  end
  return result
end
def.method("=>", "boolean").NeedReddot = function(self)
  return false
end
def.static("table", "table")._OnLeaveWorld = function(param, context)
  PetSoulData.Instance():OnLeaveWorld(param, context)
end
def.static("table", "table")._OnFunctionOpenChange = function(param, context)
  if param.feature ~= ModuleFunSwitchInfo.TYPE_PET_SOUL or false == param.open then
  else
  end
end
def.static("table", "table")._OnUseItem = function(param, context)
  if PetSoulMgr.Instance():IsOpen(true) then
    local PetPanel = require("Main.Pet.ui.PetPanel")
    PetPanel.Instance():ShowPanelEx(PetPanel.NodeId.Soul)
    Toast(textRes.Pet.Soul.SOUL_USE_ITEM)
  end
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
end
def.method().PlayExchangeEffect = function(self)
  self:_ClearEffectTimer()
  self:_DestroyExchangeEffect()
  local effectParent = require("Main.MainUI.ui.MainUIPanel").Instance().m_panel
  if effectParent then
    if nil == self._exchangeEffect then
      local PetUtility = require("Main.Pet.PetUtility")
      local effectId = PetUtility.Instance():GetPetConstants("PET_SOUL_EXCHANGE_EFFECT_ID")
      local effectCfg = GetEffectRes(effectId)
      if effectCfg then
        self._exchangeEffect = require("Fx.GUIFxMan").Instance():PlayAsChild(effectParent, effectCfg.path, 0, 0, -1, false)
      else
        warn("[ERROR][PetSoulMgr:PlayExchangeEffect] effectCfg nil for effectid:", effectId)
      end
    end
    if self._exchangeEffect then
      self._effectTimerID = GameUtil.AddGlobalTimer(EFFECT_DURATION, true, function()
        self:_DestroyExchangeEffect()
      end)
    end
  else
    warn("[ERROR][PetSoulMgr:PlayExchangeEffect] effectParent nil, play failed.")
  end
end
def.method()._DestroyExchangeEffect = function(self)
  if self._exchangeEffect then
    self._exchangeEffect:Destroy()
    self._exchangeEffect = nil
  end
end
def.method()._ClearEffectTimer = function(self)
  if self._effectTimerID > 0 then
    GameUtil.RemoveGlobalTimer(self._effectTimerID)
    self._effectTimerID = 0
  end
end
PetSoulMgr.Commit()
return PetSoulMgr
