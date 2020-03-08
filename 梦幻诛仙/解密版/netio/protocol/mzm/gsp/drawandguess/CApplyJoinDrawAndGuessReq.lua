local CApplyJoinDrawAndGuessReq = class("CApplyJoinDrawAndGuessReq")
CApplyJoinDrawAndGuessReq.TYPEID = 12617249
function CApplyJoinDrawAndGuessReq:ctor(activity_cfgid, npc_cfgid)
  self.id = 12617249
  self.activity_cfgid = activity_cfgid or nil
  self.npc_cfgid = npc_cfgid or nil
end
function CApplyJoinDrawAndGuessReq:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.npc_cfgid)
end
function CApplyJoinDrawAndGuessReq:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.npc_cfgid = os:unmarshalInt32()
end
function CApplyJoinDrawAndGuessReq:sizepolicy(size)
  return size <= 65535
end
return CApplyJoinDrawAndGuessReq
