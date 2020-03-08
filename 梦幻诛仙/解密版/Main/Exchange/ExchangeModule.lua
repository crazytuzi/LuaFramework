local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ExchangeModule = Lplus.Extend(ModuleBase, "ExchangeModule")
local ExchangeInterface = require("Main.Exchange.ExchangeInterface")
local exchangeInterface = ExchangeInterface.Instance()
local def = ExchangeModule.define
local instance
def.static("=>", ExchangeModule).Instance = function()
  if instance == nil then
    instance = ExchangeModule()
    instance.m_moduleId = ModuleId.EXCHANGE
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.exchange.SSyncExchangeInfo", ExchangeModule.OnSSyncExchangeInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.exchange.SExchangeAwardSuccess", ExchangeModule.OnSExchangeAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.exchange.SExchangeAwardFail", ExchangeModule.OnSExchangeAwardFail)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, ExchangeModule.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, ExchangeModule.OnActivityEnd)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ExchangeModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, ExchangeModule.OnActivityTodo)
  require("Main.Exchange.NpcExchangeMgr").Instance():Init()
end
def.override().OnReset = function(self)
  exchangeInterface:Reset()
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1[1]
  local activityIdList = exchangeInterface:getAllExchangeActivity()
  for _, v in pairs(activityIdList) do
    if v == activityId then
      instance:ShowExchangePanel()
      break
    end
  end
end
def.static("table", "table").OnActivityStart = function(p1, p2)
  local allExchangeId = exchangeInterface:getAllExchangeActivity()
  local openActivityId = p1[1]
  for i, v in ipairs(allExchangeId) do
    if openActivityId == v then
      exchangeInterface:setExchangeInfos(openActivityId, {})
    end
  end
end
def.static("table", "table").OnActivityEnd = function(p1, p2)
  exchangeInterface:removeExchangeActivity(p1[1])
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if Feature.TYPE_COMMON_EXCHANGE == p1.feature then
    local activitMain = require("Main.activity.ui.ActivityMain").Instance()
    if activitMain:IsShow() then
      activitMain:setExchangeDisplay()
    end
    if not p1.open then
      local exchangePanel = require("Main.Exchange.ui.ExchangePanel").Instance()
      if exchangePanel:IsShow() then
        exchangePanel:HidePanel()
      end
    end
  end
end
def.static("table").OnSSyncExchangeInfo = function(p)
  for i, v in pairs(p.exchange_activity_infos) do
    exchangeInterface:setExchangeInfos(i, v.exchange_award_infos)
  end
end
def.static("table").OnSExchangeAwardSuccess = function(p)
  exchangeInterface:setExchangeNum(p.activity_cfg_id, p.sort_id, p.already_exchange_times)
  Event.DispatchEvent(ModuleId.EXCHANGE, gmodule.notifyId.Exchange.EXCHANGE_SUCCESS, {
    p.activity_cfg_id,
    p.sort_id
  })
end
def.static("table").OnSExchangeAwardFail = function(p)
  warn("-------OnSExchangeAwardFail:", p.res)
end
def.method().ShowExchangePanel = function()
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isOpen = feature:CheckFeatureOpen(Feature.TYPE_COMMON_EXCHANGE)
  if isOpen then
    require("Main.Exchange.ui.ExchangePanel").Instance():ShowPanel()
  end
end
return ExchangeModule.Commit()
