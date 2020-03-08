local OctetsStream = require("netio.OctetsStream")
local FloorFightRes = class("FloorFightRes")
function FloorFightRes:ctor(names, killTime, usedTime)
  self.names = names or {}
  self.killTime = killTime or nil
  self.usedTime = usedTime or nil
end
function FloorFightRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.names))
  for _, v in ipairs(self.names) do
    os:marshalOctets(v)
  end
  os:marshalInt32(self.killTime)
  os:marshalInt32(self.usedTime)
end
function FloorFightRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.names, v)
  end
  self.killTime = os:unmarshalInt32()
  self.usedTime = os:unmarshalInt32()
end
return FloorFightRes
