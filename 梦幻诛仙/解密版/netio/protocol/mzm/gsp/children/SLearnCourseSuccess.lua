local CourseStudyInfo = require("netio.protocol.mzm.gsp.children.CourseStudyInfo")
local SLearnCourseSuccess = class("SLearnCourseSuccess")
SLearnCourseSuccess.TYPEID = 12609299
function SLearnCourseSuccess:ctor(childid, course_info)
  self.id = 12609299
  self.childid = childid or nil
  self.course_info = course_info or CourseStudyInfo.new()
end
function SLearnCourseSuccess:marshal(os)
  os:marshalInt64(self.childid)
  self.course_info:marshal(os)
end
function SLearnCourseSuccess:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.course_info = CourseStudyInfo.new()
  self.course_info:unmarshal(os)
end
function SLearnCourseSuccess:sizepolicy(size)
  return size <= 65535
end
return SLearnCourseSuccess
