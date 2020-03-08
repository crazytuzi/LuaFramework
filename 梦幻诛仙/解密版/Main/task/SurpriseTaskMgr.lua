local Lplus = require("Lplus")
local SurpriseTaskMgr = Lplus.Class("SurpriseTaskMgr")
local TaskNeedItemType = require("consts.mzm.gsp.activity3.confbean.TaskNeedItemType")
local NPCInterface = require("Main.npc.NPCInterface")
local TaskInterface = require("Main.task.TaskInterface")
local ItemData = require("Main.Item.ItemData")
local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = SurpriseTaskMgr.define
local instance
def.field("table").graphInfo = nil
def.field("table").serverLevelStartTime = nil
def.field("table").newGraphIds = nil
def.field("table").graphId2Info = nil
def.static("=>", SurpriseTaskMgr).Instance = function()
  if instance == nil then
    instance = SurpriseTaskMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SynSurpriseGraphFinishInfo", SurpriseTaskMgr.OnSynSurpriseGraphFinishInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SSurpriseGraphFinishNotice", SurpriseTaskMgr.OnSSurpriseGraphFinishNotice)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SSurpriseNormalResult", SurpriseTaskMgr.OnSSurpriseNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SActiveSurpriseGraphNotice", SurpriseTaskMgr.OnSActiveSurpriseGraphNotice)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SSyncSurpriseServerLevel", SurpriseTaskMgr.OnSSyncSurpriseServerLevel)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SNewSurpriseGraphNotice", SurpriseTaskMgr.OnSNewSurpriseGraphNotice)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, SurpriseTaskMgr.OnNpcNomalServer)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, SurpriseTaskMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, SurpriseTaskMgr.OnLeaveWorld)
  self:registerServerCondition()
  self:initGraphOpenId()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance.graphInfo = nil
  instance.newGraphIds = nil
end
def.method().initGraphOpenId = function(self)
  self.graphId2Info = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SURPRISE_SCHEDULE_CFG)
  if entries == nil then
    warn("!!!!!!!!!no find cfg :", CFG_PATH.DATA_SURPRISE_SCHEDULE_CFG)
    return nil
  end
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  for j = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, j - 1)
    local rec2 = record:GetStructValue("dayScheduleInfosStruct")
    local count = rec2:GetVectorSize("dayScheduleInfos")
    for i = 1, count do
      local rec3 = rec2:GetVectorValueByIdx("dayScheduleInfos", i - 1)
      local needServerLevelTime = rec3:GetIntValue("needServerLevelTime")
      local t = {}
      t.openId = rec3:GetIntValue("openId")
      t.graphId = rec3:GetIntValue("graphId")
      t.finishCount = rec3:GetIntValue("finishCount")
      self.graphId2Info[t.graphId] = t
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method().registerServerCondition = function(self)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SURPRISE_ITEM_TASK_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local npcInterface = NPCInterface.Instance()
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local serverId = DynamicRecord.GetIntValue(entry, "serverId")
    npcInterface:RegisterNPCServiceCustomCondition(serverId, SurpriseTaskMgr.OnNPCService_SurpriseTaskCondition)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.static("number", "=>", "boolean").OnNPCService_SurpriseTaskCondition = function(serverId)
  local cfg = SurpriseTaskMgr.GetSurpriseItemTaskCfg(serverId)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_SURPRISE_ITEM_CON_0) then
    return false
  end
  if cfg then
    local myLevel = _G.GetHeroProp().level
    local taskId = TaskInterface.Instance():GetTaskIdByGraphId(cfg.graphId)
    if cfg.finishCount <= instance:getFinishSurpriseTaskNum(cfg.graphId) then
      return false
    end
    if myLevel < cfg.joinLevel then
      return false
    end
    if taskId > 0 then
      return false
    end
    local requireServerLevel = cfg.joinServerLevel
    local delay = cfg.needServerLevelTime * 86400
    if not SurpriseTaskMgr.Instance():IsSurpriseTaskMatchServerLevel(requireServerLevel, delay) then
      return false
    end
  end
  return true
end
def.static("table", "table").OnNpcNomalServer = function(p1, p2)
  local serverId = p1[1]
  local npcId = p1[2]
  local surpriseCfg = SurpriseTaskMgr.GetSurpriseItemTaskCfg(serverId)
  if surpriseCfg then
    warn("-----------SurpriseTaskMgr------:", serverId)
    if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_SURPRISE_ITEM_CON_0) then
      Toast(textRes.Task[403])
      return
    end
    local taskId = TaskInterface.Instance():GetTaskIdByGraphId(surpriseCfg.graphId)
    if taskId > 0 then
      Toast(textRes.Task[404])
      return
    end
    local condId = surpriseCfg.itemConId
    local itemType = surpriseCfg.itemType
    if itemType == TaskNeedItemType.CONDITION then
      require("Main.task.ui.SurpriseTaskGiveItem").Instance():ShowPanel(serverId)
    else
      do
        local surpriseItemCfg = SurpriseTaskMgr.GetSurpriseItemConCfg(surpriseCfg.itemConId)
        local itemData = ItemData.Instance()
        local contents = {}
        local content = {}
        content.npcid = npcId
        local canAccept = true
        for i, v in pairs(surpriseItemCfg.needItems) do
          local num = itemData:GetNumberByItemId(BagInfo.BAG, v.itemXId)
          if num <= 0 then
            canAccept = false
            break
          end
        end
        if canAccept then
          content.txt = surpriseCfg.canActiveDlg
        else
          content.txt = surpriseCfg.canNotActiveDlg
        end
        table.insert(contents, content)
        local function callback()
          if canAccept then
            local p = require("netio.protocol.mzm.gsp.task.CAccepteSurpriseItemReq").new(serverId, {})
            gmodule.network.sendProtocol(p)
            warn("-------CAccepteSurpriseItemReq:", serverId)
          else
            Toast(textRes.Task[405])
          end
        end
        local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
        taskModule:ShowTaskTalkCustom(contents, nil, callback)
      end
    end
  end
end
def.static("number", "=>", "table").GetSurpriseItemTaskCfg = function(serverId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SURPRISE_ITEM_TASK_CFG, serverId)
  if record == nil then
    warn("!!!!!!!! GetSurpriseItemTaskCfg is nil:", serverId)
    return nil
  end
  local cfg = {}
  cfg.serverId = record:GetIntValue("serverId")
  cfg.activityId = record:GetIntValue("activityId")
  cfg.npcId = record:GetIntValue("npcId")
  cfg.graphId = record:GetIntValue("graphId")
  cfg.finishCount = record:GetIntValue("finishCount")
  cfg.isTakeAway = record:GetCharValue("isTakeAway") ~= 0
  cfg.itemConId = record:GetIntValue("itemConId")
  cfg.itemType = record:GetIntValue("itemType")
  cfg.joinLevel = record:GetIntValue("joinLevel")
  cfg.joinServerLevel = record:GetIntValue("joinServerLevel")
  cfg.needServerLevelTime = record:GetIntValue("needServerLevelTime")
  cfg.canActiveDlg = record:GetStringValue("canActiveDlg")
  cfg.canNotActiveDlg = record:GetStringValue("canNotActiveDlg")
  return cfg
end
def.static("number", "=>", "table").GetSurpriseItemConCfg = function(libId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SURPRISE_ITEM_CON_CFG, libId)
  if record == nil then
    warn("!!!!!!!! GetSurpriseItemConCfg is nil:", libId)
    return nil
  end
  local cfg = {}
  cfg.libId = record:GetIntValue("libId")
  cfg.needItems = {}
  local rec2 = record:GetStructValue("needItemDataStruct")
  local count = rec2:GetVectorSize("needItemDatas")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("needItemDatas", i - 1)
    local t = {}
    t.itemXId = rec3:GetIntValue("itemXId")
    table.insert(cfg.needItems, t)
  end
  return cfg
end
def.static("table").OnSynSurpriseGraphFinishInfo = function(p)
  warn("----->>>>>>OnSynSurpriseGraphFinishInfo")
  instance.graphInfo = p.finishGraphInfo
end
def.static("table").OnSSurpriseGraphFinishNotice = function(p)
  warn("---->>>>>>OnSSurpriseGraphFinishNotice:", p.graphId)
  instance.graphInfo = instance.graphInfo or {}
  local num = instance.graphInfo[p.graphId] or 0
  instance.graphInfo[p.graphId] = num + 1
end
def.static("table").OnSSurpriseNormalResult = function(p)
  warn("----->>>>>>>OnSSurpriseNormalResult:", p.result)
  local str = textRes.Task.surpriseTaskResult[p.result]
  if str then
    Toast(str)
  end
end
def.static("table").OnSActiveSurpriseGraphNotice = function(p)
  warn("-----OnSActiveSurpriseGraphNotice:", p.graphId)
  TaskInterface.Instance():addTaskLightRoundGraphId(p.graphId, constant.SurpriseConsts.ACTIVE_TIP_EFFECT)
end
def.static("table").OnSSyncSurpriseServerLevel = function(p)
  instance.serverLevelStartTime = {}
  for level, t in pairs(p.level2startTime) do
    local serverLevelData = {}
    serverLevelData.level = level
    serverLevelData.startTime = t
    table.insert(instance.serverLevelStartTime, serverLevelData)
  end
  table.sort(instance.serverLevelStartTime, function(a, b)
    return a.level < b.level
  end)
end
def.static("table").OnSNewSurpriseGraphNotice = function(p)
  instance.newGraphIds = instance.newGraphIds or {}
  for i, v in pairs(p.newGraphIds) do
    instance.newGraphIds[i] = v
  end
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_New_Surprise_Task_Change, nil)
end
def.method("number", "=>", "number").getFinishSurpriseTaskNum = function(self, graphId)
  if self.graphInfo and self.graphInfo[graphId] then
    return self.graphInfo[graphId]
  end
  return 0
end
def.method().clearNewGraph = function(self)
  self.newGraphIds = {}
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_New_Surprise_Task_Change, nil)
end
def.method("number", "=>", "boolean").isNewSurpriseGraph = function(self, graphId)
  if not _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_SURPRISE_RED_NOTICE) then
    return false
  end
  if self.newGraphIds and self.newGraphIds[graphId] then
    local info = self.graphId2Info[graphId]
    if info then
      if not _G.IsFeatureOpen(info.openId) then
        return false
      end
      local finishCount = self:getFinishSurpriseTaskNum(graphId)
      if finishCount >= info.finishCount then
        return false
      end
    end
    return true
  end
  return false
end
def.method("=>", "boolean").isOwnNewSurpriseGraph = function(self)
  if not _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_SHOW_SURPRISE_CLUE) then
    return false
  end
  if self.newGraphIds then
    for i, v in pairs(self.newGraphIds) do
      if self:isNewSurpriseGraph(v) then
        return true
      end
    end
  end
  return false
end
def.method("number", "number", "=>", "boolean").IsSurpriseTaskMatchServerLevel = function(self, requireServerLevel, delay)
  if self.serverLevelStartTime == nil then
    warn("serverLevelStartTime is nil")
    return false
  end
  local matchServerData
  for i = 1, #self.serverLevelStartTime do
    if requireServerLevel <= self.serverLevelStartTime[i].level then
      matchServerData = self.serverLevelStartTime[i]
      break
    end
  end
  if matchServerData == nil then
    return false
  else
    local taskStartTime = matchServerData.startTime + delay
    local curTime = _G.GetServerTime()
    return not Int64.lt(curTime, taskStartTime)
  end
end
def.method("=>", "table").getCurSurpriseTaskList = function(self)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SURPRISE_SCHEDULE_CFG)
  if entries == nil then
    warn("!!!!!!!!!no find cfg :", CFG_PATH.DATA_SURPRISE_SCHEDULE_CFG)
    return nil
  end
  local list = {}
  local serverLevelData = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
  local curServerLevel = serverLevelData.level
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  for j = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, j - 1)
    local serverLv = record:GetIntValue("needServerLevel")
    if curServerLevel >= serverLv then
      local rec2 = record:GetStructValue("dayScheduleInfosStruct")
      local count = rec2:GetVectorSize("dayScheduleInfos")
      for i = 1, count do
        local rec3 = rec2:GetVectorValueByIdx("dayScheduleInfos", i - 1)
        local needServerLevelTime = rec3:GetIntValue("needServerLevelTime")
        local openId = rec3:GetIntValue("openId")
        if self:IsSurpriseTaskMatchServerLevel(serverLv, needServerLevelTime * 86400) and _G.IsFeatureOpen(openId) then
          local t = {}
          t.needServerLevel = serverLv
          t.needServerLevelTime = needServerLevelTime
          t.openId = openId
          t.graphId = rec3:GetIntValue("graphId")
          t.joinLevel = rec3:GetIntValue("joinLevel")
          t.surpriseType = rec3:GetIntValue("surpriseType")
          t.finishCount = rec3:GetIntValue("finishCount")
          t.clue = rec3:GetStringValue("clue")
          t.titleDes = rec3:GetStringValue("titleDes")
          table.insert(list, t)
        end
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local curFeature = p1.feature
  if curFeature == ModuleFunSwitchInfo.TYPE_SURPRISE_RED_NOTICE or curFeature == ModuleFunSwitchInfo.TYPE_SHOW_SURPRISE_CLUE or curFeature == ModuleFunSwitchInfo.TYPE_SURPRISE_ACTION_0 or curFeature == ModuleFunSwitchInfo.TYPE_SURPRISE_ACHIEVEMENT_0 or curFeature == ModuleFunSwitchInfo.TYPE_SURPRISE_ITEM_CON_0 or curFeature == ModuleFunSwitchInfo.TYPE_SURPRISE_USE_ITEM then
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_New_Surprise_Task_Change, nil)
  end
end
return SurpriseTaskMgr.Commit()
