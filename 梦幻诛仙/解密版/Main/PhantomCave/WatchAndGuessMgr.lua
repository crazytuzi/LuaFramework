local Lplus = require("Lplus")
local WatchAndGuessMgr = Lplus.Class("WatchAndGuessMgr")
local def = WatchAndGuessMgr.define
local WatchAndGuessPanel = require("Main.PhantomCave.ui.WatchAndGuessPanel")
local PhantomCaveUtils = require("Main.PhantomCave.PhantomCaveUtils")
local QuestionType = require("consts.mzm.gsp.question.confbean.PictureQuestionType")
local instance
def.static("=>", WatchAndGuessMgr).Instance = function()
  if instance == nil then
    instance = WatchAndGuessMgr()
  end
  return instance
end
def.field("table").modelInfo = nil
def.field("table").actionInfo = nil
def.field("table").answers = nil
def.field("table").members = nil
def.field("number").questionId = 0
def.field("number").leftHelp = 0
def.field("number").levelId = 0
def.field("boolean").useHelp = true
def.field("table").cacheProtocol = nil
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncPictureInfo", WatchAndGuessMgr.onStart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncPictureQuestionInfo", WatchAndGuessMgr.onQuestion)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncHelpAnswerPictureQuestion", WatchAndGuessMgr.onHelp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SAnswerPictureQuestionRes", WatchAndGuessMgr.onAnswer)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SHelpAnswerPictureQuestionRes", WatchAndGuessMgr.onHelpResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SPreparePictureQuestionRes", WatchAndGuessMgr.onPrepare)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SPictureQuestionError", WatchAndGuessMgr.onError)
end
def.method().ReleaseCacheProtocol = function(self)
  if self.cacheProtocol then
    WatchAndGuessMgr.onQuestion(self.cacheProtocol)
    self.cacheProtocol = nil
  end
end
def.method().Reset = function(self)
  self.modelInfo = nil
  self.actionInfo = nil
  self.answers = nil
  self.questionId = 0
  self.levelId = 0
  self.leftHelp = 0
  self.useHelp = true
end
def.static("number").Answer = function(select)
  warn("select", select)
  local ans = WatchAndGuessMgr.Instance().answers[select] or -1
  warn("Answer==", ans, type(ans))
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.question.CAnswerPictureQuestionReq").new(ans))
end
def.static("number", "=>", "boolean").Help = function(select)
  if WatchAndGuessMgr.Instance().useHelp then
    Toast(textRes.Question[24])
    return false
  elseif WatchAndGuessMgr.Instance().leftHelp == 0 then
    Toast(textRes.Question[34])
    return false
  else
    local ans = WatchAndGuessMgr.Instance().answers[select]
    local questionId = WatchAndGuessMgr.Instance().questionId
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.question.CHelpAnswerPictureQuestionReq").new(ans, questionId))
    WatchAndGuessMgr.Instance().useHelp = true
    return true
  end
end
def.static().Start = function()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.question.CStartPictureQuestionReq").new())
end
def.static("table").onError = function(p)
  if p.rescode == p.NOT_LEADER then
    Toast(textRes.Question.Error[2])
  elseif p.rescode == p.ALREADY_IN_PICTURE_QUESTION then
    Toast(textRes.Question.Error[1])
  end
end
def.static("table").onPrepare = function(p)
  local tip = require("Main.Common.TipsHelper").GetHoverTip(constant.CEveryDayConsts.PICTURE_QUESTION_TIP_ID)
  WatchAndGuessPanel.Instance():ShowPrepare(tip, constant.CEveryDayConsts.PICTURE_QUESTION_TIME)
end
def.static("table").onStart = function(p)
  warn("On PIC Start")
  local modelInfo = {}
  for k, v in ipairs(p.info.resourceList) do
    local cfg = PhantomCaveUtils.GetPQModelCfg(v)
    if cfg then
      modelInfo[k] = {
        modelId = cfg.modelId,
        colorId = cfg.colorId,
        hasOranment = cfg.isEquipDecorate,
        name = cfg.name
      }
    end
  end
  WatchAndGuessMgr.Instance().modelInfo = modelInfo
  local lvCfg = PhantomCaveUtils.GetPQLevelCfg(p.info.difficultyLevelId)
  WatchAndGuessMgr.Instance().levelId = p.info.difficultyLevelId
  local allTime = lvCfg.moveInterval * (#p.info.movePath + 1)
  local move = {}
  for k, v in ipairs(p.info.movePath) do
    local oneMove = {}
    for k1, v1 in ipairs(v.steps) do
      table.insert(oneMove, {
        who = v1.resourceNo,
        pos = v1.targetPos
      })
    end
    move[k * lvCfg.moveInterval] = oneMove
  end
  WatchAndGuessMgr.Instance().actionInfo = move
  WatchAndGuessPanel.Instance():ShowWatchAndGuess(WatchAndGuessMgr.Instance().modelInfo, WatchAndGuessMgr.Instance().actionInfo, allTime)
end
def.static("table").onQuestion = function(p)
  if not require("Main.Login.LoginModule").Instance().isEnteredWorld then
    instance.cacheProtocol = p
    return
  end
  warn("On PIC Question")
  WatchAndGuessMgr.Instance().members = p.answerList
  WatchAndGuessMgr.Instance().useHelp = false
  WatchAndGuessMgr.Instance().leftHelp = p.remainHelperCount
  WatchAndGuessMgr.Instance().levelId = p.difficultyLevelId
  local lvCfg = PhantomCaveUtils.GetPQLevelCfg(WatchAndGuessMgr.Instance().levelId)
  local score = lvCfg.rightScore * p.rightCount + (p.totalCount - p.rightCount) * lvCfg.wrongScore
  local time = p.endTime - GetServerTime()
  WatchAndGuessPanel.Instance():SetScore(score, lvCfg.passScore)
  WatchAndGuessPanel.Instance():SetHelpTimes(WatchAndGuessMgr.Instance().leftHelp)
  WatchAndGuessMgr.ShowQuestion(p.info, p.answerRoleId, time)
end
def.static("table").onHelpResult = function(p)
  warn("On PIC Result")
  WatchAndGuessMgr.Instance().leftHelp = p.remainHelperCount
  if WatchAndGuessPanel.Instance().m_panel == nil then
    return
  end
  if WatchAndGuessPanel.Instance().m_panel then
    WatchAndGuessPanel.Instance():SetHelpTimes(p.remainHelperCount)
  end
end
def.static("table").onHelp = function(p)
  warn("On PIC Help")
  if WatchAndGuessPanel.Instance().m_panel == nil then
    return
  end
  local roleId = p.answerProviderId
  local questionCfg = PhantomCaveUtils.GetPQQuestionCfg(p.questionItemId)
  local measureWord = PhantomCaveUtils.QuestionTypeToMeasure(questionCfg.type)
  local ansStr = p.answer .. measureWord
  if WatchAndGuessPanel.Instance().m_panel then
    WatchAndGuessPanel.Instance():ShowHelp(ansStr, roleId)
  end
end
def.static("table").onAnswer = function(p)
  warn("On PIC Answer")
  if WatchAndGuessPanel.Instance().m_panel == nil then
    return
  end
  WatchAndGuessMgr.Instance().useHelp = false
  local ans = p.lastAnswer
  for k, v in ipairs(WatchAndGuessMgr.Instance().answers) do
    if v == ans then
      ans = k
      break
    end
  end
  local isRight = p.isRight > 0
  local lvCfg = PhantomCaveUtils.GetPQLevelCfg(WatchAndGuessMgr.Instance().levelId)
  local score = lvCfg.rightScore * p.rightNum + (p.totalNum - p.rightNum) * lvCfg.wrongScore
  WatchAndGuessPanel.Instance():SetScore(score, lvCfg.passScore)
  if ans > 0 then
    WatchAndGuessPanel.Instance():ShowResult(ans, isRight)
  else
    Toast(textRes.Question[23])
  end
  GameUtil.AddGlobalTimer(1, true, function()
    if p.nextAnswerRoleId:gt(0) then
      WatchAndGuessMgr.ShowQuestion(p.nextQuestionInfo, p.nextAnswerRoleId, 0)
    else
      WatchAndGuessPanel.Instance():HideWatchAndGuess()
    end
  end)
end
def.static("table", "userdata", "number").ShowQuestion = function(info, roleId, time)
  local questionCfg = PhantomCaveUtils.GetPQQuestionCfg(info.questionItemId)
  local measureWord = PhantomCaveUtils.QuestionTypeToMeasure(questionCfg.type)
  local questionStr
  if questionCfg.type == QuestionType.NUMBER or questionCfg.type == QuestionType.MOVE_STEPS then
    local species = tonumber(info.paramMap[info.RESOURCE_TYPE])
    local monsterName = PhantomCaveUtils.GetSpeciesName(species)
    questionStr = string.format(questionCfg.desc, "[e60000]" .. monsterName .. "[-]")
  elseif questionCfg.type == QuestionType.SPECIAL_BIANYI_NUMBER or questionCfg.type == QuestionType.BIANYI_MOVE_STEPS then
    local species = tonumber(info.paramMap[info.RESOURCE_TYPE])
    local monsterName = textRes.Question[35] .. PhantomCaveUtils.GetSpeciesName(species)
    questionStr = string.format(questionCfg.desc, "[e60000]" .. monsterName .. "[-]")
  else
    questionStr = questionCfg.desc
  end
  table.sort(info.answerList)
  local ans = {}
  for k, v in ipairs(info.answerList) do
    ans[k] = v .. measureWord
  end
  WatchAndGuessMgr.Instance().answers = info.answerList
  WatchAndGuessMgr.Instance().questionId = info.questionItemId
  local lvCfg = PhantomCaveUtils.GetPQLevelCfg(WatchAndGuessMgr.Instance().levelId)
  local teams = WatchAndGuessMgr.Instance().members
  local sec = time > 0 and time or lvCfg.questionTime
  WatchAndGuessPanel.Instance():ShowQuestion(questionStr, ans, teams, roleId, sec)
end
WatchAndGuessMgr.Commit()
return WatchAndGuessMgr
