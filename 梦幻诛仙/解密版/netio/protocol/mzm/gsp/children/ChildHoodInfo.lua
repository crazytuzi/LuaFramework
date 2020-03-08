local OctetsStream = require("netio.OctetsStream")
local CourseStudyInfo = require("netio.protocol.mzm.gsp.children.CourseStudyInfo")
local ChildHoodInfo = class("ChildHoodInfo")
function ChildHoodInfo:ctor(interest, courses, cur_course, daily_num)
  self.interest = interest or nil
  self.courses = courses or {}
  self.cur_course = cur_course or CourseStudyInfo.new()
  self.daily_num = daily_num or nil
end
function ChildHoodInfo:marshal(os)
  os:marshalInt32(self.interest)
  do
    local _size_ = 0
    for _, _ in pairs(self.courses) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.courses) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  self.cur_course:marshal(os)
  os:marshalInt32(self.daily_num)
end
function ChildHoodInfo:unmarshal(os)
  self.interest = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.children.CourseInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.courses[k] = v
  end
  self.cur_course = CourseStudyInfo.new()
  self.cur_course:unmarshal(os)
  self.daily_num = os:unmarshalInt32()
end
return ChildHoodInfo
