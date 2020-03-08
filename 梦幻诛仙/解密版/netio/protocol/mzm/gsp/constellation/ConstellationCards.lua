local OctetsStream = require("netio.OctetsStream")
local ConstellationCards = class("ConstellationCards")
function ConstellationCards:ctor(constellation, stars, fortune)
  self.constellation = constellation or nil
  self.stars = stars or {}
  self.fortune = fortune or nil
end
function ConstellationCards:marshal(os)
  os:marshalInt32(self.constellation)
  os:marshalCompactUInt32(table.getn(self.stars))
  for _, v in ipairs(self.stars) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.fortune)
end
function ConstellationCards:unmarshal(os)
  self.constellation = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.stars, v)
  end
  self.fortune = os:unmarshalInt32()
end
return ConstellationCards
