local OctetsStream = require("netio.OctetsStream")
local RobotPetInfo = class("RobotPetInfo")
function RobotPetInfo:ctor(monster_cfgid, model_ratio, level, grade, score)
  self.monster_cfgid = monster_cfgid or nil
  self.model_ratio = model_ratio or nil
  self.level = level or nil
  self.grade = grade or nil
  self.score = score or nil
end
function RobotPetInfo:marshal(os)
  os:marshalInt32(self.monster_cfgid)
  os:marshalInt32(self.model_ratio)
  os:marshalInt32(self.level)
  os:marshalInt32(self.grade)
  os:marshalInt32(self.score)
end
function RobotPetInfo:unmarshal(os)
  self.monster_cfgid = os:unmarshalInt32()
  self.model_ratio = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.grade = os:unmarshalInt32()
  self.score = os:unmarshalInt32()
end
return RobotPetInfo
