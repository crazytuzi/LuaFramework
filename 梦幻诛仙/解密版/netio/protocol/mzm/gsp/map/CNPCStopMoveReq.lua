local CNPCStopMoveReq = class("CNPCStopMoveReq")
CNPCStopMoveReq.TYPEID = 12590877
function CNPCStopMoveReq:ctor(npcId)
  self.id = 12590877
  self.npcId = npcId or nil
end
function CNPCStopMoveReq:marshal(os)
  os:marshalInt32(self.npcId)
end
function CNPCStopMoveReq:unmarshal(os)
  self.npcId = os:unmarshalInt32()
end
function CNPCStopMoveReq:sizepolicy(size)
  return size <= 65535
end
return CNPCStopMoveReq
