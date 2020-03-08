local SOpenLuckyBagFailed = class("SOpenLuckyBagFailed")
SOpenLuckyBagFailed.TYPEID = 12607490
SOpenLuckyBagFailed.ERROR_CURRENCY_NOT_ENOUGH = -1
SOpenLuckyBagFailed.ERROR_YUAN_BAO_NOT_ENOUGH = -2
SOpenLuckyBagFailed.ERROR_LUCKY_BAG_NOT_EXIST = -3
SOpenLuckyBagFailed.ERROR_ACTIVITY_NOT_OPEN = -4
SOpenLuckyBagFailed.ERROR_BAG_FULL = -5
SOpenLuckyBagFailed.ERROR_YUAN_BAO_NOT_IDENTICAL = -6
function SOpenLuckyBagFailed:ctor(retcode, instanceid, use_yuanbao, client_yuanbao, need_yuanbao)
  self.id = 12607490
  self.retcode = retcode or nil
  self.instanceid = instanceid or nil
  self.use_yuanbao = use_yuanbao or nil
  self.client_yuanbao = client_yuanbao or nil
  self.need_yuanbao = need_yuanbao or nil
end
function SOpenLuckyBagFailed:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.instanceid)
  os:marshalUInt8(self.use_yuanbao)
  os:marshalInt64(self.client_yuanbao)
  os:marshalInt64(self.need_yuanbao)
end
function SOpenLuckyBagFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.instanceid = os:unmarshalInt32()
  self.use_yuanbao = os:unmarshalUInt8()
  self.client_yuanbao = os:unmarshalInt64()
  self.need_yuanbao = os:unmarshalInt64()
end
function SOpenLuckyBagFailed:sizepolicy(size)
  return size <= 65535
end
return SOpenLuckyBagFailed
