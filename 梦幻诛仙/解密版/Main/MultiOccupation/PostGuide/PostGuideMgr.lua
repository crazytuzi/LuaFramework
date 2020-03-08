local FILE_NAME = (...)
local Lplus = require("Lplus")
local PostGuideMgr = Lplus.Class(FILE_NAME)
local Cls = PostGuideMgr
local def = Cls.define
local instance
local GuideTypes = require("consts.mzm.gsp.guide.confbean.ConType")
def.const("table").GUIDETYPES = GuideTypes
def.field("table")._guideCfgReaders = nil
def.field("table")._guideRunInfo = nil
def.field("boolean")._bSetNotSendGuide = false
def.field("function")._pnlCreatCallback = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, Cls.OnNewDay)
  Event.RegisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.OccupationChange, Cls.OnOccupationChg)
  Event.RegisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.OccupationChange, Cls.OnOccupationChg)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, Cls.OnHeroLvUp)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, Cls.OnEnterWorld)
end
def.method("=>", "table").GetGuideCfgReaders = function(self)
  if self._guideCfgReaders == nil then
    local Utils = require("Main.MultiOccupation.PostGuide.Utils")
    self._guideCfgReaders = {
      [GuideTypes.MULTI_OCCUP__JIADIAN] = Utils.GetJiaDainGuideIds,
      [GuideTypes.MULTI_OCCUP__EQUIP] = Utils.GetEquipGuideIds,
      [GuideTypes.MULTI_OCCUP__TIANSHU] = Utils.GetTianShuGuideIds,
      [GuideTypes.MULTI_OCCUP__LONGJING] = Utils.GetLongJingGuideIds,
      [GuideTypes.MULTI_OCCUP__LINGSHI] = Utils.GetLingShiGuideIds,
      [GuideTypes.MULTI_OCCUP__WING] = Utils.GetWingGuideIds
    }
  end
  if _G.GetHeroProp().level <= 99 then
    self._guideCfgReaders[GuideTypes.MULTI_OCCUP__LINGSHI] = nil
  end
  return self._guideCfgReaders
end
def.method("number", "=>", "function").GetGuideCfgReaderByType = function(self, guideType)
  local mapReaders = self:GetGuideCfgReaders()
  return mapReaders[guideType]
end
def.method("number", "=>", "boolean").IsGuideDone = function(self, guideType)
  local guideInfo = self:GetGuideRunInfo()
  return guideInfo[guideType] or false
end
local PKEY_PREFIX = "POSTGUIDE_"
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
def.method("number", "boolean").SetGuideState = function(self, guideType, bRun)
  local guideInfo = self:GetGuideRunInfo()
  guideInfo[guideType] = bRun
  local key = string.format("%s%d", PKEY_PREFIX, guideType)
  if bRun then
    warn("key", key)
    LuaPlayerPrefs.SetRoleInt(key, 1)
  else
    LuaPlayerPrefs.DeleteRoleKey(key)
  end
end
def.method().ResetGuideState = function(self)
  local guideReaders = self:GetGuideCfgReaders()
  if self._guideRunInfo == nil then
    self._guideRunInfo = {}
  end
  for guideType, _ in pairs(guideReaders) do
    local key = string.format("%s%d", PKEY_PREFIX, guideType)
    self._guideRunInfo[guideType] = false
    LuaPlayerPrefs.DeleteRoleKey(key)
  end
end
local CLOSE_KEY = PKEY_PREFIX .. "CloseSys"
def.method("boolean").SetCloseGuideSys = function(self, bOpen)
  if bOpen then
    LuaPlayerPrefs.SetRoleInt(CLOSE_KEY, 1)
  else
    LuaPlayerPrefs.DeleteRoleKey(CLOSE_KEY)
  end
end
def.method("=>", "boolean").IsCloseGuideSys = function(self)
  local bHasKey = LuaPlayerPrefs.HasRoleKey(CLOSE_KEY)
  return bHasKey
end
def.method("=>", "table").GetGuideRunInfo = function(self)
  if self._guideRunInfo == nil then
    local guideReaders = self:GetGuideCfgReaders()
    self._guideRunInfo = {}
    for guideType, _ in pairs(guideReaders) do
      local key = string.format("%s%d", PKEY_PREFIX, guideType)
      local bHasKey = LuaPlayerPrefs.HasRoleKey(key)
      self._guideRunInfo[guideType] = bHasKey
    end
  end
  return self._guideRunInfo
end
def.method("=>", "boolean").IsAllGuideDone = function(self)
  local guideRuninfo = self:GetGuideRunInfo()
  for guideType, isDone in pairs(guideRuninfo) do
    if not isDone then
      return false
    end
  end
  return true
end
def.static("number").StartGuide = function(guideType)
  local self = instance
  self:addNotSendGuide()
  local GuideModule = require("Main.Guide.GuideModule")
  local readers = self:GetGuideCfgReaders()
  local reader = readers[guideType]
  if reader == nil then
    warn(string.format("[ERROR: GUIDE READER %d NOT EXIST]", guideType))
    return
  end
  local guideids = reader()
  local function funcGuide()
    self:SetGuideState(guideType, true)
    if self:IsAllGuideDone() then
      Event.DispatchEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.RedPtNotifyChg, nil)
    end
    GuideModule.Instance():RetryGuides(guideids)
  end
  local function funcOpenPnlGuide(pnl, cb)
    if pnl:IsShow() then
      cb()
    else
      self:SetPnlCreateGuide(cb)
      pnl:ShowPanel()
    end
  end
  if guideType == Cls.GUIDETYPES.MULTI_OCCUP__JIADIAN then
    local pnl = require("Main.Hero.ui.HeroAssignPropPanel").Instance()
    funcOpenPnlGuide(pnl, funcGuide)
  elseif guideType == Cls.GUIDETYPES.MULTI_OCCUP__EQUIP then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_BAG_CLICK, nil)
    funcGuide()
  elseif guideType == Cls.GUIDETYPES.MULTI_OCCUP__TIANSHU then
    if _G.IsCrossingServer() then
      ToastCrossingServerForbiden()
      return
    end
    local pnl = require("Main.Oracle.ui.DlgOracle")
    if pnl.Instance():IsShow() then
      funcGuide()
    else
      self:SetPnlCreateGuide(funcGuide)
      pnl.ShowDlg()
    end
  elseif guideType == Cls.GUIDETYPES.MULTI_OCCUP__WING then
    if not require("Main.Wing.WingModule").Instance():IsWingSetup() then
      return
    end
    local pnl = require("Main.Wing.ui.WingPanel")
    if pnl.Instance():IsShow() then
      funcGuide()
    else
      self:SetPnlCreateGuide(funcGuide)
      pnl.ShowWingPanel(-1)
    end
  elseif guideType == Cls.GUIDETYPES.MULTI_OCCUP__LINGSHI then
    self:GotoNpcAndGuide(constant.SuperEquipmentJewelConstants.TRANSFER_NPC_ID, function()
      funcGuide()
    end)
  elseif guideType == Cls.GUIDETYPES.MULTI_OCCUP__LONGJING then
    local FabaoUtils = require("Main.Fabao.FabaoUtils")
    local npcId, serviceId = FabaoUtils.GetLJTranformNpcIdAndServiceId()
    self:GotoNpcAndGuide(npcId, function()
      funcGuide()
    end)
  else
    funcGuide()
  end
end
def.method("number", "function").GotoNpcAndGuide = function(self, npcId, callback)
  callback()
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {npcId})
end
def.method().addNotSendGuide = function(self)
  if not self._bSetNotSendGuide then
    local GuideModule = require("Main.Guide.GuideModule")
    local readers = self:GetGuideCfgReaders()
    for guideType, reader in pairs(readers) do
      GuideModule.AddNotSendGuide(guideType)
    end
    self._bSetNotSendGuide = true
  end
end
def.method().removeNotSendGuide = function(...)
  local GuideModule = require("Main.Guide.GuideModule")
  local readers = self:GetGuideCfgReaders()
  for guideType, reader in pairs(readers) do
    GuideModule.RemoveNotSendGuide(guideType)
  end
  self._bSetNotSendGuide = false
end
def.method("function").SetPnlCreateGuide = function(self, cb)
  if self._pnlCreatCallback == nil then
    Event.RegisterEventWithContext(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostCreate, Cls.OnPnlFirstCreated, self)
    self._pnlCreatCallback = cb
  end
end
def.static("=>", "boolean").IsShowGuideEntry = function()
  local result = _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MULTI_OCCUP_GUIDE)
  if not result then
    return false
  end
  if instance:IsCloseGuideSys() then
    return false
  end
  return instance:IsInGuideDate()
end
def.method("=>", "boolean").IsInGuideDate = function(self)
  local data = require("Main.MultiOccupation.MultiOccupationModule").Instance().data
  if data:getOwnOccupationCount() < 2 then
    return false
  end
  local timeNow = _G.GetServerTime()
  local activeTime = data:getActivateTime()
  if activeTime ~= 0 and _G.DiffDays(activeTime, timeNow) <= constant.CMultiOccupConsts.GuideDays then
    return true
  end
  local switchTime = data:getSwitchTime()
  if switchTime ~= 0 and _G.DiffDays(switchTime, timeNow) <= constant.CMultiOccupConsts.GuideDays then
    return true
  end
  return false
end
def.method("table").OnPnlFirstCreated = function(self, p)
  Event.UnregisterEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostCreate, Cls.OnPnlFirstCreated)
  if self._pnlCreatCallback then
    self._pnlCreatCallback()
    self._pnlCreatCallback = nil
  end
end
def.static("table", "table").OnNewDay = function(p, c)
  local self = instance
  if not self:IsInGuideDate() then
    Event.DispatchEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.GuideOpenChange, nil)
  end
end
def.static("table", "table").OnOccupationChg = function(p, c)
  local self = instance
  self:SetCloseGuideSys(false)
  self:ResetGuideState()
  Event.DispatchEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.GuideOpenChange, nil)
end
def.static("table", "table").OnHeroLvUp = function(p, c)
  instance._guideCfgReaders = nil
  instance._guideRunInfo = nil
  Event.DispatchEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.POSTGUIDE_LIST_CHG, nil)
end
def.static("table", "table").OnEnterWorld = function(p, c)
  _G.GameUtil.AddGlobalTimer(3, true, function()
    Event.DispatchEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.GuideOpenChange, nil)
  end)
end
return Cls.Commit()
