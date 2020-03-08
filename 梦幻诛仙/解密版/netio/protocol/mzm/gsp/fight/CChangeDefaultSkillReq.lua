local CChangeDefaultSkillReq = class("CChangeDefaultSkillReq")
CChangeDefaultSkillReq.TYPEID = 12594178
function CChangeDefaultSkillReq:ctor(roleid, uuid, skill, fighter_type)
  self.id = 12594178
  self.roleid = roleid or nil
  self.uuid = uuid or nil
  self.skill = skill or nil
  self.fighter_type = fighter_type or nil
end
function CChangeDefaultSkillReq:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.skill)
  os:marshalInt32(self.fighter_type)
end
function CChangeDefaultSkillReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.uuid = os:unmarshalInt64()
  self.skill = os:unmarshalInt32()
  self.fighter_type = os:unmarshalInt32()
end
function CChangeDefaultSkillReq:sizepolicy(size)
  return size <= 65535
end
return CChangeDefaultSkillReq
