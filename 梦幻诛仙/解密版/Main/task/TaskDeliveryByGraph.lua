local Lplus = require("Lplus")
local TaskDeliveryByGraph = Lplus.Class("TaskDeliveryByGraph")
local def = TaskDeliveryByGraph.define
local TaskInterface = require("Main.task.TaskInterface")
local taskInterface = TaskInterface.Instance()
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local instance
local G_tblRegistTastGraph = {}
def.static("=>", TaskDeliveryByGraph).Instance = function()
  if instance == nil then
    instance = TaskDeliveryByGraph()
    instance:Init()
  end
  return instance
end
def.field("table")._taskGraphFnTable = nil
def.method().Init = function(self)
  self._taskGraphFnTable = {}
  self._taskGraphFnTable[constant.HuanHunMiShuConsts.HUANHUN_TASK_GRAPH_ID] = TaskDeliveryByGraph.OnHuanhunTaskGraph
  self._taskGraphFnTable[constant.GangMiFangConsts.GANGMIFANG_TASK_GRAPH_ID] = TaskDeliveryByGraph.OnTaskTraceNotifyAnother
  self._taskGraphFnTable[constant.LingQiFengYinConsts.LINGQIFENGYIN_TASK_ICON_ID] = TaskDeliveryByGraph.OnLingQiFengYinTaskGraph
  for k, v in pairs(G_tblRegistTastGraph) do
    self._taskGraphFnTable[k] = v
  end
end
def.static("number", "function").RegisteTaskGraph = function(taskGraphId, func)
  if taskGraphId == nil or func == nil then
    return
  end
  G_tblRegistTastGraph[taskGraphId] = func
end
def.method("number", "number", "=>", "boolean").DeliveryByGraph = function(self, taskID, graphID)
  local fn = self._taskGraphFnTable[graphID]
  if fn ~= nil then
    fn(taskID, graphID)
    return false
  end
  local guideTaskCfg = TaskInterface.GetGuideTaskCfg(taskID)
  if guideTaskCfg ~= nil then
    if PlayerIsInFight() == true then
      warn("********************\229\156\168\230\136\152\230\150\151\228\184\173\229\143\145\232\181\183\230\140\135\229\188\149\228\187\187\229\138\161\229\175\187\232\183\175\239\188\140\229\188\138\230\142\137\239\188\129")
      return true
    end
    local taskCfg = TaskInterface.GetTaskCfg(taskID)
    local hasTask = false
    local infos = taskInterface:GetTaskInfos()
    for taskId, graphIdValue in pairs(infos) do
      for graphId, info in pairs(graphIdValue) do
        if guideTaskCfg.graphIDSet[graphId] ~= nil and (info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH) then
          hasTask = true
          Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TaskFindPath, {taskId, graphId})
        end
      end
    end
    if hasTask == false then
      Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_GotoNPC, {
        npcID = guideTaskCfg.NPCID,
        useFlySword = taskCfg.useFlySword
      })
    end
    return false
  end
  return true
end
def.static("number", "number").OnHuanhunTaskGraph = function(taskID, graphID)
  local myRoleID = _G.GetMyRoleID()
  local huanhunItemInfos = activityInterface._huanhunItemInfos
  if huanhunItemInfos == nil or activityInterface._huanhunTimeLimit == nil then
    return
  end
  local huanhun = require("Main.activity.ui.Huanhun").Instance()
  huanhun:SetEnddingSec(activityInterface._huanhunTimeLimit:ToNumber() / 1000)
  huanhun:ShowDlg(myRoleID, huanhunItemInfos)
end
def.static("number", "number").OnLingQiFengYinTaskGraph = function(taskID, graphID)
  local MassExpInfo = require("netio.protocol.mzm.gsp.massexp.MassExpInfo")
  if activityInterface._lingqifengyinStatus == MassExpInfo.STATUS_ACCEPTED then
    local LingQiFengYinPanel = require("Main.activity.ui.LingQiFengYinPanel")
    LingQiFengYinPanel.Instance():ShowDlg()
  end
end
def.static("number", "number").OnTaskTraceNotifyAnother = function(taskID, graphID)
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TaskTraceNotifyAnother, {taskID, graphID})
end
TaskDeliveryByGraph.Commit()
return TaskDeliveryByGraph
