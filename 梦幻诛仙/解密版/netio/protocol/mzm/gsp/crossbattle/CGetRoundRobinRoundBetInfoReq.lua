local CGetRoundRobinRoundBetInfoReq = class("CGetRoundRobinRoundBetInfoReq")
CGetRoundRobinRoundBetInfoReq.TYPEID = 12617034
function CGetRoundRobinRoundBetInfoReq:ctor(activity_cfg_id, round_index)
  self.id = 12617034
  self.activity_cfg_id = activity_cfg_id or nil
  self.round_index = round_index or nil
end
function CGetRoundRobinRoundBetInfoReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.round_index)
end
function CGetRoundRobinRoundBetInfoReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.round_index = os:unmarshalInt32()
end
function CGetRoundRobinRoundBetInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoundRobinRoundBetInfoReq
