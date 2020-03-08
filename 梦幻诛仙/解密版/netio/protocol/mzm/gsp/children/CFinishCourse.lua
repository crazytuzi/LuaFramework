local CFinishCourse = class("CFinishCourse")
CFinishCourse.TYPEID = 12609301
function CFinishCourse:ctor(childid, course_type, client_yuanbao)
  self.id = 12609301
  self.childid = childid or nil
  self.course_type = course_type or nil
  self.client_yuanbao = client_yuanbao or nil
end
function CFinishCourse:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.course_type)
  os:marshalInt64(self.client_yuanbao)
end
function CFinishCourse:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.course_type = os:unmarshalInt32()
  self.client_yuanbao = os:unmarshalInt64()
end
function CFinishCourse:sizepolicy(size)
  return size <= 65535
end
return CFinishCourse
