local CAddWingExpReq = class("CAddWingExpReq")
CAddWingExpReq.TYPEID = 12596535
function CAddWingExpReq:ctor(uuid, num)
  self.id = 12596535
  self.uuid = uuid or nil
  self.num = num or nil
end
function CAddWingExpReq:marshal(os)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.num)
end
function CAddWingExpReq:unmarshal(os)
  self.uuid = os:unmarshalInt64()
  self.num = os:unmarshalInt32()
end
function CAddWingExpReq:sizepolicy(size)
  return size <= 65535
end
return CAddWingExpReq
