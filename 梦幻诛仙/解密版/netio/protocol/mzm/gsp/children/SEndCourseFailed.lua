local SEndCourseFailed = class("SEndCourseFailed")
SEndCourseFailed.TYPEID = 12609303
SEndCourseFailed.ERROR_YUANBAO_NOT_ENOUGH = -1
function SEndCourseFailed:ctor(childid, retcode)
  self.id = 12609303
  self.childid = childid or nil
  self.retcode = retcode or nil
end
function SEndCourseFailed:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.retcode)
end
function SEndCourseFailed:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.retcode = os:unmarshalInt32()
end
function SEndCourseFailed:sizepolicy(size)
  return size <= 65535
end
return SEndCourseFailed
