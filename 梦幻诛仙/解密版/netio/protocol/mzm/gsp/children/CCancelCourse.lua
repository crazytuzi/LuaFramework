local CCancelCourse = class("CCancelCourse")
CCancelCourse.TYPEID = 12609310
function CCancelCourse:ctor(childid)
  self.id = 12609310
  self.childid = childid or nil
end
function CCancelCourse:marshal(os)
  os:marshalInt64(self.childid)
end
function CCancelCourse:unmarshal(os)
  self.childid = os:unmarshalInt64()
end
function CCancelCourse:sizepolicy(size)
  return size <= 65535
end
return CCancelCourse
