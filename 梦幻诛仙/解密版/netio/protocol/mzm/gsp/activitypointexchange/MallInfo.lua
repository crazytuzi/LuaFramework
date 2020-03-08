local OctetsStream = require("netio.OctetsStream")
local ExchangeCountInfo = require("netio.protocol.mzm.gsp.activitypointexchange.ExchangeCountInfo")
local ManualRefreshCountInfo = require("netio.protocol.mzm.gsp.activitypointexchange.ManualRefreshCountInfo")
local SoldOutInfo = require("netio.protocol.mzm.gsp.activitypointexchange.SoldOutInfo")
local MallInfo = class("MallInfo")
function MallInfo:ctor(pointCount, exchangeCountInfo, manualRefreshCountInfo, soldOutInfo)
  self.pointCount = pointCount or nil
  self.exchangeCountInfo = exchangeCountInfo or ExchangeCountInfo.new()
  self.manualRefreshCountInfo = manualRefreshCountInfo or ManualRefreshCountInfo.new()
  self.soldOutInfo = soldOutInfo or SoldOutInfo.new()
end
function MallInfo:marshal(os)
  os:marshalInt64(self.pointCount)
  self.exchangeCountInfo:marshal(os)
  self.manualRefreshCountInfo:marshal(os)
  self.soldOutInfo:marshal(os)
end
function MallInfo:unmarshal(os)
  self.pointCount = os:unmarshalInt64()
  self.exchangeCountInfo = ExchangeCountInfo.new()
  self.exchangeCountInfo:unmarshal(os)
  self.manualRefreshCountInfo = ManualRefreshCountInfo.new()
  self.manualRefreshCountInfo:unmarshal(os)
  self.soldOutInfo = SoldOutInfo.new()
  self.soldOutInfo:unmarshal(os)
end
return MallInfo
