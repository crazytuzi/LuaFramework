local Lplus = require("Lplus")
local BTGDailySign = Lplus.Class("BTGDailySign")
local BackToGameUtils = require("Main.BackToGame.BackToGameUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = BTGDailySign.define
local instance
def.static("=>", BTGDailySign).Instance = function()
  if instance == nil then
    instance = BTGDailySign()
  end
  return instance
end
def.field("number").m_cfgId = 0
def.field("number").m_signTimes = 0
def.field("userdata").m_lastSignMs = nil
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SBackGameSignSuccess", BTGDailySign.OnSBackGameSignSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SBackGameSignFail", BTGDailySign.OnSBackGameSignFail)
end
def.method("table", "number").SetData = function(self, bean, cfgId)
  self.m_cfgId = cfgId
  self.m_signTimes = bean.sign_count
  self.m_lastSignMs = bean.last_sign_time
end
def.method().Clear = function(self)
  self.m_cfgId = 0
  self.m_signTimes = 0
  self.m_lastSignMs = nil
end
def.method().NewDay = function(self)
  if self.m_cfgId > 0 then
    Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.DailySignUpdate, nil)
  end
end
def.static("table").OnSBackGameSignSuccess = function(p)
  local self = BTGDailySign.Instance()
  if p.index == self.m_signTimes + 1 then
    self.m_signTimes = p.index
    self.m_lastSignMs = Int64.new(GetServerTime()) * 1000
    Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.DailySignUpdate, nil)
    Toast(textRes.BackToGame.Sign[1])
  end
end
def.static("table").OnSBackGameSignFail = function(p)
  local tip = textRes.BackToGame.Sign.Error[p.error_code]
  if tip then
    Toast(tip)
  end
end
def.method("number").Sign = function(self, signDay)
  local p = require("netio.protocol.mzm.gsp.backgameactivity.CBackGameSignReq").new(signDay)
  gmodule.network.sendProtocol(p)
end
def.method("=>", "table").GetSignData = function(self)
  local signCfg = BackToGameUtils.GetDailySignCfg(self.m_cfgId)
  if signCfg then
    local lastSignDay = BackToGameUtils.MsToDay(self.m_lastSignMs)
    local curDay = BackToGameUtils.SecToDay(GetServerTime())
    local signs = {}
    for k, v in ipairs(signCfg.signs) do
      local signed = k <= self.m_signTimes
      local canSign = k - self.m_signTimes == 1 and lastSignDay < curDay or false
      local item = ItemUtils.GetAwardItems(v)
      signs[k] = {
        signed = signed,
        canSign = canSign,
        item = item[1]
      }
    end
    return signs
  else
    return {}
  end
end
def.method("=>", "boolean").IsRed = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_SIGN)
  if open then
    if self.m_cfgId > 0 then
      local lastSignDay = BackToGameUtils.MsToDay(self.m_lastSignMs)
      local curDay = BackToGameUtils.SecToDay(GetServerTime())
      if lastSignDay < curDay then
        local signCfg = BackToGameUtils.GetDailySignCfg(self.m_cfgId)
        return self.m_signTimes < #signCfg.signs
      else
        return false
      end
    else
      return false
    end
  else
    return false
  end
end
BTGDailySign.Commit()
return BTGDailySign
