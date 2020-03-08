local Lplus = require("Lplus")
local NPCInterface = Lplus.Class("NPCInterface")
local def = NPCInterface.define
local instance
local ThreeStateEnum = require("consts.mzm.gsp.npc.confbean.ThreeStateEnum")
local NPCCfgCache = require("Main.npc.NPCCfgCache")
local NPCServiceCfgCache = require("Main.npc.NPCServiceCfgCache")
def.static("=>", NPCInterface).Instance = function()
  if instance == nil then
    instance = NPCInterface()
    instance:Init()
  end
  return instance
end
def.field("number")._LastInteractiveNPCID = 0
def.field("number")._TargetNPC = 0
def.field("table")._TargetNPCInfo = nil
def.field("table")._NPCTaskStatus = nil
def.field("table")._NPCServiceCustomConditionFnTable = nil
def.field("table")._NPCServiceCustomNameFnTable = nil
def.field("table")._NPCServiceCustomConditionWaitTable = nil
def.field("table")._NPCServiceCustomConditionWaitStateTable = nil
def.field(NPCCfgCache)._NPCCfgCache = nil
def.field(NPCServiceCfgCache)._NPCServiceCfgCache = nil
NPCInterface.NPC_TASK_STATE_NONE = 0
NPCInterface.NPC_TASK_STATE_FIGHT = 1
NPCInterface.NPC_TASK_STATE_MAIN = 2
NPCInterface.NPC_TASK_STATE_BRANCH = 3
NPCInterface.NPC_TASK_STATE_NA_FT = 4
NPCInterface.NPC_TASK_STATE_DAILY_FT = 5
NPCInterface.NPC_TASK_STATE_NA_C = 6
NPCInterface.NPC_TASK_STATE_DAILY_C = 7
NPCInterface.NPC_TASK_STATE_NAD_A = 8
NPCInterface.NPC_TYPE_CLOSE = -1
NPCInterface.NPC_TYPE_NORMAL = 0
NPCInterface.NPC_TYPE_TRADE = 1
NPCInterface.NPC_TYPE_TRANSFER = 2
NPCInterface.NPC_TYPE_STALL = 3
NPCInterface.NPC_TYPE_FIGHT = 4
NPCInterface.NPC_TYPE_BUFF = 5
NPCInterface.NPC_TYPE_SONG = 7
NPCInterface.NPC_TYPE_TASK = 11
NPCInterface.NPC_TYPE_TASK_BATTLE = 12
NPCInterface.NPC_TYPE_MONSTER = 13
NPCInterface.NPC_TYPE_CUSTOM = 14
NPCInterface.NPC_TYPE_WATCH = 15
def.method().Init = function(self)
  self._NPCCfgCache = NPCCfgCache.New(15)
  self._NPCServiceCfgCache = NPCServiceCfgCache.New(10)
  self:Reset()
end
def.method().Reset = function(self)
  self._LastInteractiveNPCID = 0
  self._TargetNPC = 0
  self._TargetNPCInfo = nil
  self._NPCTaskStatus = {}
  self._NPCServiceCustomConditionFnTable = self._NPCServiceCustomConditionFnTable or {}
  self._NPCServiceCustomNameFnTable = self._NPCServiceCustomNameFnTable or {}
  self._NPCServiceCustomConditionWaitTable = self._NPCServiceCustomConditionWaitTable or {}
  self._NPCServiceCustomConditionWaitStateTable = {}
end
def.method("number", "varlist").SetTargetNPCID = function(self, npcID, npcInfo)
  self._TargetNPC = npcID
  self:SetTargetNPCInfo(npcInfo)
end
def.method("=>", "number").GetTargetNPCID = function(self)
  return self._TargetNPC
end
def.method("table").SetTargetNPCInfo = function(self, npcInfo)
  self._TargetNPCInfo = npcInfo
end
def.method("=>", "table").GetTargetNPCInfo = function(self)
  return self._TargetNPCInfo
end
def.method("number").SetLastInteractiveNPCID = function(self, npcID)
  self._LastInteractiveNPCID = npcID
end
def.method("=>", "number").GetLastInteractiveNPCID = function(self, npcID)
  return self._LastInteractiveNPCID
end
def.method("table").SetNPCTaskStatus = function(self, NPCTaskStatus)
  self._NPCTaskStatus = NPCTaskStatus
end
def.method("=>", "table").GetNPCTaskStatus = function(self)
  return self._NPCTaskStatus
end
def.method("number", "=>", "number").GetNPCTitleIcon = function(self, npcID)
  local npcCfg = NPCInterface.GetNPCCfg(npcID)
  if npcCfg.npcIconId ~= 0 then
    return npcCfg.npcIconId
  end
  local s = self._NPCTaskStatus[npcID]
  s = s or 0
  local iconID = NPCInterface.GetFlagIcon(s)
  return iconID
end
def.method("number", "function").RegisterNPCServiceCustomCondition = function(self, ServiceID, fn)
  self._NPCServiceCustomConditionFnTable[ServiceID] = fn
end
def.method("number", "=>", "boolean").CheckNPCCustomCondition = function(self, ServiceID, fn)
  local fn = self._NPCServiceCustomConditionFnTable[ServiceID]
  if fn == nil then
    return true
  end
  return fn(ServiceID)
end
def.method("number", "function").RegisterNPCServiceCustomName = function(self, ServiceID, fn)
  self._NPCServiceCustomNameFnTable[ServiceID] = fn
end
def.method("number", "function").RegisterNPCServiceCustomConditionWait = function(self, ServiceID, fn)
  self._NPCServiceCustomConditionWaitTable[ServiceID] = fn
end
def.method("number").NPCServiceCustomConditionWaitReady = function(self, ServiceID)
  local wait = false
  for k, v in pairs(self._NPCServiceCustomConditionWaitStateTable) do
    wait = true
    break
  end
  if wait == false then
    return
  end
  self._NPCServiceCustomConditionWaitStateTable[ServiceID] = nil
  for k, v in pairs(self._NPCServiceCustomConditionWaitStateTable) do
    return
  end
  local NPCModuleInstance = gmodule.moduleMgr:GetModule(ModuleId.NPC)
  local fn = NPCModuleInstance._npcServiceWaitReadyFunction
  if fn ~= nil then
    fn()
  end
end
def.static("number", "=>", "number").GetFlagIcon = function(state)
  local id = 0
  if state == NPCInterface.NPC_TASK_STATE_NONE then
    id = 0
  elseif state == NPCInterface.NPC_TASK_STATE_FIGHT then
    id = 5022
  elseif state == NPCInterface.NPC_TASK_STATE_MAIN then
    id = 5020
  elseif state == NPCInterface.NPC_TASK_STATE_BRANCH then
    id = 5021
  elseif state == NPCInterface.NPC_TASK_STATE_NA_FT then
    id = 5024
  elseif state == NPCInterface.NPC_TASK_STATE_DAILY_FT then
    id = 5027
  elseif state == NPCInterface.NPC_TASK_STATE_NA_C then
    id = 5023
  elseif state == NPCInterface.NPC_TASK_STATE_DAILY_C then
    id = 5026
  elseif state == NPCInterface.NPC_TASK_STATE_NAD_A then
    id = 5025
  end
  return id
end
def.static("number", "=>", "table").GetNPCCfg = function(npcID)
  if npcID == 100 then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    if heroProp ~= nil then
      local activityInterface = require("Main.activity.ActivityInterface").Instance()
      local menpaiNPC = activityInterface:GetMenpaiNPCData(heroProp.occupation)
      npcID = menpaiNPC.NPCID
    end
  end
  if npcID == 101 then
    return nil
  end
  local ret = instance._NPCCfgCache:GetData(npcID)
  return ret
end
def.static("number", "=>", "table")._LoadNPCCfg = function(npcID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_NPC_CONFIG, npcID)
  if record == nil then
    print("** GetNPCCfg(", npcID, ") return nil")
    return nil
  end
  local ret = {}
  ret.NpcID = record:GetIntValue("NpcID")
  ret.npcName = record:GetStringValue("npcName")
  ret.npcTitle = record:GetStringValue("npcTitle")
  ret.npcType = record:GetIntValue("npcType")
  ret.npcState = record:GetIntValue("npcState")
  ret.outlookid = record:GetIntValue("outlookid")
  ret.npcIconId = record:GetIntValue("npcIconId")
  ret.dyeMode = record:GetIntValue("dyeMode")
  ret.defaultAudioId = record:GetIntValue("defaultAudioId")
  ret.autoAudioId = record:GetIntValue("autoAudioId")
  ret.isAutoTurning = record:GetCharValue("isAutoTurning") ~= 0
  ret.isInAir = record:GetCharValue("isInAir") ~= 0
  ret.canSearch = record:GetCharValue("canSearch") ~= 0
  ret.canTeamMemberOpenDialog = record:GetCharValue("canTeamMemberOpenDialog") ~= 0
  ret.isVisible = record:GetCharValue("isVisible") ~= 0
  ret.miniMapName = record:GetStringValue("miniMapName")
  ret.miniMapNameColor = record:GetIntValue("miniMapNameColor")
  ret.monsterModelTableId = record:GetIntValue("monsterModelTableId")
  ret.mapId = record:GetIntValue("mapId")
  ret.x = record:GetIntValue("x")
  ret.y = record:GetIntValue("y")
  ret.serviceCfgs = {}
  local rec2 = record:GetStructValue("npcServiceListStruct")
  local count = rec2:GetVectorSize("npcServiceList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("npcServiceList", i - 1)
    local t = rec3:GetIntValue("ServiceId")
    local serviceCfg = NPCInterface.GetNpcServiceCfg(t)
    ret.serviceCfgs[t] = serviceCfg
  end
  ret.autoTalkList = {}
  rec2 = record:GetStructValue("autoTalkListStruct")
  count = rec2:GetVectorSize("autoTalkList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("autoTalkList", i - 1)
    local t = rec3:GetStringValue("autoTalk")
    table.insert(ret.autoTalkList, t)
  end
  ret.defaultTalk = {}
  rec2 = record:GetStructValue("defaultTalkListStruct")
  count = rec2:GetVectorSize("defaultTalkList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("defaultTalkList", i - 1)
    local t = rec3:GetStringValue("defaultTalk")
    table.insert(ret.defaultTalk, t)
  end
  return ret
end
def.static("number", "=>", "table").GetNpcServiceCfg = function(serviceID)
  local cfg = instance._NPCServiceCfgCache:GetData(serviceID)
  return cfg
end
def.static("number", "=>", "table")._LoadNpcServiceCfg = function(serviceID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_NPC_SERVICE_CFG, serviceID)
  if record == nil then
    print("GetNpcServiceCfg(" .. serviceID .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.serviceID = DynamicRecord.GetIntValue(record, "id")
  cfg.conditionGroupId = DynamicRecord.GetIntValue(record, "conditonGroupId")
  cfg.serviceType = DynamicRecord.GetIntValue(record, "serviceType")
  cfg.weight = DynamicRecord.GetIntValue(record, "weight")
  cfg.choiceName = DynamicRecord.GetStringValue(record, "choiseName")
  function cfg.GetChoiceName()
    local fn = instance._NPCServiceCustomNameFnTable[cfg.serviceID]
    if fn ~= nil then
      return fn(cfg)
    end
    return cfg.choiceName
  end
  local rec2 = record:GetStructValue("dialogsStruct")
  local count = rec2:GetVectorSize("dialogs")
  for i = 1, count do
    cfg.dialogs = cfg.dialogs or {}
    local rec3 = rec2:GetVectorValueByIdx("dialogs", i - 1)
    local t = rec3:GetStringValue("dialog")
    table.insert(cfg.dialogs, t)
  end
  return cfg
end
def.static("number", "=>", "table").GetNpcByServiceId = function(serviceID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SERVICE_TO_NPC, serviceID)
  if record == nil then
    warn("Get ServiceToNpc fail, wrong serviceID or it's not a buy/sell service")
    return nil
  end
  local cfg = {}
  cfg.serviceId = serviceID
  cfg.npcIds = {}
  local npcIdsStruct = DynamicRecord.GetStructValue(record, "npcIdsStruct")
  local npcIdsCount = DynamicRecord.GetVectorSize(npcIdsStruct, "npcIds")
  for i = 0, npcIdsCount - 1 do
    local rec = DynamicRecord.GetVectorValueByIdx(npcIdsStruct, "npcIds", i)
    local npcId = DynamicRecord.GetIntValue(rec, "npcId")
    table.insert(cfg.npcIds, npcId)
  end
  return cfg
end
def.static("number", "=>", "table").GetNPCToTaskCfg = function(npcID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_NPC_TO_TASK_CFG, npcID)
  if record == nil then
    return nil
  end
  local ret = {}
  ret.NpcID = DynamicRecord.GetIntValue(record, "npcId")
  local n2t = DynamicRecord.GetStructValue(record, "Npc2Task")
  local acceptableSize = DynamicRecord.GetVectorSize(n2t, "acceptTaskIds")
  ret.acceptableTaskIDs = {}
  for i = 0, acceptableSize - 1 do
    local rec = DynamicRecord.GetVectorValueByIdx(n2t, "acceptTaskIds", i)
    local taskID = DynamicRecord.GetIntValue(rec, "acceptTaskId")
    table.insert(ret.acceptableTaskIDs, taskID, taskID)
  end
  local finishSize = DynamicRecord.GetVectorSize(n2t, "finishTaskIds")
  ret.finishTaskIDs = {}
  for i = 0, finishSize - 1 do
    local rec = DynamicRecord.GetVectorValueByIdx(n2t, "finishTaskIds", i)
    local taskID = DynamicRecord.GetIntValue(rec, "finishTaskId")
    table.insert(ret.finishTaskIDs, taskID, taskID)
  end
  local battleSize = DynamicRecord.GetVectorSize(n2t, "battleTaskIds")
  ret.battleTaskIDs = {}
  for i = 0, battleSize - 1 do
    local rec = DynamicRecord.GetVectorValueByIdx(n2t, "battleTaskIds", i)
    local taskID = DynamicRecord.GetIntValue(rec, "battleTaskId")
    table.insert(ret.battleTaskIDs, taskID, taskID)
  end
  local targetTalkSize = DynamicRecord.GetVectorSize(n2t, "targetTalkTaskIds")
  ret.targetTalkTaskIDs = {}
  for i = 0, targetTalkSize - 1 do
    local talk = {}
    local rec = DynamicRecord.GetVectorValueByIdx(n2t, "targetTalkTaskIds", i)
    talk.taskID = DynamicRecord.GetIntValue(rec, "taskId")
    talk.dlgStr = DynamicRecord.GetStringValue(rec, "dlgStr")
    table.insert(ret.targetTalkTaskIDs, talk.taskID, talk)
  end
  local graphIdSize = DynamicRecord.GetVectorSize(n2t, "graphSetIds")
  ret.graphSetIds = {}
  for i = 0, graphIdSize - 1 do
    local rec = DynamicRecord.GetVectorValueByIdx(n2t, "graphSetIds", i)
    local graphId = DynamicRecord.GetIntValue(rec, "graphId")
    ret.graphSetIds[graphId] = graphId
  end
  return ret
end
def.static("number", "=>", "table").GetNpcServiceConditionCfg = function(conditonGroupId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_NPC_SERVICE_CONDITON_CFG, conditonGroupId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.conditionGroupId = DynamicRecord.GetIntValue(record, "id")
  cfg.bianShenState = DynamicRecord.GetIntValue(record, "bianShenState")
  cfg.factionState = DynamicRecord.GetIntValue(record, "factionState")
  cfg.jieBaiState = DynamicRecord.GetIntValue(record, "jieBaiState")
  cfg.levelMax = DynamicRecord.GetIntValue(record, "levelMax")
  cfg.levelMin = DynamicRecord.GetIntValue(record, "levelMin")
  cfg.marriedState = DynamicRecord.GetIntValue(record, "marriedState")
  cfg.forceDivorce = DynamicRecord.GetIntValue(record, "forceDivorce")
  cfg.menpai = DynamicRecord.GetIntValue(record, "menpai")
  cfg.sex = DynamicRecord.GetIntValue(record, "sex")
  cfg.shiTuState = DynamicRecord.GetIntValue(record, "shiTuState")
  cfg.teamLevelMin = DynamicRecord.GetIntValue(record, "teamLevelMin")
  cfg.teamNumMin = DynamicRecord.GetIntValue(record, "teamNumMin")
  cfg.teamNumMax = DynamicRecord.GetIntValue(record, "teamNumMax")
  cfg.teamState = DynamicRecord.GetIntValue(record, "teamState")
  return cfg
end
def.static("number", "=>", "table").GetNpcServiceTransferCfg = function(serviceID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_NPC_SERVICE_TRANSFER_CFG, serviceID)
  if record == nil then
    warn("GetNpcServiceTransferCfg(" .. serviceID .. ")")
    return nil
  end
  local cfg = {}
  cfg.serviceID = serviceID
  cfg.ACKAgainWords = DynamicRecord.GetStringValue(record, "ACKAgainWords")
  return cfg
end
def.static("number", "=>", "table").GetNpcFigureCfg = function(figureId)
  if figureId > 0 then
    return GetAppearanceCfg(figureId)
  else
    return nil
  end
end
def.static("number").MoveToNPC = function(npcID)
  local npcCfg = NPCInterface.GetNPCCfg(npcID)
  if npcCfg.mapId ~= 0 then
    local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    heroModule.needShowAutoEffect = true
    local Space = require("consts.mzm.gsp.map.confbean.Space")
    heroModule:MoveTo(npcCfg.mapId, npcCfg.x, npcCfg.y, npcCfg.isInAir and Space.SKY or Space.GROUND, 5, MoveType.AUTO, nil)
  else
    print("@@@@ Path find NPC(" .. npcID .. ") mapID==0!!!!!\n")
  end
end
def.static("table", "=>", "boolean").CheckNpcServiceConditon = function(serviceConditionCfg)
  local cfg = serviceConditionCfg
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return false
  end
  if cfg.factionState ~= ThreeStateEnum.Ignore then
    local gangModule = gmodule.moduleMgr:GetModule(ModuleId.GANG)
    local bHaveGang = gangModule:HasGang()
    if cfg.factionState == ThreeStateEnum.Yes then
      if bHaveGang == false then
        return false
      end
      local gangData = require("Main.Gang.data.GangData").Instance()
      local mapIID = gangData:GetGangMapInstanceId()
      local mapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
      if mapIID ~= mapModule.mapInstanceId then
        return false
      end
    end
    if cfg.factionState == ThreeStateEnum.No and bHaveGang == true then
      return false
    end
  end
  if cfg.jieBaiState ~= ThreeStateEnum.Ignore then
    local SwornUtils = require("Main.Sworn.SwornUtils")
    if cfg.jieBaiState == ThreeStateEnum.Yes and SwornUtils.IsSworn() == false then
      return false
    end
    if cfg.jieBaiState == ThreeStateEnum.No and SwornUtils.IsSworn() == true then
      return false
    end
  end
  if heroProp.level < cfg.levelMin or heroProp.level > cfg.levelMax then
    return false
  end
  if cfg.marriedState ~= ThreeStateEnum.Ignore then
    local MarriageInterface = require("Main.Marriage.MarriageInterface")
    local isMarried = MarriageInterface.IsMarried()
    if cfg.marriedState == ThreeStateEnum.Yes and isMarried == false then
      return false
    end
    if cfg.marriedState == ThreeStateEnum.No and isMarried == true then
      return false
    end
  end
  if cfg.forceDivorce ~= ThreeStateEnum.Ignore then
    local MarriageInterface = require("Main.Marriage.MarriageInterface")
    local isDivorcing = MarriageInterface.IsDivorcing()
    if cfg.forceDivorce == ThreeStateEnum.Yes and isDivorcing == false then
      return false
    end
    if cfg.forceDivorce == ThreeStateEnum.No and isDivorcing == true then
      return false
    end
  end
  if cfg.menpai ~= 0 and cfg.menpai ~= heroProp.occupation then
    return false
  end
  if cfg.sex ~= 0 and cfg.sex ~= heroProp.gender then
    return false
  end
  return true
end
def.static("table", "=>", "boolean").CheckNpcServiceTeamConditon = function(serviceConditionCfg)
  local teamData = require("Main.Team.TeamData").Instance()
  local members = teamData:GetAllTeamMembers()
  local memberCount = 0
  local teamLevelMin = 10000000
  if teamData:HasTeam() == false then
    memberCount = 1
  else
    for k, v in pairs(members) do
      memberCount = memberCount + 1
      if teamLevelMin > v.level then
        teamLevelMin = v.level
      end
    end
  end
  if cfg.teamNumMax ~= 0 and memberCount > cfg.teamNumMax then
    return false
  end
  if cfg.teamNumMin ~= 0 and memberCount < cfg.teamNumMin then
    return false
  end
  if teamLevelMin < cfg.teamLevelMin then
    return false
  end
  return true
end
def.static("number", "number", "boolean", "=>", "boolean").CheckBattalTeamMemberCount = function(enterFightMinRoleNum, enterFightMaxRoleNum, msg)
  local teamData = require("Main.Team.TeamData").Instance()
  local members = teamData:GetAllTeamMembers()
  local memberCount = 1
  local ST_NORMAL = require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL
  if teamData:HasTeam() == true then
    memberCount = 0
    for k, v in pairs(members) do
      if v.status == ST_NORMAL then
        memberCount = memberCount + 1
      end
    end
  end
  local ret = enterFightMinRoleNum <= memberCount and enterFightMaxRoleNum >= memberCount
  if ret == false and msg == true then
    if enterFightMaxRoleNum == 1 then
      Toast(textRes.NPC[15])
    else
      if enterFightMinRoleNum > memberCount then
        Toast(string.format(textRes.NPC[16], enterFightMinRoleNum))
      end
      if enterFightMaxRoleNum < memberCount then
        Toast(string.format(textRes.NPC[19], enterFightMaxRoleNum))
      end
    end
  end
  return ret
end
def.static("number", "=>", "boolean").CheckBattleTeamMemberLevel = function(levelMin)
  local teamData = require("Main.Team.TeamData").Instance()
  local members = teamData:GetAllTeamMembers()
  for _, v in pairs(members) do
    if levelMin > v.level then
      return false
    end
  end
  return true
end
def.method("number", "=>", "boolean").isInNpcNear = function(self, npcID)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local npcCfg = NPCInterface.GetNPCCfg(npcID)
  if npcCfg == nil then
    warn("**********isInNpcNear(),npcCfg == nil:", npcID)
    return false
  end
  local myRole = heroModule.myRole
  if myRole == nil then
    return false
  end
  local heroPos = heroModule.myRole:GetPos()
  if heroPos == nil then
    warn("---------------HeroPos is nil")
    return false
  end
  local npcx = npcCfg.x
  local npcy = npcCfg.y
  local displayMapID = npcCfg.mapId
  local theNPC = pubroleModule:GetNpc(npcID)
  if theNPC ~= nil then
    local npcPos = theNPC:GetPos()
    npcx = npcPos.x
    npcy = npcPos.y
    local mapId = theNPC:GetDisplayMapId()
    if mapId ~= 0 then
      displayMapID = mapId
    end
  else
    return false
  end
  local myx = heroPos.x
  local myy = heroPos.y
  local dx = (npcx - myx) * (npcx - myx)
  local dy = (npcy - myy) * (npcy - myy)
  local d = dx + dy
  local MapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  local mapID = MapModule:GetMapId()
  if mapID ~= displayMapID or d > 32768 or npcCfg.isInAir ~= heroModule.myRole:IsInState(RoleState.FLY) then
    return false
  end
  return true
end
def.method("number").ShowSong = function(self, serviceId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SONG, serviceId)
  if record == nil then
    warn("ShowSong nil", serviceId)
    return
  end
  local musicName = record:GetStringValue("musicName")
  local singerName = record:GetStringValue("singerName")
  local album = record:GetStringValue("album")
  local lyric = record:GetStringValue("lyric")
  require("Main.npc.ui.SongDlg").ShowDlg(musicName, singerName, album, lyric)
end
NPCInterface.Commit()
return NPCInterface
