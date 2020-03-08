local CReceiveShiTuActiveRewardReq = class("CReceiveShiTuActiveRewardReq")
CReceiveShiTuActiveRewardReq.TYPEID = 12601657
function CReceiveShiTuActiveRewardReq:ctor(role_id, index_id)
  self.id = 12601657
  self.role_id = role_id or nil
  self.index_id = index_id or nil
end
function CReceiveShiTuActiveRewardReq:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.index_id)
end
function CReceiveShiTuActiveRewardReq:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.index_id = os:unmarshalInt32()
end
function CReceiveShiTuActiveRewardReq:sizepolicy(size)
  return size <= 65535
end
return CReceiveShiTuActiveRewardReq
