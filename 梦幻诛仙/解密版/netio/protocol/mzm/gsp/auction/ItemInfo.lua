local OctetsStream = require("netio.OctetsStream")
local ItemInfo = class("ItemInfo")
function ItemInfo:ctor(itemCfgId, bidderCount, maxBidPrice, bidderName, bidderRoleId, bidEndTimeStamp)
  self.itemCfgId = itemCfgId or nil
  self.bidderCount = bidderCount or nil
  self.maxBidPrice = maxBidPrice or nil
  self.bidderName = bidderName or nil
  self.bidderRoleId = bidderRoleId or nil
  self.bidEndTimeStamp = bidEndTimeStamp or nil
end
function ItemInfo:marshal(os)
  os:marshalInt32(self.itemCfgId)
  os:marshalInt32(self.bidderCount)
  os:marshalInt64(self.maxBidPrice)
  os:marshalOctets(self.bidderName)
  os:marshalInt64(self.bidderRoleId)
  os:marshalInt64(self.bidEndTimeStamp)
end
function ItemInfo:unmarshal(os)
  self.itemCfgId = os:unmarshalInt32()
  self.bidderCount = os:unmarshalInt32()
  self.maxBidPrice = os:unmarshalInt64()
  self.bidderName = os:unmarshalOctets()
  self.bidderRoleId = os:unmarshalInt64()
  self.bidEndTimeStamp = os:unmarshalInt64()
end
return ItemInfo
