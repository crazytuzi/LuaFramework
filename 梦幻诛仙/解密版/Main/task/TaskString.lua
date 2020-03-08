local Lplus = require("Lplus")
local TaskString = Lplus.Class("TaskString")
local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
local def = TaskString.define
local instance
local TaskInterface = require("Main.task.TaskInterface")
def.static("=>", TaskString).Instance = function()
  if instance == nil then
    instance = TaskString()
  end
  return instance
end
def.field("table")._taskCfg = nil
def.field("table")._conditionData = nil
def.field("number")._state = 0
def.method("table").SetTargetTaskCfg = function(self, taskCfg)
  self._taskCfg = taskCfg
end
def.method("=>", "table").GetTargetTaskCfg = function(self)
  return self._taskCfg
end
def.method("table").SetConditionData = function(self, conDatas)
  self._conditionData = conDatas
end
def.method("=>", "table").GetConditionData = function(self)
  return self._conditionData
end
def.method("number").SetTargetTaskState = function(self, state)
  self._state = state
end
def.method("table", "string", "=>", "string").GeneratTaskFinishTarget = function(self, taskCfg, separator)
  separator = separator or ";"
  local ret = ""
  for k, v in pairs(taskCfg.finishConIds) do
    local conditionStr = self:GeneratTaskTarget(taskCfg, v.classType, v.id)
    if conditionStr ~= nil and conditionStr ~= "" then
      ret = ret .. conditionStr
      ret = ret .. separator
    end
  end
  local l = string.len(ret)
  if l > 0 then
    local c = string.sub(ret, l, l)
    if c == separator then
      ret = string.sub(ret, 1, l - 1)
    end
  end
  return ret
end
def.method("table", "number", "number", "=>", "string").GeneratTaskTarget = function(self, taskCfg, conditionType, conditionID)
  local fns = {}
  fns[TaskConClassType.CON_LEVEL] = TaskString._GeneratTaskTargetLevel
  fns[TaskConClassType.CON_NPC_DLG] = TaskString._GeneratTaskTargetTalkWithNPC
  fns[TaskConClassType.CON_TO_PLACE] = TaskString._GeneratTaskTargetArrive
  fns[TaskConClassType.CON_MAP_WIN_COUNT] = TaskString._GeneratTaskTargetFightCount
  fns[TaskConClassType.CON_KILL_NPC] = TaskString._GeneratTaskTargetKillNPC
  fns[TaskConClassType.CON_TEAM] = TaskString._GeneratTaskTargetTeam
  fns[TaskConClassType.CON_KILL_MONSTER] = TaskString._GeneratTaskTargetKillMonsterCount
  fns[TaskConClassType.CON_BAG] = TaskString._GeneratTaskTargetItem
  fns[TaskConClassType.CON_PET] = TaskString._GeneratTaskTargetPet
  fns[TaskConClassType.CON_TIME_LIMIT] = TaskString._GeneratTaskTargetTime
  fns[TaskConClassType.CON_GRAPH_FINISH_COUNT] = TaskString._GeneratTaskTargetGraphFinishCount
  fns[TaskConClassType.CON_GATHER_ITEM] = TaskString._GeneratTaskTargetGatherItem
  fns[TaskConClassType.CON_LEITAI_WIN] = TaskString._GeneratTaskTargetLeitaiWin
  fns[TaskConClassType.CON_ACTIVITY_FINISH] = TaskString._GeneratTaskTargetActivityFinish
  local fn = fns[conditionType]
  if fn ~= nil then
    return fn(self, taskCfg, conditionID)
  end
  return nil
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetLevel = function(self, taskCfg, conditionID)
  local condition = TaskInterface.GetTaskConditionLevel(conditionID)
  if condition.isVisiable == false then
    return ""
  end
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  local lvTypeFn = {}
  lvTypeFn[TaskConsts.ROLE_LEVEL_TYPE] = function(minLevel, maxLevel)
    return textRes.Task[50] .. minLevel .. textRes.Task[51]
  end
  lvTypeFn[TaskConsts.TEAM_LEADER_TYPE] = function(minLevel, maxLevel)
    return textRes.Task[52] .. minLevel .. textRes.Task[51]
  end
  lvTypeFn[TaskConsts.TEAM_MAX_LEVEL] = function(minLevel, maxLevel)
    return textRes.Task[53] .. maxLevel .. textRes.Task[51]
  end
  lvTypeFn[TaskConsts.TEAM_MIN_LEVEL] = function(minLevel, maxLevel)
    return textRes.Task[54] .. minLevel .. textRes.Task[51]
  end
  lvTypeFn[TaskConsts.TEAM_AVG_LEVEL] = function(minLevel, maxLevel)
    return textRes.Task[54] .. minLevel .. textRes.Task[51]
  end
  local fn = lvTypeFn[condition.levelType]
  if fn ~= nil then
    return fn(condition.minLevel, condition.maxLevel)
  end
  return string.format(textRes.Task[55], condition.minLevel, condition.maxLevel)
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetTeam = function(self, taskCfg, conditionID)
  local condition = TaskInterface.GetTaskConditionTeam(conditionID)
  if condition.isVisiable == false then
    return ""
  end
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  local rel = {}
  rel[TaskConsts.TEAMER_REL_COUPLE] = textRes.Task[56]
  rel[TaskConsts.TEAMER_REL_TEACHER] = textRes.Task[57]
  rel[TaskConsts.TEAMER_REL_OPPOSITE_SEX] = textRes.Task[58]
  rel[TaskConsts.TEAMER_REL_FRIEND] = textRes.Task[59]
  rel[TaskConsts.TEAMER_REL_CARREAR] = textRes.Task[60]
  rel[TaskConsts.TEAMER_REL_FACTION] = textRes.Task[61]
  rel[TaskConsts.TEAMER_REL_NO_LIMIT] = textRes.Task[62]
  local pc = ""
  if condition.personCount > 0 then
    pc = tostring(condition.personCount)
    pc = pc .. textRes.Task[63]
  end
  return textRes.Task[64] .. rel[condition.personRelation] .. pc .. textRes.Task[65]
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetItem = function(self, taskCfg, conditionID)
  local condition = TaskInterface.GetTaskConditionBag(conditionID)
  local ret = ""
  local ItemUtils = require("Main.Item.ItemUtils")
  local takeItemBase = ItemUtils.GetItemBase2(condition.takeCfgId)
  if takeItemBase == nil then
    local spcfg = ItemUtils.GetItemFilterCfg(condition.takeCfgId)
    if spcfg ~= nil then
      ret = ret .. textRes.Task[70] .. "[00ff00]" .. spcfg.name .. "[-]"
      if condition.takeCfgCount > 1 then
        local conData = self._conditionData
        local found = false
        if conData ~= nil then
          for k, v in pairs(conData) do
            if v.conId == conditionID then
              ret = ret .. "(" .. tostring(v.param) .. "/" .. condition.takeCfgCount .. ")"
              found = true
            end
          end
        end
        if found == false then
          ret = ret .. " x " .. condition.takeCfgCount
        end
      end
    end
  else
    ret = ret .. textRes.Task[70] .. "[00ff00]" .. takeItemBase.name .. "[-]"
    if condition.takeCfgCount > 1 then
      local conData = self._conditionData
      local found = false
      if conData ~= nil then
        for k, v in pairs(conData) do
          if v.conId == conditionID then
            ret = ret .. "(" .. tostring(v.param) .. "/" .. condition.takeCfgCount .. ")"
            found = true
          end
        end
      end
      if found == false then
        ret = ret .. " x " .. condition.takeCfgCount
      end
    end
  end
  return ret
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetArrive = function(self, taskCfg, conditionID)
  local condition = TaskInterface.GetTaskConditionArrive(conditionID)
  local mapInterface = require("Main.Map.Interface")
  local mapCfg = mapInterface.GetMapCfg(condition.mapId)
  return textRes.Task[75] .. mapCfg.mapName .. "(" .. condition.x .. "," .. condition.y .. ")"
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetFightCount = function(self, taskCfg, conditionID)
  local condition = TaskInterface.GetTaskConditionWinCount(conditionID)
  local mapInterface = require("Main.Map.Interface")
  local mapCfg = mapInterface.GetMapCfg(condition.mapId)
  if self._conditionData ~= nil then
    local found = false
    local count = 0
    for k, v in pairs(self._conditionData) do
      if v.conId == condition.id then
        count = v.param
        found = true
        break
      end
    end
    if found then
      return string.format(textRes.Task[76], mapCfg.mapName, tostring(count), tostring(condition.winCount))
    end
  end
  return string.format(textRes.Task[77], mapCfg.mapName, tostring(condition.winCount))
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetKillMonsterCount = function(self, taskCfg, conditionID)
  local condition = TaskInterface.GetTaskConditionKillMonsterCount(conditionID)
  local PetInterface = require("Main.Pet.Interface")
  local monsCfg = PetInterface.GetMonsterCfg(condition.killMonsterId)
  local mapCfg = require("Main.Map.Interface").GetMapCfg(condition.killMonsterMapId)
  if self._conditionData ~= nil then
    local found = false
    local count = 0
    for k, v in pairs(self._conditionData) do
      if v.conId == condition.id then
        count = v.param
        found = true
        break
      end
    end
    if found then
      return string.format(textRes.Task[80], mapCfg.mapName, monsCfg.name)
    end
  end
  return string.format(textRes.Task[81], mapCfg.mapName, monsCfg.name)
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetKillNPC = function(self, taskCfg, conditionID)
  local condition = TaskInterface.GetTaskConditionKillNpc(conditionID)
  local NPCInterface = require("Main.npc.NPCInterface")
  local NPCCfg = NPCInterface.GetNPCCfg(condition.fixNPCId)
  return string.format(textRes.Task[85], NPCCfg.npcName)
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetTime = function(self, taskCfg, conditionID)
  local condition = TaskInterface.GetTaskConditionTime(conditionID)
  local nowSec = GetServerTime()
  local endingTime = nowSec
  local found = false
  if self._conditionData ~= nil then
    for k, v in pairs(self._conditionData) do
      if v.conId == condition.id then
        endingTime = v.param:ToNumber()
        found = true
        break
      end
    end
  end
  if found == true then
    local remainTime = endingTime - nowSec
    if remainTime < 0 then
      remainTime = 0
    end
    return condition.timeLimitTitle .. tostring(math.ceil(remainTime)) .. textRes.Task[90]
  end
  return condition.timeLimitTitle .. condition.timeLimit .. textRes.Task[90]
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetGraphFinishCount = function(self, taskCfg, conditionID)
  return ""
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetGatherItem = function(self, taskCfg, conditionID)
  local condition = TaskInterface.GetTaskConditionGatherItem(conditionID)
  if self._conditionData ~= nil then
    local found = false
    local count = 0
    for k, v in pairs(self._conditionData) do
      if v.conId == condition.id then
        local pv = v.param:ToNumber()
        count = math.max(pv, 0)
        found = true
        break
      end
    end
    if found then
      return string.format(textRes.Task[116], condition.name, count, condition.gatherCount)
    end
  end
  return string.format(textRes.Task[115], condition.name, condition.gatherCount)
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetTalkWithNPC = function(self, taskCfg, conditionID)
  local condition = TaskInterface.GetTaskConditionNPCDialog(conditionID)
  local NPCInterface = require("Main.npc.NPCInterface")
  local NPCCfg = NPCInterface.GetNPCCfg(condition.NpcID)
  return string.format(textRes.Task[100], NPCCfg.npcName)
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetPet = function(self, taskCfg, conditionID)
  local condition = TaskInterface.GetTaskConditionPet(conditionID)
  local PetUtility = require("Main.Pet.PetUtility").Instance()
  local petCfg = PetUtility:GetPetCfg(condition.petId)
  if self._conditionData ~= nil then
    local found = false
    local count = 0
    for k, v in pairs(self._conditionData) do
      if v.conId == condition.id then
        local pv = v.param:ToNumber()
        count = math.max(pv, 0)
        found = true
        break
      end
    end
    if found then
      return string.format(textRes.Task[110], petCfg.petName, count, condition.petCount)
    end
  end
  if condition.petCount > 1 then
    return string.format(textRes.Task[111], petCfg.templateName, condition.petCount)
  end
  return string.format(textRes.Task[112], petCfg.templateName)
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetLeitaiWin = function(self, taskCfg, conditionID)
  local condition = TaskInterface.TaskConditionLeiTaiWinCountCfg(conditionID)
  if self._conditionData ~= nil then
    local found = false
    local count = 0
    for k, v in pairs(self._conditionData) do
      if v.conId == condition.id then
        local pv = v.param:ToNumber()
        count = math.max(pv, 0)
        found = true
        break
      end
    end
    if found then
      return string.format(textRes.Task[116], count, condition.winCount)
    end
  end
  return string.format(textRes.Task[117], condition.winCount)
end
def.static(TaskString, "table", "number", "=>", "string")._GeneratTaskTargetActivityFinish = function(self, taskCfg, conditionID)
  local condition = TaskInterface.TaskConditionActivityFinishCountCfg(conditionID)
  if self._conditionData ~= nil then
    local found = false
    local count = 0
    for k, v in pairs(self._conditionData) do
      if v.conId == condition.id then
        local pv = v.param:ToNumber()
        count = math.max(pv, 0)
        found = true
        break
      end
    end
    if found then
      return string.format(textRes.Task[116], count, condition.circleCount)
    end
  end
  return string.format(textRes.Task[117], condition.circleCount)
end
def.static("string", "=>", "string").DoReplace = function(param)
  local tFn = {}
  tFn.name = TaskString.TaskStringName
  tFn.sex = TaskString.TaskStringSex
  tFn.level = TaskString.TaskStringLevel
  tFn.menpai = TaskString.TaskStringMenpai
  tFn.killmonster = TaskString.TaskStringKillMonster
  tFn.killmonstername = TaskString.TaskStringKillMonsterName
  tFn.getpet = TaskString.TaskStringGetPet
  tFn.acceptnpc = TaskString.TaskStringAcceptNpc
  tFn.finishnpc = TaskString.TaskStringFinish
  tFn.talknpc = TaskString.TaskStringTalkNpc
  tFn.killnpc = TaskString.TaskStringKillNpc
  tFn.giveitem = TaskString.TaskStringGiveItem
  tFn.item = TaskString.TaskStringItem
  tFn.gatheritem = TaskString.TaskStringGatherItem
  tFn.fightwin = TaskString.TaskStringFightCount
  tFn.winCount = TaskString.TaskStringLeitaiWin
  tFn.circleCount = TaskString.TaskStringActivityFinish
  tFn.faceID = TaskString.TaskStringFaceID
  tFn.timeLimit = TaskString.TaskStringTimeLimt
  tFn.shareCount = TaskString.TaskStringShareNum
  local t = string.split(param, "/")
  local f = t[1]
  local fn = tFn[f]
  if fn == nil then
    return "_@_" .. f .. "_@_"
  end
  local ret = fn(t, instance._taskCfg, instance._conditionData)
  return ret
end
def.static("table", "table", "table", "=>", "string").TaskStringName = function(params, taskCfg, condData)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return "Hero Name"
  end
  return "[00ff00]" .. heroProp.name .. "[-]"
end
def.static("table", "table", "table", "=>", "string").TaskStringSex = function(params, taskCfg, condData)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return "Hero Gender"
  end
  if heroProp.gender == 1 then
    return params[2]
  end
  return params[3]
end
def.static("table", "table", "table", "=>", "string").TaskStringLevel = function(params, taskCfg, condData)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return "0"
  end
  return "" .. heroProp.level
end
def.static("table", "table", "table", "=>", "string").TaskStringMenpai = function(params, taskCfg, condData)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return "!!menpai!!!"
  end
  local occupationName = GetOccupationName(heroProp.occupation)
  return occupationName
end
def.static("table", "table", "table", "=>", "string").TaskStringKillMonster = function(params, taskCfg, condData)
  local condtype = TaskConClassType.CON_KILL_MONSTER
  local condID = taskCfg.FindFinishConditionID(condtype)
  local condCfg = TaskInterface.GetTaskConditionKillMonsterCount(condID)
  local PetInterface = require("Main.Pet.Interface")
  local monsterCfg = PetInterface.GetMonsterCfg(condCfg.killMonsterId)
  local ret
  if condCfg.killMonsterCount > 1 then
    if condData ~= nil and condData[1] ~= nil then
      warn("************************ ")
      ret = string.format(textRes.Task[82], monsterCfg.name, tostring(condData[1].param), condCfg.killMonsterCount)
    else
      ret = string.format(textRes.Task[83], monsterCfg.name, condCfg.killMonsterCount)
    end
  else
    ret = string.format(textRes.Task[84], monsterCfg.name)
  end
  return ret
end
def.static("table", "table", "table", "=>", "string").TaskStringKillMonsterName = function(params, taskCfg, condData)
  local condtype = TaskConClassType.CON_KILL_MONSTER
  local condID = taskCfg.FindFinishConditionID(condtype)
  local condCfg = TaskInterface.GetTaskConditionKillMonsterCount(condID)
  local PetInterface = require("Main.Pet.Interface")
  local monsterCfg = PetInterface.GetMonsterCfg(condCfg.killMonsterId)
  local ret = string.format(textRes.Task[84], monsterCfg.name)
  return ret
end
def.static("table", "table", "table", "=>", "string").TaskStringGetPet = function(params, taskCfg, condData)
  local condtype = TaskConClassType.CON_PET
  local conditionID = taskCfg.FindFinishConditionID(condtype)
  if conditionID > 0 then
    local condition = TaskInterface.GetTaskConditionPet(conditionID)
    if condition ~= nil then
      local PetUtility = require("Main.Pet.PetUtility")
      local petCfg = PetUtility.Instance():GetPetCfg(condition.petId)
      if petCfg ~= nil then
        if condition.petCount > 1 then
          return string.format(textRes.Task[113], petCfg.templateName, condition.petCount)
        else
          return string.format(textRes.Task[114], petCfg.templateName)
        end
      else
        error("******** TaskStringGetPet petCfg == nil taskID = " .. taskCfg.taskID .. " petId =" .. tostring(condition.petId))
      end
    else
      error("******** TaskStringGetPet condition == nil taskID = " .. taskCfg.taskID .. " conditionID = " .. tostring(conditionID))
    end
  else
    error("******** TaskStringGetPet conditionID <= 0 taskID = " .. taskCfg.taskID .. " conditionID = " .. tostring(conditionID))
  end
  return "@" .. textRes.Task[300] .. "@"
end
def.static("table", "table", "table", "=>", "string").TaskStringAcceptNpc = function(params, taskCfg, condData)
  local NPCInterface = require("Main.npc.NPCInterface")
  local giveTaskNPCCfg = NPCInterface.GetNPCCfg(taskCfg.GetGiveTaskNPC())
  return "[00ff00]" .. giveTaskNPCCfg.npcName .. "[-]"
end
def.static("table", "table", "table", "=>", "string").TaskStringFinish = function(params, taskCfg, condData)
  local NPCInterface = require("Main.npc.NPCInterface")
  local finishTaskNPCCfg = NPCInterface.GetNPCCfg(taskCfg.GetFinishTaskNPC())
  return "[00ff00]" .. finishTaskNPCCfg.npcName .. "[-]"
end
def.static("table", "table", "table", "=>", "string").TaskStringTalkNpc = function(params, taskCfg, condData)
  local condtype = TaskConClassType.CON_NPC_DLG
  local condID = taskCfg.FindFinishConditionID(condtype)
  local condCfg = TaskInterface.GetTaskConditionNPCDialog(condID)
  local NPCInterface = require("Main.npc.NPCInterface")
  local NPCCfg = NPCInterface.GetNPCCfg(condCfg.NpcID)
  return "[00ff00]" .. NPCCfg.npcName .. "[-]"
end
def.static("table", "table", "table", "=>", "string").TaskStringKillNpc = function(params, taskCfg, condData)
  local condtype = TaskConClassType.CON_KILL_NPC
  local condID = taskCfg.FindFinishConditionID(condtype)
  local condCfg = TaskInterface.GetTaskConditionKillNpc(condID)
  local NPCInterface = require("Main.npc.NPCInterface")
  local NPCCfg = NPCInterface.GetNPCCfg(condCfg.fixNPCId)
  if condData and condData[1] and condData[1].subParam ~= "" then
    return "[00ff00]" .. condData[1].subParam .. "[-]"
  end
  return "[00ff00]" .. NPCCfg.npcName .. "[-]"
end
def.static("table", "table", "table", "=>", "string").TaskStringFaction = function(params, taskCfg, condData)
  return "@" .. textRes.Task[301] .. "@"
end
def.static("table", "table", "table", "=>", "string").TaskStringGiveItem = function(params, taskCfg, condData)
  local condtype = TaskConClassType.CON_BAG
  local condID = taskCfg.FindFinishConditionID(condtype)
  local condition = TaskInterface.GetTaskConditionBag(condID)
  if condition == nil then
    return
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local condCfg = ItemUtils.GetItemFilterCfg(condition.takeCfgId)
  local ret = ""
  local takeItemBase = ItemUtils.GetItemBase2(condition.takeCfgId)
  if takeItemBase == nil then
    local spcfg = ItemUtils.GetItemFilterCfg(condition.takeCfgId)
    if spcfg ~= nil then
      ret = ret .. "[00ff00]" .. spcfg.name .. "[-]"
      if condition.takeCfgCount > 1 then
        local conData = instance._conditionData
        local found = false
        if conData ~= nil then
          for k, v in pairs(conData) do
            if v.conId == condID then
              ret = ret .. "(" .. tostring(v.param) .. "/" .. condition.takeCfgCount .. ")"
              found = true
            end
          end
        end
        if found == false then
          ret = ret .. " x " .. condition.takeCfgCount
        end
      end
    end
  else
    ret = "[00ff00]" .. takeItemBase.name .. "[-]"
    if condition.takeCfgCount > 1 then
      local conData = instance._conditionData
      local found = false
      if conData ~= nil then
        for k, v in pairs(conData) do
          if v.conId == condID then
            ret = ret .. "(" .. tostring(v.param) .. "/" .. condition.takeCfgCount .. ")"
            found = true
          end
        end
      end
      if found == false then
        ret = ret .. " x " .. condition.takeCfgCount
      end
    end
  end
  return ret
end
def.static("table", "table", "table", "=>", "string").TaskStringItem = function(params, taskCfg, condData)
  local condtype = TaskConClassType.CON_BAG
  local condID = taskCfg.FindFinishConditionID(condtype)
  local condition = TaskInterface.GetTaskConditionBag(condID)
  local ret = ""
  local ItemUtils = require("Main.Item.ItemUtils")
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  local takeItemBase = ItemUtils.GetItemBase2(condition.takeCfgId)
  if takeItemBase == nil then
    local spcfg = ItemUtils.GetItemFilterCfg(condition.takeCfgId)
    if spcfg ~= nil then
      ret = ret .. "[00ff00]" .. spcfg.name .. "[-]"
      if condition.takeCfgCount > 1 then
        local found = false
        if condData ~= nil then
          for k, v in pairs(condData) do
            if v.conId == condID then
              if instance and instance._state == TaskConsts.TASK_STATE_FINISH then
                ret = ret .. " x " .. condition.takeCfgCount
              else
                ret = ret .. "(" .. tostring(v.param) .. "/" .. condition.takeCfgCount .. ")"
              end
              found = true
            end
          end
        end
        if found == false then
          ret = ret .. " x " .. condition.takeCfgCount
        end
      end
    end
  else
    ret = "[00ff00]" .. takeItemBase.name .. "[-]"
    if condition.takeCfgCount > 1 then
      local found = false
      if condData ~= nil then
        for k, v in pairs(condData) do
          if v.conId == condID then
            if instance and instance._state == TaskConsts.TASK_STATE_FINISH then
              ret = ret .. " x " .. condition.takeCfgCount
            else
              ret = ret .. "(" .. tostring(v.param) .. "/" .. condition.takeCfgCount .. ")"
            end
            found = true
          end
        end
      end
      if found == false then
        ret = ret .. " x " .. condition.takeCfgCount
      end
    end
  end
  return ret
end
def.static("table", "table", "table", "=>", "string").TaskStringGatherItem = function(params, taskCfg, condData)
  local condtype = TaskConClassType.CON_GATHER_ITEM
  local condID = taskCfg.FindFinishConditionID(condtype)
  local condition = TaskInterface.GetTaskConditionGatherItem(condID)
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  if condData ~= nil then
    local found = false
    local count = 0
    for k, v in pairs(condData) do
      if v.conId == condition.id then
        local pv = v.param:ToNumber()
        count = math.max(pv, 0)
        found = true
        break
      end
    end
    if found then
      if instance and instance._state == TaskConsts.TASK_STATE_FINISH then
        return string.format(textRes.Task[83], condition.name, condition.gatherCount)
      else
        return string.format(textRes.Task[82], condition.name, count, condition.gatherCount)
      end
    end
  end
  return string.format(textRes.Task[83], condition.name, condition.gatherCount)
end
def.static("table", "table", "table", "=>", "string").TaskStringFightCount = function(params, taskCfg, condData)
  local condtype = TaskConClassType.CON_MAP_WIN_COUNT
  local conditionID = taskCfg.FindFinishConditionID(condtype)
  local condition = TaskInterface.GetTaskConditionWinCount(conditionID)
  local mapInterface = require("Main.Map.Interface")
  local mapCfg = mapInterface.GetMapCfg(condition.mapId)
  if condData ~= nil then
    local found = false
    local count = 0
    for k, v in pairs(condData) do
      if v.conId == condition.id then
        count = v.param
        found = true
        break
      end
    end
    if found then
      return string.format(textRes.Task[76], mapCfg.mapName, tostring(count), tostring(condition.winCount))
    end
  end
  return string.format(textRes.Task[77], mapCfg.mapName, tostring(condition.winCount))
end
def.static("table", "table", "table", "=>", "string").TaskStringLeitaiWin = function(params, taskCfg, condData)
  local condtype = TaskConClassType.CON_LEITAI_WIN
  local conditionID = taskCfg.FindFinishConditionID(condtype)
  local condition = TaskInterface.TaskConditionLeiTaiWinCountCfg(conditionID)
  if condData ~= nil then
    local found = false
    local count = 0
    for k, v in pairs(condData) do
      if v.conId == condition.id then
        local pv = v.param:ToNumber()
        count = math.max(pv, 0)
        found = true
        break
      end
    end
    if found then
      return string.format(textRes.Task[118], count, condition.winCount)
    end
  end
  return string.format(textRes.Task[119], condition.winCount)
end
def.static("table", "table", "table", "=>", "string").TaskStringActivityFinish = function(params, taskCfg, condData)
  local condtype = TaskConClassType.CON_ACTIVITY_FINISH
  local conditionID = taskCfg.FindFinishConditionID(condtype)
  local condition = TaskInterface.TaskConditionActivityFinishCountCfg(conditionID)
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  if condData ~= nil then
    local found = false
    local count = 0
    for k, v in pairs(condData) do
      if v.conId == condition.id then
        local pv = v.param:ToNumber()
        count = math.max(pv, 0)
        found = true
        break
      end
    end
    if found then
      if instance and instance._state == TaskConsts.TASK_STATE_FINISH then
        return string.format(textRes.Task[118], condition.circleCount, condition.circleCount)
      else
        return string.format(textRes.Task[118], count, condition.circleCount)
      end
    end
  end
  return string.format(textRes.Task[119], condition.circleCount)
end
def.static("table", "table", "table", "=>", "string").TaskStringTime = function(params, taskCfg, condData)
  local condtype = TaskConClassType.CON_TIME_LIMIT
  local condID = taskCfg.FindFinishConditionID(condtype)
  local condCfg = TaskInterface.GetTaskConditionKillMonsterCount(condID)
  if condCfg ~= nil then
    return condCfg.timeLimitTitle .. condCfg.timeLimit .. textRes.Task[90]
  end
  return "@" .. textRes.Task[302] .. "@"
end
def.static("table", "table", "table", "=>", "string").TaskStringRetime = function(params, taskCfg, condData)
  return "@" .. textRes.Task[303] .. "@"
end
def.static("table", "table", "table", "=>", "string").TaskStringFaceID = function(params, taskCfg, condData)
  local faceID = tonumber(tostring(params[2]))
  local strFaceID = string.format("%04d", faceID)
  return "<img src='Arts/Image/Atlas/Compressed/Emoji.prefab.u3dext:" .. strFaceID .. "' width=60 height=60 fps=8/>"
end
def.static("table", "table", "table", "=>", "string").TaskStringGoto = function(params, taskCfg, condData)
  return "@" .. textRes.Task[304] .. "@"
end
def.static("table", "table", "table", "=>", "string").TaskStringTimeLimt = function(params, taskCfg, conData)
  local condtype = TaskConClassType.CON_TIME_LIMIT
  local condID = taskCfg.FindFinishConditionID(condtype)
  local condition = TaskInterface.GetTaskConditionTime(condID)
  local nowSec = GetServerTime()
  local endingTime = nowSec
  local found = false
  if conData then
    for k, v in pairs(conData) do
      if v.conId == condID then
        endingTime = v.param:ToNumber()
        found = true
        break
      end
    end
  end
  if found == true then
    local remainTime = endingTime - nowSec
    if remainTime < 0 then
      remainTime = 0
    end
    local hour = math.floor(remainTime / 3600)
    local min = math.floor((remainTime - hour * 3600) / 60)
    local sec = remainTime - hour * 3600 - min * 60
    if hour > 0 then
      return tostring(hour) .. textRes.Task[251] .. tostring(min) .. textRes.Task[252] .. tostring(sec) .. textRes.Task[90]
    end
    if min > 0 then
      return tostring(min) .. textRes.Task[252] .. tostring(sec) .. textRes.Task[90]
    end
    return tostring(sec) .. textRes.Task[90]
  end
  return 0 .. textRes.Task[90]
end
def.static("table", "table", "table", "=>", "string").TaskStringShareNum = function(params, taskCfg, conData)
  local condtype = TaskConClassType.CON_SHARE
  local condID = taskCfg.FindFinishConditionID(condtype)
  local sharePengYouCfg = TaskInterface.GetTaskConSharePengYouQuan(condID)
  local finishNum = 0
  if conData then
    for k, v in pairs(conData) do
      if v.conId == condID then
        finishNum = v.param:ToNumber()
        break
      end
    end
  end
  if finishNum < 0 then
    finishNum = 0
  end
  return "(" .. finishNum .. "/" .. sharePengYouCfg.needShareCount .. ")"
end
TaskString.Commit()
return TaskString
