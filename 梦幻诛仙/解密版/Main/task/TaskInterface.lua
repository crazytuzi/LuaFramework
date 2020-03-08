local Lplus = require("Lplus")
local TaskInterface = Lplus.Class("TaskInterface")
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
local def = TaskInterface.define
local instance
def.static("=>", TaskInterface).Instance = function()
  if instance == nil then
    instance = TaskInterface()
    instance:Init()
    GameUtil.AddGlobalTimer(10, false, TaskInterface.CheckTaskCache)
  end
  return instance
end
def.field("table")._taskCfgs = nil
def.field("table")._GraphCfgs = nil
def.field("table")._taskInfo = nil
def.field("table")._taskRing = nil
def.field("table")._taskRequirements = nil
def.field("table")._taskPetRequirements = nil
def.field("table")._taskLegendTime = nil
def.field("number")._taskPathFindTaskID = 0
def.field("number")._taskPathFindGraphID = 0
def.field("number")._taskFindPathRequirementID = 0
def.field("number")._taskFindPathNeedCount = 0
def.field("number")._currQingyunHistoryChapter = 0
def.field("number")._currQingyunHistoryNode = 0
def.field("table")._taskItems = nil
def.field("string")._playingOpera = ""
def.field("table")._taskLightRoundGraphIDs = nil
def.field("table")._taskLightRoundEffectIds = nil
def.field("table")._enterFightConfirmMembers = nil
def.field("number")._curTaskId = 0
def.field("table")._resetTask = nil
def.field("table")._accpetTaskInfo = nil
def.field("table")._timeLimitGraph = nil
def.field("table")._allBanGraphIds = nil
def.field("table")._taskCustomNpcIdFn = nil
def.static("number", "=>", "table").GetTaskCfg = function(taskID)
  local ret = instance._taskCfgs[taskID]
  if ret ~= nil then
    ret.timeStamp = _G.GetServerTime()
    return ret
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_CFG, taskID)
  if record == nil then
    error("Not found the task config!!!! id = " .. tostring(taskID))
    return nil
  end
  local cfg = {}
  cfg.taskID = taskID
  cfg.acceptAutoFindPath = record:GetCharValue("acceptAutoFindPath") ~= 0
  cfg.finishAutoFindPath = record:GetCharValue("finishAutoFindPath") ~= 0
  cfg.autoDialog = record:GetCharValue("autoDialog") ~= 0
  cfg.autoFinish = record:GetCharValue("autoFinish") ~= 0
  cfg.noSeekPath = record:GetCharValue("noSeekPath") ~= 0
  cfg._finishTaskNPC = record:GetIntValue("finishTaskNPC")
  cfg._giveTaskNPC = record:GetIntValue("giveTaskNPC")
  cfg.giveUpConfirm = record:GetStringValue("giveUpConfirm")
  cfg.pathNpcId = record:GetIntValue("pathNpcId")
  cfg.serviceId = record:GetIntValue("serverId")
  cfg.taskDes = record:GetStringValue("taskDes")
  cfg.taskName = record:GetStringValue("taskName")
  cfg.taskTarget = record:GetStringValue("taskTarget")
  cfg.taskFinishTarget = record:GetStringValue("taskFinishTarget")
  cfg.battlePeopleNumLower = record:GetIntValue("battlePeopleNumLower")
  cfg.battlePeopleNumUpper = record:GetIntValue("battlePeopleNumUpper")
  cfg.giveTaskGoods = record:GetIntValue("giveTaskGoods")
  cfg.isAcceptDlg = record:GetCharValue("isAcceptDlg") ~= 0
  cfg.isAcceptTip = record:GetCharValue("isAcceptTip") ~= 0
  cfg.isFinishTip = record:GetCharValue("isFinishTip") ~= 0
  cfg.isFailTip = record:GetCharValue("isFailTip") ~= 0
  cfg.isGiveUpTip = record:GetCharValue("isGiveUpTip") ~= 0
  cfg.isShowFinish = record:GetCharValue("isShowFinish") ~= 0
  cfg.useFlySword = record:GetCharValue("useFlySword") ~= 0
  cfg.acceptTip = record:GetStringValue("acceptTip")
  cfg.finishTip = record:GetStringValue("finishTip")
  cfg.failTip = record:GetStringValue("failTip")
  cfg.giveUpTip = record:GetStringValue("giveUpTip")
  cfg.acceptConIds = {}
  cfg.finishConIds = {}
  cfg.acceptOperIds = {}
  cfg.finishOperIds = {}
  local rec2 = record:GetStructValue("acceptConIdsStruct")
  local count = rec2:GetVectorSize("acceptConIds")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("acceptConIds", i - 1)
    local t = {}
    t.id = rec3:GetIntValue("conId")
    t.classType = rec3:GetIntValue("classType")
    table.insert(cfg.acceptConIds, t)
  end
  rec2 = record:GetStructValue("finishConIdsStruct")
  count = rec2:GetVectorSize("finishConIds")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("finishConIds", i - 1)
    local t = {}
    t.id = rec3:GetIntValue("conId")
    t.classType = rec3:GetIntValue("classType")
    table.insert(cfg.finishConIds, t)
  end
  rec2 = record:GetStructValue("acceptOperIdsStruct")
  count = rec2:GetVectorSize("acceptOperIds")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("acceptOperIds", i - 1)
    local opera = {}
    opera.id = rec3:GetIntValue("operId")
    opera.classType = rec3:GetIntValue("classType")
    table.insert(cfg.acceptOperIds, opera)
  end
  rec2 = record:GetStructValue("finishOperIdsStruct")
  count = rec2:GetVectorSize("finishOperIds")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("finishOperIds", i - 1)
    local opera = {}
    opera.id = rec3:GetIntValue("operId")
    opera.classType = rec3:GetIntValue("classType")
    table.insert(cfg.finishOperIds, opera)
  end
  record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_MAPPOSITION_CFG, taskID)
  if record ~= nil then
    cfg.pathFinds = {}
    rec2 = record:GetStructValue("mapInfoListStruct")
    count = rec2:GetVectorSize("mapInfoList")
    for i = 1, count do
      local rec3 = rec2:GetVectorValueByIdx("mapInfoList", i - 1)
      local pathFind = {}
      pathFind.mapID = rec3:GetIntValue("mapID")
      pathFind.x = rec3:GetIntValue("x")
      pathFind.y = rec3:GetIntValue("y")
      table.insert(cfg.pathFinds, pathFind)
    end
  end
  function cfg.FindFinishConditionID(condType)
    for k, v in pairs(cfg.finishConIds) do
      if v.classType == condType then
        return v.id
      end
    end
    return -1
  end
  function cfg.FindFinishOprationID(operType)
    for k, v in pairs(cfg.operIds) do
      if v.classType == condType then
        return v.id
      end
    end
    return -1
  end
  function cfg.GetFinishTaskNPC()
    if cfg._finishTaskNPC == 100 then
      local heroProp = require("Main.Hero.Interface").GetHeroProp()
      if heroProp == nil then
        return cfg._finishTaskNPC
      end
      local activityInterface = require("Main.activity.ActivityInterface").Instance()
      local menpaiNPC = activityInterface:GetMenpaiNPCData(heroProp.occupation)
      return menpaiNPC.NPCID
    end
    local customNpcId = instance:getCustomTaskNpcId(cfg._finishTaskNPC)
    if customNpcId ~= 0 then
      return customNpcId
    end
    return cfg._finishTaskNPC
  end
  function cfg.GetGiveTaskNPC()
    if cfg._giveTaskNPC == 100 then
      local heroProp = require("Main.Hero.Interface").GetHeroProp()
      if heroProp == nil then
        return cfg._giveTaskNPC
      end
      local activityInterface = require("Main.activity.ActivityInterface").Instance()
      local menpaiNPC = activityInterface:GetMenpaiNPCData(heroProp.occupation)
      return menpaiNPC.NPCID
    end
    local customNpcId = instance:getCustomTaskNpcId(cfg._giveTaskNPC)
    if customNpcId ~= 0 then
      return customNpcId
    end
    return cfg._giveTaskNPC
  end
  cfg.timeStamp = _G.GetServerTime()
  instance._taskCfgs[taskID] = cfg
  return cfg
end
def.static("number", "=>", "table").GetTaskUsedLibCfg = function(libId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_USED_NPCLIB_CFG, libId)
  if record == nil then
    error("Not found the task lib cfg!!!! libid = " .. tostring(libId))
    return nil
  end
  local cfg = {}
  cfg.npcLibId = libId
  cfg.npcIds = {}
  local rec2 = record:GetStructValue("npcIdStruct")
  local count = rec2:GetVectorSize("npcIds")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("npcIds", i - 1)
    local npcId = rec3:GetIntValue("npcId")
    table.insert(cfg.npcIds, npcId)
  end
  return cfg
end
def.static().CheckTaskCache = function()
  if instance._taskCfgs == nil then
    return
  end
  local curtime = _G.GetServerTime()
  for k, v in pairs(instance._taskCfgs) do
    if curtime - v.timeStamp >= 10 then
      instance._taskCfgs[k] = nil
    end
  end
end
def.static("number", "number", "=>", "table").GetTaskAwardCfg = function(graphId, taskId)
  local awardKey = "key_" .. tostring(graphId) .. tostring(taskId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_AWARD_SHOW_CFG, awardKey)
  if record == nil then
    return nil
  end
  local awardShowCfg = {}
  awardShowCfg.isShow = record:GetCharValue("isVisiable") ~= 0
  awardShowCfg.awardKey = record:GetStringValue("awardKey")
  awardShowCfg.graphId = record:GetIntValue("graphId")
  awardShowCfg.taskId = record:GetIntValue("taskId")
  awardShowCfg.itemIDs = {}
  local rec2 = record:GetStructValue("awardItemIdsStruct")
  local count = rec2:GetVectorSize("awardItemIds")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("awardItemIds", i - 1)
    local itemID = rec3:GetIntValue("itemId")
    if itemID > 0 then
      table.insert(awardShowCfg.itemIDs, itemID)
    end
  end
  return awardShowCfg
end
def.static("number", "=>", "table").GetTaskTalkCfg = function(taskId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_DIALOG_CFG, taskId)
  if record == nil then
    print("** ************* TaskInterface.GetTaskTalkCfg", taskId, "record == nil")
    return nil
  end
  local cfg = {}
  cfg.id = taskId
  cfg.dlgs = {}
  local dlgSize = record:GetVectorSize("dlgs")
  for i = 1, dlgSize do
    local recordDlg = record:GetVectorValueByIdx("dlgs", i - 1)
    if recordDlg == nil then
      return nil
    end
    local dlg = {}
    dlg.type = recordDlg:GetIntValue("type")
    dlg.content = {}
    local OneDlgSize = recordDlg:GetVectorSize("dlg")
    for j = 1, OneDlgSize do
      local content = recordDlg:GetVectorValueByIdx("dlg", j - 1)
      local voiceID = content:GetIntValue("voiceId")
      local talkerId = content:GetIntValue("talkerId")
      local words = content:GetStringValue("words")
      local content = {}
      content.voiceID = voiceID
      content.npcid = talkerId
      content.txt = words
      table.insert(dlg.content, j, content)
    end
    cfg.dlgs[dlg.type] = dlg
  end
  return cfg
end
def.static("number", "=>", "table").GetTaskConditionArrive = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKCONTOPLACE_CFG, conditionID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.mapId = record:GetIntValue("mapId")
  cfg.radis = record:GetIntValue("radis")
  cfg.x = record:GetIntValue("x")
  cfg.y = record:GetIntValue("y")
  cfg.z = record:GetIntValue("z")
  cfg.tipDialog = record:GetStringValue("tipDialog")
  return cfg
end
def.static("number", "=>", "table").GetTaskConditionLevel = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKCONLEVEL_CFG, conditionID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.contype = record:GetIntValue("contype")
  cfg.isVisiable = record:GetCharValue("isVisiable") ~= 0
  cfg.levelType = record:GetIntValue("levelType")
  cfg.maxLevel = record:GetIntValue("maxLevel")
  cfg.minLevel = record:GetIntValue("minLevel")
  return cfg
end
def.static("number", "=>", "table").GetTaskConditionWinCount = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKCONWINCOUNT_CFG, conditionID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.contype = record:GetIntValue("contype")
  cfg.mapId = record:GetIntValue("mapId")
  cfg.winCount = record:GetIntValue("winCount")
  return cfg
end
def.static("number", "=>", "table").GetTaskConditionBag = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKCONBAG_CFG, conditionID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.contype = record:GetIntValue("contype")
  cfg.bagMoney = record:GetIntValue("bagMoney")
  cfg.takeCfgCount = record:GetIntValue("takeCfgCount")
  cfg.takeCfgId = record:GetIntValue("takeCfgId")
  cfg.takeItemType = record:GetIntValue("takeItemType")
  return cfg
end
def.static("number", "=>", "table").GetTaskConditionKillNpc = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKCONKILLNPC_CFG, conditionID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.contype = record:GetIntValue("contype")
  cfg.fixNPCId = record:GetIntValue("fixNPCId")
  return cfg
end
def.static("number", "=>", "table").GetTaskConditionKillMonsterCount = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKCONKILLMONSTERCOUNT_CFG, conditionID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.contype = record:GetIntValue("contype")
  cfg.killMonsterId = record:GetIntValue("killMonsterId")
  cfg.killMonsterCount = record:GetIntValue("killMonsterCount")
  cfg.killMonsterMapId = record:GetIntValue("killMonsterMapId")
  return cfg
end
def.static("number", "=>", "table").GetTaskConditionNPCDialog = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKCONNPCDIALOG_CFG, conditionID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.contype = record:GetIntValue("contype")
  cfg.NpcID = record:GetIntValue("npcId")
  return cfg
end
def.static("number", "=>", "table").GetTaskConditionTeam = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKCONTEAM_CFG, conditionID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.contype = record:GetIntValue("contype")
  cfg.friendPoint = record:GetIntValue("friendPoint")
  cfg.isVisiable = record:GetCharValue("isVisiable") ~= 0
  cfg.personCount = record:GetIntValue("personCount")
  cfg.personRelation = record:GetIntValue("personRelation")
  return cfg
end
def.static("number", "=>", "table").GetTaskConditionTime = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKCONTIMELIMIT_CFG, conditionID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.contype = record:GetIntValue("contype")
  cfg.timeLimit = record:GetIntValue("timeLimit")
  cfg.timeOutHandleTask = record:GetIntValue("timeOutHandleTask")
  cfg.timeLimitTitle = record:GetStringValue("timeLimitTitle")
  return cfg
end
def.static("number", "=>", "table").GetTaskConditionPet = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKCONPETCON_CFG, conditionID)
  if record == nil then
    print("************************* return nil conditionID =", conditionID)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.contype = record:GetIntValue("contype")
  cfg.petCount = record:GetIntValue("petCount")
  cfg.petId = record:GetIntValue("petId")
  return cfg
end
def.static("number", "=>", "table").GetTaskConditionGatherItem = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKCONGATHERITEM_CFG, conditionID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.contype = record:GetIntValue("contype")
  cfg.gatherCount = record:GetIntValue("gatherCount")
  cfg.gatherId = record:GetIntValue("gatherId")
  cfg.taskBagItemId = record:GetIntValue("taskBagItemId")
  local record2 = DynamicData.GetRecord(CFG_PATH.DATA_MAP_ITEM_CFG, cfg.gatherId)
  cfg.name = record2:GetStringValue("name")
  cfg.desc = record2:GetStringValue("desc")
  return cfg
end
def.static("number", "=>", "table").TaskConditionLeiTaiWinCountCfg = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKCONLEITAIWINCOUNT_CFG, conditionID)
  if record == nil then
    warn("************************ TaskConditionLeiTaiWinCountCfg(", conditionID, ") == nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.contype = record:GetIntValue("contype")
  cfg.winCount = record:GetIntValue("winCount")
  return cfg
end
def.static("number", "=>", "table").TaskConditionActivityFinishCountCfg = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKCONACTIVITYFINISHCOUNT_CFG, conditionID)
  if record == nil then
    warn("************************ TaskConditionActivityFinishCountCfg(", conditionID, ") == nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.contype = record:GetIntValue("contype")
  cfg.circleCount = record:GetIntValue("circleCount")
  return cfg
end
def.static("number", "=>", "table").TaskConditionFinishQuestion = function(conditionID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_CON_FINISH_QUESTION, conditionID)
  if record == nil then
    warn("!!!!!!!!! TaskConditionFinishQuestion(", conditionID, ") == nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.conType = record:GetIntValue("conType")
  cfg.npcId = record:GetIntValue("npcId")
  cfg.questionLibId = record:GetIntValue("questionLibId")
  cfg.needRightNum = record:GetIntValue("needRightNum")
  return cfg
end
def.static("number", "=>", "table").GetTaskGraphCfg = function(graphID)
  local ret = instance._GraphCfgs[graphID]
  if ret ~= nil then
    return ret
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_GRAPH_CFG, graphID)
  if record == nil then
    error("** ************* Not found the graph config!!!! id = " .. tostring(graphID))
    return nil
  end
  local cfg = {}
  cfg.graphID = record:GetIntValue("id")
  cfg.ringCount = record:GetIntValue("ringCount")
  cfg.taskType = record:GetIntValue("taskType")
  cfg.iconId = record:GetIntValue("iconId")
  cfg.giveTaskNpc = record:GetIntValue("giveTaskNpc")
  local isImportant = record:GetCharValue("isImportant")
  cfg.isImportant = isImportant ~= 0
  local isContinueTask = record:GetCharValue("isContinueTask")
  cfg.isContinueTask = isContinueTask ~= 0
  local notShowInAcceptableList = record:GetCharValue("notShowInAcceptableList")
  cfg.notShowInAcceptableList = notShowInAcceptableList ~= 0
  local canGiveUpTask = record:GetCharValue("canGiveUpTask")
  cfg.canGiveUpTask = canGiveUpTask ~= 0
  cfg.giveUpTaskConfirmTip = record:GetStringValue("giveUpTaskConfirmTip")
  local hideSchedule = record:GetCharValue("hideSchedule")
  cfg.hideSchedule = hideSchedule ~= 0
  instance._GraphCfgs[graphID] = cfg
  return cfg
end
def.static("number", "=>", "table").GetTaskGivePetOperate = function(operateID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKOPERATEGIVEPET_CFG, operateID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.operType = record:GetIntValue("operType")
  cfg.takePet = record:GetIntValue("takePet")
  cfg.teamType = record:GetIntValue("teamType")
  return cfg
end
def.static("number", "=>", "table").GetTaskGiveItemOperate = function(operateID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKOPERATEGIVEITEM_CFG, operateID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.operType = record:GetIntValue("operType")
  cfg.cfgId = record:GetIntValue("cfgId")
  cfg.cfgCount = record:GetIntValue("cfgCount")
  cfg.cfgType = record:GetIntValue("cfgType")
  cfg.teamType = record:GetIntValue("teamType")
  return cfg
end
def.static("number", "=>", "table").GetTaskPlayOperaOperate = function(operateID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKOPERATEPLAYOPERA_CFG, operateID)
  if record == nil then
    print("*********** GetTaskPlayOperaOperate(", operateID, ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.operType = record:GetIntValue("operType")
  cfg.operaID = record:GetIntValue("operaID")
  cfg.teamType = record:GetIntValue("teamType")
  return cfg
end
def.static("number", "=>", "table").GetTaskOperPlayEffectOperate = function(operateID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKOPERPLAYEFFECT_CFG, operateID)
  if record == nil then
    print("*********** GetTaskOperPlayEffectOperate(", operateID, ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.operType = record:GetIntValue("operType")
  cfg.teamType = record:GetIntValue("teamType")
  cfg.playTime = record:GetIntValue("playTime")
  cfg.effectIds = {}
  local rec2 = record:GetStructValue("effectIdsStruct")
  local count = rec2:GetVectorSize("effectIds")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("effectIds", i - 1)
    local id = rec3:GetIntValue("Id")
    table.insert(cfg.effectIds, id)
  end
  return cfg
end
def.static("number", "=>", "table").GetOperaCfg = function(operaID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_OPERA_CFG, operaID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.operaId = record:GetIntValue("operaId")
  cfg.name = record:GetStringValue("name")
  cfg.path = record:GetStringValue("path")
  return cfg
end
def.static("number", "=>", "table").GetTaskGoodsCfg = function(itemID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_GOODS_CFG, itemID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.canuse = record:GetCharValue("canuse") ~= 0
  cfg.mapid = record:GetIntValue("mapid")
  cfg.posx = record:GetIntValue("posx")
  cfg.posy = record:GetIntValue("posy")
  cfg.useEffectType = record:GetIntValue("useEffectType")
  cfg.specialEffect = record:GetIntValue("specialEffect")
  cfg.displayWords = record:GetStringValue("displayWords")
  return cfg
end
def.static("number", "=>", "table").GetTaskSpecialEffectCfg = function(specialEffectID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SPECIAL_EFFECT_CFG, specialEffectID)
  if record == nil then
    print("*************  GetTaskSpecialEffectCfg(", specialEffectID, ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.loadType = record:GetIntValue("loadType")
  cfg.npcId = record:GetIntValue("npcId")
  cfg.coordX = record:GetIntValue("coordX")
  cfg.coordY = record:GetIntValue("coordY")
  cfg.effectId = record:GetIntValue("effectId")
  return cfg
end
def.static("number", "=>", "table").GetTaskVoiceChildCfg = function(voiceChildID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_VOICE_CHILD_CFG, voiceChildID)
  if record == nil then
    print("*************  GetTaskVoiceChildCfg(", voiceChildID, ") return nil")
    return nil
  end
  local cfg = {}
  cfg.gender = record:GetIntValue("gender")
  cfg.occupation = record:GetIntValue("occupation")
  cfg.voiceCfgId = record:GetIntValue("voiceCfgId")
  return cfg
end
def.static("number", "=>", "table").GetTaskVoiceMumCfg = function(voiceMumID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_VOICE_MUM_CFG, voiceMumID)
  if record == nil then
    print("*************  GetTaskVoiceMumCfg(", voiceMumID, ") return nil")
    return nil
  end
  local cfg = {}
  cfg.taskVoiceId = record:GetIntValue("taskVoiceId")
  cfg.voicechildIds = {}
  local rec2 = record:GetStructValue("voicechildIdsStruct")
  local count = rec2:GetVectorSize("voicechildIds")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("voicechildIds", i - 1)
    local voiceChildId = rec3:GetIntValue("voiceChildId")
    if voiceChildId ~= 0 then
      table.insert(cfg.voicechildIds, voiceChildId)
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetLevelActiveGraphCfg = function(graphId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_LEVEL_ACTIVE_GRAPH_CFG, graphId)
  if record == nil then
    warn("!!!!!!!! GetLevelActiveGraphCfg graphId is nil:", graphId)
    return nil
  end
  local cfg = {}
  cfg.graphId = record:GetIntValue("graphId")
  cfg.id = record:GetIntValue("id")
  cfg.activeLv = record:GetIntValue("activeLv")
  cfg.activityId = record:GetIntValue("activityId")
  cfg.openId = record:GetIntValue("openId")
  return cfg
end
def.static("number", "=>", "table").IsOwnLevelActiveGraphCfgByActivityId = function(activityId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_LEVEL_ACTIVE_GRAPH_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local curActivityId = record:GetIntValue("activityId")
    if activityId == curActivityId then
      local graphId = record:GetIntValue("graphId")
      cfg = TaskInterface.GetLevelActiveGraphCfg(graphId)
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
def.static("number", "=>", "table").IsOwnLevelActiveGraphCfgByOpenId = function(openId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_LEVEL_ACTIVE_GRAPH_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local curOpenId = record:GetIntValue("openId")
    if openId == curOpenId then
      local graphId = record:GetIntValue("graphId")
      cfg = TaskInterface.GetLevelActiveGraphCfg(graphId)
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
def.static("number", "=>", "table").GetTaskShareCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_SHARE_CFG, id)
  if record == nil then
    warn("!!!!!!!! GetTaskShareCfg is nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.describe = record:GetStringValue("describe")
  cfg.shareType = record:GetIntValue("shareType")
  cfg.picURL = record:GetStringValue("picURL")
  return cfg
end
def.static("number", "=>", "table").GetTaskConSharePengYouQuan = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_CON_SHARE_PENG_YOU_QUAN, id)
  if record == nil then
    warn("!!!!!!!! GetTaskConSharePengYouQuan is nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.contype = record:GetIntValue("contype")
  cfg.needShareCount = record:GetIntValue("needShareCount")
  cfg.shareId = record:GetIntValue("shareId")
  return cfg
end
def.static("number", "=>", "table").GetTaskOperGotoPosition = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKOPERGOTOPOSITION_CFG, id)
  if record == nil then
    warn("!!!!!!!! GetTaskOperGotoPosition is nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.operType = record:GetIntValue("operType")
  cfg.teamType = record:GetIntValue("teamType")
  cfg.mapID = record:GetIntValue("mapID")
  cfg.positionX = record:GetIntValue("positionX")
  cfg.positionY = record:GetIntValue("positionY")
  return cfg
end
def.static("number", "number", "=>", "number").FindTaskVoiceID = function(voiceID, npcID)
  local voiceMumCfg = TaskInterface.GetTaskVoiceMumCfg(voiceID)
  if voiceMumCfg ~= nil then
    local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
    local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    for k, v in pairs(voiceMumCfg.voicechildIds) do
      while true do
        local VoiceChildCfg = TaskInterface.GetTaskVoiceChildCfg(v)
        if VoiceChildCfg.gender ~= GenderEnum.ALL and heroProp.gender ~= VoiceChildCfg.gender then
          break
        end
        if VoiceChildCfg.occupation ~= OccupationEnum.ALL and heroProp.occupation ~= VoiceChildCfg.occupation then
          break
        end
        return VoiceChildCfg.voiceCfgId
      end
    end
  end
  return 0
end
def.static("number", "=>", "string").GetTaskTypeStr = function(taskType)
  if taskType == TaskConsts.TASK_TYPE_MAIN then
    return textRes.Task[41]
  elseif taskType == TaskConsts.TASK_TYPE_BRANCH then
    return textRes.Task[42]
  elseif taskType == TaskConsts.TASK_TYPE_INSTANCE then
    return textRes.Task[43]
  elseif taskType == TaskConsts.TASK_TYPE_DAILY then
    return textRes.Task[44]
  elseif taskType == TaskConsts.TASK_TYPE_NORMAL then
    return textRes.Task[45]
  elseif taskType == TaskConsts.TASK_TYPE_ACTIVITY then
    return textRes.Task[46]
  elseif taskType == TaskConsts.TASK_TYPE_TRIAL then
    return textRes.Task[47]
  elseif taskType == TaskConsts.TASK_TYPE_MASTER then
    return textRes.Task[48]
  elseif taskType == TaskConsts.TASK_TYPE_MENPAITIAOZHAN then
    return textRes.Task[49]
  elseif taskType == TaskConsts.TASK_TYPE_ZHIYIN then
    return ""
  elseif taskType == TaskConsts.TASK_TYPE_FESTIVAL then
    return textRes.Task[231]
  elseif taskType == TaskConsts.TASK_TYPE_NULL then
    return ""
  elseif taskType == TaskConsts.TASK_TYPE_FEISHENG then
    return ""
  elseif taskType == TaskConsts.TASK_TYPE_SURPRISE then
    return textRes.Task[232]
  end
  return textRes.Task[305]
end
def.static("number", "string", "=>", "string").WarpTaskTypeStr = function(taskType, taskName)
  if taskType == TaskConsts.TASK_TYPE_MAIN then
    return string.format(textRes.Task[181], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_BRANCH then
    return string.format(textRes.Task[182], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_INSTANCE then
    return string.format(textRes.Task[183], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_DAILY then
    return string.format(textRes.Task[184], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_NORMAL then
    return string.format(textRes.Task[185], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_ACTIVITY then
    return string.format(textRes.Task[186], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_TRIAL then
    return string.format(textRes.Task[187], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_MASTER then
    return string.format(textRes.Task[188], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_MENPAITIAOZHAN then
    return string.format(textRes.Task[189], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_ZHIYIN then
    return taskName
  elseif taskType == TaskConsts.TASK_TYPE_FESTIVAL then
    return string.format(textRes.Task[230], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_NULL then
    return taskName
  elseif taskType == TaskConsts.TASK_TYPE_FEISHENG then
    return taskName
  elseif taskType == TaskConsts.TASK_TYPE_SURPRISE then
    return string.format(textRes.Task[310], taskName)
  end
  return string.format(textRes.Task[305] .. "%s", taskName)
end
def.static("number", "string", "=>", "string").WarpTaskTypeStrForTaskTrace = function(taskType, taskName)
  if taskType == TaskConsts.TASK_TYPE_MAIN then
    return string.format(textRes.Task[221], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_BRANCH then
    return string.format(textRes.Task[222], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_INSTANCE then
    return string.format(textRes.Task[223], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_DAILY then
    return string.format(textRes.Task[224], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_NORMAL then
    return string.format(textRes.Task[225], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_ACTIVITY then
    return string.format(textRes.Task[226], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_TRIAL then
    return string.format(textRes.Task[227], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_MASTER then
    return string.format(textRes.Task[228], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_MENPAITIAOZHAN then
    return string.format(textRes.Task[229], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_ZHIYIN then
    return taskName
  elseif taskType == TaskConsts.TASK_TYPE_FESTIVAL then
    return string.format(textRes.Task[230], taskName)
  elseif taskType == TaskConsts.TASK_TYPE_NULL then
    return taskName
  elseif taskType == TaskConsts.TASK_TYPE_FEISHENG then
    return taskName
  elseif taskType == TaskConsts.TASK_TYPE_SURPRISE then
    return string.format(textRes.Task[310], taskName)
  end
  return string.format(textRes.Task[305] .. "%s", taskName)
end
def.static("number", "number", "=>", "boolean").GetTaskEffectCfg = function(graphID, taskID)
  local key = "key_" .. graphID .. taskID
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_EFFECT_CFG, key)
  if record == nil then
    return false
  end
  return true
end
def.static("number", "=>", "table").GetGuideTaskCfg = function(taskID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GUIDE_TASK_CFG, taskID)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.taskId = record:GetIntValue("taskId")
  cfg.NPCID = record:GetIntValue("NPC_ID")
  cfg.graphIDs = {}
  cfg.graphIDSet = {}
  local rec2 = record:GetStructValue("childGraphListStruct")
  local count = rec2:GetVectorSize("childGraphList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("childGraphList", i - 1)
    local graphID = rec3:GetIntValue("graphID")
    table.insert(cfg.graphIDs, graphID)
    cfg.graphIDSet[graphID] = graphID
  end
  return cfg
end
def.static("number", "=>", "table").GetBountyTaskCfg = function(taskId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BOUNTY_TASK_CFG, taskId)
  if record == nil then
    warn("------GetBountyTaskCfg is nil:", taskId)
    return nil
  end
  local cfg = {}
  cfg.taskId = record:GetIntValue("taskId")
  cfg.rank = record:GetIntValue("rank")
  cfg.tipStr = record:GetStringValue("tipStr")
  return cfg
end
def.method().Init = function(self)
  self._taskCfgs = {}
  self._GraphCfgs = {}
  self:Reset()
end
def.method().Reset = function(self)
  self._taskInfo = {}
  self._taskRing = {}
  self._taskRequirements = {}
  self._taskPetRequirements = {}
  self._taskLegendTime = {}
  self._taskItems = nil
  self._taskPathFindTaskID = 0
  self._taskPathFindGraphID = 0
  self._taskFindPathRequirementID = 0
  self._taskFindPathNeedCount = 0
  self._playingOpera = ""
  self._taskLightRoundGraphIDs = {}
  self._taskLightRoundEffectIds = {}
  self._resetTask = {}
  self._accpetTaskInfo = nil
  self._timeLimitGraph = {}
  self._allBanGraphIds = {}
end
def.method("=>", "table").GetAllTasks = function(self)
  local rets = {}
  for taskId, graphIdValue in pairs(self._taskInfo) do
    local taskCfg = TaskInterface.GetTaskCfg(taskId)
    for graphId, info in pairs(graphIdValue) do
      if info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH then
        local graphCfg = TaskInterface.GetTaskGraphCfg(graphId)
        local dispName = taskCfg.taskName
        local ringNum = self:GetTaskRing(graphId)
        if ringNum >= 0 then
          dispName = dispName .. " (" .. tostring(ringNum + 1) .. "/" .. tostring(graphCfg.ringCount) .. ")"
        end
        local ret = {}
        ret.taskID = taskId
        ret.graphId = graphId
        ret.dispName = dispName
        ret.taskType = graphCfg.taskType
        table.insert(rets, ret)
      end
    end
  end
  return rets
end
def.method("number", "=>", "table").GetTasksByType = function(self, taskType)
  local rets = {}
  local alltasks = self:GetAllTasks()
  for i, task in ipairs(alltasks) do
    if task.taskType == taskType then
      table.insert(rets, task)
    end
  end
  return rets
end
def.method("=>", "table").GetMainTask = function(self)
  return self:GetTasksByType(TaskConsts.TASK_TYPE_MAIN)[1]
end
def.method("=>", "table").GetTaskInfos = function(self)
  return self._taskInfo
end
def.method("number", "number", "=>", "table").GetTaskInfo = function(self, taskId, graphId)
  local graphInfo = self._taskInfo[taskId]
  if graphInfo == nil then
    return nil
  end
  return graphInfo[graphId]
end
def.method("number", "number", "number", "table").SetTaskInfo = function(self, taskId, graphId, state, conDatas)
  local kTaskIdInfo = self._taskInfo[taskId]
  if kTaskIdInfo == nil then
    kTaskIdInfo = {}
    table.insert(self._taskInfo, taskId, kTaskIdInfo)
  end
  local kInfo = kTaskIdInfo[graphId]
  if kInfo == nil then
    kInfo = {}
    table.insert(kTaskIdInfo, graphId, kInfo)
  end
  kInfo.taskId = taskId
  kInfo.graphId = graphId
  if kInfo.state ~= TaskConsts.TASK_STATE_ALREADY_ACCEPT and state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or kInfo.state ~= TaskConsts.TASK_STATE_FINISH and state == TaskConsts.TASK_STATE_FINISH then
    kInfo.time = os.time()
  else
    kInfo.time = kInfo.time or 0
  end
  kInfo.state = state
  kInfo.conDatas = conDatas
  self:setTimeLimitGraphTask(graphId, taskId, conDatas)
end
def.method("number", "number", "table").SetTaskConditionData = function(self, taskId, graphId, conData)
  local kTaskIdInfo = self._taskInfo[taskId]
  if kTaskIdInfo == nil then
    kTaskIdInfo = {}
    table.insert(self._taskInfo, taskId, kTaskIdInfo)
  end
  local kInfo = kTaskIdInfo[graphId]
  if kInfo == nil then
    kInfo = {}
    kInfo.taskId = taskId
    kInfo.graphId = graphId
    kInfo.state = -1
    table.insert(kTaskIdInfo, graphId, kInfo)
  end
  if kInfo.conDatas ~= nil then
    local found = false
    for i, v in pairs(kInfo.conDatas) do
      if v.conId == conData.conId then
        if v.param == conData.param and v.subParam == conData.subParam then
          return
        end
        v.param = conData.param
        v.subParam = conData.subParam
        found = true
        break
      end
    end
    if found == false then
      table.insert(kInfo.conDatas, conData)
    end
  else
    kInfo.conDatas = {}
    table.insert(kInfo.conDatas, conData)
  end
  kInfo.time = os.time()
end
def.method("number", "number", "table").SetTaskUnConditionData = function(self, taskId, graphId, unConDataIDs)
  local kTaskIdInfo = self._taskInfo[taskId]
  if kTaskIdInfo == nil then
    kTaskIdInfo = {}
    table.insert(self._taskInfo, taskId, kTaskIdInfo)
  end
  local kInfo = kTaskIdInfo[graphId]
  if kInfo == nil then
    kInfo = {}
    kInfo.taskId = taskId
    kInfo.graphId = graphId
    kInfo.time = 0
    kInfo.state = -1
    table.insert(kTaskIdInfo, graphId, kInfo)
  end
  kInfo.unConDataIDs = unConDataIDs
end
def.method("number", "number").RemoveTaskInfo = function(self, taskId, graphId)
  if self._resetTask[graphId] then
    self._resetTask[graphId] = nil
  end
  if self._taskLightRoundEffectIds and self._taskLightRoundEffectIds[graphId] then
    self._taskLightRoundEffectIds[graphId] = nil
  end
  if self._timeLimitGraph and self._timeLimitGraph[graphId] then
    self._timeLimitGraph[graphId] = nil
  end
  if taskId == self._curTaskId then
    self._curTaskId = 0
  end
  local graphIdValue = self._taskInfo[taskId]
  if graphIdValue == nil then
    return
  end
  graphIdValue[graphId] = nil
  local empty = true
  for graphId, info in pairs(graphIdValue) do
    empty = false
    break
  end
  if empty == true then
    self._taskInfo[taskId] = nil
  end
end
def.method("number", "number", "=>", "number").GetTaskState = function(self, taskId, graphId)
  local graphInfo = self._taskInfo[taskId]
  if graphInfo == nil then
    return -1
  end
  local kInfo = graphInfo[graphId]
  if kInfo == nil then
    return -1
  end
  return kInfo.state
end
def.method("number", "number", "number").SetTaskState = function(self, taskId, graphId, state)
  if self._taskInfo[taskId] == nil then
    self._taskInfo[taskId] = {}
  end
  local kInfo = self._taskInfo[taskId][graphId]
  if kInfo == nil then
    kInfo = {}
    self._taskInfo[taskId][graphId] = kInfo
    kInfo.taskId = taskId
    kInfo.graphId = graphId
  end
  if kInfo.state ~= TaskConsts.TASK_STATE_ALREADY_ACCEPT and state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or kInfo.state ~= TaskConsts.TASK_STATE_FINISH and state == TaskConsts.TASK_STATE_FINISH then
    kInfo.time = os.time()
  else
    kInfo.time = kInfo.time or 0
  end
  kInfo.state = state
end
def.method("table").SetTaskRingMap = function(self, taskRings)
  self._taskRing = taskRings or {}
end
def.method("number", "number").SetTaskRing = function(self, graphID, TaskRing)
  self._taskRing = self._taskRing or {}
  self._taskRing[graphID] = TaskRing
end
def.method("number", "=>", "number").GetTaskRing = function(self, graphID)
  self._taskRing = self._taskRing or {}
  local ret = self._taskRing[graphID]
  if ret == nil then
    ret = -1
  end
  return ret
end
def.method("number", "number").SetTaskPathFindParam = function(self, taskID, graphID)
  self._taskPathFindTaskID = taskID
  self._taskPathFindGraphID = graphID
end
def.method("=>", "number", "number").GetTaskPathFindParam = function(self, taskID, graphID)
  return self._taskPathFindTaskID, self._taskPathFindGraphID
end
def.method("number", "number", "number", "number")._addTaskRequirements = function(self, taskId, graphId, requirementID, needCount)
  local graphIdRequiremnt = self._taskRequirements[taskId]
  if graphIdRequiremnt == nil then
    self._taskRequirements[taskId] = {}
    graphIdRequiremnt = self._taskRequirements[taskId]
  end
  local requiremnt = graphIdRequiremnt[graphId]
  if requiremnt == nil then
    graphIdRequiremnt[graphId] = {}
    requiremnt = graphIdRequiremnt[graphId]
    requiremnt.graphId = graphId
    requiremnt.requirementID = requirementID
    requiremnt.needCount = 0
  end
  requiremnt.needCount = requiremnt.needCount + needCount
end
def.method()._RefeshTaskRequirements = function(self)
  self._taskRequirements = {}
  self._taskPetRequirements = {}
  for taskId, graphIdValue in pairs(self._taskInfo) do
    local taskCfg = TaskInterface.GetTaskCfg(taskId)
    for graphId, info in pairs(graphIdValue) do
      local graphCfg = TaskInterface.GetTaskGraphCfg(graphId)
      if info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
        local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_BAG)
        if conditionID > 0 then
          local condCfg = TaskInterface.GetTaskConditionBag(conditionID)
          local currCount = condCfg.takeCfgCount
          if info.conDatas ~= nil then
            for i, v in pairs(info.conDatas) do
              if v.conId == conditionID then
                currCount = currCount - v.param:ToNumber()
                break
              end
            end
          end
          self:_addTaskRequirements(taskId, graphId, condCfg.takeCfgId, currCount)
        end
        local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_PET)
        if conditionID > 0 then
          local condCfg = TaskInterface.GetTaskConditionPet(conditionID)
          local graphIdRequiremnt = self._taskPetRequirements[taskId]
          if graphIdRequiremnt == nil then
            self._taskPetRequirements[taskId] = {}
            graphIdRequiremnt = self._taskPetRequirements[taskId]
          end
          local requiremnt = graphIdRequiremnt[graphId]
          if requiremnt == nil then
            graphIdRequiremnt[graphId] = {}
            requiremnt = graphIdRequiremnt[graphId]
            requiremnt.graphId = graphId
            requiremnt.requirementID = condCfg.petId
            requiremnt.needCount = 0
          end
          requiremnt.needCount = requiremnt.needCount + condCfg.petCount
        end
      end
    end
  end
end
def.method("=>", "table").GetTaskRequirements = function(self)
  return self._taskRequirements
end
def.method("number", "number")._SetCurrTaskFindPathRequirement = function(self, taskID, graphID)
  local graphIdRequiremnt = self._taskRequirements[taskID]
  if graphIdRequiremnt ~= nil then
    local requiremnt = graphIdRequiremnt[graphID]
    if requiremnt ~= nil then
      self._taskFindPathRequirementID = requiremnt.requirementID
      self._taskFindPathNeedCount = requiremnt.needCount
    end
  end
end
def.method("=>", "number", "number").GetCurrTaskFindPathRequirement = function(self)
  return self._taskFindPathRequirementID, self._taskFindPathNeedCount
end
def.method("=>", "table").GetTaskPetRequirements = function(self)
  return self._taskPetRequirements
end
def.method("number", "number")._SetCurrTaskFindPathPetRequirement = function(self, taskID, graphID)
  local graphIdRequiremnt = self._taskPetRequirements[taskID]
  if graphIdRequiremnt ~= nil then
    local requiremnt = graphIdRequiremnt[graphID]
    if requiremnt ~= nil then
      self._taskFindPathRequirementID = requiremnt.requirementID
      self._taskFindPathNeedCount = requiremnt.needCount
    end
  end
end
def.method("number", "number", "userdata")._SetLegendTime = function(self, taskId, graphId, endTime)
  local graphIdTime = self._taskLegendTime[taskId]
  if graphIdTime == nil and endTime ~= nil then
    graphIdTime = {}
    self._taskLegendTime[taskId] = graphIdTime
  end
  if graphIdTime ~= nil then
    if endTime ~= nil then
      local endTimeInfo = {}
      endTimeInfo.graphId = graphId
      endTimeInfo.endTime = endTime
      graphIdTime[graphId] = endTimeInfo
    else
      graphIdTime[graphId] = nil
    end
  end
end
def.method("number", "number", "=>", "userdata").GetLegendTime = function(self, taskId, graphId)
  local graphIdTime = self._taskLegendTime[taskId]
  if graphIdTime == nil then
    return nil
  end
  local endTimeInfo = graphIdTime[graphId]
  if endTimeInfo == nil then
    return nil
  end
  return endTimeInfo.endTime
end
def.method("number", "boolean", "boolean", "boolean", "=>", "boolean").HasTaskByGraphID = function(self, graphID, aceptable, acepted, finished)
  for taskId, graphIdValue in pairs(self._taskInfo) do
    for graphId, info in pairs(graphIdValue) do
      if graphId == graphID and (aceptable == true and info.state == TaskConsts.TASK_STATE_CAN_ACCEPT or aceptable == true and info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or aceptable == true and info.state == TaskConsts.TASK_STATE_FINISH) then
        return true
      end
    end
  end
  return false
end
def.method("number", "number").SetQingyunHistoryInfo = function(self, chapter, node)
  self._currQingyunHistoryChapter = chapter
  self._currQingyunHistoryNode = node
end
def.method("=>", "number", "number").GetQingyunHistoryInfo = function(self)
  local currChapterNum = self._currQingyunHistoryChapter
  local currNodeNum = self._currQingyunHistoryNode
  if currChapterNum == 0 or currChapterNum == nil then
    currChapterNum = 1
    currNodeNum = 1
  end
  return currChapterNum, currNodeNum
end
def.method().RefreshTaskItemBag = function(self)
  local oldIsNil = self._taskItems == nil
  local oldTaskItems = {}
  if self._taskItems ~= nil then
    for k, v in pairs(self._taskItems) do
      if v.showTip == true then
        local count = oldTaskItems[v.itemID] or 0
        count = count + v.count
        oldTaskItems[v.itemID] = count
      end
    end
  end
  self._taskItems = {}
  for taskId, graphIdValue in pairs(self._taskInfo) do
    local taskCfg = TaskInterface.GetTaskCfg(taskId)
    for graphId, info in pairs(graphIdValue) do
      if info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH then
        local graphCfg = TaskInterface.GetTaskGraphCfg(graphId)
        if 0 < taskCfg.giveTaskGoods then
          local canuse = true
          local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_TASKOPERATEPLAYOPERA_CFG, operateID)
          if record ~= nil then
            canuse = record:GetCharValue("canuse") ~= 0
          end
          local showTip = true
          local record2 = DynamicData.GetRecord(CFG_PATH.DATA_TASK_GOODS_CFG, taskCfg.giveTaskGoods)
          if record2 ~= nil then
            showTip = record2:GetCharValue("istip") ~= 0
          end
          local t = {}
          t.itemID = taskCfg.giveTaskGoods
          t.count = 1
          t.canBeUsed = canuse
          t.showTip = showTip
          t.param = {}
          t.param.taskId = taskId
          t.param.graphId = graphId
          table.insert(self._taskItems, t)
        end
        local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_GATHER_ITEM)
        if conditionID > 0 then
          local condition = TaskInterface.GetTaskConditionGatherItem(conditionID)
          if 0 < condition.taskBagItemId then
            if info.conDatas ~= nil and info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
              for i, v in pairs(info.conDatas) do
                if v.conId == conditionID then
                  local t = {}
                  t.itemID = condition.taskBagItemId
                  t.count = tonumber(tostring(v.param))
                  t.canBeUsed = false
                  t.showTip = true
                  t.param = {}
                  t.param.taskId = taskId
                  t.param.graphId = graphId
                  table.insert(self._taskItems, t)
                  break
                end
              end
            elseif info.state == TaskConsts.TASK_STATE_FINISH then
              local t = {}
              t.itemID = condition.taskBagItemId
              t.count = condition.gatherCount
              t.canBeUsed = false
              t.showTip = true
              t.param = {}
              t.param.taskId = taskId
              t.param.graphId = graphId
              table.insert(self._taskItems, t)
            end
          end
        end
      end
    end
  end
  local itemModule = gmodule.moduleMgr:GetModule(ModuleId.ITEM)
  local newTaskItems = {}
  for k, v in pairs(self._taskItems) do
    if v.showTip == true then
      local count = newTaskItems[v.itemID] or 0
      count = count + v.count
      newTaskItems[v.itemID] = count
    end
  end
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  if oldIsNil == false then
    for itemID, newCount in pairs(newTaskItems) do
      local oldCount = oldTaskItems[itemID] or 0
      if newCount > oldCount then
        local itemMap = {}
        itemMap[itemID] = newCount - oldCount
        PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Common[150], PersonalHelper.Type.ItemMap, itemMap)
        itemModule._getNewItem:GetItem(itemID)
      end
    end
  end
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_Item_Changed, nil)
end
def.method("=>", "table").GetTaskItemBag = function(self)
  return self._taskItems or {}
end
def.method("number", "=>", "boolean").isOwnTaskByGraphId = function(self, graphId)
  for taskId, graphInfo in pairs(self._taskInfo) do
    for i, v in pairs(graphInfo) do
      if i == graphId then
        return true
      end
    end
  end
  return false
end
def.method("number", "=>", "number").GetTaskIdByGraphId = function(self, graphId)
  for taskId, graphInfo in pairs(self._taskInfo) do
    for i, v in pairs(graphInfo) do
      if i == graphId then
        return taskId
      end
    end
  end
  return 0
end
def.method("number", "number", "table").setTimeLimitGraphTask = function(self, graphId, taskId, conDatas)
  local condtype = TaskConClassType.CON_TIME_LIMIT
  local taskCfg = TaskInterface.GetTaskCfg(taskId)
  local condID = taskCfg.FindFinishConditionID(condtype)
  if conDatas then
    for k, v in pairs(conDatas) do
      if v.conId == condID then
        self._timeLimitGraph[graphId] = taskId
        break
      end
    end
  end
end
def.method().resetShimenTask = function(self)
  local heroProp = _G.GetHeroProp()
  if heroProp == nil then
    return
  end
  local curOccupation = heroProp.occupation
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local menpaiData = ActivityInterface.Instance():GetMenpaiNPCData(curOccupation)
  if menpaiData then
    self:resetTaskCondition(menpaiData.graphID, 0)
  end
end
def.method("number", "number").resetTaskCondition = function(self, graphId, param)
  local ringNum = self:GetTaskRing(graphId)
  if ringNum > -1 then
    self:SetTaskRing(graphId, param)
  end
  for taskId, graphInfo in pairs(self._taskInfo) do
    for i, v in pairs(graphInfo) do
      warn("----------resetTaskCondition:", i, graphId)
      if i == graphId then
        self._resetTask[graphId] = taskId
        Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, nil)
        return
      end
    end
  end
end
def.method("=>", "boolean").isOwnTimeLimitGraph = function(self)
  if self._timeLimitGraph then
    for i, v in pairs(self._timeLimitGraph) do
      if v and v > 0 then
        return true
      end
    end
  end
  return false
end
def.method("number", "=>", "boolean").isTimeLimitGraphId = function(self, graphId)
  if self._timeLimitGraph and self._timeLimitGraph[graphId] then
    return true
  end
  return false
end
def.method("number", "=>", "boolean").isOpenTaskGraph = function(self, graphId)
  local levelActiveGraphCfg = TaskInterface.GetLevelActiveGraphCfg(graphId)
  if levelActiveGraphCfg then
    local openId = levelActiveGraphCfg.openId
    if openId ~= 0 and not IsFeatureOpen(openId) then
      return false
    end
  end
  return true
end
def.method("number", "=>", "boolean").isBanTaskGraphId = function(self, graphId)
  if self._allBanGraphIds then
    local banGoOnGraphIds = self._allBanGraphIds[TaskConsts.BAN_TYPE__GO_ON]
    if banGoOnGraphIds and banGoOnGraphIds.graphIds and banGoOnGraphIds.graphIds[graphId] then
      return true
    end
  end
  return false
end
def.method("number", "function").registerCustomTaskNpcIdFn = function(self, clsId, fn)
  self._taskCustomNpcIdFn = self._taskCustomNpcIdFn or {}
  self._taskCustomNpcIdFn[clsId] = fn
end
def.method("number", "=>", "number").getCustomTaskNpcId = function(self, clsId)
  if self._taskCustomNpcIdFn then
    local fn = self._taskCustomNpcIdFn[clsId]
    if fn then
      return fn(clsId)
    end
  end
  return 0
end
def.method("number", "number").addTaskLightRoundGraphId = function(self, graphId, effectId)
  self._taskLightRoundGraphIDs = self._taskLightRoundGraphIDs or {}
  self._taskLightRoundGraphIDs[graphId] = graphId
  if effectId ~= 0 then
    self._taskLightRoundEffectIds = self._taskLightRoundEffectIds or {}
    self._taskLightRoundEffectIds[graphId] = effectId
  end
  Event.DispatchEvent(ModuleId.GUIDE, gmodule.notifyId.Guide.Apply_TaskTrace_Light, {graphId})
end
def.method("number", "=>", "number").getTaskLightRoundEffectId = function(self, graphId)
  if self._taskLightRoundEffectIds then
    return self._taskLightRoundEffectIds[graphId] or 0
  end
  return 0
end
TaskInterface.Commit()
return TaskInterface
