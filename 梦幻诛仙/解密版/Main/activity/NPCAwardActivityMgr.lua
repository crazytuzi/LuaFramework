local Lplus = require("Lplus")
local NPCAwardActivityMgr = Lplus.Class("NPCAwardActivityMgr")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local MTaskInfo = require("netio.protocol.mzm.gsp.mourn.MTaskInfo")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local NPCInterface = require("Main.npc.NPCInterface")
local npcInterface = NPCInterface.Instance()
local def = NPCAwardActivityMgr.define
local instance
def.static("=>", NPCAwardActivityMgr).Instance = function()
  if instance == nil then
    instance = NPCAwardActivityMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.npcreward.SGetRewardSuccess", NPCAwardActivityMgr.OnSGetRewardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.npcreward.SGetRewardFailed", NPCAwardActivityMgr.OnSGetRewardFailed)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, NPCAwardActivityMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, NPCAwardActivityMgr.OnNpcNomalServer)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, NPCAwardActivityMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, NPCAwardActivityMgr.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, NPCAwardActivityMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  local npcAwardCfgs = NPCAwardActivityMgr.GetAllNPCAwardCfg()
  for i, v in ipairs(npcAwardCfgs) do
    npcInterface:RegisterNPCServiceCustomCondition(v.npcExchangeServiceCfgid, NPCAwardActivityMgr.OnNPCService_NPCAwardCondition)
    npcInterface:RegisterNPCServiceCustomCondition(v.npcRewardServiceCfgid, NPCAwardActivityMgr.OnNPCService_NPCAwardCondition)
    npcInterface:RegisterNPCServiceCustomCondition(v.npcExchangeServiceCfgid_2, NPCAwardActivityMgr.OnNPCService_NPCAwardCondition)
  end
end
def.method().Reset = function(self)
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1[1]
  local npcAwardCfg = NPCAwardActivityMgr.GetNPCAWardCfg(activityId)
  if npcAwardCfg then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      npcAwardCfg.npcCfgid
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
  local npcAwardCfgs = NPCAwardActivityMgr.GetAllNPCAwardCfg()
  for i, v in ipairs(npcAwardCfgs) do
    if npcId == v.npcCfgid then
      local ActivityInterface = require("Main.activity.ActivityInterface")
      local activityInterface = ActivityInterface.Instance()
      if _G.IsFeatureOpen(v.openCfgid) and activityInterface:isAchieveActivityLevel(v.activityId) and activityInterface:isActivityOpend2(v.activityId) then
        if serviceId == v.npcExchangeServiceCfgid or serviceId == v.npcExchangeServiceCfgid_2 then
          do
            local ActivityModule = require("Main.activity.ActivityModule")
            local fivePerciousItemId = ActivityModule.GetFivePreciousExchange(npcId, serviceId)
            if fivePerciousItemId > 0 then
              local ItemUtils = require("Main.Item.ItemUtils")
              local fivePreciousItemCfg = ItemUtils.GetFivePreciousItemCfg(fivePerciousItemId)
              local exchangeID = fivePreciousItemCfg.exchangeid
              local NpcExchangePanel = require("Main.Exchange.ui.NpcExchangePanel")
              local npcExchangePanel = NpcExchangePanel.Instance()
              npcExchangePanel:ShowPanel(exchangeID, fivePreciousItemCfg.isuseyuanbao)
            end
          end
          break
        end
        if serviceId == v.npcRewardServiceCfgid then
          if ActivityInterface.CheckActivityConditionFinishCount(v.activityId) then
            if v.effectCfgid and 0 < v.effectCfgid then
              do
                local NpcAwardPanel = require("Main.activity.ui.NpcAwardPanel")
                NpcAwardPanel.Instance():ShowPanel(v.activityId)
              end
              break
            end
            do
              local p = require("netio.protocol.mzm.gsp.npcreward.CGetReward").new(v.activityId)
              gmodule.network.sendProtocol(p)
              warn("------------NPCAward getReward:", v.activityId)
            end
            break
          end
          Toast(textRes.activity[702])
        end
        break
      end
      Toast(textRes.activity[51])
      break
    end
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  local npcAwardCfgs = NPCAwardActivityMgr.GetAllNPCAwardCfg()
  for i, v in ipairs(npcAwardCfgs) do
    if _G.IsFeatureOpen(v.openCfgid) then
      activityInterface:removeCustomCloseActivity(v.activityId)
    else
      activityInterface:addCustomCloseActivity(v.activityId)
    end
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local openId = p1.feature
  local npcAwardCfgs = NPCAwardActivityMgr.GetAllNPCAwardCfg()
  for i, v in ipairs(npcAwardCfgs) do
    if v.openCfgid == openId then
      local activityInterface = require("Main.activity.ActivityInterface").Instance()
      if _G.IsFeatureOpen(v.openCfgid) then
        activityInterface:removeCustomCloseActivity(v.activityId)
        break
      end
      activityInterface:addCustomCloseActivity(v.activityId)
      break
    end
  end
end
def.static("number", "=>", "table").GetNPCAWardCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_NPC_REWARD_CFG, activityId)
  if record == nil then
    warn("!!!!!!!!GetNPCAWardCfg got nil record for activityId: ", activityId)
    return nil
  end
  local cfg = {}
  cfg.activityId = activityId
  cfg.openCfgid = record:GetIntValue("openCfgid")
  cfg.npcCfgid = record:GetIntValue("npcCfgid")
  cfg.npcExchangeServiceCfgid = record:GetIntValue("npcExchangeServiceCfgid_1")
  cfg.exchangeItemCfgid = record:GetIntValue("exchangeItemCfgid_1")
  cfg.npcExchangeServiceCfgid_2 = record:GetIntValue("npcExchangeServiceCfgid_2")
  cfg.exchangeItemCfgid_2 = record:GetIntValue("exchangeItemCfgid_2")
  cfg.npcRewardServiceCfgid = record:GetIntValue("npcRewardServiceCfgid")
  cfg.awardCfgid = record:GetIntValue("awardCfgid")
  cfg.effectCfgid = record:GetIntValue("effectCfgid")
  return cfg
end
def.static("=>", "table").GetAllNPCAwardCfg = function()
  local cfgList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_NPC_REWARD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local activityId = entry:GetIntValue("activityId")
    local cfg = NPCAwardActivityMgr.GetNPCAWardCfg(activityId)
    if cfg then
      table.insert(cfgList, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgList
end
def.static("table").OnSGetRewardSuccess = function(p)
  warn("--------OnSGetRewardSuccess:", p.activity_cfgid)
end
def.static("table").OnSGetRewardFailed = function(p)
  warn("!!!!!!OnSGetRewardFailed:", p.activity_cfgid, p.retcode)
  local str = textRes.activity.NpcAwardError[p.retcode]
  if str then
    Toast(str)
  end
end
return NPCAwardActivityMgr.Commit()
