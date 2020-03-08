local CTeamLeaderInteractNpcReq = class("CTeamLeaderInteractNpcReq")
CTeamLeaderInteractNpcReq.TYPEID = 12586753
function CTeamLeaderInteractNpcReq:ctor(npcId, args)
  self.id = 12586753
  self.npcId = npcId or nil
  self.args = args or {}
end
function CTeamLeaderInteractNpcReq:marshal(os)
  os:marshalInt32(self.npcId)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalInt32(v)
  end
end
function CTeamLeaderInteractNpcReq:unmarshal(os)
  self.npcId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.args, v)
  end
end
function CTeamLeaderInteractNpcReq:sizepolicy(size)
  return size <= 65535
end
return CTeamLeaderInteractNpcReq
