local CWatchRoundRobinFightReq = class("CWatchRoundRobinFightReq")
CWatchRoundRobinFightReq.TYPEID = 12617029
function CWatchRoundRobinFightReq:ctor(activity_cfg_id, round_index, corps_a_id, corps_b_id, watch_corps_id)
  self.id = 12617029
  self.activity_cfg_id = activity_cfg_id or nil
  self.round_index = round_index or nil
  self.corps_a_id = corps_a_id or nil
  self.corps_b_id = corps_b_id or nil
  self.watch_corps_id = watch_corps_id or nil
end
function CWatchRoundRobinFightReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.round_index)
  os:marshalInt64(self.corps_a_id)
  os:marshalInt64(self.corps_b_id)
  os:marshalInt64(self.watch_corps_id)
end
function CWatchRoundRobinFightReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.round_index = os:unmarshalInt32()
  self.corps_a_id = os:unmarshalInt64()
  self.corps_b_id = os:unmarshalInt64()
  self.watch_corps_id = os:unmarshalInt64()
end
function CWatchRoundRobinFightReq:sizepolicy(size)
  return size <= 65535
end
return CWatchRoundRobinFightReq
