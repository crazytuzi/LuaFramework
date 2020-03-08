local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ActivityRetrieveData = Lplus.Class(MODULE_NAME)
local Cls = ActivityRetrieveData
local def = Cls.define
local instance
def.field("table")._mapActivitiesInfo = nil
def.field("table")._retrieveActList = nil
def.field("table")._retrieveGroups = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = ActivityRetrieveData()
    instance._mapActivitiesInfo = {}
    instance._retrieveActList = {}
  end
  return instance
end
def.method("number", "=>", "table").GetActivityInfo = function(self, actId)
  return self._mapActivitiesInfo[actId]
end
def.method("number", "table").SetActivityInfo = function(self, actId, info)
  self._mapActivitiesInfo[actId] = info
end
def.method("number", "number").SetRetrieveActLeftTimes = function(self, actId, iLeftTimes)
  local retrieveInfo = self._mapActivitiesInfo[actId]
  if retrieveInfo ~= nil then
    retrieveInfo.times = iLeftTimes
  end
end
def.method("table").SetRetrieveGroup = function(self, groups)
  self._retrieveGroups = groups
  self:SortAllActivities()
end
def.method().SortAllActivities = function(self)
  for atype, actList in pairs(self._retrieveGroups) do
    self:SortActivities(actList)
  end
end
def.method("table").SortActivities = function(self, actList)
  if actList == nil then
    return
  end
  table.sort(actList, function(a, b)
    if a.times < 1 and b.times > 0 then
      return false
    elseif a.times > 0 and b.times < 1 then
      return true
    elseif a.id < b.id then
      return true
    else
      return false
    end
  end)
end
def.method("number").SetEasyRetrieve = function(self, groupType)
  local retrieveActList = self._retrieveGroups[groupType]
  if retrieveActList == nil then
    return
  end
  for i = 1, #retrieveActList do
    local retrieveInfo = retrieveActList[i]
    retrieveInfo.times = 0
  end
end
def.method("table").SetRetrieveActList = function(self, list)
  self._mapActivitiesInfo = {}
  self._retrieveActList = {}
  if list ~= nil then
    for i = 1, #list do
      local retrieveInfo = list[i]
      self._mapActivitiesInfo[retrieveInfo.activityid] = retrieveInfo
    end
    self._retrieveActList = list
  end
end
def.method("=>", "table").GetRetrieveList = function(self)
  return self._retrieveActList
end
return Cls.Commit()
