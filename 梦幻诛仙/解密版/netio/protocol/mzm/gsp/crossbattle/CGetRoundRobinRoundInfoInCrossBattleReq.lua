local CGetRoundRobinRoundInfoInCrossBattleReq = class("CGetRoundRobinRoundInfoInCrossBattleReq")
CGetRoundRobinRoundInfoInCrossBattleReq.TYPEID = 12616966
function CGetRoundRobinRoundInfoInCrossBattleReq:ctor(activity_cfg_id, index)
  self.id = 12616966
  self.activity_cfg_id = activity_cfg_id or nil
  self.index = index or nil
end
function CGetRoundRobinRoundInfoInCrossBattleReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.index)
end
function CGetRoundRobinRoundInfoInCrossBattleReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function CGetRoundRobinRoundInfoInCrossBattleReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoundRobinRoundInfoInCrossBattleReq
