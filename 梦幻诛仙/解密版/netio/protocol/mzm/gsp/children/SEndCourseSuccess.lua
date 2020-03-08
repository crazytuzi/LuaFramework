local StudyEffectInfo = require("netio.protocol.mzm.gsp.children.StudyEffectInfo")
local SEndCourseSuccess = class("SEndCourseSuccess")
SEndCourseSuccess.TYPEID = 12609306
function SEndCourseSuccess:ctor(childid, study_effect_info)
  self.id = 12609306
  self.childid = childid or nil
  self.study_effect_info = study_effect_info or StudyEffectInfo.new()
end
function SEndCourseSuccess:marshal(os)
  os:marshalInt64(self.childid)
  self.study_effect_info:marshal(os)
end
function SEndCourseSuccess:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.study_effect_info = StudyEffectInfo.new()
  self.study_effect_info:unmarshal(os)
end
function SEndCourseSuccess:sizepolicy(size)
  return size <= 65535
end
return SEndCourseSuccess
