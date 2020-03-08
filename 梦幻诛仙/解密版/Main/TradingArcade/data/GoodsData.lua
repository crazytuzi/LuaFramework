local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GoodsData = Lplus.Class(MODULE_NAME)
local MathHelper = require("Common.MathHelper")
local MarketState = require("netio.protocol.mzm.gsp.market.MarketState")
local def = GoodsData.define
def.const("table").Type = {Item = 0, Pet = 1}
def.const("table").State = MarketState
def.field("number").type = 0
def.field("userdata").marketId = nil
def.field("number").price = 0
def.field("number").state = 0
def.field("number").num = 0
def.field("number").concernRoleNum = 0
def.field("number").bidRoleNum = 0
def.field("userdata").publicEndTime = function()
  return Int64.new(0)
end
def.field("boolean").isMaxPrice = false
def.field("userdata").sellerRoleId = nil
def.virtual("=>", "string").GetName = function(self)
  return ""
end
def.virtual("=>", "table").GetIcon = function(self)
  return nil
end
def.virtual("=>", "string").GetTypeName = function(self)
  return textRes.TradingArcade.GoodsTypeName[self.type] or ""
end
def.virtual("table").MarshalMarketBean = function(self, bean)
  self.marketId = bean.marketId
  self.price = bean.price
  self.state = bean.state
  self.publicEndTime = bean.publicEndTime
  if self:IsInState(GoodsData.State.STATE_AUCTION) then
    self.bidRoleNum = bean.concernRoleNum
  else
    self.concernRoleNum = bean.concernRoleNum
  end
end
def.virtual("number").SetNum = function(self, num)
  local num = MathHelper.Clamp(num, 0, num)
  if num == 0 then
    self:AddState(GoodsData.State.STATE_SELLED)
  end
  self.num = num
end
def.virtual("=>", "number").GetPublicRemainTime = function(self)
  if not self:IsInState(GoodsData.State.STATE_PUBLIC) and not self:IsInState(GoodsData.State.STATE_AUCTION) then
    return 0
  end
  local serverTime = gmodule.moduleMgr:GetModule(ModuleId.SERVER):GetServerTime()
  local remainTime = Int64.ToNumber(self.publicEndTime - serverTime)
  return math.max(0, remainTime)
end
def.virtual("=>", "number").GetOnSellRemainTime = function(self)
  if not self:IsInState(GoodsData.State.STATE_SELL) then
    return 0
  end
  local serverTime = gmodule.moduleMgr:GetModule(ModuleId.SERVER):GetServerTime()
  local remainTime = Int64.ToNumber(self.publicEndTime - serverTime)
  return math.max(0, remainTime)
end
def.virtual("=>", "number").GetGainMoney = function(self)
end
def.method("number").AddState = function(self, state)
  self.state = bit.bor(self.state, state)
end
def.method("number").RemoveState = function(self, state)
  self.state = bit.bxor(self.state, state)
end
def.method("number", "=>", "boolean").IsInState = function(self, state)
  return bit.band(self.state, state) ~= 0
end
def.method().IncConcernRoleNum = function(self)
  self.concernRoleNum = self.concernRoleNum + 1
end
def.method().DecConcernRoleNum = function(self)
  self.concernRoleNum = self.concernRoleNum - 1
  if self.concernRoleNum < 0 then
    self.concernRoleNum = 0
  end
end
def.virtual(GoodsData).Copy = function(self, data)
  self.marketId = data.marketId
  self.price = data.price
  self.state = data.state
  self.concernRoleNum = data.concernRoleNum
  self.bidRoleNum = data.bidRoleNum
  self.publicEndTime = data.publicEndTime
end
def.virtual("=>", "table").GetSellPriceBoundCfg = function(self)
  return {min = 0, max = 0}
end
def.virtual("=>", "number").GetRefId = function(self)
  return 0
end
def.virtual("=>", "number").GetConcernRoleNum = function(self)
  return self.concernRoleNum
end
def.virtual("=>", "number").GetBidRoleNum = function(self)
  return self.bidRoleNum
end
def.virtual("=>", "number").GetStateRoleNum = function(self)
  if self:IsInState(GoodsData.State.STATE_AUCTION) then
    return self.bidRoleNum
  else
    return self.concernRoleNum
  end
end
return GoodsData.Commit()
