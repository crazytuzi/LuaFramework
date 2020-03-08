local OctetsStream = require("netio.OctetsStream")
local WingSkill = class("WingSkill")
function WingSkill:ctor(mainSkillId, subSkillIds)
  self.mainSkillId = mainSkillId or nil
  self.subSkillIds = subSkillIds or {}
end
function WingSkill:marshal(os)
  os:marshalInt32(self.mainSkillId)
  os:marshalCompactUInt32(table.getn(self.subSkillIds))
  for _, v in ipairs(self.subSkillIds) do
    os:marshalInt32(v)
  end
end
function WingSkill:unmarshal(os)
  self.mainSkillId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.subSkillIds, v)
  end
end
return WingSkill
