local CEndCourse = class("CEndCourse")
CEndCourse.TYPEID = 12609297
function CEndCourse:ctor(childid, client_yuanbao)
  self.id = 12609297
  self.childid = childid or nil
  self.client_yuanbao = client_yuanbao or nil
end
function CEndCourse:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt64(self.client_yuanbao)
end
function CEndCourse:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.client_yuanbao = os:unmarshalInt64()
end
function CEndCourse:sizepolicy(size)
  return size <= 65535
end
return CEndCourse
