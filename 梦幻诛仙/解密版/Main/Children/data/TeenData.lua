local Lplus = require("Lplus")
local BaseData = require("Main.Children.data.BaseData")
local TeenData = Lplus.Extend(BaseData, "TeenData")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local def = TeenData.define
def.final("=>", TeenData).New = function()
  local teenData = TeenData()
  return teenData
end
def.field("number").interest = 0
def.field("table").courseInfo = nil
def.field("table").curCourse = nil
def.field("number").todayTimes = 0
def.final(TeenData, TeenData).Copy = function(old, new)
  if old == nil or new == nil then
    return
  end
  BaseData.Copy(old, new)
  new.interest = old.interest
  new.courseInfo = clone(old.courseInfo)
  new.curCourse = clone(old.curCourse)
  new.todayTimes = old.todayTimes
end
def.override("table").RawSet = function(self, child)
  BaseData.RawSet(self, child)
  local ChildHoodInfo = require("netio.protocol.mzm.gsp.children.ChildHoodInfo")
  local childHoodInfo = UnmarshalBean(ChildHoodInfo, child.child_period_info)
  self.interest = childHoodInfo.interest
  self.courseInfo = {}
  for k, v in pairs(childHoodInfo.courses) do
    self.courseInfo[k] = {
      num = v.num,
      crit = v.crit_num
    }
  end
  if childHoodInfo.cur_course.course_type > 0 then
    self.curCourse = {
      courseType = childHoodInfo.cur_course.course_type,
      startSecond = childHoodInfo.cur_course.time
    }
  end
  self.todayTimes = childHoodInfo.daily_num
end
def.method("=>", "table").GetCurCourse = function(self)
  return self.curCourse
end
def.method("table").SetCurCourse = function(self, course)
  if course.course_type > 0 then
    self.curCourse = {
      courseType = course.course_type,
      startSecond = course.time
    }
  else
    self.curCourse = nil
  end
end
def.method().ClearCurCourse = function(self)
  self.curCourse = nil
end
def.method("number").SetInterest = function(self, interest)
  self.interest = interest
end
def.method("=>", "number").GetInterest = function(self)
  return self.interest
end
def.method("number", "=>", "table").GetCourseInfo = function(self, courseType)
  if self.courseInfo then
    return self.courseInfo[courseType]
  else
    return nil
  end
end
def.method("number", "number", "number").SetCourseInfo = function(self, courseType, num, crit)
  if self.courseInfo == nil then
    self.courseInfo = {}
  end
  self.courseInfo[courseType] = {num = num, crit = crit}
end
def.method("number", "boolean").AddCourseInfo = function(self, courseType, isCrit)
  if self.courseInfo == nil then
    self.courseInfo = {}
  end
  local info = self.courseInfo[courseType]
  if info == nil then
    info = {num = 0, crit = 0}
    self.courseInfo[courseType] = info
  end
  info.num = info.num + 1
  if isCrit then
    info.crit = info.crit + 1
  end
  self.todayTimes = self.todayTimes + 1
end
def.method("=>", "table").GetCourseList = function(self)
  local allCourse = ChildrenUtils.GetAllCourse()
  local ret = {}
  for k, v in ipairs(allCourse) do
    local num = 0
    if self.courseInfo then
      local courseInfo = self.courseInfo[v]
      num = courseInfo and courseInfo.num or 0
    end
    table.insert(ret, {course = v, num = num})
  end
  return ret
end
def.method("=>", "number").GetTotalCourseNum = function(self)
  local count = 0
  if self.courseInfo then
    for k, v in pairs(self.courseInfo) do
      count = count + v.num
    end
  end
  return count
end
def.method().ClearAllCourse = function(self)
  self.courseInfo = nil
end
def.method("=>", "number").GetTodayTimes = function(self)
  return self.todayTimes
end
def.method("number").SetTodayTimes = function(self, times)
  self.todayTimes = times
end
def.method().AddTodayTimes = function(self)
  self.todayTimes = self.todayTimes + 1
end
def.method("=>", "table").GetCourseProps = function(self)
  if self.courseInfo then
    local props = {}
    for k, v in pairs(self.courseInfo) do
      local courseCfg = ChildrenUtils.GetCourseCfg(k)
      if courseCfg then
        for _, v1 in ipairs(courseCfg.props) do
          if props[v1.prop] == nil then
            props[v1.prop] = 0
          end
          local add = v1.value * v.num + v1.critValue * v.crit
          props[v1.prop] = props[v1.prop] + add
        end
      end
    end
    return props
  else
    return {}
  end
end
def.method("=>", "table").GetInterestProps = function(self)
  if self.interest > 0 then
    local interestCfg = ChildrenUtils.GetInterestCfg(self.interest)
    if interestCfg then
      local props = {}
      for _, v in pairs(interestCfg.props) do
        props[v.prop] = v.value
      end
      return props
    else
      return {}
    end
  else
    return {}
  end
end
def.method("=>", "table").GetAllProps = function(self)
  local courseProp = self:GetCourseProps()
  for k, v in pairs(courseProp) do
    local propCfg = ChildrenUtils.GetPropCfg(k)
    if propCfg and v > propCfg.limit then
      courseProp[k] = propCfg.limit
    end
  end
  local interestProp = self:GetInterestProps()
  local props = {}
  for k, v in pairs(courseProp) do
    if props[k] == nil then
      props[k] = 0
    end
    props[k] = props[k] + v
  end
  for k, v in pairs(interestProp) do
    if props[k] == nil then
      props[k] = 0
    end
    props[k] = props[k] + v
  end
  return props
end
TeenData.Commit()
return TeenData
