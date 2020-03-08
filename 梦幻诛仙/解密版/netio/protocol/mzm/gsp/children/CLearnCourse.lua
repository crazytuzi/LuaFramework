local CLearnCourse = class("CLearnCourse")
CLearnCourse.TYPEID = 12609298
function CLearnCourse:ctor(childid, course_type)
  self.id = 12609298
  self.childid = childid or nil
  self.course_type = course_type or nil
end
function CLearnCourse:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.course_type)
end
function CLearnCourse:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.course_type = os:unmarshalInt32()
end
function CLearnCourse:sizepolicy(size)
  return size <= 65535
end
return CLearnCourse
