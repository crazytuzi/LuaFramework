local CTakeActiveAwardReq = class("CTakeActiveAwardReq")
CTakeActiveAwardReq.TYPEID = 12599556
function CTakeActiveAwardReq:ctor(index_id)
  self.id = 12599556
  self.index_id = index_id or nil
end
function CTakeActiveAwardReq:marshal(os)
  os:marshalInt32(self.index_id)
end
function CTakeActiveAwardReq:unmarshal(os)
  self.index_id = os:unmarshalInt32()
end
function CTakeActiveAwardReq:sizepolicy(size)
  return size <= 65535
end
return CTakeActiveAwardReq
