local Lplus = require("Lplus")
local MasterTaskData = require("Main.Shitu.interact.data.MasterTaskData")
local ActiveAwardData = require("Main.Shitu.interact.data.ActiveAwardData")
local InteractData = Lplus.Class("InteractData")
local def = InteractData.define
local _instance
def.static("=>", InteractData).Instance = function()
  if _instance == nil then
    _instance = InteractData()
  end
  return _instance
end
def.field("table")._taskCfg = nil
def.field("table")._activeCfg = nil
def.field("table")._masterTaskMap = nil
def.field("table")._masterRoleInfo = nil
def.field("table")._prenticeRoleInfoMap = nil
def.field("table")._activeAwardMap = nil
def.field("number")._lastRemindTime = 0
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._taskCfg = nil
  self._activeCfg = nil
  self._masterTaskMap = nil
  self._masterRoleInfo = nil
  self._prenticeRoleInfoMap = nil
  self._activeAwardMap = nil
  self._lastRemindTime = 0
end
def.method()._LoadTaskCfg = function(self)
  warn("[InteractData:_LoadTaskCfg] start Load taskCfg!")
  self._taskCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SHITU_INTERACT_TASK_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local taskCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    taskCfg.task_id = DynamicRecord.GetIntValue(entry, "task_id")
    taskCfg.rank = DynamicRecord.GetIntValue(entry, "rank")
    self._taskCfg[taskCfg.task_id] = taskCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetTaskCfgs = function(self)
  if nil == self._taskCfg then
    self:_LoadTaskCfg()
  end
  return self._taskCfg
end
def.method("number", "=>", "table").GetTaskCfg = function(self, id)
  return self:_GetTaskCfgs()[id]
end
def.method("number", "=>", "number").GetTaskStar = function(self, taskId)
  local taskCfg = self:GetTaskCfg(taskId)
  if taskCfg then
    return taskCfg.rank
  else
    warn("[ERROR][InteractData:GetTaskStar] taskCfg nil for taskId:", taskId)
    return 0
  end
end
def.method()._LoadActiveCfg = function(self)
  warn("[InteractData:_LoadActiveCfg] start Load activeCfg!")
  self._activeCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SHITU_INTERACT_ACTIVE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local activeCfg = {}
    local entryType = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    activeCfg.award_type_id = DynamicRecord.GetIntValue(entryType, "award_type_id")
    activeCfg.levelAwardCfgs = {}
    local structType = entryType:GetStructValue("awardTypeCfgStruct")
    local levelCount = structType:GetVectorSize("typeCfgList")
    for k = 1, levelCount do
      local levelAwardCfg = {}
      local recordLevel = structType:GetVectorValueByIdx("typeCfgList", k - 1)
      levelAwardCfg.role_level = recordLevel:GetIntValue("role_level")
      levelAwardCfg.awardCfgs = {}
      local structLevel = recordLevel:GetStructValue("levelCfgStruct")
      local awardCount = structLevel:GetVectorSize("levelCfgList")
      for j = 1, awardCount do
        local award = {}
        local recordAward = structLevel:GetVectorValueByIdx("levelCfgList", j - 1)
        award.award_index = recordAward:GetIntValue("award_index")
        award.activite_value = recordAward:GetIntValue("activite_value")
        award.role_level = levelAwardCfg.role_level
        award.is_bind = recordAward:GetIntValue("is_bind")
        award.award_item_id = recordAward:GetIntValue("award_item_id")
        award.award_item_count = recordAward:GetIntValue("award_item_count")
        table.insert(levelAwardCfg.awardCfgs, award)
      end
      if levelAwardCfg.awardCfgs and #levelAwardCfg.awardCfgs > 0 then
        table.sort(levelAwardCfg.awardCfgs, function(a, b)
          if a == nil then
            return true
          elseif b == nil then
            return false
          else
            return a.activite_value < b.activite_value
          end
        end)
      end
      activeCfg.levelAwardCfgs[levelAwardCfg.role_level] = levelAwardCfg
    end
    self._activeCfg[activeCfg.award_type_id] = activeCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetActiveCfgs = function(self)
  if nil == self._activeCfg then
    self:_LoadActiveCfg()
  end
  return self._activeCfg
end
def.method("number", "=>", "table").GetActiveCfg = function(self, awardTypeId)
  local activeCfg = self:_GetActiveCfgs()[awardTypeId]
  return activeCfg
end
def.method("number", "number", "=>", "table").GetActiveLevelAwardCfg = function(self, awardTypeId, roleLevel)
  local result
  local activeCfg = self:GetActiveCfg(awardTypeId)
  if activeCfg and activeCfg.levelAwardCfgs then
    local levelDiff = math.huge
    for level, levelActiveCfg in pairs(activeCfg.levelAwardCfgs) do
      local diff = level - roleLevel
      if diff >= 0 and levelDiff > diff then
        result = levelActiveCfg.awardCfgs
        levelDiff = diff
      end
    end
  else
    warn("[ERROR][InteractData:GetActiveLevelAwardCfg] activeCfg or activeCfg.levelAwardCfgs nil for awardTypeId:", awardTypeId)
  end
  return result
end
def.method("number", "number", "=>", "number").GetLevelActiveMax = function(self, awardTypeId, roleLevel)
  local result = 0
  local awardCfgs = self:GetActiveLevelAwardCfg(awardTypeId, roleLevel)
  if awardCfgs and #awardCfgs > 0 then
    local levelDiff = math.huge
    for _, awardCfg in pairs(awardCfgs) do
      if result < awardCfg.activite_value then
        result = awardCfg.activite_value
      end
    end
  else
    warn("[ERROR][InteractData:GetLevelActiveMax] activeCfg or activeCfg.levelAwardCfgs nil for awardTypeId:", awardTypeId)
  end
  return result
end
def.method("userdata", "table", "=>", "table").SetMasterTaskInfo = function(self, roleId, p)
  local masterTaskData
  if p then
    masterTaskData = MasterTaskData.New(p)
  end
  if self._masterTaskMap == nil then
    self._masterTaskMap = {}
  end
  local key = Int64.tostring(roleId)
  self._masterTaskMap[key] = masterTaskData
  warn("[InteractData:SetMasterTaskInfo] set masterTaskInfo for role:", Int64.tostring(roleId))
  return masterTaskData
end
def.method("userdata", "=>", "table").GetMasterTaskInfo = function(self, roleId)
  if nil == roleId then
    return nil
  end
  if self._masterTaskMap == nil then
    return nil
  end
  local key = Int64.tostring(roleId)
  return self._masterTaskMap[key]
end
def.method("number").SetLastRemindTime = function(self, remindTime)
  self._lastRemindTime = remindTime
end
def.method("=>", "number").GetLastRemindTime = function(self)
  return self._lastRemindTime
end
def.method("table").SetMasterRoleInfo = function(self, roleInfo)
  self._masterRoleInfo = roleInfo
end
def.method("=>", "table").GetMasterRoleInfo = function(self)
  return self._masterRoleInfo
end
def.method("userdata", "table").SetPrenticeRoleInfo = function(self, roleId, roleInfo)
  if roleId == nil then
    return
  end
  if self._prenticeRoleInfoMap == nil then
    self._prenticeRoleInfoMap = {}
  end
  local key = Int64.tostring(roleId)
  self._prenticeRoleInfoMap[key] = roleInfo
end
def.method("userdata", "=>", "table").GetPrenticeRoleInfo = function(self, roleId)
  if nil == roleId then
    return nil
  end
  if nil == self._prenticeRoleInfoMap then
    return nil
  end
  local key = Int64.tostring(roleId)
  return self._prenticeRoleInfoMap[key]
end
def.method("=>", "table").GetPrenticeRoleInfoMap = function(self)
  return self._prenticeRoleInfoMap
end
def.method("userdata", "table").SetActiveAwardInfo = function(self, roleId, activeAwardInfo)
  if roleId == nil then
    return
  end
  local activeAwardData
  if activeAwardInfo then
    activeAwardData = ActiveAwardData.New(activeAwardInfo)
  end
  if self._activeAwardMap == nil then
    self._activeAwardMap = {}
  end
  local key = Int64.tostring(roleId)
  self._activeAwardMap[key] = activeAwardData
  warn("[InteractData:SetActiveAwardInfo] set activeAwardData for:", Int64.tostring(roleId))
end
def.method("userdata", "=>", "table").GetActiveAwardInfo = function(self, roleId)
  if nil == roleId then
    return nil
  end
  if self._activeAwardMap == nil then
    return nil
  end
  local key = Int64.tostring(roleId)
  return self._activeAwardMap[key]
end
def.method("=>", "table").GetAllActiveAwardInfo = function(self)
  return self._activeAwardMap
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
def.method("table", "table").OnNewDay = function(self, param, context)
  self._masterTaskMap = nil
end
def.method("table").OnSSynTaskStatus = function(self, p)
  if nil == p then
    return
  end
  local taskInfo = self:GetMasterTaskInfo(p.role_id)
  if taskInfo then
    taskInfo:UpdateTaskState(p.graph_id, p.task_id, p.task_state)
  else
    warn("[ERROR][InteractData:OnSSynTaskStatus] taskInfo nil for roleid:", Int64.tostring(p.role_id))
  end
end
def.method("userdata", "number").SynShiTuActiveUpdate = function(self, roleId, active)
  local activeAwardInfo = self:GetActiveAwardInfo(roleId)
  if activeAwardInfo then
    activeAwardInfo:UpdateActive(active)
    warn(string.format("[InteractData:SynShiTuActiveUpdate] set roleid[%s] active to [%d].", Int64.tostring(roleId), active))
  else
    warn("[ERROR][InteractData:SynShiTuActiveUpdate] activeAwardInfo nil for roleid:", Int64.tostring(roleId))
  end
end
InteractData.Commit()
return InteractData
