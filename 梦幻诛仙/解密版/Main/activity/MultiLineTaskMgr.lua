local Lplus = require("Lplus")
local MultiLineTaskMgr = Lplus.Class("MultiLineTaskMgr")
local ActivityInterface = require("Main.activity.ActivityInterface")
local NPCInterface = require("Main.npc.NPCInterface")
local npcInterface = NPCInterface.Instance()
local TaskInterface = require("Main.task.TaskInterface")
local def = MultiLineTaskMgr.define
local instance
def.static("=>", MultiLineTaskMgr).Instance = function()
  if instance == nil then
    instance = MultiLineTaskMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SMultiLineTaskNormalRes", MultiLineTaskMgr.OnSMultiLineTaskNormalRes)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, MultiLineTaskMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, MultiLineTaskMgr.OnNpcNomalServer)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MultiLineTaskMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, MultiLineTaskMgr.OnFeatureOpenInit)
end
def.method().Reset = function(self)
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1[1]
  local multilTaskCfg = MultiLineTaskMgr.GetMultiLineTaskCfg(activityId)
  if multilTaskCfg then
    warn("-----MultiLineTaskMgr Activity:", activityId, multilTaskCfg.npcid)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      multilTaskCfg.npcid
    })
  end
end
def.static("table", "table").OnNewDay = function(p1, p2)
end
def.static("number", "=>", "boolean").OnNPCService_NPCAwardCondition = function(serviceId)
  local npcAwardCfgs = NPCAwardActivityMgr.GetAllNPCAwardCfg()
  for i, v in ipairs(npcAwardCfgs) do
    if serviceId == v.npcExchangeServiceCfgid or serviceId == v.npcRewardServiceCfgid or serviceId == v.npcExchangeServiceCfgid_2 then
      if not _G.IsFeatureOpen(v.openCfgid) then
        return false
      end
      break
    end
  end
  return true
end
def.static("table", "table").OnNpcNomalServer = function(p1, p2)
  local serviceId = p1[1]
  local npcId = p1[2]
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MultiLineTaskCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    if entry:GetIntValue("serviceid") == serviceId and entry:GetIntValue("npcid") == npcId then
      local openId = entry:GetIntValue("openId")
      if _G.IsFeatureOpen(openId) then
        do
          local activityId = entry:GetIntValue("activityId")
          if ActivityInterface.Instance():isActivityOpend2(activityId) then
            do
              local graphId = entry:GetIntValue("graphId")
              if TaskInterface.Instance():isOwnTaskByGraphId(graphId) then
                Toast(textRes.activity[606])
                break
              end
              local p = require("netio.protocol.mzm.gsp.activity.CAcceptMultiLineTask").new(activityId)
              gmodule.network.sendProtocol(p)
              warn("-------CAcceptMultiLineTask:", activityId)
            end
            break
          end
          Toast(textRes.activity[51])
        end
        break
      end
      Toast(textRes.activity[407])
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.static("number", "=>", "table").GetMultiLineTaskCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MultiLineTaskCfg, activityId)
  if record == nil then
    warn("!!!!!!!!GetMultiLineTaskCfg got nil record for activityId: ", activityId)
    return nil
  end
  local cfg = {}
  cfg.activityId = activityId
  cfg.openId = record:GetIntValue("openId")
  cfg.npcid = record:GetIntValue("npcid")
  cfg.serviceid = record:GetIntValue("serviceid")
  cfg.graphId = record:GetIntValue("graphId")
  cfg.awardCircleSum = record:GetIntValue("awardCircleSum")
  cfg.awardId = record:GetIntValue("awardId")
  return cfg
end
def.static("table").OnSMultiLineTaskNormalRes = function(p)
  warn("!!!!!!!!OnSMultiLineTaskNormalRes:", p.result)
  local str = textRes.activity.MultiLineTaskError[p.result]
  if str then
    Toast(str)
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MultiLineTaskCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local activityInterface = ActivityInterface.Instance()
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local openId = entry:GetIntValue("openId")
    local activityId = entry:GetIntValue("activityId")
    if _G.IsFeatureOpen(openId) then
      activityInterface:removeCustomCloseActivity(activityId)
    else
      activityInterface:addCustomCloseActivity(activityId)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MultiLineTaskCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local activityInterface = ActivityInterface.Instance()
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local openId = entry:GetIntValue("openId")
    if openId == p1.feature then
      local activityId = entry:GetIntValue("activityId")
      if _G.IsFeatureOpen(openId) then
        activityInterface:removeCustomCloseActivity(activityId)
      else
        activityInterface:addCustomCloseActivity(activityId)
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
return MultiLineTaskMgr.Commit()
