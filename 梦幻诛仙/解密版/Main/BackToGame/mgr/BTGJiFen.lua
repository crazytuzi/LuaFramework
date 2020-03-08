local Lplus = require("Lplus")
local BTGJiFen = Lplus.Class("BTGJiFen")
local BackToGameUtils = require("Main.BackToGame.BackToGameUtils")
local ActivityInterface = require("Main.activity.ActivityInterface")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ItemModule = require("Main.Item.ItemModule")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local def = BTGJiFen.define
local instance
def.static("=>", BTGJiFen).Instance = function()
  if instance == nil then
    instance = BTGJiFen()
  end
  return instance
end
def.field("number").m_cfgId = 0
def.field("table").m_relatedActivity = nil
def.field("boolean").m_isViewedJifen = false
def.method().Init = function(self)
  Event.RegisterEventWithContext(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, BTGJiFen.OnActivityUpdate, self)
end
def.method("table").OnActivityUpdate = function(self, param)
  if self.m_cfgId > 0 then
    local actId = param[1]
    if actId == nil then
      return
    end
    if self.m_relatedActivity and self.m_relatedActivity[self.m_cfgId] then
      local actIds = self.m_relatedActivity[self.m_cfgId]
      if actIds[actId] then
        Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ActivityUpdate, nil)
      end
    else
      local actIds = BackToGameUtils.GetRelatedActivityIds(self.m_cfgId)
      if actIds then
        self.m_relatedActivity = {}
        self.m_relatedActivity[self.m_cfgId] = actIds
        if actIds[actId] then
          Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ActivityUpdate, nil)
        end
      end
    end
  end
end
def.method("number").SetData = function(self, cfgId)
  self.m_cfgId = cfgId
end
def.method().Clear = function(self)
  self.m_cfgId = 0
  self.m_relatedActivity = nil
  self.m_isViewedJifen = false
end
def.method().NewDay = function(self)
  if self.m_cfgId > 0 then
    Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ActivityUpdate, nil)
  end
end
def.method("=>", "number").GetTipsId = function(self)
  return BackToGameUtils.GetJifenTipsId(self.m_cfgId)
end
def.method("=>", "table", "table").GetActivityAndJifenData = function(self)
  local BackToGameModule = require("Main.BackToGame.BackToGameModule")
  local startDay = BackToGameUtils.MsToDay(BackToGameModule.Instance():GetJoinTime())
  local curDay = BackToGameUtils.SecToDay(GetServerTime())
  local day = curDay - startDay + 1
  local cfg = BackToGameUtils.GetJifenCfg(self.m_cfgId, day)
  local activityData = {}
  local curJifen = 0
  for k, v in ipairs(cfg.activity) do
    local actCfg = ActivityInterface.GetActivityCfgById(v.activityId)
    if actCfg then
      local name = actCfg.activityName
      local icon = actCfg.activityIcon
      local times = v.activityMaxCount
      local point = v.pointCountEachRun
      local actInfo = ActivityInterface.Instance():GetActivityInfo(v.activityId)
      local count = actInfo and actInfo.count or 0
      table.insert(activityData, {
        activityId = v.activityId,
        name = name,
        icon = icon,
        times = times,
        point = point,
        count = count
      })
    end
  end
  local items = {}
  for k, v in ipairs(cfg.items) do
    table.insert(items, {
      itemId = v.showItemId
    })
  end
  return activityData, items
end
def.method("=>", "boolean").IsRed = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_POINT)
  if open then
    local hasJifenNotify = self:HasJifenNotify()
    return hasJifenNotify
  else
    return false
  end
end
def.method("boolean").MarkViewedJifen = function(self, b)
  local value = ItemModule.Instance():GetCredits(TokenType.BACK_GAME_ACTIVITY_POINT) or Int64.new(0)
  if not Int64.gt(value, 0) then
    return
  end
  if self.m_isViewedJifen ~= b then
    self.m_isViewedJifen = b
    Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ActivityUpdate, nil)
  end
end
def.method("=>", "boolean").HasJifenNotify = function(self)
  local value = ItemModule.Instance():GetCredits(TokenType.BACK_GAME_ACTIVITY_POINT) or Int64.new(0)
  if not Int64.gt(value, 0) then
    return false
  end
  return not self.m_isViewedJifen
end
def.method().GoToExchangeShop = function(self)
  local activityId = gmodule.moduleMgr:GetModule(ModuleId.BACK_TO_GAME).m_activityId
  gmodule.moduleMgr:GetModule(ModuleId.TOKEN_MALL):OpenTokenMallByActivityId(activityId)
end
BTGJiFen.Commit()
return BTGJiFen
