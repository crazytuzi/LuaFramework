local SFinishCourseFailed = class("SFinishCourseFailed")
SFinishCourseFailed.TYPEID = 12609309
SFinishCourseFailed.ERROR_LEARN_LIMIT = -1
SFinishCourseFailed.ERROR_VIGOR_NOT_ENOUGH = -2
SFinishCourseFailed.ERROR_MONEY_NOT_ENOUGH = -3
SFinishCourseFailed.ERROR_YUANBAO_NOT_ENOUGH = -4
SFinishCourseFailed.ERROR_INTEREST_LIMIT = -5
function SFinishCourseFailed:ctor(childid, course_type, retcode)
  self.id = 12609309
  self.childid = childid or nil
  self.course_type = course_type or nil
  self.retcode = retcode or nil
end
function SFinishCourseFailed:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.course_type)
  os:marshalInt32(self.retcode)
end
function SFinishCourseFailed:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.course_type = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SFinishCourseFailed:sizepolicy(size)
  return size <= 65535
end
return SFinishCourseFailed
