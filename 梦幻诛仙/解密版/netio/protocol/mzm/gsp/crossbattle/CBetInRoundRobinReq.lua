local CBetInRoundRobinReq = class("CBetInRoundRobinReq")
CBetInRoundRobinReq.TYPEID = 12617039
function CBetInRoundRobinReq:ctor(activity_cfg_id, round_index, target_corps_id, sortid)
  self.id = 12617039
  self.activity_cfg_id = activity_cfg_id or nil
  self.round_index = round_index or nil
  self.target_corps_id = target_corps_id or nil
  self.sortid = sortid or nil
end
function CBetInRoundRobinReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.round_index)
  os:marshalInt64(self.target_corps_id)
  os:marshalInt32(self.sortid)
end
function CBetInRoundRobinReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.round_index = os:unmarshalInt32()
  self.target_corps_id = os:unmarshalInt64()
  self.sortid = os:unmarshalInt32()
end
function CBetInRoundRobinReq:sizepolicy(size)
  return size <= 65535
end
return CBetInRoundRobinReq
