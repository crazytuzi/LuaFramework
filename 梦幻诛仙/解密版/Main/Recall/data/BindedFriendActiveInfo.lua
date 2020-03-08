local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RecallUtils = require("Main.Recall.RecallUtils")
local RecallFriendInfo = require("Main.Recall.data.RecallFriendInfo")
local BindedFriendActiveInfo = Lplus.Extend(RecallFriendInfo, "BindedFriendActiveInfo")
local def = BindedFriendActiveInfo.define
def.field("boolean").bCaller = false
def.field("number").active = 0
def.field("number").updateTime = 0
def.field("number").bindTime = 0
def.field("boolean").bAwardFetched = false
def.final("table", "boolean", "=>", BindedFriendActiveInfo).New = function(friendInfo, bCaller)
  local bindedFriendInfo = BindedFriendActiveInfo()
  bindedFriendInfo.userInfo = friendInfo.user_info
  bindedFriendInfo.roleInfo = friendInfo.role_info
  bindedFriendInfo.active = friendInfo.vitality
  bindedFriendInfo.updateTime = friendInfo.update_time
  bindedFriendInfo.bindTime = friendInfo.bind_time or 0
  bindedFriendInfo.bAwardFetched = friendInfo.state == 1
  bindedFriendInfo.bCaller = bCaller
  return bindedFriendInfo
end
def.override().Release = function(self)
  base:Release()
end
def.method("=>", "boolean").IsCaller = function(self)
  return self.bCaller
end
def.method("number").SetActive = function(self, active)
  self.active = active
end
def.method("=>", "number").GetActive = function(self)
  return self.active
end
def.method("number").SetUpdateTime = function(self, time)
  self.updateTime = time
end
def.method("=>", "number").GetUpdateTime = function(self)
  return self.updateTime
end
def.method("=>", "number").GetBindDay = function(self)
  local day = RecallUtils.GetPastDayBy0(self.bindTime)
  return day + 1
end
def.method("=>", "number").GetBindTime = function(self)
  return self.bindTime
end
def.method("boolean").SetAwardFetched = function(self, value)
  self.bAwardFetched = value
end
def.method("=>", "boolean").IsAwardFetched = function(self)
  return self.bAwardFetched
end
def.method("=>", "boolean").CanFetchAward = function(self)
  local result = false
  if not self.bAwardFetched then
    local awardActive = RecallUtils.GetConst("BIND_VITALITY")
    local heroActiveInfo = require("Main.Recall.data.RecallData").Instance():GetHeroActiveInfo()
    result = heroActiveInfo and awardActive <= heroActiveInfo:GetActive() and awardActive <= self:GetActive()
  end
  return result
end
return BindedFriendActiveInfo.Commit()
