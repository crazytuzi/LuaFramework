local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RecallFriendInfo = require("Main.Recall.data.RecallFriendInfo")
local RecallUtils = require("Main.Recall.RecallUtils")
local RecallHeroFriendInfo = Lplus.Extend(RecallFriendInfo, "RecallHeroFriendInfo")
local def = RecallHeroFriendInfo.define
def.field("number").recallCount = 0
def.field("boolean").bBinded = false
def.final("table", "=>", RecallHeroFriendInfo).New = function(friendInfo)
  local recallHeroFriendInfo = RecallHeroFriendInfo()
  recallHeroFriendInfo.userInfo = friendInfo.user_info
  recallHeroFriendInfo.roleInfo = friendInfo.role_info
  recallHeroFriendInfo.recallCount = friendInfo.callback
  recallHeroFriendInfo.bBinded = friendInfo.state == 1
  return recallHeroFriendInfo
end
def.override().Release = function(self)
  base:Release()
end
def.method("=>", "number").GetRecallCount = function(self)
  return self.recallCount
end
def.method("boolean").SetBinded = function(self, value)
  self.bBinded = value
end
def.method("=>", "boolean").HasBinded = function(self)
  return self.bBinded
end
return RecallHeroFriendInfo.Commit()
