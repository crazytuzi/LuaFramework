local Lplus = require("Lplus")
local QuestionAndAnswerMgr = Lplus.Class("QuestionAndAnswerMgr")
local def = QuestionAndAnswerMgr.define
local PhantomCaveUtils = require("Main.PhantomCave.PhantomCaveUtils")
local ExamDlg = require("Main.Keju.ui.ExamDlg")
local WordQuestionType = require("consts.mzm.gsp.question.confbean.WordQuestionType")
local instance
def.static("=>", QuestionAndAnswerMgr).Instance = function()
  if instance == nil then
    instance = QuestionAndAnswerMgr()
  end
  return instance
end
def.field("number").curQuestion = 0
def.field("userdata").sessionId = nil
def.field("number").curIndex = 0
def.field("number").rightNum = 0
def.field("number").levelId = 0
def.field("number").closeTimer = 0
def.field("number").startTime = 0
def.field("table").cacheProtocol = nil
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncWordQuestionInfo", QuestionAndAnswerMgr.onQuestion)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SAnswerWordQuestionRes", QuestionAndAnswerMgr.onResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncAllWordQuestionOver", QuestionAndAnswerMgr.onEnd)
end
def.method().ReleaseCacheProtocol = function(self)
  if self.cacheProtocol then
    QuestionAndAnswerMgr.onQuestion(self.cacheProtocol)
    self.cacheProtocol = nil
  end
end
def.method().Reset = function(self)
  self.curQuestion = 0
  self.sessionId = nil
  self.curIndex = 0
  self.rightNum = 0
  self.levelId = 0
  self.startTime = 0
  GameUtil.RemoveGlobalTimer(self.closeTimer)
end
def.static("number").Answer = function(ans)
  if ans >= 0 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.question.CAnswerWordQuestionReq").new(ans, instance.curQuestion, instance.sessionId))
  end
end
def.static("table").onQuestion = function(p)
  if not require("Main.Login.LoginModule").Instance().isEnteredWorld then
    instance.cacheProtocol = p
    return
  end
  instance.curQuestion = p.curQuestionId
  instance.sessionId = p.sessionid
  instance.curIndex = p.rightNum + p.wrongNum + 1
  instance.rightNum = p.rightNum
  instance.levelId = p.levelCfgId
  local levelCfg = PhantomCaveUtils.GetWQLevelCfg(instance.levelId)
  local all = levelCfg.questionNum
  local sec = p.endTime - GetServerTime()
  local title = textRes.Question[39]
  if levelCfg.questionType == WordQuestionType.SINGLE then
    ExamDlg.ReplaceUIRes(RESPATH.PREFAB_DENGMI_QUESTION)
    title = textRes.Question[40]
  elseif levelCfg.questionType == WordQuestionType.TEAM then
    title = textRes.Question[29]
  elseif levelCfg.questionType == WordQuestionType.MOURN then
    ExamDlg.ReplaceUIRes(RESPATH.PREFAB_ACTIVITY_QINGMING_QUIZE)
  elseif levelCfg.questionType == WordQuestionType.MAYDAY then
    ExamDlg.ReplaceUIRes(RESPATH.PREFAB_QUESTION_WUYILAODONG)
    title = textRes.Question[110]
  elseif levelCfg.questionType == WordQuestionType.TASK_USE then
    title = textRes.Question[111]
  end
  GameUtil.RemoveGlobalTimer(instance.closeTimer)
  ExamDlg.QuizeInTime(instance.curQuestion, title, p.answer_sequence, all, instance.rightNum, instance.curIndex, sec, function(select)
    QuestionAndAnswerMgr.Answer(select)
  end)
  local estimateTime = (instance.curIndex - 1) * levelCfg.answerInterval
  instance.startTime = GetServerTime() - estimateTime
end
def.static("table").onResult = function(p)
  if instance.levelId <= 0 then
    return
  end
  instance.curQuestion = p.nextQuestionId
  instance.sessionId = p.sessionid
  instance.curIndex = instance.curIndex + 1
  instance.rightNum = 0 < p.isRight and instance.rightNum + 1 or instance.rightNum
  local curQuestion = instance.curQuestion
  local curIndex = instance.curIndex
  local rightNum = instance.rightNum
  if 0 > p.isRight then
    Toast(textRes.Question[33])
  end
  local levelCfg = PhantomCaveUtils.GetWQLevelCfg(instance.levelId)
  local all = levelCfg.questionNum
  local sec = levelCfg.answerInterval
  GameUtil.AddGlobalTimer(1, true, function()
    if curQuestion > 0 then
      local title = textRes.Question[39]
      if levelCfg.questionType == WordQuestionType.SINGLE then
        title = textRes.Question[40]
      elseif levelCfg.questionType == WordQuestionType.TEAM then
        title = textRes.Question[29]
      elseif levelCfg.questionType == WordQuestionType.WOURN then
        title = textRes.Question[109]
      end
      GameUtil.RemoveGlobalTimer(instance.closeTimer)
      ExamDlg.QuizeInTime(curQuestion, title, p.answer_sequence, all, rightNum, curIndex, sec, function(select)
        QuestionAndAnswerMgr.Answer(select)
      end)
    elseif levelCfg.questionType == WordQuestionType.TEAM then
      local leftTime = levelCfg.questionNum * levelCfg.answerInterval - (GetServerTime() - instance.startTime)
      if leftTime <= 0 then
        leftTime = 2
      end
      ExamDlg.ShowResult(textRes.Question[32], leftTime)
    elseif 0 >= instance.curQuestion then
      ExamDlg.Close()
    end
  end)
end
def.static("table").onEnd = function()
  instance.closeTimer = GameUtil.AddGlobalTimer(2, true, function()
    if instance.curQuestion <= 0 then
      ExamDlg.Close()
    end
  end)
end
QuestionAndAnswerMgr.Commit()
return QuestionAndAnswerMgr
