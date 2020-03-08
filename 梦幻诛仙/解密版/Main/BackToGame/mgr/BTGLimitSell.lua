local Lplus = require("Lplus")
local BTGLimitSell = Lplus.Class("BTGLimitSell")
local BackToGameUtils = require("Main.BackToGame.BackToGameUtils")
local BackGameGiftRefreshType = require("consts.mzm.gsp.activity3.confbean.BackGameGiftRefreshType")
local ItemModule = require("Main.Item.ItemModule")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = BTGLimitSell.define
local instance
def.static("=>", BTGLimitSell).Instance = function()
  if instance == nil then
    instance = BTGLimitSell()
  end
  return instance
end
def.field("number").m_cfgId = 0
def.field("table").m_goodsBuyTimes = nil
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SBuyBackGameGiftSuccess", BTGLimitSell.OnSBuyBackGameGiftSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SBuyBackGameGiftFail", BTGLimitSell.OnSBuyBackGameGiftFail)
end
def.method("table", "number").SetData = function(self, bean, cfgId)
  self.m_cfgId = cfgId
  self.m_goodsBuyTimes = {}
  for k, v in pairs(bean.gift_buy_count) do
    self.m_goodsBuyTimes[k] = v
  end
end
def.method().Clear = function(self)
  self.m_cfgId = 0
  self.m_goodsBuyTimes = nil
end
def.method().NewDay = function(self)
  if self.m_cfgId > 0 and self.m_goodsBuyTimes then
    for k, v in pairs(self.m_goodsBuyTimes) do
      local cfg = BackToGameUtils.GetLimitSellItemCfg(k)
      if cfg.refreshType == BackGameGiftRefreshType.DAILY then
        self.m_goodsBuyTimes[k] = 0
      end
    end
    Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.LimitSellUpdate, nil)
  end
end
def.static("table").OnSBuyBackGameGiftSuccess = function(p)
  local self = BTGLimitSell.Instance()
  if self.m_goodsBuyTimes then
    local num = self.m_goodsBuyTimes[p.gift_id] or 0
    self.m_goodsBuyTimes[p.gift_id] = num + p.buy_count
    Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.LimitSellUpdate, nil)
    Toast(textRes.BackToGame.LimitSell[1])
  end
end
def.static("table").OnSBuyBackGameGiftFail = function(p)
  local tip = textRes.BackToGame.LimitSell.Error[p.error_code]
  if tip then
    Toast(tip)
  end
end
def.method("number", "number").Buy = function(self, cfgId, count)
  local cfg = BackToGameUtils.GetLimitSellItemCfg(cfgId)
  if cfg then
    local full = ItemModule.Instance():IsBagFullForItemId(cfg.itemId)
    if full > 0 then
      ItemModule.Instance():ToastBagFull(full)
      return
    end
    local p = require("netio.protocol.mzm.gsp.backgameactivity.CBuyBackGameGiftReq").new(cfgId, count)
    gmodule.network.sendProtocol(p)
  end
end
def.method("=>", "table").GetGoodsData = function(self)
  local charge = ItemModule.Instance():GetYuanbao(ItemModule.CASH_SAVE_AMT)
  local tier = {}
  local cfg = BackToGameUtils.GetLimitSellCfg(self.m_cfgId)
  for k, v in ipairs(cfg.tier) do
    if charge >= Int64.new(v.needRecharge) then
      local goods = {}
      for k1, v1 in ipairs(v.goods) do
        local g = clone(v1)
        g.times = self:GetBuyTimes(v1.id)
        table.insert(goods, g)
      end
      table.insert(tier, goods)
    end
  end
  return tier
end
def.method("number", "=>", "number").GetBuyTimes = function(self, cfgId)
  return self.m_goodsBuyTimes[cfgId] or 0
end
def.method("=>", "boolean").IsRed = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_BUY_GIFT)
  if open then
    return false
  else
    return false
  end
end
BTGLimitSell.Commit()
return BTGLimitSell
