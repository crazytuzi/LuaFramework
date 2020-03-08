local SLearnCourseFailed = class("SLearnCourseFailed")
SLearnCourseFailed.TYPEID = 12609296
SLearnCourseFailed.ERROR_LEARN_LIMIT = -1
SLearnCourseFailed.ERROR_VIGOR_NOT_ENOUGH = -2
SLearnCourseFailed.ERROR_MONEY_NOT_ENOUGH = -3
SLearnCourseFailed.ERROR_INTEREST_LIMIT = -4
function SLearnCourseFailed:ctor(childid, course_type, retcode)
  self.id = 12609296
  self.childid = childid or nil
  self.course_type = course_type or nil
  self.retcode = retcode or nil
end
function SLearnCourseFailed:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.course_type)
  os:marshalInt32(self.retcode)
end
function SLearnCourseFailed:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.course_type = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SLearnCourseFailed:sizepolicy(size)
  return size <= 65535
end
return SLearnCourseFailed
