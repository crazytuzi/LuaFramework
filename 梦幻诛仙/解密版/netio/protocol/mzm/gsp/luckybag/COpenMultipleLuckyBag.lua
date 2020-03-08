local COpenMultipleLuckyBag = class("COpenMultipleLuckyBag")
COpenMultipleLuckyBag.TYPEID = 12607500
function COpenMultipleLuckyBag:ctor(instanceid, use_yuanbao, client_yuanbao, need_yuanbao)
  self.id = 12607500
  self.instanceid = instanceid or nil
  self.use_yuanbao = use_yuanbao or nil
  self.client_yuanbao = client_yuanbao or nil
  self.need_yuanbao = need_yuanbao or nil
end
function COpenMultipleLuckyBag:marshal(os)
  os:marshalInt32(self.instanceid)
  os:marshalUInt8(self.use_yuanbao)
  os:marshalInt64(self.client_yuanbao)
  os:marshalInt64(self.need_yuanbao)
end
function COpenMultipleLuckyBag:unmarshal(os)
  self.instanceid = os:unmarshalInt32()
  self.use_yuanbao = os:unmarshalUInt8()
  self.client_yuanbao = os:unmarshalInt64()
  self.need_yuanbao = os:unmarshalInt64()
end
function COpenMultipleLuckyBag:sizepolicy(size)
  return size <= 65535
end
return COpenMultipleLuckyBag
