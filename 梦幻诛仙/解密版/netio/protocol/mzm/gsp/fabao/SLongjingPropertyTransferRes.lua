local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SLongjingPropertyTransferRes = class("SLongjingPropertyTransferRes")
SLongjingPropertyTransferRes.TYPEID = 12596037
function SLongjingPropertyTransferRes:ctor(toTransferItemUuid, beforeitemid, targetiteminfo, resttransfercount, moneynum)
  self.id = 12596037
  self.toTransferItemUuid = toTransferItemUuid or nil
  self.beforeitemid = beforeitemid or nil
  self.targetiteminfo = targetiteminfo or ItemInfo.new()
  self.resttransfercount = resttransfercount or nil
  self.moneynum = moneynum or nil
end
function SLongjingPropertyTransferRes:marshal(os)
  os:marshalInt64(self.toTransferItemUuid)
  os:marshalInt32(self.beforeitemid)
  self.targetiteminfo:marshal(os)
  os:marshalInt32(self.resttransfercount)
  os:marshalInt32(self.moneynum)
end
function SLongjingPropertyTransferRes:unmarshal(os)
  self.toTransferItemUuid = os:unmarshalInt64()
  self.beforeitemid = os:unmarshalInt32()
  self.targetiteminfo = ItemInfo.new()
  self.targetiteminfo:unmarshal(os)
  self.resttransfercount = os:unmarshalInt32()
  self.moneynum = os:unmarshalInt32()
end
function SLongjingPropertyTransferRes:sizepolicy(size)
  return size <= 65535
end
return SLongjingPropertyTransferRes
