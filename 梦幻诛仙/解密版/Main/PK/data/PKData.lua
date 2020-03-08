local Lplus = require("Lplus")
local PresentUtility = require("Main.Present.PresentUtility")
local PKData = Lplus.Class("PKData")
local def = PKData.define
local instance
def.field("table").TeamList = nil
def.field("table").myInfo = nil
def.field("number").activityTime = 60
def.field("number").rank = 0
def.field("number").points = 0
def.field("number").state = 0
def.field("number").mWin1 = 0
def.field("number").mWin2 = 0
def.static("=>", PKData).Instance = function()
  if nil == instance then
    instance = PKData()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.TeamList = {}
  self.myInfo = {}
  local teamInfo = {}
  teamInfo.type = 0
  teamInfo.points = 2
  local teamInfo2 = {}
  teamInfo2.type = 1
  teamInfo2.points = 1
  local teamInfo3 = {}
  teamInfo3.type = 2
  teamInfo3.points = 3
  self.TeamList[1] = teamInfo
  self.TeamList[2] = teamInfo2
  self.TeamList[3] = teamInfo3
  local info = {}
  info.teamType = 0
  info.points = 0
  info.xingdong = 0
  info.pkpoint = 0
  info.winCount = 0
  info.awardList = {}
  self.myInfo = info
  self.mWin1 = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "WinTimes1"):GetIntValue("value")
  self.mWin2 = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "WinTimes2"):GetIntValue("value")
end
function _G.comps(a, b)
  return a.points > b.points
end
def.method("number", "=>", "boolean").IsReceiveWinItem = function(self, winFlag)
  for i = 1, #self.myInfo.awardList do
    if self.myInfo.awardList[i] == winFlag then
      return true
    end
  end
  return false
end
def.method().SortRankList = function(self)
  table.sort(self.TeamList, comps)
end
return PKData.Commit()
