local CTakeMultiRoleAwardReq = class("CTakeMultiRoleAwardReq")
CTakeMultiRoleAwardReq.TYPEID = 12583436
function CTakeMultiRoleAwardReq:ctor(awardUUid, index)
  self.id = 12583436
  self.awardUUid = awardUUid or nil
  self.index = index or nil
end
function CTakeMultiRoleAwardReq:marshal(os)
  os:marshalInt64(self.awardUUid)
  os:marshalInt32(self.index)
end
function CTakeMultiRoleAwardReq:unmarshal(os)
  self.awardUUid = os:unmarshalInt64()
  self.index = os:unmarshalInt32()
end
function CTakeMultiRoleAwardReq:sizepolicy(size)
  return size <= 65535
end
return CTakeMultiRoleAwardReq
