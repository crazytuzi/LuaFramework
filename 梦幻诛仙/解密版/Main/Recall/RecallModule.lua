local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local RecallData = require("Main.Recall.data.RecallData")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local RecallModule = Lplus.Extend(ModuleBase, "RecallModule")
local instance
local def = RecallModule.define
def.static("=>", RecallModule).Instance = function()
  if instance == nil then
    instance = RecallModule()
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  require("Main.Recall.RecallMgr").Instance():Init()
  require("Main.Recall.RecallProtocols").RegisterProtocols()
  RecallData.Instance():Init()
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  local result = true
  if false == self:IsFeatrueOpen(bToast) then
    result = false
  end
  return result
end
def.method("boolean", "=>", "boolean").IsFeatrueOpen = function(self, bToast)
  local result = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_CROSS_SERVER_RECALL_FRIEND)
  if false == result and bToast then
    Toast(textRes.Recall.FEATRUE_IDIP_NOT_OPEN)
  end
  return result
end
def.method("boolean", "=>", "boolean").IsRebateOpen = function(self, bToast)
  local result = self:IsOpen(false) and _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_RECALL_FRIEND_REBATE)
  if false == result and bToast then
    Toast(textRes.Recall.FEATRUE_REBATE_IDIP_NOT_OPEN)
  end
  return result
end
def.method("boolean", "=>", "boolean").IsBindActiveOpen = function(self, bToast)
  local result = self:IsOpen(false) and _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_RECALL_FRIEND_BIND)
  if false == result and bToast then
    Toast(textRes.Recall.FEATRUE_BIND_IDIP_NOT_OPEN)
  end
  return result
end
def.method("=>", "boolean").NeedReddot = function(self)
  if self:IsOpen(false) then
    return self:NeedRecallReddot() or self:NeedGiftReddot() or self:NeedLoginReddot() or self:NeedActiveReddot() or self:NeedRebateReddot()
  else
    return false
  end
end
def.method("=>", "boolean").NeedRecallReddot = function(self)
  if self:IsOpen(false) then
    return not RecallData.Instance():ReachDayRecallLimit() and RecallData.Instance():HaveCanRecallAfkFriend()
  else
    return false
  end
end
def.method("=>", "boolean").NeedGiftReddot = function(self)
  local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
  return RelationShipChainMgr.GetBigGiftAwardState() == 0
end
def.method("=>", "boolean").NeedLoginReddot = function(self)
  local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
  return RelationShipChainMgr.CanGetRecallFriendSignAward()
end
def.method("=>", "boolean").NeedActiveReddot = function(self)
  if self:IsOpen(false) and self:IsBindActiveOpen(false) then
    return RecallData.Instance():HaveUnfetchedActiveAward() or RecallData.Instance():CanBindRecallFriend()
  else
    return false
  end
end
def.method("=>", "boolean").NeedRebateReddot = function(self)
  if self:IsRebateOpen(false) then
    return RecallData.Instance():GetTodayLeftRebateNum() > 0
  else
    return false
  end
end
return RecallModule.Commit()
