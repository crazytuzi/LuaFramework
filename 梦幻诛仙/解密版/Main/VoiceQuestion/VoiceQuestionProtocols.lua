local MODULE_NAME = (...)
local Lplus = require("Lplus")
local VoiceQuestionProtocols = Lplus.Class(MODULE_NAME)
local instance
local def = VoiceQuestionProtocols.define
local txtConst = textRes.VoiceQuestion
local ANSWER_CONST = require
local G_sessionId = 0
def.static("=>", VoiceQuestionProtocols).Instance = function()
  if instance == nil then
    instance = VoiceQuestionProtocols()
  end
  return instance
end
def.method().Init = function()
  local Cls = VoiceQuestionProtocols
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.questionvoice.SGetQuestionVoiceSuccessRes", Cls.OnSGetVoiceQuestionSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.questionvoice.SGetQuestionVoiceFailRes", Cls.OnSGetVoiceQuestionFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.questionvoice.SAnswerQuestionVoiceSuccessRes", Cls.OnSAnswerQuestionSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.questionvoice.SAnswerQuestionVoiceFailRes", Cls.OnSAnswerQuestionFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.questionvoice.SGetLastQuestionVoiceSuccessRes", Cls.OnSGetLastQuesionRes)
end
def.static("=>", "number").GetSessionId = function()
  return G_sessionId
end
def.static("number", "number").CSendGetVoiceQuestionReq = function(actId, npcId)
  local p = require("netio.protocol.mzm.gsp.questionvoice.CGetQuestionVoiceReq").new(actId, npcId)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number", "number", "number").CSendAnswerVoiceQuestionReq = function(actId, npcId, questionId, answerIdx, sessionId)
  local p = require("netio.protocol.mzm.gsp.questionvoice.CAnswerQuestionVoiceReq").new(actId, npcId, questionId, answerIdx, Int64.new(sessionId))
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").CSendGetLastVoiceQuestion = function(actId, npcId)
  local p = require("netio.protocol.mzm.gsp.questionvoice.CGetLastQuestionVoiceReq").new(actId, npcId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetVoiceQuestionSuccess = function(p)
  require("Main.VoiceQuestion.ui.UIVoiceQuestion").Instance():ShowPanel(p.activity_id or 0, p.question_id or 0, p.answer_list)
end
def.static("table").OnSGetVoiceQuestionFailed = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.questionvoice.SGetQuestionVoiceFailRes")
  if p.error_code == ERROR_CODE.ERROR_SYSTEM then
    warn(">>>SYSTEM_ERROR")
  elseif p.error_code == ERROR_CODE.ERROR_USERID then
    warn(">>>>USER NOT EXIST")
  elseif p.error_code == ERROR_CODE.ERROR_CFG then
    warn(">>>>ERROR_CFG")
  elseif p.error_code == ERROR_CODE.ERROR_PARAM then
    warn(">>>>ERROR PARAMS")
  elseif p.error_code == ERROR_CODE.ERROR_NPC_SERVICE then
    warn(">>>>npc service id error")
  elseif p.error_code == ERROR_CODE.ERROR_ACTIVITY_CLOSED then
    Toast(txtConst[2])
  else
    warn(">>>>UNKNOW ERROR")
  end
end
def.static("table").OnSAnswerQuestionSuccess = function(p)
  Event.DispatchEvent(ModuleId.VOICE_QUESTION, gmodule.notifyId.VoiceQuestion.AnswerRes, {
    actId = p.activity_id,
    questionId = p.activity_id,
    result = p.answer_result == 1,
    rightIdx = p.right_index or 0
  })
end
def.static("table").OnSAnswerQuestionFailed = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.questionvoice.SAnswerQuestionVoiceFailRes")
  if ERROR_CODE.ERROR_SYSTEM == p.error_code then
    warn(">>>SYSTEM_ERROR")
  elseif ERROR_CODE.ERROR_USERID == p.error_code then
    warn(">>>>USER NOT EXIST")
  elseif ERROR_CODE.ERROR_CFG == p.error_code then
    warn(">>>>ERROR_CFG")
  elseif ERROR_CODE.ERROR_PARAM == p.error_code then
    warn(">>>>ERROR PARAMS")
  elseif ERROR_CODE.ERROR_NPC_SERVICE == p.error_code then
    warn(">>>>npc service id error")
  elseif ERROR_CODE.ERROR_ACTIVITY_CLOSED == p.error_code then
    Toast(txtConst[2])
  elseif ERROR_CODE.ERROR_TIME_OUT == p.error_code then
    warn(">>>>TIME OUT")
  end
end
def.static("table").OnSGetLastQuesionRes = function(p)
  local arrAnswer = {}
  table.insert(arrAnswer, p.answer)
  require("Main.VoiceQuestion.ui.UIVoiceQuestion").Instance():ShowPanel(p.activity_id or 0, p.question_id or 0, arrAnswer)
end
return VoiceQuestionProtocols.Commit()
