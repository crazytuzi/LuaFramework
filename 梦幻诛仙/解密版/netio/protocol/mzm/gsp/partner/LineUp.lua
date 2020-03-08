local OctetsStream = require("netio.OctetsStream")
local LineUp = class("LineUp")
function LineUp:ctor(positions, zhenFaId)
  self.positions = positions or {}
  self.zhenFaId = zhenFaId or nil
end
function LineUp:marshal(os)
  os:marshalCompactUInt32(table.getn(self.positions))
  for _, v in ipairs(self.positions) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.zhenFaId)
end
function LineUp:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.positions, v)
  end
  self.zhenFaId = os:unmarshalInt32()
end
return LineUp
