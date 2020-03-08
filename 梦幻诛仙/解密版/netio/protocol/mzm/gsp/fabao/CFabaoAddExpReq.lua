local CFabaoAddExpReq = class("CFabaoAddExpReq")
CFabaoAddExpReq.TYPEID = 12595976
function CFabaoAddExpReq:ctor(equiped, fabaouuid, expItemKey, itemCount)
  self.id = 12595976
  self.equiped = equiped or nil
  self.fabaouuid = fabaouuid or nil
  self.expItemKey = expItemKey or nil
  self.itemCount = itemCount or nil
end
function CFabaoAddExpReq:marshal(os)
  os:marshalInt32(self.equiped)
  os:marshalInt64(self.fabaouuid)
  os:marshalInt32(self.expItemKey)
  os:marshalInt32(self.itemCount)
end
function CFabaoAddExpReq:unmarshal(os)
  self.equiped = os:unmarshalInt32()
  self.fabaouuid = os:unmarshalInt64()
  self.expItemKey = os:unmarshalInt32()
  self.itemCount = os:unmarshalInt32()
end
function CFabaoAddExpReq:sizepolicy(size)
  return size <= 65535
end
return CFabaoAddExpReq
