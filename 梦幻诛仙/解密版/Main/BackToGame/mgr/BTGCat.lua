local Lplus = require("Lplus")
local BTGCat = Lplus.Class("BTGCat")
local BackToGameUtils = require("Main.BackToGame.BackToGameUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local def = BTGCat.define
def.field("userdata").curRechargeCount = nil
def.field("table").tokenCount = nil
local instance
def.static("=>", BTGCat).Instance = function()
  if instance == nil then
    instance = BTGCat()
  end
  return instance
end
def.field("number").m_cfgId = 0
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SSynRechargeInfo", BTGCat.OnSSynRechargeInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SUseManekiTokenRsp", BTGCat.OnSUseManekiTokenRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SUseManekiTokenError", BTGCat.OnSUseManekiTokenError)
end
def.method("table", "number").SetData = function(self, bean, cfgId)
  self.m_cfgId = cfgId
  self.curRechargeCount = bean.accumulateRechargeCount
  self.tokenCount = bean.manekiTokenCfgId2count
end
def.method("table").ChangeRechargeDataAndToast = function(self, bean)
  local changeTokens = {}
  for tokenCfgId, newNum in pairs(bean.manekiTokenCfgId2count) do
    local oldNum = self:GetCurrentTokenCount(tokenCfgId)
    local tokenCfg = BackToGameUtils.GetRechargeAwardCfg(tokenCfgId)
    if tokenCfg and newNum > oldNum then
      table.insert(changeTokens, string.format(textRes.BackToGame.Cat[2], tokenCfg.manekiTokenName, newNum - oldNum))
    end
  end
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_RECHARGE)
  if open and #changeTokens > 0 then
    local str = string.format(textRes.BackToGame.Cat[3], table.concat(changeTokens, ","))
    PersonalHelper.SendOut(str)
  end
  self.curRechargeCount = bean.accumulateRechargeCount
  self.tokenCount = bean.manekiTokenCfgId2count
end
def.method().Clear = function(self)
  self.m_cfgId = 0
  self.curRechargeCount = nil
  self.tokenCount = nil
end
def.static("table").OnSSynRechargeInfo = function(p)
  local self = BTGCat.Instance()
  self:ChangeRechargeDataAndToast(p.rechargeInfo)
  Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.RechargeDataChange, nil)
  Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.CatTokenChange, nil)
end
def.static("table").OnSUseManekiTokenRsp = function(p)
  local self = BTGCat.Instance()
  if self.tokenCount == nil then
    return
  end
  local preCount = self:GetCurrentTokenCount(p.manekiTokenCfgId)
  self:SetCurrentTokenCount(p.manekiTokenCfgId, math.max(0, preCount - 1))
  local tokenCfg = BackToGameUtils.GetRechargeAwardCfg(p.manekiTokenCfgId)
  if tokenCfg then
    local str = string.format(textRes.BackToGame.Cat[1], 1, tokenCfg.manekiTokenName, tokenCfg.getYuanBaoCount)
    PersonalHelper.SendOut(str)
  end
  Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.CatTokenChange, nil)
end
def.static("table").OnSUseManekiTokenError = function(p)
  if textRes.BackToGame.Cat.SUseManekiTokenError[p.errorCode] then
    Toast(textRes.BackToGame.Cat.SUseManekiTokenError[p.errorCode])
  else
    Toast(string.format(textRes.BackToGame.Cat.SUseManekiTokenError[-1], p.errorCode))
  end
end
def.method("number").UseToken = function(self, tokenCfgId)
  local curCount = self:GetCurrentTokenCount(tokenCfgId)
  if curCount <= 0 then
    local tokenCfg = BackToGameUtils.GetRechargeAwardCfg(tokenCfgId)
    if tokenCfg then
      Toast(string.format(textRes.BackToGame.Cat[4], tokenCfg.manekiTokenName))
    end
    return
  end
  local activityId = gmodule.moduleMgr:GetModule(ModuleId.BACK_TO_GAME).m_activityId
  local p = require("netio.protocol.mzm.gsp.backgameactivity.CUseManekiTokenReq").new(activityId, tokenCfgId)
  gmodule.network.sendProtocol(p)
end
def.method("=>", "userdata").GetCurrentRechargeCount = function(self)
  if self.curRechargeCount == nil then
    return Int64.new(0)
  else
    return self.curRechargeCount
  end
end
def.method("number", "=>", "number").GetCurrentTokenCount = function(self, tokenCfgId)
  if self.tokenCount == nil then
    return 0
  end
  local count = self.tokenCount[tokenCfgId] or 0
  return count
end
def.method("number", "number").SetCurrentTokenCount = function(self, tokenCfgId, tokenCount)
  if self.tokenCount == nil then
    return
  end
  self.tokenCount[tokenCfgId] = tokenCount
end
def.method("=>", "boolean").HasAnyToken = function(self)
  if self.tokenCount == nil then
    return false
  end
  for cfgId, num in pairs(self.tokenCount) do
    if num > 0 then
      return true
    end
  end
  return false
end
def.method("=>", "table").GetBasicCfg = function(self)
  local cfg = BackToGameUtils.GetAccumulateRechargeCfg(self.m_cfgId)
  return cfg
end
def.method("=>", "boolean").IsRed = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_RECHARGE)
  if open then
    return self:HasAnyToken()
  else
    return false
  end
end
BTGCat.Commit()
return BTGCat
