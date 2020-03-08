local CGetRoundRobinPointInfoInCrossBattleReq = class("CGetRoundRobinPointInfoInCrossBattleReq")
CGetRoundRobinPointInfoInCrossBattleReq.TYPEID = 12616963
function CGetRoundRobinPointInfoInCrossBattleReq:ctor(activity_cfg_id)
  self.id = 12616963
  self.activity_cfg_id = activity_cfg_id or nil
end
function CGetRoundRobinPointInfoInCrossBattleReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CGetRoundRobinPointInfoInCrossBattleReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CGetRoundRobinPointInfoInCrossBattleReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoundRobinPointInfoInCrossBattleReq
