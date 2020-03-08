local OctetsStream = require("netio.OctetsStream")
local StudyEffectInfo = class("StudyEffectInfo")
function StudyEffectInfo:ctor(course_type, is_crit)
  self.course_type = course_type or nil
  self.is_crit = is_crit or nil
end
function StudyEffectInfo:marshal(os)
  os:marshalInt32(self.course_type)
  os:marshalUInt8(self.is_crit)
end
function StudyEffectInfo:unmarshal(os)
  self.course_type = os:unmarshalInt32()
  self.is_crit = os:unmarshalUInt8()
end
return StudyEffectInfo
