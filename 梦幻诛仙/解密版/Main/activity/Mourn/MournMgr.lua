local Lplus = require("Lplus")
local MournMgr = Lplus.Class("MournMgr")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local MTaskInfo = require("netio.protocol.mzm.gsp.mourn.MTaskInfo")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local NPCInterface = require("Main.npc.NPCInterface")
local npcInterface = NPCInterface.Instance()
local def = MournMgr.define
def.field("table").mournInfos = nil
def.field("table").mournList = nil
def.field("number").questionTaskState = 0
def.field("boolean").isNeedRefresh = false
local instance
def.static("=>", MournMgr).Instance = function()
  if instance == nil then
    instance = MournMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mourn.SSynMournInfo", MournMgr.OnSSynMournInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mourn.SSynSingleMournInfo", MournMgr.OnSSynSingleMournInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mourn.SSynLastMourn", MournMgr.OnSSynLastMourn)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mourn.SMournNormalResult", MournMgr.OnSMournNormalResult)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, MournMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, MournMgr.OnNpcNomalServer)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MournMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, MournMgr.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, MournMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  npcInterface:RegisterNPCServiceCustomCondition(constant.CMournConsts.npcServiceId, MournMgr.OnNPCService_MournCondition)
end
def.method().Reset = function(self)
  self.mournInfos = {}
  self.mournList = {}
  self.questionTaskState = 1
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  warn("-----MournMgr toDo:", p1[1])
  if p1[1] == constant.CMournConsts.activityId then
    local MourPanel = require("Main.activity.Mourn.ui.MournPanel")
    MourPanel.Instance():ShowPanel()
  end
end
def.static("table", "table").OnNewDay = function(p1, p2)
  instance.mournInfos = {}
  instance.mournList = {}
  instance.questionTaskState = 1
  instance.isNeedRefresh = true
end
def.static("number", "=>", "boolean").OnNPCService_MournCondition = function(serviceId)
  if serviceId == constant.CMournConsts.npcServiceId then
    if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MOURN) then
      return false
    end
    local taskInterface = require("Main.task.TaskInterface").Instance()
    if taskInterface:HasTaskByGraphID(constant.CMournConsts.questionGraphId, true, true, true) == true then
      return false
    end
  end
  return true
end
def.static("table", "table").OnNpcNomalServer = function(p1, p2)
  if p1[1] == constant.CMournConsts.npcServiceId and p1[2] == constant.CMournConsts.npcId then
    local curNum = instance:getMournNum()
    if curNum >= constant.CMournConsts.countMax then
      if instance.questionTaskState == MTaskInfo.UN_ACCEPTED then
        if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MOURN) then
          Toast(textRes.activity[407])
          return
        end
        local p = require("netio.protocol.mzm.gsp.mourn.CLastMournReq").new()
        gmodule.network.sendProtocol(p)
      elseif instance.questionTaskState == MTaskInfo.ALREADY_ACCEPTED then
        Toast(textRes.activity[606])
      elseif instance.questionTaskState == MTaskInfo.FINISHED then
        Toast(textRes.activity[602])
      end
    else
      Toast(textRes.activity[601])
    end
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local openId = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MOURN
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if IsFeatureOpen(openId) then
    activityInterface:removeCustomCloseActivity(constant.CMournConsts.activityId)
  else
    activityInterface:addCustomCloseActivity(constant.CMournConsts.activityId)
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local openId = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MOURN
  if p1.feature == openId then
    local activityInterface = require("Main.activity.ActivityInterface").Instance()
    if IsFeatureOpen(openId) then
      activityInterface:removeCustomCloseActivity(constant.CMournConsts.activityId)
    else
      activityInterface:addCustomCloseActivity(constant.CMournConsts.activityId)
    end
  end
end
def.static("number", "=>", "table").GetMournCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MOURN_CFG, id)
  if record == nil then
    warn("GetMournCfg got nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.deadName = record:GetStringValue("deadName")
  cfg.modelId = record:GetIntValue("modelId")
  cfg.story = record:GetStringValue("story")
  cfg.graphId = record:GetIntValue("graphId")
  cfg.awardId = record:GetIntValue("awardId")
  return cfg
end
def.static("=>", "table").GetAllMournCfg = function()
  local cfgList = {}
  if instance.mournList then
    for i, v in ipairs(instance.mournList) do
      local cfg = MournMgr.GetMournCfg(v)
      if cfg then
        table.insert(cfgList, cfg)
      end
    end
  end
  return cfgList
end
def.static("table").OnSSynMournInfo = function(p)
  warn("-------OnSSynMournInfo---")
  instance.mournInfos = p.mournInfos
  instance.mournList = p.sort
  instance.questionTaskState = p.questionTaskState
  instance.isNeedRefresh = false
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Mourn_Info_Change, nil)
end
def.static("table").OnSSynSingleMournInfo = function(p)
  warn("-------OnSSynSingleMournInfo:", p.mournInfo, type(p.mournInfo), p.mournInfo.state)
  instance.mournInfos[p.mournId] = p.mournInfo
  if p.mournInfo.state == MTaskInfo.FINISHED then
    local callback = function(id)
      if id == 1 then
        local MourPanel = require("Main.activity.Mourn.ui.MournPanel")
        MourPanel.Instance():ShowPanel()
      end
    end
    local str = textRes.activity[603]
    if instance:getMournNum() >= constant.CMournConsts.countMax then
      str = textRes.activity[604]
    end
    CommonConfirmDlg.ShowConfirm("", str, callback, nil)
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Mourn_Info_Change, nil)
end
def.static("table").OnSSynLastMourn = function(p)
  warn("--------OnSSynLastMourn:", p.state)
  instance.questionTaskState = p.state
end
def.static("table").OnSMournNormalResult = function(p)
  warn("---------OnSMournNormalResult:", p.result)
  local str = textRes.activity.mournError[p.result]
  if str then
    Toast(str)
  end
end
def.method("=>", "number").getMournNum = function(self)
  local num = 0
  if self.mournInfos then
    for i, v in pairs(self.mournInfos) do
      if v.state == MTaskInfo.FINISHED then
        num = num + 1
      end
    end
  end
  return num
end
def.method("number", "=>", "number").getMournState = function(self, mournId)
  if self.mournInfos and self.mournInfos[mournId] then
    return self.mournInfos[mournId].state or MTaskInfo.UN_ACCEPTED
  end
  return MTaskInfo.UN_ACCEPTED
end
def.method("=>", "string").getRefreshTimeStr = function()
  local curTime = GetServerTime()
  local curTimeTable = AbsoluteTimer.GetServerTimeTable(curTime)
  local nowYear = curTimeTable.year
  local nowMonth = curTimeTable.month
  local nowDay = curTimeTable.day
  local resetTime = AbsoluteTimer.GetServerTimeByDate(nowYear, nowMonth, nowDay, 23, 59, 59)
  local leftTime = resetTime - curTime
  if leftTime < 0 then
    leftTime = 0
  end
  local hours = math.floor(leftTime / 3600)
  local min = math.floor((leftTime - hours * 3600) / 60)
  local sec = leftTime - hours * 3600 - min * 60
  return string.format("%02d:%02d:%02d", hours, min, sec)
end
return MournMgr.Commit()
