local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local FashionModule = Lplus.Extend(ModuleBase, "FashionModule")
local FashionPanel = require("Main.Fashion.ui.FashionPanel")
local FashionData = require("Main.Fashion.FashionData")
local FashionUtils = require("Main.Fashion.FashionUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemData = require("Main.Item.ItemData")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local FashionTips = require("Main.Fashion.ui.FashionTips")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
require("Main.module.ModuleId")
local def = FashionModule.define
local instance
def.field("number")._timerId = -1
def.static("=>", FashionModule).Instance = function()
  if instance == nil then
    instance = FashionModule()
    instance.m_moduleId = ModuleId.FASHION
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fashiondress.SSyncFashionDressInfo", FashionModule._OnSyncFashionDressInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fashiondress.SUnLockFashionDressSuccess", FashionModule._OnUnLockFashionDressSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fashiondress.SPutOnFashionDressSuccess", FashionModule._OnPutOnFashionDressSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fashiondress.SPutOffFashionDressSuccess", FashionModule._OnPutOffFashionDressSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fashiondress.SSelectPropertySuccess", FashionModule._OnSelectPropertySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fashiondress.SChangeFashionDressPropertySuccess", FashionModule._OnSChangeFashionDressPropertySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fashiondress.SUnSelectPropertySuccess", FashionModule._OnUnSelectPropertySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fashiondress.SFashionDressExpired", FashionModule._OnFashionDressExpired)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fashiondress.SExtendFashionDressTimeSuccess", FashionModule._OnExtendFashionDressTimeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fashiondress.SFashionDressNormalFailed", FashionModule._OnSFashionDressNormalFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fashiondress.SSyncThemeFashionDressInfo", FashionModule._OnSSyncThemeFashionDressInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fashiondress.SSyncThemeFashionDressUpdateInfo", FashionModule._OnSSyncThemeFashionDressUpdateInfo)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, FashionModule._OnRoleLvUp)
  Event.RegisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.UseFationItem, FashionModule._OnUseFationItem)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, FashionModule._OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, FashionModule._OnLeaveWorld)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, FashionModule._OnNewDay)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, FashionModule.OnFunctionOpenChange)
end
def.static().OpenFashionPanel = function()
  if FashionPanel.Instance():IsCreated() then
    FashionPanel.Instance():DestroyPanel()
  end
  FashionPanel.Instance():ShowFashionPanel()
end
def.static("number").ShowFashionTips = function(fashionType)
  local fashionItem = FashionUtils.GetFashionItemByFashionType(fashionType)
  local unlockItemId = fashionItem.costItemId
  ItemTipsMgr.Instance():ShowFashionItemTip(unlockItemId)
end
def.static("table")._OnSyncFashionDressInfo = function(p)
  FashionData.Instance():SyncFashionDressInfo(p)
end
def.static("number").UnLockFashionDress = function(id)
  local req = require("netio.protocol.mzm.gsp.fashiondress.CUnLockFashionDress").new(id)
  gmodule.network.sendProtocol(req)
end
def.static("table")._OnUnLockFashionDressSuccess = function(p)
  FashionData.Instance():UnlockFashionDress(p.fashionDressCfgId)
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.UnlockFationItem, {
    id = p.fashionDressCfgId
  })
  local fashionItem = FashionUtils.GetFashionItemDataById(p.fashionDressCfgId)
  Toast(string.format(textRes.Fashion[14], fashionItem.fashionDressName))
end
def.static("number").PutOnFashionDress = function(id)
  local req = require("netio.protocol.mzm.gsp.fashiondress.CPutOnFashionDress").new(id)
  gmodule.network.sendProtocol(req)
end
def.static("table")._OnPutOnFashionDressSuccess = function(p)
  FashionData.Instance():PutOnFashionDress(p.fashionDressCfgId)
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.DressFashionChanged, {
    id = p.fashionDressCfgId
  })
  local fashionItem = FashionUtils.GetFashionItemDataById(p.fashionDressCfgId)
  Toast(textRes.Fashion[16])
end
def.static("number").PutOffFashionDress = function(id)
  local req = require("netio.protocol.mzm.gsp.fashiondress.CPutOffFashionDress").new(id)
  gmodule.network.sendProtocol(req)
end
def.static("table")._OnPutOffFashionDressSuccess = function(p)
  FashionData.Instance():PutOffFashionDress(p.fashionDressCfgId)
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.DressFashionChanged, {
    id = p.fashionDressCfgId
  })
  Toast(textRes.Fashion[34])
end
def.static("number").SelectProperty = function(id)
  if FashionData.Instance():GetCurrentActivePropertyCount() >= constant.FashionDressConsts.maxUsePropertyNum then
    local preCfgId = FashionData.Instance().activatePropertyList[1]
    if preCfgId ~= nil then
      local req = require("netio.protocol.mzm.gsp.fashiondress.CChangeFashionDressProperty").new(preCfgId, id)
      gmodule.network.sendProtocol(req)
    end
  else
    local req = require("netio.protocol.mzm.gsp.fashiondress.CSelectProperty").new(id)
    gmodule.network.sendProtocol(req)
  end
end
def.static("table")._OnSChangeFashionDressPropertySuccess = function(p)
  FashionData.Instance():DeActiveProperty(p.old_fashion_dress_cfg_id)
  FashionData.Instance():ActiveProperty(p.new_fashion_dress_cfg_id)
  Toast(textRes.Fashion[39])
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionPropertyChanged, nil)
end
def.static("table")._OnSelectPropertySuccess = function(p)
  FashionData.Instance():ActiveProperty(p.fashionDressCfgId)
  Toast(textRes.Fashion[35])
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionPropertyChanged, nil)
end
def.static("number").UnSelectProperty = function(id)
  local req = require("netio.protocol.mzm.gsp.fashiondress.CUnSelectProperty").new(id)
  gmodule.network.sendProtocol(req)
end
def.static("table")._OnUnSelectPropertySuccess = function(p)
  FashionData.Instance():DeActiveProperty(p.fashionDressCfgId)
  Toast(textRes.Fashion[36])
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionPropertyChanged, nil)
end
def.static("table", "table")._OnRoleLvUp = function(params, context)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local myLv = HeroPropMgr.heroProp.level
  local preLevel = HeroPropMgr.lastHeroProp.level
  local unlockLevel = constant.FashionDressConsts.openLevel
  if myLv >= unlockLevel and preLevel < unlockLevel then
    instance:_OnFashionFunctionUnlock()
  end
end
def.method()._OnFashionFunctionUnlock = function(self)
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionFunctionUnlock, nil)
end
def.static("table", "table")._OnUseFationItem = function(params, context)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_FASHION_DRESS) then
    Toast(textRes.Fashion[30])
    return
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local myLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  local unlockLevel = constant.FashionDressConsts.openLevel
  if myLv < unlockLevel then
    Toast(string.format(textRes.Fashion[26], unlockLevel))
    return
  end
  local item = ItemData.Instance():GetItem(ItemModule.BAG, params.itemKey)
  local itemId = item.id
  local fashionItem = FashionUtils.GetFashionItemByUnlockItemId(itemId)
  if fashionItem == nil then
    return
  end
  local FashionShowType = require("consts.mzm.gsp.fashiondress.confbean.FashionShowType")
  if fashionItem.fashionShowType == FashionShowType.REPLACE and not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_FASHION_REPLACE) then
    Toast(textRes.Fashion[40])
    return
  end
  if not FashionModule.Instance():IsFashionIDIPOpen(fashionItem.fashionDressType) then
    Toast(textRes.Fashion[43])
    return
  end
  local fashionId = fashionItem.id
  local fashionData = FashionData.Instance()
  if fashionData.haveFashionInfo[fashionId] == nil then
    FashionPanel.Instance():ShowFashionPanelWithCfgId(fashionId)
  elseif fashionItem.effectTime == -1 then
    Toast(textRes.Fashion[23])
  else
    local currentLeftTime = FashionUtils.ConvertSecondToSentence(fashionData.haveFashionInfo[fashionId])
    local nextLeftTime = FashionUtils.ConvertSecondToSentence(Int64.add(fashionData.haveFashionInfo[fashionId], fashionItem.effectTime * 3600))
    CommonConfirmDlg.ShowConfirmCoundDown("", string.format(textRes.Fashion[24], currentLeftTime, nextLeftTime), "", "", 0, 10, function(selection, tag)
      if selection == 1 then
        FashionModule._CExtendFashionDressTime(fashionId)
      end
    end, nil)
  end
end
def.static("number")._CExtendFashionDressTime = function(cfgId)
  local itemNumber = 1
  local req = require("netio.protocol.mzm.gsp.fashiondress.CExtendFashionDressTime").new(cfgId, itemNumber)
  gmodule.network.sendProtocol(req)
end
def.static("table")._OnExtendFashionDressTimeSuccess = function(p)
  FashionData.Instance().haveFashionInfo[p.fashionDressCfgId] = p.leftTime
  local fashionItem = FashionUtils.GetFashionItemDataById(p.fashionDressCfgId)
  Toast(string.format(textRes.Fashion[25], fashionItem.fashionDressName, FashionUtils.ConvertSecondToSentence(p.leftTime)))
end
def.static("table")._OnSFashionDressNormalFailed = function(p)
  if textRes.Fashion.SFashionDressNormalFailed[p.result] ~= nil then
    Toast(textRes.Fashion.SFashionDressNormalFailed[p.result])
  else
    Toast(textRes.Fashion[38])
  end
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionOperateFailed, nil)
end
def.static().GotoDyeNPC = function()
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.FashionDressConsts.dyeNpcId
  })
end
def.static("table")._OnFashionDressExpired = function(p)
  local fashionData = FashionData.Instance()
  local isCurrentFashionExpired = fashionData:IsSameWithCurrentFashion(p.fashionDressCfgId)
  fashionData:SetFashionExpired(p.fashionDressCfgId)
  local fashionItem = FashionUtils.GetFashionItemDataById(p.fashionDressCfgId)
  Toast(string.format(textRes.Fashion[17], fashionItem.fashionDressName))
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionExpired, {
    p.fashionDressCfgId
  })
  if isCurrentFashionExpired then
    Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.DressFashionChanged, nil)
  end
end
def.static("table")._OnSSyncThemeFashionDressInfo = function(p)
  FashionData.Instance():SyncThemeFashionDressInfo(p)
  local status = FashionData.Instance():GetThemeFashionUnlockStatus()
  for themeFashionCfgId, data in pairs(status) do
    if FashionModule.Instance():IsThemeFashionHasFullUnlockNotify(themeFashionCfgId) then
      FashionModule.Instance():SetThemeFashionFullUnlockNotify(themeFashionCfgId, data.isFullUnlock)
    end
    local notifyAwardIndex = FashionModule.Instance():GetThemeFashionAwardNotifyData(themeFashionCfgId)
    if notifyAwardIndex > data.awardIndex then
      FashionModule.Instance():RemoveThemeFashionAwardNotify(themeFashionCfgId)
    end
  end
  FashionModule.Instance():CheckLimitedThemeFashionNotify()
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, nil)
end
def.static("table")._OnSSyncThemeFashionDressUpdateInfo = function(p)
  local oldStatus = FashionData.Instance():GetThemeFashionUnlockStatus()
  FashionData.Instance():SyncThemeFashionDressUpdateInfo(p)
  local newStatus = FashionData.Instance():GetThemeFashionUnlockStatus()
  for themeFahionId, old in pairs(oldStatus) do
    local new = newStatus[themeFahionId]
    if new then
      if old.awardIndex < new.awardIndex then
        FashionModule.Instance():SetThemeFashionAwardNotify(new.id, new.awardIndex)
      end
      if not old.isFullUnlock and new.isFullUnlock then
        FashionModule.Instance():SetThemeFashionFullUnlockNotify(new.id, true)
        FashionModule.Instance():PlayThemeFashionFullUnlockEffect(new.id)
      end
    end
  end
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, nil)
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.ThemeFashionChanged, nil)
end
local fullUnlockKey = "ThemeFashionFullUnlock_"
def.method("number", "boolean").SetThemeFashionFullUnlockNotify = function(self, themeFashionCfgId, isNotify)
  local storageKey = fullUnlockKey .. themeFashionCfgId
  if isNotify then
    LuaPlayerPrefs.SetRoleString(storageKey, "1")
  elseif LuaPlayerPrefs.HasRoleKey(storageKey) then
    LuaPlayerPrefs.DeleteRoleKey(storageKey)
  end
end
def.method("number", "=>", "boolean").IsThemeFashionHasFullUnlockNotify = function(self, themeFashionCfgId)
  local storageKey = fullUnlockKey .. themeFashionCfgId
  return LuaPlayerPrefs.HasRoleKey(storageKey)
end
local awardKey = "ThemeFashionAward_"
def.method("number", "number").SetThemeFashionAwardNotify = function(self, themeFashionCfgId, awardIndex)
  local storageKey = awardKey .. themeFashionCfgId
  LuaPlayerPrefs.SetRoleInt(storageKey, awardIndex)
end
def.method("number", "=>", "number").GetThemeFashionAwardNotifyData = function(self, themeFashionCfgId)
  local storageKey = awardKey .. themeFashionCfgId
  if LuaPlayerPrefs.HasRoleKey(storageKey) then
    return LuaPlayerPrefs.GetRoleInt(storageKey)
  end
  return 0
end
def.method("number", "=>", "boolean").IsThemeFashionHasAwardNotify = function(self, themeFashionCfgId)
  local storageKey = awardKey .. themeFashionCfgId
  return LuaPlayerPrefs.HasRoleKey(storageKey)
end
def.method("number").RemoveThemeFashionAwardNotify = function(self, themeFashionCfgId)
  local storageKey = awardKey .. themeFashionCfgId
  if LuaPlayerPrefs.HasRoleKey(storageKey) then
    LuaPlayerPrefs.DeleteRoleKey(storageKey)
  end
end
def.method("number").PlayThemeFashionFullUnlockEffect = function(self, themeFashionCfgId)
  local themeFashionCfg = FashionUtils.GetThemeFashionCfgById(themeFashionCfgId)
  if themeFashionCfg ~= nil then
    local effectId = themeFashionCfg.fullEffectId
    if effectId ~= 0 then
      local effectCfg = _G.GetEffectRes(effectId)
      if nil == effectCfg then
        warn("theme fashion effet cfg is nil id = " .. effectId)
        return
      end
      local GUIFxMan = require("Fx.GUIFxMan")
      GUIFxMan.Instance():Play(effectCfg.path, "ThemeFashionFullUnlock", 0, 0, 5, false)
    end
  end
end
def.method("=>", "boolean").IsFashionModuleHasNotify = function(self)
  if FashionModule.Instance():IsThemeFashionHasNotify() then
    return true
  end
  if FashionModule.Instance():IsLimitedThemeFashionHasNotify() then
    return true
  end
  if require("Main.Aircraft.AircraftModule").Instance():NeedReddot() then
    return true
  end
  return false
end
def.method("=>", "boolean").IsThemeFashionHasNotify = function(self)
  if FashionModule.Instance():IsThemeFashionFunctionOpen() then
    local status = FashionData.Instance():GetThemeFashionUnlockStatus()
    for themeFashionCfgId, data in pairs(status) do
      local fullUnlock = fullUnlockKey .. themeFashionCfgId
      if LuaPlayerPrefs.HasRoleKey(fullUnlock) then
        return true
      end
      local award = awardKey .. themeFashionCfgId
      if LuaPlayerPrefs.HasRoleKey(award) then
        return true
      end
    end
  end
  return false
end
def.static("table", "table")._OnNewDay = function(params, context)
  FashionModule.Instance():CheckLimitedThemeFashionNotify()
end
def.method().CheckLimitedThemeFashionNotify = function(self)
  local preCfgId = self:GetLastLimitedThemeFashionCfgData()
  local curCfg = FashionUtils.GetNowLimitedThemeFashionCfg()
  local curCfgId = curCfg and curCfg.id or 0
  if curCfgId ~= 0 and curCfgId ~= preCfgId then
    self:SetLimitedThemeFashionNotify(true)
  else
    self:SetLastLimitedThemeFashionCfgData(curCfgId)
    self:SetLimitedThemeFashionNotify(false)
  end
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, nil)
end
local limitedCfgKey = "LimitedThemeFashionCfg"
def.method("number").SetLastLimitedThemeFashionCfgData = function(self, cfgId)
  LuaPlayerPrefs.SetRoleInt(limitedCfgKey, cfgId)
end
def.method("=>", "number").GetLastLimitedThemeFashionCfgData = function(self)
  if LuaPlayerPrefs.HasRoleKey(limitedCfgKey) then
    return LuaPlayerPrefs.GetRoleInt(limitedCfgKey)
  end
  return 0
end
local limitedNotifyKey = "LimitedThemeFashionNotify"
def.method("boolean").SetLimitedThemeFashionNotify = function(self, isNotify)
  if isNotify then
    LuaPlayerPrefs.SetRoleString(limitedNotifyKey, "1")
  elseif LuaPlayerPrefs.HasRoleKey(limitedNotifyKey) then
    LuaPlayerPrefs.DeleteRoleKey(limitedNotifyKey)
  end
end
def.method("=>", "boolean").IsLimitedThemeFashionHasNotify = function(self)
  if self:IsThemeFashionFunctionOpen() and _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_TIME_LIMITED_THEME_FASHION_DRESS) then
    return LuaPlayerPrefs.HasRoleKey(limitedNotifyKey)
  end
  return false
end
def.static("table", "table")._OnEnterWorld = function(params, context)
  instance:_StartFashionTimer()
end
def.static("table", "table")._OnLeaveWorld = function(params, context)
  instance:_StopFashionTimer()
  FashionData.Instance():ClearData()
end
def.method("=>", "boolean").IsFashionFunctionOpen = function(self)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_FASHION_DRESS) then
    return false
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local myLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  local unlockLevel = constant.FashionDressConsts.openLevel
  if myLv < unlockLevel then
    return false
  end
  return true
end
def.method("=>", "boolean").IsThemeFashionFunctionOpen = function(self)
  if not self:IsFashionFunctionOpen() then
    return false
  end
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_THEME_FASHION_DRESS) then
    return false
  end
  return true
end
def.method()._StartFashionTimer = function(self)
  self._timerId = GameUtil.AddGlobalTimer(60, false, function()
    FashionData.Instance():ReduceFashionLeftTime()
    Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionLeftTimeChange, nil)
  end)
end
def.method()._StopFashionTimer = function(self)
  GameUtil.RemoveGlobalTimer(self._timerId)
end
def.method("number", "=>", "boolean").IsFashionIDIPOpen = function(self, fashionDressType)
  local IDIPInterface = require("Main.IDIP.IDIPInterface")
  local ItemSwitchInfo = require("netio.protocol.mzm.gsp.idip.ItemSwitchInfo")
  local isOpen = IDIPInterface.IsItemIDIPOpen(ItemSwitchInfo.FASHION, fashionDressType)
  return isOpen
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p1.feature == ModuleFunSwitchInfo.TYPE_FASHION_DRESS or p1.feature == ModuleFunSwitchInfo.TYPE_THEME_FASHION_DRESS or p1.feature == ModuleFunSwitchInfo.TYPE_TIME_LIMITED_THEME_FASHION_DRESS then
    Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, nil)
  end
end
FashionModule.Commit()
return FashionModule
