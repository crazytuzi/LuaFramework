local Lplus = require("Lplus")
local BTGBackHome = Lplus.Class("BTGBackHome")
local BackToGameUtils = require("Main.BackToGame.BackToGameUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local BuffUtility = require("Main.Buff.BuffUtility")
local BackGameActivityAwardInfo = require("netio.protocol.mzm.gsp.backgameactivity.BackGameActivityAwardInfo")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = BTGBackHome.define
local instance
def.static("=>", BTGBackHome).Instance = function()
  if instance == nil then
    instance = BTGBackHome()
  end
  return instance
end
def.field("number").m_cfgId = 0
def.field("boolean").m_state = false
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SGetBackGameAwardSuccess", BTGBackHome.OnSGetBackGameAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SGetBackGameAwardFail", BTGBackHome.OnSGetBackGameAwardFail)
end
def.method("table").SetData = function(self, bean)
  self.m_cfgId = bean.back_game_award_tier_cfg_id
  self.m_state = bean.back_game_award_available == BackGameActivityAwardInfo.AVAILABLE
end
def.method().Clear = function(self)
  self.m_cfgId = 0
  self.m_state = false
end
def.method().NewDay = function(self)
end
def.static("table").OnSGetBackGameAwardSuccess = function(p)
  local self = BTGBackHome.Instance()
  self.m_state = false
  Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.BackHomeUpdate, nil)
  Toast(textRes.BackToGame.BackHome[1])
end
def.static("table").OnSGetBackGameAwardFail = function(p)
  local tip = textRes.BackToGame.BackHome.Error[p.error_code]
  if tip then
    Toast(tip)
  end
end
def.method().GetBackHomeGift = function(self)
  if self.m_state then
    local p = require("netio.protocol.mzm.gsp.backgameactivity.CGetBackGameAwardReq").new(self.m_cfgId)
    gmodule.network.sendProtocol(p)
  else
    Toast(textRes.BackToGame.BackHome[2])
  end
end
def.method("=>", "table", "string", "string", "number", "number").GetBackHomeData = function(self)
  local cfg = BackToGameUtils.GetBackHomeAward(self.m_cfgId)
  if cfg then
    local items = ItemUtils.GetAwardItems(cfg.awardId)
    local buff1Cfg = BuffUtility.GetBuffCfg(cfg.buffId1)
    local buff2Cfg = BuffUtility.GetBuffCfg(cfg.buffId2)
    local buff1Desc = cfg.buff1Desc
    local buff2Desc = cfg.buff2Desc
    return items, buff1Desc, buff2Desc, buff1Cfg.icon, buff2Cfg.icon
  else
    return nil, nil, "", "", 0, 0
  end
end
def.method("=>", "boolean").GetCanDraw = function(self)
  return self.m_state
end
def.method("=>", "boolean").IsRed = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_AWARD)
  if open then
    return self.m_state
  else
    return false
  end
end
BTGBackHome.Commit()
return BTGBackHome
