local OctetsStream = require("netio.OctetsStream")
local CourseStudyInfo = class("CourseStudyInfo")
function CourseStudyInfo:ctor(course_type, time)
  self.course_type = course_type or nil
  self.time = time or nil
end
function CourseStudyInfo:marshal(os)
  os:marshalInt32(self.course_type)
  os:marshalInt32(self.time)
end
function CourseStudyInfo:unmarshal(os)
  self.course_type = os:unmarshalInt32()
  self.time = os:unmarshalInt32()
end
return CourseStudyInfo
