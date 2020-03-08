local StudyEffectInfo = require("netio.protocol.mzm.gsp.children.StudyEffectInfo")
local SyncCourseInfo = class("SyncCourseInfo")
SyncCourseInfo.TYPEID = 12609304
function SyncCourseInfo:ctor(childid, study_effect_info)
  self.id = 12609304
  self.childid = childid or nil
  self.study_effect_info = study_effect_info or StudyEffectInfo.new()
end
function SyncCourseInfo:marshal(os)
  os:marshalInt64(self.childid)
  self.study_effect_info:marshal(os)
end
function SyncCourseInfo:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.study_effect_info = StudyEffectInfo.new()
  self.study_effect_info:unmarshal(os)
end
function SyncCourseInfo:sizepolicy(size)
  return size <= 65535
end
return SyncCourseInfo
