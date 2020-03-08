local OctetsStream = require("netio.OctetsStream")
local Skillids = class("Skillids")
function Skillids:ctor(skillList)
  self.skillList = skillList or {}
end
function Skillids:marshal(os)
  os:marshalCompactUInt32(table.getn(self.skillList))
  for _, v in ipairs(self.skillList) do
    os:marshalInt32(v)
  end
end
function Skillids:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.skillList, v)
  end
end
return Skillids
