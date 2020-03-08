local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local MemoryGameMgr = Lplus.Class(CUR_CLASS_NAME)
local MemoryGameDataMgr = require("Main.MiniGame.MemoryGame.MemoryGameDataMgr")
local def = MemoryGameMgr.define
local instance
def.static("=>", MemoryGameMgr).Instance = function()
  if instance == nil then
    instance = MemoryGameMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SMemoryCompetitionStart", MemoryGameMgr.OnSMemoryCompetitionStart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SMemoryCompetitionQuestionStart", MemoryGameMgr.OnSMemoryCompetitionQuestionStart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SMemoryCompetitionAnswerNotify", MemoryGameMgr.OnSMemoryCompetitionAnswerNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SMemoryCompetitionRoundCal", MemoryGameMgr.OnSMemoryCompetitionRoundCal)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SMemoryCompetitionEndNotify", MemoryGameMgr.OnSMemoryCompetitionEndNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SMemoryCompetitionSeekHelpSuccess", MemoryGameMgr.OnSMemoryCompetitionSeekHelpSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SMemoryCompetitionSeekHelpNotify", MemoryGameMgr.OnSMemoryCompetitionSeekHelpNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SMemoryCompetitionHelpAnswerNotfiy", MemoryGameMgr.OnSMemoryCompetitionHelpAnswerNotfiy)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SMemoryCompetitionNormalFail", MemoryGameMgr.OnSMemoryCompetitionNormalFail)
end
def.method().OnReset = function(self)
  MemoryGameDataMgr.Instance():Reset()
end
def.static("table").OnSMemoryCompetitionStart = function(p)
  MemoryGameDataMgr.Instance():SetMemoryStartData(p)
  Event.DispatchEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_START, {
    activityId = p.activity_cfg_id,
    remainTime = p.left_seconds
  })
end
def.static("table").OnSMemoryCompetitionQuestionStart = function(p)
  MemoryGameDataMgr.Instance():SetMemoryGameStatus(p)
  Event.DispatchEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_QUESTION_START, {
    p.activity_cfg_id
  })
end
def.static("table").OnSMemoryCompetitionAnswerNotify = function(p)
  Event.DispatchEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_QUESTION_ANSWER, {
    activityId = p.activity_cfg_id,
    roleId = p.team_member_role_id,
    answer = p.answer_id
  })
end
def.static("table").OnSMemoryCompetitionRoundCal = function(p)
  local gameStatus = MemoryGameDataMgr.Instance():GetCurGameStatus()
  if gameStatus then
    gameStatus:SetPlayerRoundResult(p.answer_result_map)
  end
  MemoryGameDataMgr.Instance():ClearRoundData()
  Event.DispatchEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_ROUND_CAL, {
    activityId = p.activity_cfg_id,
    result = p.answer_result_map,
    score = p.score
  })
end
def.static("table").OnSMemoryCompetitionEndNotify = function(p)
  Event.DispatchEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_END, {
    activityId = p.activity_cfg_id,
    roleAnswerMap = p.roles_answer_map
  })
end
def.static("table").OnSMemoryCompetitionSeekHelpSuccess = function(p)
  local gameStatus = MemoryGameDataMgr.Instance():GetCurGameStatus()
  if gameStatus then
    gameStatus:SetLeftSeekHelpTimes(p.left_seek_help_times)
  end
  Event.DispatchEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_SEEK_HELP, {
    p.activity_cfg_id
  })
end
def.static("table").OnSMemoryCompetitionSeekHelpNotify = function(p)
  MemoryGameDataMgr.Instance():AddSeekingHelpRoleId(p.seek_help_role_id)
  Event.DispatchEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_SEEK_HELP_NOTIFY, {
    activityId = p.activity_cfg_id,
    roleId = p.seek_help_role_id
  })
end
def.static("table").OnSMemoryCompetitionHelpAnswerNotfiy = function(p)
  Event.DispatchEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_HELP_NOTIFY, {
    activityId = p.activity_cfg_id,
    roleId = p.active_help_role_id,
    answer = p.answer_id
  })
end
def.static("table").OnSMemoryCompetitionNormalFail = function(p)
  if textRes.MemoryCompetition.SMemoryCompetitionNormalFail[p.result] then
    Toast(textRes.MemoryCompetition.SMemoryCompetitionNormalFail[p.result])
  end
end
def.method("number").MemoryCompetitionAnswer = function(self, answer)
  local req = require("netio.protocol.mzm.gsp.memorycompetition.CMemoryCompetitionAnswer").new(answer)
  gmodule.network.sendProtocol(req)
end
def.method().MemoryCompetitionSeekHelp = function(self)
  local req = require("netio.protocol.mzm.gsp.memorycompetition.CMemoryCompetitionSeekHelp").new()
  gmodule.network.sendProtocol(req)
end
def.method("userdata", "number").MemoryCompetitionHelpAnswer = function(self, roleId, answer)
  local req = require("netio.protocol.mzm.gsp.memorycompetition.CMemoryCompetitionHelpAnswer").new(roleId, answer)
  gmodule.network.sendProtocol(req)
end
def.method("number", "=>", "table").GetMemoryGameCfgById = function(self, cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MEMORY_COMPETITION_CFG, cfgId)
  if nil == record then
    warn("no memorycompetition:", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.mappingType = record:GetIntValue("mapping_type_id")
  cfg.mappingNum = record:GetIntValue("mapping_num")
  cfg.questionNum = record:GetIntValue("question_num")
  cfg.mappingShowSeconds = record:GetIntValue("mapping_answer_show_seconds")
  cfg.questionShowSeconds = record:GetIntValue("question_answer_seconds")
  cfg.seekHelpTimes = record:GetIntValue("seek_help_times")
  cfg.questionOptionNum = record:GetIntValue("question_option_num")
  return cfg
end
return MemoryGameMgr.Commit()
