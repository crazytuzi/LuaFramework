local Lplus = require("Lplus")
local TaskAceptOperationByGraph = Lplus.Class("TaskAceptOperationByGraph")
local def = TaskAceptOperationByGraph.define
local TaskInterface = require("Main.task.TaskInterface")
local taskInterface = TaskInterface.Instance()
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local instance
def.static("=>", TaskAceptOperationByGraph).Instance = function()
  if instance == nil then
    instance = TaskAceptOperationByGraph()
    instance:Init()
  end
  return instance
end
def.field("table")._taskGraphFnTable = nil
def.method().Init = function(self)
  self._taskGraphFnTable = {}
  self._taskGraphFnTable[constant.BountyConsts.BOUNTYHUNTER_TASK_GRAPH_ID_1] = TaskAceptOperationByGraph.OnBountyHunterAceptTask
  self._taskGraphFnTable[constant.BountyConsts.BOUNTYHUNTER_TASK_GRAPH_ID_2] = TaskAceptOperationByGraph.OnBountyHunterAceptTask
  self._taskGraphFnTable[constant.BountyConsts.BOUNTYHUNTER_TASK_GRAPH_ID_3] = TaskAceptOperationByGraph.OnBountyHunterAceptTask
  self._taskGraphFnTable[constant.BountyConsts.BOUNTYHUNTER_TASK_GRAPH_ID_4] = TaskAceptOperationByGraph.OnBountyHunterAceptTask
end
def.method("number", "number").AceptTask = function(self, taskID, graphID)
  local fn = self._taskGraphFnTable[graphID]
  if fn ~= nil then
    fn(self, taskID, graphID)
    return
  end
  local pAccept = require("netio.protocol.mzm.gsp.task.CAcceptTaskReq").new(taskID, graphID)
  gmodule.network.sendProtocol(pAccept)
end
def.static(TaskAceptOperationByGraph, "number", "number").OnBountyHunterAceptTask = function(self, taskID, graphID)
  local pGiveUp = require("netio.protocol.mzm.gsp.bounty.CGetBountyTaskReq").new(graphID, taskID)
  gmodule.network.sendProtocol(pGiveUp)
end
TaskAceptOperationByGraph.Commit()
return TaskAceptOperationByGraph
