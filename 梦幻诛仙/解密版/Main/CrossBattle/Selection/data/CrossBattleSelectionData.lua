local Lplus = require("Lplus")
local CrossBattleSelectionData = Lplus.Class("CrossBattleSelectionData")
local def = CrossBattleSelectionData.define
def.field("table").joinConditionStatus = nil
def.field("userdata").watingLeftSeconds = nil
def.field("number").curFightStage = 0
def.field("table").selectionFightCorpsInfo = nil
def.field("table").selectionFightInfo = nil
def.field("table").selectionMatchInfo = nil
def.field("userdata").rescheduleBeginTime = nil
def.field("userdata").rescheduleEndTime = nil
def.field("boolean").canAttendSelection = false
local instance
def.static("=>", CrossBattleSelectionData).Instance = function()
  if instance == nil then
    instance = CrossBattleSelectionData()
  end
  return instance
end
def.method("table").SetJoinConditionStatus = function(self, status)
  self.joinConditionStatus = {}
  self.joinConditionStatus.is_five_role_team = status.is_five_role_team == 1
  self.joinConditionStatus.is_in_one_corps = status.is_in_one_corps == 1
  self.joinConditionStatus.is_can_take_part_in_selection = status.is_can_take_part_in_selection == 1
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
def.method("table").SetSelectionFightCorpsInfo = function(self, corpsMap)
  self.selectionFightCorpsInfo = corpsMap
end
def.method("=>", "table").GetSelectionFightCorpsInfo = function(self)
  return self.selectionFightCorpsInfo
end
def.method().ClearSelectionFightCorpsInfo = function(self)
  self.selectionFightCorpsInfo = nil
end
def.method("table").SetSelectionFightInfo = function(self, fightInfo)
  self.selectionFightInfo = fightInfo
end
def.method("=>", "table").GetSelectionFightInfo = function(self)
  return self.selectionFightInfo
end
def.method().ClearSelectionFightInfo = function(self)
  self.selectionFightInfo = nil
end
def.method("table").SetSelectionMatchInfo = function(self, matchInfo)
  self.selectionMatchInfo = matchInfo
end
def.method("=>", "table").GetSelectionMatchInfo = function(self)
  return self.selectionMatchInfo
end
def.method("userdata", "number").SetSelectionMatchRoleProgress = function(self, roleId, progress)
  if self.selectionMatchInfo == nil then
    return
  end
  if self.selectionMatchInfo[1] ~= nil and self.selectionMatchInfo[1]:GetRole(roleId) ~= nil then
    self.selectionMatchInfo[1]:GetRole(roleId):SetProgress(progress)
  end
  if self.selectionMatchInfo[2] ~= nil and self.selectionMatchInfo[2]:GetRole(roleId) ~= nil then
    self.selectionMatchInfo[2]:GetRole(roleId):SetProgress(progress)
  end
end
def.method().ClearSelectionMatchInfo = function(self)
  self.selectionMatchInfo = nil
end
def.method("userdata", "userdata").SetReschedulePrepareTime = function(self, beginTime, endTime)
  self.rescheduleBeginTime = beginTime
  self.rescheduleEndTime = endTime
end
def.method("=>", "boolean").IsDuringRescheduleSelection = function(self)
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
def.method("=>", "boolean").CanAttendSelection = function(self)
  return self.canAttendSelection
end
def.method("boolean").SetCanAttendSelection = function(self, b)
  self.canAttendSelection = b
end
def.method().Clear = function(self)
  self:ClearJoinConditionStatus()
  self:ClearWaitingSeconds()
  self:ClearCurFightStage()
  self:ClearSelectionFightCorpsInfo()
  self:ClearSelectionFightInfo()
  self:ClearSelectionMatchInfo()
  self:ClearRescheduleTime()
  self:SetCanAttendSelection(false)
end
CrossBattleSelectionData.Commit()
return CrossBattleSelectionData
