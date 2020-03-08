local Lplus = require("Lplus")
local ActivityInterface = require("Main.activity.ActivityInterface")
local WorldGoalUtils = require("Main.activity.WorldGoal.WorldGoalUtils")
local GUIFxMan = require("Fx.GUIFxMan")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityType = require("consts.mzm.gsp.worldgoal.confbean.ActivityType")
local WorldGoalMgr = Lplus.Class("WorldGoalMgr")
local def = WorldGoalMgr.define
def.const("table").CommitPostion = {At_Npc = 1, At_Entity = 2}
local ActivityServiceCfgCache
def.field("table").m_Activity2CommitNum = nil
def.field("table").m_Fxs = nil
def.field("table").m_Timers = nil
def.field("number").m_LastQueryNpcId = 0
local instance
def.static("=>", WorldGoalMgr).Instance = function()
  if nil == instance then
    instance = WorldGoalMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worldgoal.SSyncRoleWorldGoalInfo", WorldGoalMgr.OnSSyncRoleWorldGoalInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worldgoal.SCommitItemSuccess", WorldGoalMgr.OnSCommitItemSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worldgoal.SCommitItemFail", WorldGoalMgr.OnSCommitItemFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worldgoal.SGetActivityScheduleSuccess", WorldGoalMgr.OnSGetActivityScheduleSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worldgoal.SGetActivityScheduleFail", WorldGoalMgr.OnSGetActivityScheduleFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worldgoal.SSyncSectionComplete", WorldGoalMgr.OnSSyncSectionComplete)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worldgoal.SEnterWorldGoalActivityMapFail", WorldGoalMgr.OnSEnterWorldGoalActivityMapFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worldgoal.SLeaveWorldGoalActivityMapFail", WorldGoalMgr.OnSLeaveWorldGoalActivityMapFail)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, WorldGoalMgr.OnNpcService)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, WorldGoalMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, WorldGoalMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Close, WorldGoalMgr.OnActivityClose)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, WorldGoalMgr.OnActivityReset)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, WorldGoalMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, WorldGoalMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, WorldGoalMgr.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, WorldGoalMgr.OnFeatureOpenChange)
  require("Main.activity.WorldGoal.ValentineFlower.ValentineFlowerMgr").Instance():Init()
end
def.static("table").OnSSyncRoleWorldGoalInfo = function(p)
  warn("~~~~~~~~~~OnSSyncRoleWorldGoalInfo~~~~~~~~~~~~", p, p.role_world_goal_info)
  local self = WorldGoalMgr.Instance()
  self:InitActivityData()
  if nil == p.role_world_goal_info then
    return
  end
  for k, v in pairs(p.role_world_goal_info) do
    self.m_Activity2CommitNum[k] = v
  end
end
def.static("table").OnSSyncSectionComplete = function(p)
  warn("~~~~~~~~OnSSyncSectionComplete~~~~~~~", p)
  local activityId = p.activity_cfg_id
  local sectionId = p.section_id
  local self = WorldGoalMgr.Instance()
  if self.m_Activity2CommitNum and self.m_Activity2CommitNum[activityId] then
    local mapInfo = WorldGoalUtils.GetSectionMapInfo(activityId, sectionId)
    if mapInfo then
      local mapId = mapInfo.mapId
      local mapCfg = require("Main.Map.MapUtility").GetMapCfg(mapId)
      local mapName = mapCfg.mapName or " "
      require("Main.Announcement.AnnouncementModule").OnWorldGoalSectionComplete(mapName)
    end
  end
end
def.static("table").OnSCommitItemSuccess = function(p)
  warn("~~~~~~~~OnSCommitItemSuccess~~~~~~~~", p)
  local activityId = p.activity_cfg_id
  local commitNum = p.commit_num
  local itemId2commitNum = p.itemid2commit_num
  local self = WorldGoalMgr.Instance()
  if nil == self.m_Activity2CommitNum then
    return
  end
  if nil == self.m_Activity2CommitNum[activityId] then
    return
  end
  self.m_Activity2CommitNum[activityId] = self.m_Activity2CommitNum[activityId] + commitNum
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  if activityCfg and itemId2commitNum then
    local activityName = activityCfg.activityName
    local ItemUtils = require("Main.Item.ItemUtils")
    for k, v in pairs(itemId2commitNum) do
      local itemBase = ItemUtils.GetItemBase(k)
      local itemName = itemBase and itemBase.name or " "
      Toast(string.format(textRes.WorldGoal[1], activityName, v, itemName))
    end
  end
end
def.static("table").OnSCommitItemFail = function(p)
  warn("~~~~~~~OnSCommitItemFail~~~~~~~", p.res, p.activity_cfg_id)
  local activityId = p.activity_cfg_id
  local errCode = p.res
  local errMsg = textRes.WorldGoal.CommitErrorCode[errCode]
  if errMsg then
    Toast(errMsg)
  end
end
def.static("table").OnSGetActivityScheduleSuc = function(p)
  warn("~~~~~~~OnSGetActivityScheduleSuc~~~~~~~~~", p.activity_cfg_id, p.current_section_id)
  local activityId = p.activity_cfg_id
  local sectionId = p.current_section_id
  local curPoint = p.current_section_point
  local reachTime = p.timestamp
  local self = WorldGoalMgr.Instance()
  if nil == self.m_Activity2CommitNum then
    return
  end
  if not self.m_Activity2CommitNum[activityId] then
    return
  end
  local sectionMapInfo = WorldGoalUtils.GetSectionMapInfo(activityId, sectionId)
  if nil == sectionMapInfo then
    return
  end
  local mapId = sectionMapInfo.mapId
  local mapCfg = require("Main.Map.MapUtility").GetMapCfg(mapId)
  local mapName = mapCfg.mapName
  local sectionTotalPoint = WorldGoalUtils.GetSectionTotalPoint(activityId, sectionId)
  local commitLimitNum = WorldGoalUtils.GetActicityCommitLimitNum(activityId)
  local hadCommitNum = self.m_Activity2CommitNum[activityId]
  local commitItemInfo = WorldGoalUtils.GetActivityCommitItemInfo(activityId)
  local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
  local contents = {}
  local content = {}
  if 0 == self.m_LastQueryNpcId then
    content.npcid = WorldGoalUtils.GetNpcIdByActivityId(activityId)
  else
    content.npcid = self.m_LastQueryNpcId
    self.m_LastQueryNpcId = 0
  end
  local itemStr = ""
  if commitItemInfo and commitItemInfo.itemInfo then
    for k, v in pairs(commitItemInfo.itemInfo) do
      itemStr = itemStr .. " " .. v.itemName
    end
  end
  content.txt = string.format(textRes.WorldGoal[5], mapName, curPoint, sectionTotalPoint, commitLimitNum - hadCommitNum, itemStr)
  table.insert(contents, content)
  taskModule:ShowTaskTalkCustom(contents, nil, nil)
end
def.static("table").OnSGetActivityScheduleFail = function(p)
  warn("~~~~~~~OnSGetActivityScheduleFail~~~~~~~~", p.res)
  local activityId = p.activity_cfg_id
  local errCode = p.res
  local errMsg = textRes.WorldGoal.QureyErrorCode[errCode]
  if errMsg then
    Toast(errMsg)
  end
end
def.static("table").OnSEnterWorldGoalActivityMapFail = function(p)
  if textRes.WorldGoal.SEnterWorldGoalActivityMapFail[p.res] then
    Toast(textRes.WorldGoal.SEnterWorldGoalActivityMapFail[p.res])
  end
end
def.static("table").OnSLeaveWorldGoalActivityMapFail = function(p)
  if textRes.WorldGoal.SEnterWorldGoalActivityMapFail[p.res] then
    Toast(textRes.WorldGoal.SEnterWorldGoalActivityMapFail[p.res])
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local self = WorldGoalMgr.Instance()
  self:UpdateActivityIDIPState()
end
def.static("table", "table").OnFeatureOpenChange = function(p1, p2)
  local featureType = p1.feature
  local self = WorldGoalMgr.Instance()
  if featureType == Feature.TYPE_WORLD_GOAL or self:GetActivityInfoByFeatrue(featureType) then
    self:UpdateActivityIDIPState()
  end
end
def.static("table", "table").OnNpcService = function(p1, p2)
  local serviceId = p1[1]
  local npcId = p1[2]
  local extraInfo = p1[3]
  local self = WorldGoalMgr.Instance()
  local activityId, activityCacheInfo = self:GetActivityInfoFromCache(npcId, serviceId)
  if 0 == activityId then
    activityId = WorldGoalUtils.GetActivityIdByNPCIdAndServiceId(npcId, serviceId)
  end
  if nil == self.m_Activity2CommitNum or not self.m_Activity2CommitNum[activityId] then
    warn("is not worldgoal npc !!!!!!!!!!!!!!!!! ", activityId)
    return
  end
  local commitServiceId = activityCacheInfo and activityCacheInfo.commitServiceId or 0
  local queryServiceId = activityCacheInfo and activityCacheInfo.queryServiceId or 0
  local enterNpcServiceId = activityCacheInfo and activityCacheInfo.enterNpcServiceId or 0
  if 0 == commitServiceId or 0 == queryServiceId then
    commitServiceId, queryServiceId = WorldGoalUtils.GetCommitAndQueryServiceId(activityId)
  end
  if serviceId ~= commitServiceId and serviceId ~= queryServiceId and serviceId == enterNpcServiceId then
    warn("is not the world goal service ID ~~~~~~~~~~~")
    return
  end
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  local minLevel = activityCfg.levelMin
  local maxLevel = activityCfg.levelMax
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  if minLevel > heroLevel then
    Toast(string.format(textRes.WorldGoal[2], minLevel))
    return
  end
  if maxLevel < heroLevel then
    Toast(string.format(textRes.WorldGoal[3], maxLevel))
    return
  end
  if serviceId == enterNpcServiceId then
    self:CEnterWorldGoalActivityMapReq(activityId, npcId)
    return
  end
  local commitPostion, instanceId
  if extraInfo and extraInfo.entityInstanceId then
    instanceId = extraInfo.entityInstanceId
    commitPostion = WorldGoalMgr.CommitPostion.At_Entity
  else
    instanceId = Int64.new(-1)
    commitPostion = WorldGoalMgr.CommitPostion.At_Npc
  end
  if commitServiceId == serviceId then
    local curCommitNum = self.m_Activity2CommitNum[activityId]
    local commitLimitNum = WorldGoalUtils.GetActicityCommitLimitNum(activityId)
    if curCommitNum >= commitLimitNum then
      Toast(string.format(textRes.WorldGoal[4], commitLimitNum))
      return
    end
    self:CCommitActivityItemReq(commitPostion, activityId, npcId, instanceId)
  elseif queryServiceId == serviceId then
    self:CQueryActivityScheduleReq(commitPostion, activityId, npcId, instanceId)
  end
end
def.static("table", "table").OnActivityStart = function(p1, p2)
  local activityId = p1[1]
  if nil == ActivityServiceCfgCache then
    ActivityServiceCfgCache = WorldGoalUtils.GetAllActivityCfg()
  end
  if nil == ActivityServiceCfgCache[activityId] then
    return
  end
  local self = WorldGoalMgr.Instance()
  self:UpdateActivityData()
end
def.static("table", "table").OnActivityClose = function(p1, p2)
  local activityId = p1[1]
  if nil == activityId then
    return
  end
  if nil == ActivityServiceCfgCache then
    ActivityServiceCfgCache = WorldGoalUtils.GetAllActivityCfg()
  end
  if nil == ActivityServiceCfgCache[activityId] then
    return
  end
  ActivityServiceCfgCache[activityId] = nil
  local self = WorldGoalMgr.Instance()
  if self.m_Activity2CommitNum and self.m_Activity2CommitNum[activityId] then
    self.m_Activity2CommitNum[activityId] = nil
  end
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1[1]
  if nil == activityId then
    return
  end
  local self = WorldGoalMgr.Instance()
  if self.m_Activity2CommitNum and self.m_Activity2CommitNum[activityId] then
    local activityInfo = self:GetActivityInfoFromCache2(activityId)
    if activityInfo == nil then
      warn("no world goal activity:" .. activityId)
      return
    end
    if activityInfo.activityType == ActivityType.INSTANCE then
      local curMapId = require("Main.Map.MapModule").Instance():GetMapId()
      if curMapId == activityInfo.enterActivityMapId then
        Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
          activityInfo.mainNpcId
        })
      else
        local npcId = activityInfo.enterNpcId
        if npcId == 0 then
          instance:CEnterWorldGoalActivityMapReq(activityId, npcId)
        else
          Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
        end
      end
    else
      local npcId = activityInfo.mainNpcId
      if 0 == npcId then
        npcId = WorldGoalUtils.GetNpcIdByActivityId(activityId)
      end
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
    end
  else
    warn(" not find world goal activity npc ~~~~~~~~~ ")
  end
end
def.static("table", "table").OnActivityReset = function(p1, p2)
  local activityId = p1[1]
  local self = WorldGoalMgr.Instance()
  if self.m_Activity2CommitNum and self.m_Activity2CommitNum[activityId] then
    self.m_Activity2CommitNum[activityId] = 0
  end
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  if nil == ActivityServiceCfgCache then
    ActivityServiceCfgCache = WorldGoalUtils.GetAllActivityCfg()
  end
  local self = WorldGoalMgr.Instance()
  local function getNpcDlgServiceName(serviceCfg)
    local serviceId = serviceCfg.serviceID
    local serviceName = serviceCfg.choiceName
    for k, v in pairs(ActivityServiceCfgCache) do
      if serviceId == v.commitServiceId then
        if self.m_Activity2CommitNum and self.m_Activity2CommitNum[k] then
          local hadCommitNum = self.m_Activity2CommitNum[k]
          local totalCommitLimitNum = v.totalCommitLimitNum or 0
          serviceName = serviceCfg.choiceName .. string.format("(%d/%d)", hadCommitNum, totalCommitLimitNum)
        end
        break
      end
    end
    return serviceName
  end
  local NpcInterface = require("Main.npc.NPCInterface")
  for k, v in pairs(ActivityServiceCfgCache) do
    NpcInterface.Instance():RegisterNPCServiceCustomName(v.commitServiceId, getNpcDlgServiceName)
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  local self = WorldGoalMgr.Instance()
  self.m_Activity2CommitNum = nil
  self:RemoveWorldGoalFx(-1)
  ActivityServiceCfgCache = nil
  self.m_LastQueryNpcId = 0
end
def.method("number", "number", "number", "userdata").CCommitActivityItemReq = function(self, commitPos, activityId, npcId, instanceId)
  if not _G.IsFeatureOpen(Feature.TYPE_WORLD_GOAL) then
    Toast(textRes.WorldGoal[10])
    return
  end
  local p = require("netio.protocol.mzm.gsp.worldgoal.CCommitItemReq").new(commitPos, activityId, npcId, instanceId)
  gmodule.network.sendProtocol(p)
end
def.method("number", "number", "number", "userdata").CQueryActivityScheduleReq = function(self, commitPos, activityId, npcId, instanceId)
  if not _G.IsFeatureOpen(Feature.TYPE_WORLD_GOAL) then
    Toast(textRes.WorldGoal[10])
    return
  end
  local p = require("netio.protocol.mzm.gsp.worldgoal.CGetActivityScheduleReq").new(commitPos, activityId, npcId, instanceId)
  gmodule.network.sendProtocol(p)
  self.m_LastQueryNpcId = npcId
end
def.method("number", "number").CEnterWorldGoalActivityMapReq = function(self, activityId, npcId)
  if not _G.IsFeatureOpen(Feature.TYPE_WORLD_GOAL) then
    Toast(textRes.WorldGoal[10])
    return
  end
  local p = require("netio.protocol.mzm.gsp.worldgoal.CEnterWorldGoalActivityMapReq").new(activityId, npcId)
  gmodule.network.sendProtocol(p)
end
def.method("number").CLeaveWorldGoalActivityMapReq = function(self, activityId)
  if not _G.IsFeatureOpen(Feature.TYPE_WORLD_GOAL) then
    Toast(textRes.WorldGoal[10])
    return
  end
  local p = require("netio.protocol.mzm.gsp.worldgoal.CLeaveWorldGoalActivityMapReq").new(activityId)
  gmodule.network.sendProtocol(p)
end
def.method("number", "number", "number").PlayWorldGoalFx = function(self, cfgId, curScore, reachTime)
  local cfg = WorldGoalUtils.GetActivityInfoByCfgId(cfgId)
  if nil == cfg then
    warn("world goal cfgId is error .....  cfgId is : ", cfgId)
    return
  end
  local activityId = cfg.activityId
  local sectionId = cfg.sectionId
  local effectId = cfg.effectId
  local effectPersistTime = cfg.effectPersistTime
  local triggerPoint = cfg.triggerPoint
  local sectionTotalPoint = WorldGoalUtils.GetSectionTotalPoint(activityId, sectionId)
  local curTime = GetServerTime()
  if curScore >= sectionTotalPoint and effectPersistTime >= curTime - reachTime then
    local effectCfg = GetEffectRes(effectId)
    if nil == effectCfg then
      warn("world goal effectId is error , effectId is : ", effectId)
      return
    end
    if nil == self.m_Fxs then
      self.m_Fxs = {}
    end
    if nil == self.m_Fxs[activityId] then
      self.m_Fxs[activityId] = {}
    end
    self.m_Fxs[activityId][sectionId] = GUIFxMan.Instance():Play(effectCfg.path, "fullScreenSnow", 0, 0, -1, false)
    if nil == self.m_Timers then
      self.m_Timers = {}
    end
    if nil == self.m_Timers[activityId] then
      self.m_Timers[activityId] = {}
    end
    if self.m_Timers[activityId][sectionId] and 0 ~= self.m_Timers[activityId][sectionId] then
      GameUtil.RemoveGlobalTimer(self.m_Timers[activityId][sectionId])
    end
    self.m_Timers[activityId][sectionId] = 0
    local leftTime = effectPersistTime - (curTime - reachTime)
    self.m_Timers[activityId][sectionId] = GameUtil.AddGlobalTimer(leftTime, true, function()
      if self.m_Fxs and self.m_Fxs[activityId] and self.m_Fxs[activityId][sectionId] then
        self:RemoveWorldGoalFx2(activityId, sectionId)
      end
      if self.m_Timers and self.m_Timers[activityId] and self.m_Timers[activityId][sectionId] then
        self.m_Timers[activityId][sectionId] = 0
      end
    end)
  end
end
def.method("number").RemoveWorldGoalFx = function(self, cfgId)
  if self.m_Fxs then
    if -1 == cfgId then
      if self.m_Fxs then
        for k, v in pairs(self.m_Fxs) do
          for k1, v1 in pairs(v) do
            if v1 and not v1.isnil then
              GUIFxMan.Instance():RemoveFx(v1)
            end
          end
        end
        self.m_Fxs = nil
        self:RemoveFxTimer(true, 0, 0)
      end
    else
      local cfg = WorldGoalUtils.GetActivityInfoByCfgId(cfgId)
      if nil == cfg then
        warn("world goal cfgId is error .....  cfgId is : ", cfgId)
        return
      end
      if nil == self.m_Fxs then
        warn("cur not has fxs ...... ")
        return
      end
      local activityId = cfg.activityId
      local sectionId = cfg.sectionId
      if activityId and sectionId and self.m_Fxs[activityId] and self.m_Fxs[activityId][sectionId] and not self.m_Fxs[activityId][sectionId].isnil then
        GUIFxMan.Instance():RemoveFx(self.m_Fxs[activityId][sectionId])
        self.m_Fxs[activityId][sectionId] = nil
      end
      self:RemoveFxTimer(false, activityId, sectionId)
    end
  end
end
def.method("number", "number").RemoveWorldGoalFx2 = function(self, activityId, sectionId)
  if nil == self.m_Fxs then
    return
  end
  if nil == self.m_Fxs[activityId] then
    return
  end
  if -1 == sectionId then
    for k, v in pairs(self.m_Fxs[activityId]) do
      if v and not v.isnil then
        GUIFxMan.Instance():RemoveFx(v)
      end
    end
    self.m_Fxs[activityId] = nil
  elseif self.m_Fxs[activityId][sectionId] and not self.m_Fxs[activityId][sectionId].isnil then
    GUIFxMan.Instance():RemoveFx(self.m_Fxs[activityId][sectionId])
    self.m_Fxs[activityId][sectionId] = nil
  end
end
def.method("boolean", "number", "number").RemoveFxTimer = function(self, isAll, activityId, sectionId)
  if nil == self.m_Timers then
    return
  end
  if isAll then
    for k, v in pairs(self.m_Timers) do
      for k1, v1 in pairs(v) do
        if 0 ~= v1 then
          GameUtil.RemoveGlobalTimer(v1)
          v[k1] = 0
        end
      end
    end
    self.m_Timers = nil
    return
  end
  if nil == self.m_Timers[activityId] then
    return
  end
  if -1 == sectionId then
    for k, v in pairs(self.m_Timers[activityId]) do
      if 0 ~= v then
        GameUtil.RemoveGlobalTimer(v)
        self.m_Timers[activityId][k] = 0
      end
    end
    self.m_Timers[activityId] = nil
  elseif self.m_Timers[activityId][sectionId] and 0 ~= self.m_Timers[activityId][sectionId] then
    GameUtil.RemoveGlobalTimer(self.m_Timers[activityId][sectionId])
    self.m_Timers[activityId][sectionId] = 0
  end
end
def.method().InitActivityData = function(self)
  if nil == ActivityServiceCfgCache then
    ActivityServiceCfgCache = WorldGoalUtils.GetAllActivityCfg()
  end
  self.m_Activity2CommitNum = {}
  for k, v in pairs(ActivityServiceCfgCache) do
    if ActivityInterface.Instance():isActivityOpend(k) then
      self.m_Activity2CommitNum[k] = 0
    end
  end
end
def.method().UpdateActivityData = function(self)
  if nil == ActivityServiceCfgCache then
    ActivityServiceCfgCache = WorldGoalUtils.GetAllActivityCfg()
  end
  if nil == self.m_Activity2CommitNum then
    self.m_Activity2CommitNum = {}
  end
  for k, v in pairs(ActivityServiceCfgCache) do
    if ActivityInterface.Instance():isActivityOpend(k) and nil == self.m_Activity2CommitNum[k] then
      self.m_Activity2CommitNum[k] = 0
    end
  end
end
def.method("number", "number", "=>", "number", "table").GetActivityInfoFromCache = function(self, targetNpcId, targetServiceId)
  if nil == ActivityServiceCfgCache then
    ActivityServiceCfgCache = WorldGoalUtils.GetAllActivityCfg()
  end
  for k, v in pairs(ActivityServiceCfgCache) do
    local mainNpcId = v.mainNpcId
    local entityNpcId = v.entityNpcId
    local commitServiceId = v.commitServiceId
    local queryServiceId = v.queryServiceId
    local enterNpcId = v.enterNpcId
    local enterNpcServiceId = v.enterNpcServiceId
    local isRightNpc = targetNpcId == mainNpcId or targetNpcId == entityNpcId or targetNpcId == enterNpcId
    local isRightService = targetServiceId == commitServiceId or targetServiceId == queryServiceId or targetServiceId == enterNpcServiceId
    if isRightNpc and isRightService then
      return k, v
    end
  end
  return 0, nil
end
def.method("number", "=>", "table").GetActivityInfoFromCache2 = function(self, activityId)
  if nil == activityId then
    return nil
  end
  if nil == ActivityServiceCfgCache then
    ActivityServiceCfgCache = WorldGoalUtils.GetAllActivityCfg()
  end
  return ActivityServiceCfgCache[activityId]
end
def.method().UpdateActivityIDIPState = function(self)
  if nil == ActivityServiceCfgCache then
    ActivityServiceCfgCache = WorldGoalUtils.GetAllActivityCfg()
  end
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_WORLD_GOAL)
  for k, v in pairs(ActivityServiceCfgCache) do
    if isOpen then
      if _G.IsFeatureOpen(v.moduleId) then
        ActivityInterface.Instance():removeCustomCloseActivity(k)
      else
        ActivityInterface.Instance():addCustomCloseActivity(k)
      end
    else
      ActivityInterface.Instance():addCustomCloseActivity(k)
    end
  end
end
def.method("number", "=>", "number").GetActivityInfoByFeatrue = function(self, feature)
  if nil == ActivityServiceCfgCache then
    ActivityServiceCfgCache = WorldGoalUtils.GetAllActivityCfg()
  end
  for k, v in pairs(ActivityServiceCfgCache) do
    local moduleId = v.moduleId
    if moduleId == feature then
      return k
    end
  end
  return 0
end
def.method().printInfo = function(self)
  if self.m_Activity2CommitNum then
    warn("************************ World Goal Info start *************************")
    for k, v in pairs(self.m_Activity2CommitNum) do
      warn("*********** commit Info is : ", k, "  ", v)
    end
    warn("************************ World Goal Info end *************************")
  end
  if self.m_Fxs then
    warn("######################## Fx Info start ################################")
    for k, v in pairs(self.m_Fxs) do
      warn("#################### fx info is : ", k, "  ", v)
    end
    warn("######################## Fx Info start ################################")
  end
end
WorldGoalMgr.Commit()
return WorldGoalMgr
