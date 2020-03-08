local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RecallFriendInfo = require("Main.Recall.data.RecallFriendInfo")
local RecallUtils = require("Main.Recall.RecallUtils")
local BindedRecalledFriendInfo = Lplus.Extend(RecallFriendInfo, "BindedRecalledFriendInfo")
local def = BindedRecalledFriendInfo.define
def.field("number").bindTime = 0
def.final("table", "=>", BindedRecalledFriendInfo).New = function(friendInfo)
  local bindedRecalledFriendInfo = BindedRecalledFriendInfo()
  bindedRecalledFriendInfo.userInfo = friendInfo.user_info
  bindedRecalledFriendInfo.bindTime = friendInfo.bind_time
  return bindedRecalledFriendInfo
end
def.override().Release = function(self)
  base:Release()
end
def.method("=>", "number").GetBindTime = function(self)
  return self.bindTime
end
def.method("=>", "number").GetReturnDay = function(self)
  return RecallUtils.GetPastDayBy24(self.bindTime)
end
def.method("=>", "number").GetRestRebateDay = function(self)
  local returnDay = RecallUtils.GetPastDayBy24(self.bindTime)
  local maxRebateDay = RecallUtils.GetConst("REBATE_PERIOD")
  return math.max(0, maxRebateDay - returnDay)
end
return BindedRecalledFriendInfo.Commit()
