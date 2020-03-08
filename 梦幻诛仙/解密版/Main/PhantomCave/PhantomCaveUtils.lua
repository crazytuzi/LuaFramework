local Lplus = require("Lplus")
local PhantomCaveUtils = Lplus.Class("PhantomCaveUtils")
local def = PhantomCaveUtils.define
local QuestionType = require("consts.mzm.gsp.question.confbean.PictureQuestionType")
def.static("number", "=>", "table").GetPQLevelCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PQ_LEVEL, cfgId)
  if record == nil then
    warn("Get Picture Question Level Cfg Fail", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = cfgId
  cfg.helpNum = record:GetIntValue("helpNum")
  cfg.questionTime = record:GetIntValue("questionTime")
  cfg.moveInterval = record:GetIntValue("moveInterval")
  cfg.passScore = record:GetIntValue("passScore")
  cfg.rightScore = record:GetIntValue("rightScore")
  cfg.wrongScore = record:GetIntValue("wrongScore")
  return cfg
end
def.static("number", "=>", "table").GetPQModelCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PQ_MODEL, cfgId)
  if record == nil then
    warn("Get Picture Question Model Cfg Fail", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = cfgId
  cfg.species = record:GetIntValue("species")
  cfg.modelId = record:GetIntValue("modelId")
  cfg.colorId = record:GetIntValue("colorId")
  cfg.isEquipDecorate = record:GetCharValue("isEquipDecorate") ~= 0
  cfg.isBianyi = record:GetCharValue("isBianyi") ~= 0
  local name = PhantomCaveUtils.GetSpeciesName(cfg.species)
  if name then
    if cfg.isBianyi then
      cfg.name = textRes.Question[35] .. name
    else
      cfg.name = name
    end
  else
    cfg.name = ""
  end
  return cfg
end
def.static("number", "=>", "table").GetPQQuestionCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PQ_QUESTION, cfgId)
  if record == nil then
    warn("Get Picture Question question Cfg Fail", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = cfgId
  cfg.desc = record:GetStringValue("desc")
  cfg.type = record:GetIntValue("type")
  return cfg
end
def.static("number", "=>", "table").GetWQLevelCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WQ_LEVEL, cfgId)
  if record == nil then
    warn("Get Word Question Level Cfg Fail", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = cfgId
  cfg.allRight = record:GetIntValue("allRight")
  cfg.oneRight = record:GetIntValue("oneRight")
  cfg.answerInterval = record:GetIntValue("answerInterval")
  cfg.questionNum = record:GetIntValue("questionNum")
  cfg.questionType = record:GetIntValue("questionType")
  return cfg
end
def.static("number", "=>", "string").GetSpeciesName = function(type)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WQ_Species, type)
  if record == nil then
    warn("Get Species Cfg Fail", type)
    return ""
  end
  local speciesName = record:GetStringValue("name")
  if speciesName then
    return speciesName
  else
    return nil
  end
end
def.static("number", "=>", "table").GetPhantomCaveCfg = function(npcService)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACTIVITY_PHANTOMCAVE_CFG, npcService)
  if record == nil then
    print("Get Phantom Cave Cfg Fail", npcService)
    return nil
  end
  local cfg = {}
  cfg.npcService = npcService
  cfg.id = record:GetIntValue("id")
  cfg.mapId = record:GetIntValue("mapid")
  cfg.layer = record:GetIntValue("layer")
  cfg.npcId = record:GetIntValue("npcid")
  cfg.controllerId = record:GetIntValue("controllerid")
  return cfg
end
def.static("number", "=>", "boolean").IsPhantomCaveMap = function(curMapId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_ACTIVITY_PHANTOMCAVE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local mapId = record:GetIntValue("mapid")
    if mapId == curMapId then
      return true
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return false
end
def.static("number", "=>", "string").QuestionTypeToMeasure = function(type)
  if type == QuestionType.NUMBER then
    return textRes.Question.Measure[1]
  elseif type == QuestionType.SPECIAL_BIANYI_NUMBER then
    return textRes.Question.Measure[1]
  elseif type == QuestionType.MOVE_STEPS then
    return textRes.Question.Measure[2]
  elseif type == QuestionType.BIANYI_MOVE_STEPS then
    return textRes.Question.Measure[2]
  elseif type == QuestionType.BIANYI_NUMBER then
    return textRes.Question.Measure[1]
  elseif type == QuestionType.NOT_BIANYI_NUMBER then
    return textRes.Question.Measure[1]
  elseif type == QuestionType.DECORATE_NUMBER then
    return textRes.Question.Measure[1]
  elseif type == QuestionType.NOT_DECORATE_NUMBER then
    return textRes.Question.Measure[1]
  end
  return ""
end
def.static("=>", "number").GetPhantomCaveActivityID = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACTIVITY_PHANTOMCAVE_CONST, "ActivityId")
  if record == nil then
    return 0
  end
  local id = record:GetIntValue("value")
  return id
end
def.static("=>", "number", "number").GetPhantomCaveOpenLevel = function()
  local activityID = PhantomCaveUtils.GetPhantomCaveActivityID()
  if 0 == activityID or nil == activityID then
    return 0, 0
  end
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local cfg = ActivityInterface.GetActivityCfgById(activityID)
  if cfg == nil then
    return 0, 0
  end
  return cfg.levelMin, cfg.levelMax
end
PhantomCaveUtils.Commit()
return PhantomCaveUtils
