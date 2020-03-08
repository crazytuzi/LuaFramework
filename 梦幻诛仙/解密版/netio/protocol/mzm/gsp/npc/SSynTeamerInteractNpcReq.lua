local SSynTeamerInteractNpcReq = class("SSynTeamerInteractNpcReq")
SSynTeamerInteractNpcReq.TYPEID = 12586755
function SSynTeamerInteractNpcReq:ctor(npcId, args)
  self.id = 12586755
  self.npcId = npcId or nil
  self.args = args or {}
end
function SSynTeamerInteractNpcReq:marshal(os)
  os:marshalInt32(self.npcId)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalInt32(v)
  end
end
function SSynTeamerInteractNpcReq:unmarshal(os)
  self.npcId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.args, v)
  end
end
function SSynTeamerInteractNpcReq:sizepolicy(size)
  return size <= 65535
end
return SSynTeamerInteractNpcReq
