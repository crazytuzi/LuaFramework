local OctetsStream = require("netio.OctetsStream")
local SkillList = class("SkillList")
function SkillList:ctor(skills)
  self.skills = skills or {}
end
function SkillList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.skills))
  for _, v in ipairs(self.skills) do
    os:marshalInt32(v)
  end
end
function SkillList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.skills, v)
  end
end
return SkillList
