local Lplus = require("Lplus")
local NpcExchangeMgr = Lplus.Class("NpcExchangeMgr")
local def = NpcExchangeMgr.define
local instance
def.field("table").exchangeInfos = nil
def.static("=>", NpcExchangeMgr).Instance = function()
  if instance == nil then
    instance = NpcExchangeMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SSynRoleExchangeUseItemInfo", NpcExchangeMgr.OnSSynRoleExchangeUseItemInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SExchangeUseItemRes", NpcExchangeMgr.OnSExchangeUseItemRes)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, NpcExchangeMgr.OnNewDay)
end
def.static("table").OnSSynRoleExchangeUseItemInfo = function(p)
  warn("-------OnSSynRoleExchangeUseItemInfo>>>>>")
  instance.exchangeInfos = p.role_exchange_use_item_infos
end
def.static("table").OnSExchangeUseItemRes = function(p)
  warn("------>>>>> OnSExchangeUseItemRes:", p.exchangecfgid, p.exchangecount)
  instance:addExchangeTimes(p.exchangecfgid, p.exchangecount)
end
def.static("table", "table").OnNewDay = function(p1, p2)
  if instance and instance.exchangeInfos then
    for i, v in pairs(instance.exchangeInfos) do
      v.daily_exchange_times = 0
    end
  end
end
def.method("number", "number").addExchangeTimes = function(self, exchangeId, num)
  local ItemUtils = require("Main.Item.ItemUtils")
  local exchangeItemCfg = ItemUtils.GetExchangeItemCfg(exchangeId)
  local dailyMaxNum = exchangeItemCfg.dailyExchangeTimesLimit
  local maxExchangeNum = exchangeItemCfg.exchangeTimesLimit
  self.exchangeInfos = self.exchangeInfos or {}
  local info = self.exchangeInfos[exchangeId] or {}
  if dailyMaxNum > 0 then
    local dailyNum = info.daily_exchange_times or 0
    dailyNum = dailyNum + num
    info.daily_exchange_times = dailyNum
  end
  if maxExchangeNum > 0 then
    local exchangeNum = info.exchange_times or 0
    exchangeNum = exchangeNum + num
    info.exchange_times = exchangeNum
  end
  self.exchangeInfos[exchangeId] = info
end
def.method("number", "=>", "number").getTodayExchangeTimes = function(self, exchangeId)
  if self.exchangeInfos and self.exchangeInfos[exchangeId] then
    return self.exchangeInfos[exchangeId].daily_exchange_times or 0
  end
  return 0
end
def.method("number", "=>", "number").getExchangeTimes = function(self, exchangeId)
  if self.exchangeInfos and self.exchangeInfos[exchangeId] then
    return self.exchangeInfos[exchangeId].exchange_times or 0
  end
  return 0
end
return NpcExchangeMgr.Commit()
