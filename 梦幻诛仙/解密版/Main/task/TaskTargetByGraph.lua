local Lplus = require("Lplus")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local TaskTargetByGraph = Lplus.Class("TaskTargetByGraph")
local ActivityType = require("consts.mzm.gsp.activity.confbean.ActivityType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local TaskInterface = require("Main.task.TaskInterface")
local taskInterface = TaskInterface.Instance()
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
local def = TaskTargetByGraph.define
local instance
def.static("=>", TaskTargetByGraph).Instance = function()
  if instance == nil then
    instance = TaskTargetByGraph()
    instance:Init()
  end
  return instance
end
def.field("table")._graphTargetFnTable = nil
def.field("boolean")._needRefresh = false
def.field("number")._lastCircleTaskRemainTime = 0
def.method().Init = function(self)
  self._graphTargetFnTable = {}
  self._graphTargetFnTable[constant.CircleTaskConsts.Circle_TASK_GRAPHIC_ID] = TaskTargetByGraph.CircleTaskGraphicTaskTarget
  self._graphTargetFnTable[constant.HuanHunMiShuConsts.HUANHUN_TASK_GRAPH_ID] = TaskTargetByGraph.HuanhunTaskGraphTaskTarget
  self._graphTargetFnTable[constant.GangMiFangConsts.GANGMIFANG_TASK_GRAPH_ID] = TaskTargetByGraph.GangMifangTarget
  self._graphTargetFnTable[constant.LingQiFengYinConsts.LINGQIFENGYIN_TASK_ICON_ID] = TaskTargetByGraph.LingQiFengYinTaskTarget
end
def.method("number", "=>", "boolean").HasCustomGraphicTaskTarget = function(self, graphID)
  return self._graphTargetFnTable[graphID] ~= nil
end
def.method("number", "number", "string", "=>", "string", "boolean").GetTaskGraphicTaskTarget = function(self, taskID, graphID, dispTarget)
  local fn = self._graphTargetFnTable[graphID]
  if fn ~= nil then
    local rets, retb = fn(self, taskID, graphID, dispTarget)
    return rets, retb
  end
  return "", false
end
def.static(TaskTargetByGraph, "number", "number", "string", "=>", "string", "boolean").CircleTaskGraphicTaskTarget = function(self, taskID, graphID, dispTarget)
  local endTime = taskInterface:GetLegendTime(taskID, graphID)
  if endTime == nil then
    return dispTarget, false
  else
    endTime = math.floor(endTime:ToNumber())
  end
  local nowSec = GetServerTime()
  local remainTime = endTime - nowSec
  if remainTime < 0 then
    if 0 <= self._lastCircleTaskRemainTime then
      self._lastCircleTaskRemainTime = remainTime
      return dispTarget, true
    end
    return dispTarget, false
  end
  self._lastCircleTaskRemainTime = remainTime
  remainTime = remainTime + 59
  local minite = math.floor(remainTime / 60)
  if minite > 2 then
    dispTarget = dispTarget .. "\n" .. string.format(textRes.Task[91], minite)
  else
    dispTarget = dispTarget .. [[

[ff0000]]] .. string.format(textRes.Task[91], minite) .. "[-]"
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    dispTarget = dispTarget .. "\n" .. textRes.Task[190]
    return dispTarget, false
  end
  local sceneInfo
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ON_HOOK_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    sceneInfo = {}
    sceneInfo.mapName = DynamicRecord.GetStringValue(entry, "mapName")
    sceneInfo.minLevel = DynamicRecord.GetIntValue(entry, "minLevel")
    sceneInfo.maxLevel = DynamicRecord.GetIntValue(entry, "maxLevel")
    if heroProp.level >= sceneInfo.minLevel and heroProp.level <= sceneInfo.maxLevel then
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  if sceneInfo ~= nil then
    dispTarget = dispTarget .. "\n" .. string.format(textRes.Task[191], sceneInfo.mapName)
  end
  return dispTarget, false
end
def.static(TaskTargetByGraph, "number", "number", "string", "=>", "string", "boolean").HuanhunTaskGraphTaskTarget = function(self, taskID, graphID, dispTarget)
  if activityInterface._huanhunTimeLimit == nil then
    return "", false
  end
  local enddingSec = activityInterface._huanhunTimeLimit:ToNumber() / 1000
  local nowSec = GetServerTime()
  local remainSec = math.max(0, enddingSec - nowSec)
  local hour = math.floor(remainSec / 3600)
  local min = math.floor(remainSec % 3600 / 60)
  local sec = math.floor(remainSec % 60)
  if hour > 0 then
    return string.format(textRes.Title[40], string.format(textRes.Title[9], hour, min)), false
  elseif min > 0 then
    return string.format(textRes.Title[40], string.format(textRes.Title[7], min, sec)), false
  else
    return string.format(textRes.Title[40], string.format(textRes.Title[8], sec)), false
  end
end
def.static(TaskTargetByGraph, "number", "number", "string", "=>", "string", "boolean").LingQiFengYinTaskTarget = function(self, taskID, graphID, dispTarget)
  if activityInterface._lingqifengyinEndTime == 0 then
    return "", false
  end
  local nowSec = GetServerTime()
  local remainSec = math.max(0, activityInterface._lingqifengyinEndTime - nowSec)
  local day = math.floor(remainSec / 86400)
  local hour = math.floor(remainSec % 86400 / 3600)
  local min = math.floor(remainSec % 3600 / 60)
  local sec = math.floor(remainSec % 60)
  if day > 0 then
    return string.format(textRes.Title[42], string.format(textRes.Title[41], day, hour)), false
  elseif hour > 0 then
    return string.format(textRes.Title[42], string.format(textRes.Title[9], hour, min)), false
  elseif min > 0 then
    return string.format(textRes.Title[42], string.format(textRes.Title[7], min, sec)), false
  else
    return string.format(textRes.Title[42], string.format(textRes.Title[8], sec)), false
  end
end
def.static(TaskTargetByGraph, "number", "number", "string", "=>", "string", "boolean").GangMifangTarget = function(self, taskID, graphID, dispTarget)
  local GangData = require("Main.Gang.data.GangData")
  if false == GangData.Instance():IsGetMifang() then
    return "", false
  end
  local GangUtility = require("Main.Gang.GangUtility")
  local itemList = GangData.Instance():GetMifangNeedItemList()
  local str = ""
  for k, v in pairs(itemList) do
    local itemBase = require("Main.Item.ItemUtils").GetItemBase(v)
    if str == "" then
      str = str .. itemBase.name
    else
      str = str .. "+" .. itemBase.name
    end
  end
  local mifangId = GangData.Instance():GetMifangCfgId()
  local mifangInfo = GangUtility.GetMifangInfo(mifangId)
  str = str .. "=" .. mifangInfo.miFangName
  local useTimes = GangData.Instance():GetMifangUseCount()
  local totalTimes = GangData.Instance():GetMifangTotalCount()
  local time = GangData.Instance():GetMifangEndTime() - GetServerTime()
  local minute = time / 60
  minute = math.ceil(Int64.ToNumber(minute))
  local timeStr = string.format(textRes.Task[306], minute)
  local total = string.format(textRes.Gang[123], str, useTimes, totalTimes, timeStr)
  return total, false
end
TaskTargetByGraph.Commit()
return TaskTargetByGraph
