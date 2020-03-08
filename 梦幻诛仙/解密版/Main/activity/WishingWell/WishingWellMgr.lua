local Lplus = require("Lplus")
local WishingWellData = require("Main.activity.WishingWell.data.WishingWellData")
local ActivityInterface = require("Main.activity.ActivityInterface")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ItemModule = require("Main.Item.ItemModule")
local WishingWellMgr = Lplus.Class("WishingWellMgr")
local def = WishingWellMgr.define
local instance
def.static("=>", WishingWellMgr).Instance = function()
  if instance == nil then
    instance = WishingWellMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEventWithContext(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, WishingWellMgr.OnActivityTodo, self)
  Event.RegisterEventWithContext(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, WishingWellMgr.OnNPCService, self)
  Event.RegisterEventWithContext(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, WishingWellMgr.OnLeaveWorld, self)
  Event.RegisterEventWithContext(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, WishingWellMgr.OnNewDay, self)
  Event.RegisterEventWithContext(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, WishingWellMgr.OnEnterWorld, self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, WishingWellMgr.OnFunctionOpenChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_Wish, WishingWellMgr.OnUseWishItem, self)
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local open = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BLESS)
  return open
end
def.method("number", "boolean", "=>", "boolean").IsActivityOpen = function(self, activityId, bToast)
  local bLevelValid = true
  local myLevel = _G.GetHeroProp().level
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  if activityCfg == nil then
    warn("[WishingWellMgr:IsActivityOpen] activityCfg nil for activityId:", activityId)
  else
    bLevelValid = myLevel >= activityCfg.levelMin and myLevel <= activityCfg.levelMax
    if false == bLevelValid and bToast then
      Toast(textRes.WishingWell.LEVEL_INVALID)
    end
  end
  local bActivityOpen = ActivityInterface.Instance():isActivityOpend(activityId)
  if false == bActivityOpen and bToast then
    Toast(textRes.WishingWell.ACTIVITY_CLOSED)
  end
  return bLevelValid and bActivityOpen
end
def.method("table").OnEnterWorld = function(self, param)
  self:_CheckOpenState()
end
def.method("table").OnActivityTodo = function(self, param)
  if not self:IsFeatureOpen() then
    return
  end
  local npcId = WishingWellData.Instance():GetNpcId(param[1])
  if npcId > 0 then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
  else
    warn("[WishingWellMgr:OnActivityTodo] find no NPC for type:", activityId)
  end
end
def.method("table").OnNPCService = function(self, param)
  local srvcId = param[1]
  local npcId = param[2]
  local type = WishingWellData.Instance():GetTypeByServiceId(srvcId)
  if type > 0 then
    if not self:IsFeatureOpen() then
      warn("[WishingWellMgr:OnNPCService] feature not open!")
      return
    end
    require("Main.activity.WishingWell.ui.DlgWishingWell").ShowDlg(type)
  else
  end
end
def.method("table").OnLeaveWorld = function(self, p1)
  WishingWellData.Instance():Reset()
end
def.method("table").OnNewDay = function(self, p1)
  WishingWellData.Instance():OnNewDay()
end
def.method("table").OnFunctionOpenChange = function(self, p1)
  if p1.feature == ModuleFunSwitchInfo.TYPE_BLESS then
    warn("[WishingWellMgr:OnFunctionOpenChange] ModuleFunSwitchInfo.TYPE_BLESS open change.")
    self:_CheckOpenState()
  end
end
def.method()._CheckOpenState = function(self)
  for activityId, wishCfg in pairs(WishingWellData.Instance():GetWishingMap()) do
    if not self:IsFeatureOpen() then
      ActivityInterface.Instance():addCustomCloseActivity(activityId)
    else
      ActivityInterface.Instance():removeCustomCloseActivity(activityId)
    end
  end
end
def.method("table").OnUseWishItem = function(self, params)
  warn("[WishingWellMgr:OnUseWishItem] on event Item_Use_Wish.")
  if not self:IsFeatureOpen() then
    Toast(textRes.WishingWell.ACTIVITY_CLOSED)
    return
  end
  local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(params.bagId, params.itemKey)
  if nil == itemInfo then
    warn("[WishingWellMgr:OnUseWishItem] itemInfo nil for bagId & itemKey:", params.bagId, params.itemKey)
    return
  end
  local wishMap = WishingWellData.Instance():GetWishingMap()
  local curWishCfg
  if wishMap then
    for activityId, wishCfg in pairs(wishMap) do
      if itemInfo.id == wishCfg.costItemId then
        curWishCfg = wishCfg
        break
      end
    end
  end
  if curWishCfg then
    if not self:IsActivityOpen(curWishCfg.type, true) then
      return
    end
    warn("[WishingWellMgr:OnUseWishItem] DispatchEvent Activity_GotoNPC for npc:", curWishCfg.npcId)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      curWishCfg.npcId
    })
  else
    warn("[WishingWellMgr:OnUseWishItem] wishCfg nil for costItem:", itemInfo.id)
  end
  return true
end
return WishingWellMgr.Commit()
