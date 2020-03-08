local Lplus = require("Lplus")
local BTGTask = Lplus.Class("BTGTask")
local BackToGameUtils = require("Main.BackToGame.BackToGameUtils")
local BackGameActivityTaskInfo = require("netio.protocol.mzm.gsp.backgameactivity.BackGameActivityTaskInfo")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = BTGTask.define
local instance
def.static("=>", BTGTask).Instance = function()
  if instance == nil then
    instance = BTGTask()
  end
  return instance
end
def.field("userdata").m_stateChangeTime = nil
def.field("number").m_state = 0
def.field("number").m_cfgId = 0
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SAcceptBackGameExpTaskSuccess", BTGTask.OnSAcceptBackGameExpTaskSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SAcceptBackGameExpTaskFail", BTGTask.OnSAcceptBackGameExpTaskFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SBackGameExpTaskFinish", BTGTask.OnSBackGameExpTaskFinish)
end
def.method("table", "number").SetData = function(self, bean, cfgId)
  self.m_state = bean.task_state
  self.m_cfgId = cfgId
end
def.method().Clear = function(self)
  self.m_state = 0
  self.m_cfgId = 0
end
def.method().NewDay = function(self)
  if self.m_cfgId > 0 then
    self:SetState(BackGameActivityTaskInfo.NOT_FINISHED, Int64.new(GetServerTime()) * 1000)
  end
end
def.static("table").OnSAcceptBackGameExpTaskSuccess = function(p)
  Toast(textRes.BackToGame.Task[1])
end
def.static("table").OnSAcceptBackGameExpTaskFail = function(p)
  local tip = textRes.BackToGame.Task[p.error_code]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSBackGameExpTaskFinish = function(p)
  local self = BTGTask.Instance()
  self:SetState(BackGameActivityTaskInfo.FINISHED, p.task_finish_time)
end
def.method("number", "userdata").SetState = function(self, state, timeMs)
  if state ~= self.m_state then
    if self.m_stateChangeTime == nil then
      self.m_state = state
      Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.TaskUpdate, nil)
    elseif timeMs >= self.m_stateChangeTime then
      self.m_state = state
      Event.DispatchEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.TaskUpdate, nil)
    end
  end
end
def.method().GetTask = function(self)
  if self.m_state == BackGameActivityTaskInfo.NOT_FINISHED then
    local cfg = BackToGameUtils.GetTaskCfg(self.m_cfgId)
    local TaskInterface = require("Main.task.TaskInterface")
    local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
    local graphID = cfg.graphId
    local taskInfos = TaskInterface.Instance():GetTaskInfos()
    for taskId, graphIdValue in pairs(taskInfos) do
      for graphId, info in pairs(graphIdValue) do
        if graphId == graphID and (info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_CAN_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH) then
          Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {taskId, graphID})
          Toast(textRes.BackToGame.Task[7])
        end
      end
    end
    if cfg.memberCount > 1 then
      local TeamData = require("Main.Team.TeamData")
      if not TeamData.Instance():HasTeam() then
        Toast(string.format(textRes.BackToGame.Task[6], cfg.memberCount))
        return
      end
      if not TeamData.Instance():MeIsCaptain() then
        Toast(textRes.BackToGame.Task[5])
        return
      end
      local count = TeamData.Instance():GetMemberCount()
      if count < cfg.memberCount then
        Toast(string.format(textRes.BackToGame.Task[6], cfg.memberCount))
        return
      end
    end
    local p = require("netio.protocol.mzm.gsp.backgameactivity.CAcceptBackGameExpTaskReq").new()
    gmodule.network.sendProtocol(p)
  else
    Toast(textRes.BackToGame.Task[4])
  end
end
def.method("=>", "number").GetTipsId = function(self)
  local cfg = BackToGameUtils.GetTaskCfg(self.m_cfgId)
  return cfg.tipsId
end
def.method("=>", "number").GetTeamPlatformId = function(self)
  local cfg = BackToGameUtils.GetTaskCfg(self.m_cfgId)
  return cfg.teamPlatformId
end
def.method("=>", "boolean").GetTaskState = function(self)
  return self.m_state == BackGameActivityTaskInfo.FINISHED
end
def.method("=>", "boolean").IsRed = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_EXP)
  if open then
    return false
  else
    return false
  end
end
BTGTask.Commit()
return BTGTask
