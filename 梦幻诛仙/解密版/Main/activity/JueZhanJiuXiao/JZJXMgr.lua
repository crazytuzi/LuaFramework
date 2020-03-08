local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local JZJXMgr = Lplus.Class(CUR_CLASS_NAME)
local def = JZJXMgr.define
local JZJXUtils = import(".JZJXUtils")
local JZJXData = import(".data.JZJXData")
local ActivityInterface = require("Main.activity.ActivityInterface")
local JiuXiaoConsts = require("netio.protocol.mzm.gsp.jiuxiao.JiuXiaoConsts")
JZJXMgr.WAITING_MAP_ID = 0
JZJXMgr.OUT_OF_ACTIVITY_MAP_LAYER = -1
def.const("number").TOP_LAYER = 10
def.field(JZJXData)._jzjxData = nil
def.field("table")._jzjxCfg = nil
def.field("table")._mapIdToCfg = nil
def.field("boolean").isInWaitingMap = false
def.field("boolean").isInActivityScene = false
def.field("table")._serviceMapActivityInfo = nil
def.field("table")._waitingRoomMapActivityInfo = nil
def.field("number")._lastMapId = 0
def.field("number")._activityId = 0
local instance
def.static("=>", JZJXMgr).Instance = function()
  if instance == nil then
    instance = JZJXMgr()
  end
  return instance
end
def.method().Init = function(self)
  import(".JZJXUIMgr", CUR_CLASS_NAME).Instance():Init()
  self:InitData()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, JZJXMgr._OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, JZJXMgr._OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, JZJXMgr._OnNPCService)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, JZJXMgr._OnMapChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jiuxiao.SEnterJiuXiaoMapRes", JZJXMgr._SEnterJiuXiaoMapRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jiuxiao.SUpdateLayerDataRes", JZJXMgr._SUpdateLayerDataRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jiuxiao.SJiuXiaoNormalResult", JZJXMgr._SJiuXiaoNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jiuxiao.SJiuXiaoWinBossRes", JZJXMgr._SJiuXiaoWinBossRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jiuxiao.SSynJiuXiaoFisrtWinRes", JZJXMgr._SSynJiuXiaoFisrtWinRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jiuxiao.SJiuXiaoPreciousItemBrd", JZJXMgr._SJiuXiaoPreciousItemBrd)
end
def.method().InitData = function(self)
end
def.method("=>", JZJXData).GetJZJXData = function(self)
  return self._jzjxData
end
def.method("=>", "table").GetJZJXCfg = function(self)
  return self._jzjxCfg
end
def.method("=>", "table").GetCurLayerMapCfg = function(self)
  if not self:IsInActivityMap() then
    return nil
  end
  local jzjxData = self._jzjxData
  for k, v in pairs(self._jzjxCfg) do
    if v.id == jzjxData.curLayerCfgId then
      return v
    end
  end
  return nil
end
def.method("number").GoToActivityNPC = function(self, npcid)
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {npcid})
end
def.method("number").EnterWaitingRoom = function(self, activityId)
  local canEnter = ActivityInterface.CheckActivityConditionLevel(activityId, true)
  if not canEnter then
    return
  end
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  local isNotOpen = not activityInterface:isActivityOpend(activityId)
  if isNotOpen then
    Toast(textRes.JueZhanJiuXiao[10])
    return
  end
  self:_CEnterJiuXiaoRoomReq(activityId)
end
def.method("=>", "table").GetEnterActivityMapStartTime = function(self)
  local activityId = self._activityId
  local activityStartTime = ActivityInterface.GetActivityBeginningTime(activityId)
  local waitSeconds = JZJXUtils.GetConstant("waitTime") * 60
  local startTimestamp = activityStartTime + waitSeconds
  return {timestamp = startTimestamp}
end
def.method("number").EnterActivityMap = function(self, activityId)
  local canEnter = ActivityInterface.CheckActivityConditionTeamMemberCount(activityId, true)
  if not canEnter then
    return
  end
  local canEnter = ActivityInterface.CheckActivityConditionLevel(activityId, true)
  if not canEnter then
    return
  end
  self:_CEnterJiuXiaoMapReq(activityId)
end
def.method().QuitActivity = function(self)
  self:_CLeaveJiuXiaoReq()
end
def.method()._LoadActivityDatas = function(self)
  if self._jzjxCfg == nil then
    self._jzjxCfg, self._mapIdToCfg = JZJXUtils.LoadActivityCfg()
  end
end
def.method("number", "=>", "number").GetMapLayer = function(self, cfgId)
  if self._jzjxCfg == nil then
    self:_LoadActivityDatas()
  end
  local layerCfg = self._jzjxCfg[cfgId]
  if layerCfg == nil then
    return JZJXMgr.OUT_OF_ACTIVITY_MAP_LAYER
  else
    return layerCfg.layer
  end
end
def.method("number", "=>", "number").GetMapLayerByMapId = function(self, mapId)
  if self._mapIdToCfg == nil then
    self:_LoadActivityDatas()
  end
  local layerCfg = self._mapIdToCfg[mapId]
  if layerCfg == nil then
    return JZJXMgr.OUT_OF_ACTIVITY_MAP_LAYER
  else
    return layerCfg.layer
  end
end
def.method("=>", "number").GetCurMapLayerCfgId = function(self)
  if self._jzjxData then
    return self._jzjxData.curLayerCfgId
  end
  return JZJXMgr.OUT_OF_ACTIVITY_MAP_LAYER
end
def.method("=>", "number").GetCurMapLayer = function(self)
  if self._jzjxData == nil then
    return JZJXMgr.OUT_OF_ACTIVITY_MAP_LAYER
  end
  local layerCfgId = self._jzjxData.curLayerCfgId
  local cfg = JZJXUtils.GetJZJXActivityCfg(layerCfgId)
  if cfg == nil then
    return JZJXMgr.OUT_OF_ACTIVITY_MAP_LAYER
  end
  return cfg.layer
end
def.method("number", "=>", "boolean").IsActivityMap = function(self, mapId)
  return self:GetMapLayerByMapId(mapId) ~= JZJXMgr.OUT_OF_ACTIVITY_MAP_LAYER
end
def.method("=>", "boolean").IsInActivityMap = function(self)
  if self._lastMapId == 0 then
    return false
  end
  return self:IsActivityMap(self._lastMapId)
end
def.method().LoadServiceActivityInfos = function(self)
  local infos = JZJXUtils.GetAllJZJXActivityInfos()
  self._serviceMapActivityInfo = {}
  for k, v in pairs(infos) do
    self._serviceMapActivityInfo[v.mapServiceid] = v
    self._serviceMapActivityInfo[v.waitRoomServiceid] = v
  end
end
def.method().LoadWaitingRoomActivityInfos = function(self)
  local infos = JZJXUtils.GetAllJZJXActivityInfos()
  self._waitingRoomMapActivityInfo = {}
  for k, v in pairs(infos) do
    self._waitingRoomMapActivityInfo[v.waitRoomMapid] = v
  end
end
def.method()._OnEnterActivityMap = function(self)
end
def.method()._OnChangeActivityMap = function(self)
end
def.method()._OnLeaveActivityMap = function(self)
  instance._jzjxData = nil
end
def.method().Release = function(self)
  self._jzjxData = nil
  self._jzjxCfg = nil
  self.isInWaitingMap = false
  self.isInActivityScene = false
  self._lastMapId = 0
end
def.static("table", "table")._OnLeaveWorld = function(params, context)
  instance:Release()
end
def.static("table", "table")._OnActivityTodo = function(params, context)
  local activityId = params[1]
  local activityInfo = JZJXUtils.GetJZJXActivityInfo(activityId)
  if activityInfo == nil then
    return
  end
  instance:GoToActivityNPC(activityInfo.npcid)
end
def.static("table", "table")._OnNPCService = function(params, context)
  local serviceId = params[1]
  local npcId = params[2]
  if instance._serviceMapActivityInfo == nil then
    instance:LoadServiceActivityInfos()
  end
  local activityInfo = instance._serviceMapActivityInfo[serviceId]
  if activityInfo == nil then
    return
  end
  if activityInfo.waitRoomServiceid == serviceId then
    instance:EnterWaitingRoom(activityInfo.activityid)
  else
    instance:EnterActivityMap(activityInfo.activityid)
  end
end
def.static("table", "table")._OnMapChange = function(params, context)
  local mapId = params[1]
  local function enterActivityScene(activityId)
    require("ProxySDK.ECMSDK").GSDKStart(0)
    instance:_LoadActivityDatas()
    instance.isInActivityScene = true
    instance._activityId = activityId
    gmodule.moduleMgr:GetModule(ModuleId.HERO):SetState(_G.RoleState.JZJX)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_Enter, nil)
  end
  local function leaveActivityScene()
    instance.isInActivityScene = false
    instance._activityId = 0
    gmodule.moduleMgr:GetModule(ModuleId.HERO):RemoveState(_G.RoleState.JZJX)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_Leave, nil)
    require("ProxySDK.ECMSDK").GSDKEnd()
  end
  local function enterWaitingRoom()
    instance.isInWaitingMap = true
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_EnterWaitingRoom, nil)
  end
  local function leaveWaitingRoom()
    instance.isInWaitingMap = false
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_LeaveWaitingRoom, nil)
  end
  local function enterActivityMap()
    local mapLayer = instance:GetMapLayerByMapId(mapId)
    instance:_OnEnterActivityMap()
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_EnterActivityMap, {mapLayer})
  end
  local function changeActivityMap()
    local lastMapLayer = instance:GetCurMapLayer()
    local mapLayer = instance:GetMapLayerByMapId(mapId)
    instance:_OnChangeActivityMap()
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_ChangeActivityMap, {mapLayer, lastMapLayer})
  end
  local function leaveActivityMap()
    instance:_OnLeaveActivityMap()
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_LeaveActivityMap, nil)
  end
  if instance._waitingRoomMapActivityInfo == nil then
    instance:LoadWaitingRoomActivityInfos()
  end
  local function isWaitingMap(mapId)
    local activityInfo = instance._waitingRoomMapActivityInfo[mapId]
    if activityInfo then
      return true
    else
      return false
    end
  end
  if instance.isInWaitingMap then
    if instance:IsActivityMap(mapId) then
      leaveWaitingRoom()
      enterActivityMap()
    elseif isWaitingMap(mapId) then
      warn("[JueZhanJiuXiao]: Attemp to teleport to waitting map but hero is in.")
    else
      leaveWaitingRoom()
      leaveActivityScene()
    end
  elseif instance:IsInActivityMap() then
    if isWaitingMap(mapId) then
      leaveActivityMap()
      enterWaitingRoom()
    elseif instance:IsActivityMap(mapId) then
      changeActivityMap()
    else
      leaveActivityMap()
      leaveActivityScene()
    end
  elseif isWaitingMap(mapId) then
    local activityInfo = instance._waitingRoomMapActivityInfo[mapId]
    enterActivityScene(activityInfo.activityid)
    enterWaitingRoom()
  else
    if instance:IsActivityMap(mapId) then
      enterActivityScene(0)
      enterActivityMap()
    else
    end
  end
  instance._lastMapId = mapId
end
def.static("table")._OnActivityStart = function(p)
  local activityId = p.activityid
end
def.method("number", "number")._CNPCTransforService = function(self, npcId, serviceId)
  local p = require("netio.protocol.mzm.gsp.npc.CNPCTransforService").new(npcId, serviceId)
  gmodule.network.sendProtocol(p)
end
def.method("number")._CEnterJiuXiaoRoomReq = function(self, activityId)
  print("CEnterJiuXiaoRoomReq", activityId)
  local p = require("netio.protocol.mzm.gsp.jiuxiao.CEnterJiuXiaoRoomReq").new(activityId)
  gmodule.network.sendProtocol(p)
end
def.method("number")._CEnterJiuXiaoMapReq = function(self, activityId)
  print("CEnterJiuXiaoMapReq")
  local p = require("netio.protocol.mzm.gsp.jiuxiao.CEnterJiuXiaoMapReq").new()
  gmodule.network.sendProtocol(p)
end
def.method()._CLeaveJiuXiaoReq = function(self)
  local p = require("netio.protocol.mzm.gsp.jiuxiao.CLeaveJiuXiaoReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table")._SEnterJiuXiaoMapRes = function(p)
  if p.result == p.class.PERSON_COUNT_NOT_ENOUGH then
    local activityId = self._activityId
    local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
    p.args[1] = tostring(activityCfg.personMin)
  elseif p.result == p.class.WAIT_TIME_NOW then
    local timeText = JZJXUtils.Seconds2TimeText(tonumber(p.args[1]))
    p.args[1] = timeText
  end
  local text = string.format(textRes.JueZhanJiuXiao.SEnterJiuXiaoMapRes[p.result], unpack(p.args))
  Toast(text)
end
def.static("table")._SJiuXiaoDataRes = function(p)
  if instance._jzjxData == nil then
    instance._jzjxData = JZJXData.New()
  end
  instance._jzjxData:RawSet(p)
end
def.static("table")._SUpdateLayerDataRes = function(p)
  warn("UpdateLayerMapData")
  if instance._jzjxData == nil then
    instance._jzjxData = JZJXData.New()
  end
  instance._jzjxData:UpdateLayerMapData(p.mapDataBean)
end
def.static("table")._SJiuXiaoNormalResult = function(p)
  local formatStr = textRes.JueZhanJiuXiao.SJiuXiaoNormalResult[p.result]
  if formatStr == nil then
    warn("_SJiuXiaoNormalResult not handle ", p.result)
    return
  end
  local text = string.format(formatStr, unpack(p.args))
  Toast(text)
end
def.static("table")._SJiuXiaoWinBossRes = function(p)
  if instance._jzjxData == nil then
    return
  end
  local cfgid = p.cfgid
  instance._jzjxData:SetDefeatBossState(cfgid, true)
end
def.static("table")._SSynJiuXiaoFisrtWinRes = function(p)
  local cfgid = p.cfgid
  local roles = p.roles
  local layerCfg = JZJXUtils.GetJZJXActivityCfg(cfgid)
  if layerCfg == nil then
    warn(string.format("OnSSynJiuXiaoFisrtWinRes: Can't find layer cfg for cfgid = %d ", cfgid))
    return
  end
  local mapid = layerCfg.mapId
  local MapUtility = require("Main.Map.MapUtility")
  local mapCfg = MapUtility.GetMapCfg(mapid)
  local mapName = mapCfg.mapName
  local bossNPCId = layerCfg.bossNPCId
  local NPCInterface = Lplus.ForwardDeclare("NPCInterface")
  local bossName = NPCInterface.GetNPCCfg(bossNPCId).npcName
  local viewData = {
    roles = roles,
    mapName = mapName,
    bossName = bossName
  }
  require("Main.Announcement.AnnouncementModule").onJiuXiaoFisrtWin(viewData)
end
def.static("table")._SJiuXiaoPreciousItemBrd = function(p)
  local roleName = p.roleName
  local npcid = p.npcid
  local item2Num = p.item2Num
  local activityid = p.activityid or 0
  local NPCInterface = require("Main.npc.NPCInterface")
  local npcCfg = NPCInterface.GetNPCCfg(npcid)
  local bossName = npcCfg and npcCfg.npcName or "unknow"
  local activityCfg = ActivityInterface.GetActivityCfgById(activityid)
  local activityName = "nil"
  if activityCfg then
    activityName = activityCfg.activityName
  end
  local viewData = {
    activityName = activityName,
    roleName = roleName,
    bossName = bossName,
    item2Num = item2Num
  }
  require("Main.Announcement.AnnouncementModule").onJiuXiaoPreciousItemBrd(viewData)
end
return JZJXMgr.Commit()
