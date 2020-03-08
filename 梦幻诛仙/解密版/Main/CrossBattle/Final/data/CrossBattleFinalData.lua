local Lplus = require("Lplus")
local CrossBattleFinalData = Lplus.Class("CrossBattleFinalData")
local def = CrossBattleFinalData.define
def.field("table").joinConditionStatus = nil
def.field("userdata").watingLeftSeconds = nil
def.field("number").curFightStage = 0
def.field("number").curFightRound = 0
def.field("table").finalFightCorpsInfo = nil
def.field("table").finalFightInfo = nil
def.field("table").finalMatchInfo = nil
def.field("userdata").rescheduleBeginTime = nil
def.field("userdata").rescheduleEndTime = nil
def.field("boolean").canAttendFinal = false
local instance
def.static("=>", CrossBattleFinalData).Instance = function()
  if instance == nil then
    instance = CrossBattleFinalData()
  end
  return instance
end
def.method("table").SetJoinConditionStatus = function(self, status)
  self.joinConditionStatus = {}
  self.joinConditionStatus.is_five_role_team = status.is_five_role_team == 1
  self.joinConditionStatus.is_in_one_corps = status.is_in_one_corps == 1
  self.joinConditionStatus.is_can_take_part_in_Final = status.is_can_take_part_in_Final == 1
  self.joinConditionStatus.is_role_same_with_sign_up = status.is_role_same_with_sign_up == 1
end
def.method("=>", "table").GetJoinConditionStatus = function(self)
  return self.joinConditionStatus
end
def.method().ClearJoinConditionStatus = function(self)
  self.joinConditionStatus = nil
end
def.method("userdata").SetWaitingSeconds = function(self, s)
  self.watingLeftSeconds = s
end
def.method("=>", "userdata").GetWatingSeconds = function(self)
  return self.watingLeftSeconds
end
def.method().ClearWaitingSeconds = function(self)
  self.watingLeftSeconds = nil
end
def.method("number").SetCurFightStage = function(self, stage)
  self.curFightStage = stage
end
def.method("=>", "number").GetCurFightStage = function(self)
  return self.curFightStage
end
def.method().ClearCurFightStage = function(self)
  self.curFightStage = 0
end
def.method("number").SetCurFightRound = function(self, round)
  self.curFightRound = round
end
def.method("=>", "number").GetCurFightRound = function(self)
  return self.curFightRound
end
def.method().ClearCurFightRound = function(self)
  self.curFightRound = 0
end
def.method("table").SetFinalFightCorpsInfo = function(self, corpsMap)
  self.finalFightCorpsInfo = corpsMap
end
def.method("=>", "table").GetFinalFightCorpsInfo = function(self)
  return self.finalFightCorpsInfo
end
def.method().ClearFinalFightCorpsInfo = function(self)
  self.finalFightCorpsInfo = nil
end
def.method("table").SetFinalFightInfo = function(self, fightInfo)
  self.finalFightInfo = fightInfo
end
def.method("=>", "table").GetFinalFightInfo = function(self)
  return self.finalFightInfo
end
def.method().ClearFinalFightInfo = function(self)
  self.finalFightInfo = nil
end
def.method("table").SetFinalMatchInfo = function(self, matchInfo)
  self.finalMatchInfo = matchInfo
end
def.method("=>", "table").GetFinalMatchInfo = function(self)
  return self.finalMatchInfo
end
def.method("userdata", "number").SetFinalMatchRoleProgress = function(self, roleId, progress)
  if self.finalMatchInfo == nil then
    return
  end
  if self.finalMatchInfo[1] ~= nil and self.finalMatchInfo[1]:GetRole(roleId) ~= nil then
    self.finalMatchInfo[1]:GetRole(roleId):SetProgress(progress)
  end
  if self.finalMatchInfo[2] ~= nil and self.finalMatchInfo[2]:GetRole(roleId) ~= nil then
    self.finalMatchInfo[2]:GetRole(roleId):SetProgress(progress)
  end
end
def.method().ClearFinalMatchInfo = function(self)
  self.finalMatchInfo = nil
end
def.method("userdata", "userdata").SetReschedulePrepareTime = function(self, beginTime, endTime)
  self.rescheduleBeginTime = beginTime
  self.rescheduleEndTime = endTime
end
def.method("=>", "boolean").IsDuringRescheduleFinal = function(self)
  if self.rescheduleBeginTime == nil or self.rescheduleEndTime == nil then
    return false
  end
  local serverTime = _G.GetServerTime()
  if Int64.lt(self.rescheduleBeginTime, serverTime) and Int64.gt(self.rescheduleEndTime, serverTime) then
    return true
  end
  return false
end
def.method().ClearRescheduleTime = function(self)
  self.rescheduleBeginTime = nil
  self.rescheduleEndTime = nil
end
def.method("=>", "boolean").CanAttendFinal = function(self)
  return self.canAttendFinal
end
def.method("boolean").SetCanAttendFinal = function(self, b)
  self.canAttendFinal = b
end
def.method().Clear = function(self)
  self:ClearJoinConditionStatus()
  self:ClearWaitingSeconds()
  self:ClearCurFightStage()
  self:ClearCurFightRound()
  self:ClearFinalFightCorpsInfo()
  self:ClearFinalFightInfo()
  self:ClearFinalMatchInfo()
  self:ClearRescheduleTime()
  self:SetCanAttendFinal(false)
end
CrossBattleFinalData.Commit()
return CrossBattleFinalData
