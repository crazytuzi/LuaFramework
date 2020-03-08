local Lplus = require("Lplus")
local MedalMgr = Lplus.Class("MedalMgr")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ExploitConsts = require("netio.protocol.mzm.gsp.exploit.ExploitConsts")
local def = MedalMgr.define
local instance
def.field("table").medalInfo = nil
def.field("table").medalAwardInfo = nil
def.static("=>", MedalMgr).Instance = function()
  if instance == nil then
    instance = MedalMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.exploit.SSynExploitTargetsInfo", MedalMgr.OnSSynExploitTargetsInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.exploit.SSynExploitStagesInfo", MedalMgr.OnSSynExploitStagesInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.exploit.SSynExploitTargetInfo", MedalMgr.OnSSynExploitTargetInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.exploit.SGetTargetAwardRep", MedalMgr.OnSGetTargetAwardRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.exploit.SGetTargetAwardError", MedalMgr.OnSGetTargetAwardError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.exploit.SGetStageAwardRep", MedalMgr.OnSGetStageAwardRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.exploit.SGetStageAwardError", MedalMgr.OnSGetStageAwardError)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MedalMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, MedalMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, MedalMgr.OnActivityReset)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, MedalMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, MedalMgr.OnActivityEnd)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, MedalMgr.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, MedalMgr.OnActivityTodo)
end
def.method().Reset = function(self)
  self.medalInfo = nil
  self.medalAwardInfo = nil
end
def.static("table", "table").OnNewDay = function(p1, p2)
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID and instance then
    if instance:isOpen() then
      require("Main.activity.Medal.ui.MedalPanel").Instance():ShowPanel()
    else
      Toast(textRes.activity[270])
    end
  end
end
def.static("table", "table").OnHeroLevelUp = function(p1, p2)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
end
def.static("table", "table").OnActivityReset = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID then
    instance.medalInfo = nil
    instance.medalAwardInfo = nil
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Info_Change, nil)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Award_Change, nil)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Red_Point_Change, nil)
  end
end
def.static("table", "table").OnActivityStart = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Red_Point_Change, nil)
  end
end
def.static("table", "table").OnActivityEnd = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Red_Point_Change, nil)
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local openId = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EXPLOIT
  if p1.feature == openId then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Red_Point_Change, nil)
  end
end
def.static("number", "=>", "table").GetMedalCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXPLOIT_TARGET_CFG, id)
  if record == nil then
    warn("GetMedal got nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.activityId = record:GetIntValue("activityId")
  cfg.targetActivityCfgid = record:GetIntValue("targetActivityCfgid")
  cfg.rewardIcon = record:GetIntValue("rewardIcon")
  cfg.needNum = record:GetIntValue("needNum")
  cfg.awardCfgid = record:GetIntValue("awardCfgid")
  return cfg
end
def.static("number", "=>", "table").GetMedalAwardCfgByStage = function(stage)
  local activityId = constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXPLOIT_STAGE_MAP_CFG, activityId)
  if record == nil then
    warn("!!!!!!!!GetMedalAwardCfgByStage is nil:", activityId)
  end
  local rec2 = record:GetStructValue("stageStruct")
  local count = rec2:GetVectorSize("stageList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("stageList", i - 1)
    local needNum = rec3:GetIntValue("needNum")
    if needNum == stage then
      local cfg = {}
      cfg.needNum = needNum
      cfg.awardCfgid = rec3:GetIntValue("awardCfgid")
      return cfg
    end
  end
  return nil
end
def.static("number", "=>", "table").GetMedalCfgByActivityId = function(targetActivityId)
  local activityId = constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXPLOIT_TARGET_MAP_CFG, activityId)
  if record == nil then
    warn("!!!!!!!!GetMedalCfgByActivityId is nil:", activityId)
  end
  local rec2 = record:GetStructValue("targetStruct")
  local count = rec2:GetVectorSize("targetList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("targetList", i - 1)
    local curTargetId = rec3:GetIntValue("targetActivityCfgid")
    if curTargetId == targetActivityId then
      local cfg = {}
      cfg.id = rec3:GetIntValue("id")
      cfg.activityId = activityId
      cfg.targetActivityCfgid = curTargetId
      cfg.rewardIcon = rec3:GetIntValue("rewardIcon")
      cfg.needNum = rec3:GetIntValue("needNum")
      cfg.awardCfgid = rec3:GetIntValue("awardCfgid")
      return cfg
    end
  end
  return nil
end
def.static("=>", "table").GetAllMedalCfgList = function()
  local activityId = constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXPLOIT_TARGET_MAP_CFG, activityId)
  if record == nil then
    warn("!!!!!!!!GetAllMedalCfgList is nil:", activityId)
  end
  local a = record:GetIntValue("activityId")
  local cfgList = {}
  local rec2 = record:GetStructValue("targetStruct")
  local count = rec2:GetVectorSize("targetList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("targetList", i - 1)
    local cfg = {}
    cfg.id = rec3:GetIntValue("id")
    cfg.activityId = activityId
    cfg.targetActivityCfgid = rec3:GetIntValue("targetActivityCfgid")
    cfg.rewardIcon = rec3:GetIntValue("rewardIcon")
    cfg.needNum = rec3:GetIntValue("needNum")
    cfg.awardCfgid = rec3:GetIntValue("awardCfgid")
    table.insert(cfgList, cfg)
  end
  return cfgList
end
def.static("table").OnSSynExploitTargetsInfo = function(p)
  warn("--------OnSSynExploitTargetsInfo:", p.activity_id)
  instance.medalInfo = instance.medalInfo or {}
  local info = p.targets
  instance.medalInfo[p.activity_id] = info
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Red_Point_Change, nil)
end
def.static("table").OnSSynExploitTargetInfo = function(p)
  warn("--------OnSSynExploitTargetInfo:", p.target_activity_id, p.target_param)
  local medalInfo = instance:getMedalActivityInfo(p.target_activity_id)
  medalInfo.target_param = p.target_param
  local cfg = MedalMgr.GetMedalCfgByActivityId(p.target_activity_id)
  if p.target_param >= cfg.needNum and medalInfo.target_state ~= ExploitConsts.ST_HAND_UP then
    medalInfo.target_state = ExploitConsts.ST_FINISHED
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Red_Point_Change, nil)
end
def.static("table").OnSSynExploitStagesInfo = function(p)
  warn("--------OnSSynExploitStagesInfo")
  instance.medalAwardInfo = instance.medalAwardInfo or {}
  local info = {}
  info.finish_num = p.finish_num
  info.stages = p.stages
  instance.medalAwardInfo[p.activity_id] = info
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Red_Point_Change, nil)
end
def.static("table").OnSGetTargetAwardRep = function(p)
  warn("------OnSGetTargetAwardRep")
  local medalInfo = instance:getMedalActivityInfo(p.target_activity_id)
  medalInfo.target_state = p.target_state
  medalInfo.target_param = p.target_param
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Info_Change, nil)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Red_Point_Change, nil)
end
def.static("table").OnSGetTargetAwardError = function(p)
  warn("------OnSGetTargetAwardError:", p.error_code)
end
def.static("table").OnSGetStageAwardRep = function(p)
  warn("------OnSGetStageAwardRep:", p.activity_id)
  local info = instance:getMedalAwardInfo()
  if info then
    info.stages[p.need_num] = p.target_state
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Award_Change, nil)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Red_Point_Change, nil)
  else
    warn("!!!!!!OnSGetStageAwardRep error:", p.activity_id)
  end
end
def.static("table").OnSGetStageAwardError = function(p)
  warn("----OnSGetStageAwardError:", p.error_code)
end
def.method("=>", "boolean").isOpen = function()
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EXPLOIT) then
    return false
  end
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityId = constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID
  if ActivityInterface.Instance():isAchieveActivityLevel(activityId) and ActivityInterface.Instance():isActivityOpend(activityId) then
    return true
  end
  return false
end
def.method("number", "=>", "table").getMedalActivityInfo = function(self, activityId)
  if self.medalInfo == nil then
    self.medalInfo = {}
  end
  local id = constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID
  if self.medalInfo[id] == nil then
    self.medalInfo[id] = {}
  end
  local info = self.medalInfo[id][activityId]
  if info == nil then
    info = {}
    self.medalInfo[id][activityId] = info
    info.target_state = ExploitConsts.ST_ON_GOING
    info.target_param = 0
  end
  return info
end
def.method("=>", "table").getMedalAwardInfo = function(self)
  if self.medalAwardInfo == nil then
    self.medalAwardInfo = {}
  end
  local id = constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID
  if self.medalAwardInfo[id] == nil then
    local info = {}
    info.finish_num = 0
    self.medalAwardInfo[id] = info
  end
  if self.medalAwardInfo[id].stages == nil then
    self.medalAwardInfo[id].stages = {}
  end
  return self.medalAwardInfo[id]
end
def.method("number", "=>", "number").getMedalAwardState = function(self, stage)
  local awardInfo = self:getMedalAwardInfo()
  return awardInfo.stages[stage] or ExploitConsts.ST_ON_GOING
end
def.method("=>", "number").getFinishNum = function(self)
  local num = 0
  if self.medalInfo then
    local id = constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID
    local info = self.medalInfo[id]
    if info then
      for i, v in pairs(info) do
        if v.target_state == ExploitConsts.ST_FINISHED or v.target_state == ExploitConsts.ST_HAND_UP then
          num = num + 1
        end
      end
    end
  end
  return num
end
def.method("=>", "boolean").HasNotify = function(self)
  if self.medalInfo then
    local id = constant.CExploitConst.EXPLOIT_ACTIVITY_CFG_ID
    local info = self.medalInfo[id]
    if info then
      for i, v in pairs(info) do
        if v.target_state == ExploitConsts.ST_FINISHED then
          return true
        end
      end
    end
  end
  local finishNum = self:getFinishNum()
  for i = 1, constant.CExploitConst.EXPLOIT_ACTIVITY_MAX_STAGE do
    local state = self:getMedalAwardState(i)
    if state ~= ExploitConsts.ST_HAND_UP and i <= finishNum then
      return true
    end
  end
  return false
end
return MedalMgr.Commit()
