local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RankListData = import(".RankListData")
local ActivityRankListData = Lplus.Extend(RankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local def = ActivityRankListData.define
def.field("boolean").isExpire = true
def.field("number").activityId = 0
def.final("number", "=>", ActivityRankListData).New = function(type)
  local obj = ActivityRankListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.method().Ctor = function(self)
  RankListModule.Instance():MapActivity2RankList(self.activityId, self)
end
def.override("=>", "boolean").IsExpire = function(self)
  return self.isExpire
end
def.method().SetExpire = function(self)
  self.isExpire = true
end
return ActivityRankListData.Commit()
