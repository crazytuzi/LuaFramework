local OctetsStream = require("netio.OctetsStream")
local CourseInfo = class("CourseInfo")
function CourseInfo:ctor(num, crit_num)
  self.num = num or nil
  self.crit_num = crit_num or nil
end
function CourseInfo:marshal(os)
  os:marshalInt32(self.num)
  os:marshalInt32(self.crit_num)
end
function CourseInfo:unmarshal(os)
  self.num = os:unmarshalInt32()
  self.crit_num = os:unmarshalInt32()
end
return CourseInfo
