local Lplus = require("Lplus")
local BTGExp = Lplus.Class("BTGExp")
local BackToGameUtils = require("Main.BackToGame.BackToGameUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = BTGExp.define
local instance
def.static("=>", BTGExp).Instance = function()
  if instance == nil then
    instance = BTGExp()
  end
  return instance
end
def.field("number").m_cfgId = 0
def.field("table").m_awardGet = nil
def.field("number").m_loginCount = 0
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SGetBackGameExpAwardSuccess", BTGExp.OnSGetBackGameExpAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SGetBackGameExpAwardFail", BTGExp.OnSGetBackGameExpAwardFail)
end
def.method("table", "number").SetData = function(self, bean, cfgId)
  self.m_cfgId = cfgId
  self.m_awardGet = {}
  for k, v in pairs(bean.already_get_exp_awards) do
    self.m_awardGet[v] = true
  end
  self.m_loginCount = bean.login_count
end
def.method().Clear = function(self)
  self.m_cfgId = 0
  self.m_awardGet = nil
  self.m_loginCount = 0
end
def.method().NewDay = function(self)
  if self.m_cfgId > 0 then
    self.m_loginCount = self.m_loginCount + 1
    Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ExpUpdate, nil)
  end
end
def.static("table").OnSGetBackGameExpAwardSuccess = function(p)
  local self = BTGExp.Instance()
  self.m_awardGet[p.index] = true
  Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ExpUpdate, nil)
  Toast(textRes.BackToGame.Exp[1])
end
def.static("table").OnSGetBackGameExpAwardFail = function(p)
  local tip = textRes.BackToGame.Exp.Error[p.error_code]
  if tip then
    Toast(tip)
  end
end
def.method("number").Draw = function(self, index)
  local p = require("netio.protocol.mzm.gsp.backgameactivity.CGetBackGameExpAwardReq").new(index)
  gmodule.network.sendProtocol(p)
end
def.method("=>", "table", "number").GetExpData = function(self)
  local cfg = BackToGameUtils.GetExpCfg(self.m_cfgId)
  if cfg then
    local exps = {}
    for k, v in ipairs(cfg.exps) do
      local signed = false
      if self.m_awardGet[v.index] then
        signed = true
      end
      local leftDay = v.index - self.m_loginCount
      table.insert(exps, {
        index = v.index,
        signed = signed,
        leftDay = leftDay,
        item1 = v.items[1],
        item2 = v.items[2]
      })
    end
    return exps, cfg.total
  else
    return {}, 0
  end
end
def.method("=>", "boolean").IsRed = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_EXP)
  if open then
    local cfg = BackToGameUtils.GetExpCfg(self.m_cfgId)
    if not cfg then
      return false
    end
    local exps = {}
    for k, v in ipairs(cfg.exps) do
      if not self.m_awardGet[v.index] and self.m_loginCount >= v.index then
        return true
      end
    end
    return false
  else
    return false
  end
end
BTGExp.Commit()
return BTGExp
