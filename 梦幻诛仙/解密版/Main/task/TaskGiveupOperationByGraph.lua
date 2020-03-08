local Lplus = require("Lplus")
local TaskGiveupOperationByGraph = Lplus.Class("TaskGiveupOperationByGraph")
local def = TaskGiveupOperationByGraph.define
local TaskInterface = require("Main.task.TaskInterface")
local taskInterface = TaskInterface.Instance()
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local instance
def.static("=>", TaskGiveupOperationByGraph).Instance = function()
  if instance == nil then
    instance = TaskGiveupOperationByGraph()
    instance:Init()
  end
  return instance
end
def.field("table")._taskGraphFnTable = nil
def.method().Init = function(self)
  self._taskGraphFnTable = {}
  self._taskGraphFnTable[constant.BountyConsts.BOUNTYHUNTER_TASK_GRAPH_ID_1] = TaskGiveupOperationByGraph.OnBountyHunterGiveUpTask
  self._taskGraphFnTable[constant.BountyConsts.BOUNTYHUNTER_TASK_GRAPH_ID_2] = TaskGiveupOperationByGraph.OnBountyHunterGiveUpTask
  self._taskGraphFnTable[constant.BountyConsts.BOUNTYHUNTER_TASK_GRAPH_ID_3] = TaskGiveupOperationByGraph.OnBountyHunterGiveUpTask
  self._taskGraphFnTable[constant.BountyConsts.BOUNTYHUNTER_TASK_GRAPH_ID_4] = TaskGiveupOperationByGraph.OnBountyHunterGiveUpTask
end
def.method("number", "number").GiveUpTask = function(self, taskID, graphID)
  local fn = self._taskGraphFnTable[graphID]
  if fn ~= nil then
    fn(self, taskID, graphID)
    return
  end
  local pGiveUp = require("netio.protocol.mzm.gsp.task.CGiveUpTaskReq").new(taskID, graphID)
  gmodule.network.sendProtocol(pGiveUp)
end
def.static(TaskGiveupOperationByGraph, "number", "number").OnBountyHunterGiveUpTask = function(self, taskID, graphID)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  heroModule.myRole:Stop()
  local XunluTip = require("Main.Hero.ui.XunluTip")
  XunluTip.HideXunlu()
  local pGiveUp = require("netio.protocol.mzm.gsp.bounty.CGiveUpBTaskReq").new(graphID, taskID)
  gmodule.network.sendProtocol(pGiveUp)
end
TaskGiveupOperationByGraph.Commit()
return TaskGiveupOperationByGraph
