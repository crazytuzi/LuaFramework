local SCancelCourseSuccess = class("SCancelCourseSuccess")
SCancelCourseSuccess.TYPEID = 12609307
function SCancelCourseSuccess:ctor(childid)
  self.id = 12609307
  self.childid = childid or nil
end
function SCancelCourseSuccess:marshal(os)
  os:marshalInt64(self.childid)
end
function SCancelCourseSuccess:unmarshal(os)
  self.childid = os:unmarshalInt64()
end
function SCancelCourseSuccess:sizepolicy(size)
  return size <= 65535
end
return SCancelCourseSuccess
