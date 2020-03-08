local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local EveryNightQuestionModule = Lplus.Extend(ModuleBase, "EveryNightQuestionModule")
local AnswerQuestionPanel = require("Main.Question.ui.AnswerQuestionPanel")
local QuestionAwardPanel = require("Main.Question.ui.QuestionAwardPanel")
local ItemModule = require("Main.Item.ItemModule")
local QYXTUtils = require("Main.Question.QYXTUtils")
local QyxtHelpStatus = require("netio.protocol.mzm.gsp.question.QyxtHelpStatus")
require("Main.module.ModuleId")
local def = EveryNightQuestionModule.define
local instance
def.const("string").QUESTION_INVITE_DAY = "QYXTInviteDay"
def.field("number").totalCount = 0
def.field("number").answered = 0
def.field("number").right = 0
def.field("number").questionId = 0
def.field("number").totalGangHelp = constant.CQYXTQuestionConst.maxSeekHelpTimes
def.field("number").gangHelpUsed = 0
def.field("number").isInGangHelp = 0
def.field("userdata").shuffleSession = nil
def.static("=>", EveryNightQuestionModule).Instance = function()
  if instance == nil then
    instance = EveryNightQuestionModule()
    instance.m_moduleId = ModuleId.EVERY_NIGHT_QUESTION
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SQYXTQuestionRes", EveryNightQuestionModule._onSJoinQYXTQuestionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SAnswerQYXTQuestionRes", EveryNightQuestionModule._onSAnswerQYXTResultRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SQYXTExtraAwardRes", EveryNightQuestionModule._onSSyncExtraReward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SQYXTSeekGangHelpRsp", EveryNightQuestionModule._onSAskForGangHelpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncQYXTGangAnswer", EveryNightQuestionModule._onAnswerGangHelp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncQuestionNormalResult", EveryNightQuestionModule._onQuestionError)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, EveryNightQuestionModule.OnMainUIReady)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, EveryNightQuestionModule.OnRoleLvUp)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, EveryNightQuestionModule._onActivityTodo)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_HelpAnno, EveryNightQuestionModule._onGangHelp)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, EveryNightQuestionModule._onActivityEnd)
  ModuleBase.Init(self)
  self.totalCount = require("Main.activity.ActivityInterface").GetActivityCfgById(constant.CQYXTQuestionConst.ACTIVITY_ID).limitCount
end
def.static("table", "table")._onActivityTodo = function(params, context)
  if constant.CQYXTQuestionConst.ACTIVITY_ID == params[1] then
    instance:JoinQuestion()
  end
end
def.static("table", "table")._onActivityEnd = function(params, context)
  if constant.CQYXTQuestionConst.ACTIVITY_ID == params[1] then
    instance:StopQuestion()
  end
end
def.static().TryAskJoinActivity = function()
  local questionOpen = require("Main.activity.ActivityInterface").GetActivityState(constant.CQYXTQuestionConst.ACTIVITY_ID)
  if questionOpen == 0 then
    local actCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(constant.CQYXTQuestionConst.ACTIVITY_ID)
    local prop = require("Main.Hero.HeroModule").Instance():GetHeroProp()
    if prop == nil then
      return
    end
    local myLevel = prop.level
    local actInfo = require("Main.activity.ActivityInterface").Instance():GetActivityInfo(constant.CQYXTQuestionConst.ACTIVITY_ID)
    local complete = actInfo and actInfo.count >= actCfg.recommendCount or false
    if myLevel >= actCfg.levelMin and myLevel <= actCfg.levelMax and not complete and not EveryNightQuestionModule.HasInvited() then
      EveryNightQuestionModule.SaveInvited()
      local CommonConfirm = require("GUI.CommonConfirmDlg")
      CommonConfirm.ShowConfirm(textRes.Question[100], textRes.Question[101], function(selection, tag)
        if selection == 1 then
          instance:JoinQuestion()
        end
      end, {m_level = 0})
    end
  end
end
def.static("table", "table").OnMainUIReady = function(p1, p2)
end
def.static("table", "table").OnRoleLvUp = function(p1, p2)
end
def.static("table")._onActivityStart = function(p)
end
def.static("=>", "boolean").HasInvited = function()
  local date = GetServerTime()
  local dateTbl = os.date("*t", date)
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  local invitedDay = PlayerPref.GetRoleInt(EveryNightQuestionModule.QUESTION_INVITE_DAY)
  if invitedDay and invitedDay == dateTbl.yday then
    return true
  else
    return false
  end
end
def.static().SaveInvited = function()
  local date = GetServerTime()
  local dateTbl = os.date("*t", date)
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  PlayerPref.SetRoleInt(EveryNightQuestionModule.QUESTION_INVITE_DAY, dateTbl.yday)
  PlayerPref.Save()
end
def.static("table")._onSJoinQYXTQuestionRes = function(p)
  local self = EveryNightQuestionModule.Instance()
  self.answered = p.alreadyAnswer
  self.right = p.rightAnswer
  self.gangHelpUsed = p.useGangHelpTimes
  self.isInGangHelp = p.isInGangHelp
  self.shuffleSession = p.session_id
  if p.questionId == 0 then
    self.questionId = -1
    Toast(textRes.Question[102])
  else
    self.questionId = p.questionId
    self:AskQuestion(self.questionId, self.answered + 1, self.totalCount, self.right, p.answer_sequence)
  end
end
def.static("table")._onSAnswerQYXTResultRes = function(p)
  local self = EveryNightQuestionModule.Instance()
  self.answered = self.answered + 1
  self.right = p.rightAnswer
  self.isInGangHelp = QyxtHelpStatus.NOT_IN_HELP
  self.shuffleSession = p.session_id
  if p.newQuestionId == 0 then
    self.questionId = -1
    Toast(textRes.Question[103])
    require("Main.Question.ui.EveryNightQuestionPanel").Close()
  else
    self.questionId = p.newQuestionId
    self:AskQuestion(self.questionId, self.answered + 1, self.totalCount, self.right, p.answer_sequence)
  end
end
def.static("table")._onSSyncExtraReward = function(p)
  require("Main.Chat.PersonalHelper").Block(true)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local itemId = p.item2countList[1].itemid
  local num = p.item2countList[1].itemCount
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.ItemMap, {
    [itemId] = num
  })
  local RewardItem = require("netio.protocol.mzm.gsp.question.RewardItem")
  local awards = {}
  for k, v in ipairs(p.item2countList) do
    local param = {}
    param[RewardItem.PARAM_ITEM_ID] = v.itemid
    param[RewardItem.PARAM_ITEM_NUM] = v.itemCount
    local BossAward = RewardItem.new(RewardItem.TYPE_ITEM, param)
    table.insert(awards, BossAward)
  end
  local QuestionAwardPanel = require("Main.Question.ui.QuestionAwardPanel")
  QuestionAwardPanel.ShowAward(awards, textRes.Question[21], QuestionAwardPanel.Type.EVERYNIGHT)
end
def.static("table")._onSAskForGangHelpRes = function(p)
  instance.gangHelpUsed = p.useGangHelpTimes
  require("Main.Question.ui.EveryNightQuestionPanel").Instance():UpdateGangHelp()
end
def.static("table", "table")._onGangHelp = function(p1, p2)
  local SSyncGangHelp = require("netio.protocol.mzm.gsp.gang.SSyncGangHelp")
  local helpType = p1[1]
  local paramString = p1[2]
  local paramLong = p1[3]
  local paramInt = p1[4]
  if helpType == SSyncGangHelp.TYPE_QING_YUN_XUE_TANG_QUESTION then
    local roleId = paramLong[SSyncGangHelp.ROLE_ID]
    local questionId = paramInt[SSyncGangHelp.QUESTION_ID]
    if questionId and questionId > 0 then
      local questionInfo = QYXTUtils.GetQuestion(questionId)
      local questionDesc = questionInfo.question
      local questionHtml = string.format(textRes.Question[105], questionId, roleId:tostring(), questionDesc)
      local memberInfo = require("Main.Gang.GangModule").Instance().data:GetMemberInfoByRoleId(roleId)
      if not memberInfo then
        return
      end
      local roleName = memberInfo.name
      local gender = memberInfo.gender
      local occupationId = memberInfo.occupationId
      local avatarId = memberInfo.avatarId
      local avatarFrameId = memberInfo.avatar_frame
      local level = memberInfo.level
      local vipLevel = 0
      local modelId = 0
      local badge = {}
      local contentType = require("netio.protocol.mzm.gsp.chat.ChatConsts").CONTENT_NORMAL
      local content = require("netio.Octets").rawFromString(questionHtml)
      local position = require("Main.Gang.GangUtility").GetDutyLv(memberInfo.duty)
      require("Main.Question.QuestionModule").SendFakeFactionProtocol(roleId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, position, avatarId, avatarFrameId)
    end
  end
end
def.static("table")._onAnswerGangHelp = function(p)
  local questionId = p.questionId
  local roleId = p.helpAnswerRoleId
  local answerString = p.helpAnswerString
  local seekHelpRoleId = p.seekHelpRoleId
  local memberInfo = require("Main.Gang.GangModule").Instance().data:GetMemberInfoByRoleId(roleId)
  local seekHelpMemberInfo = require("Main.Gang.GangModule").Instance().data:GetMemberInfoByRoleId(seekHelpRoleId)
  if memberInfo and seekHelpMemberInfo then
    local questionInfo = QYXTUtils.GetQuestion(questionId)
    local questionDesc = questionInfo.question
    local answerHtml = string.format(textRes.Question[16], seekHelpMemberInfo.name, questionDesc, answerString)
    local roleName = memberInfo.name
    local gender = memberInfo.gender
    local occupationId = memberInfo.occupationId
    local avatarId = memberInfo.avatarId
    local avatarFrameId = memberInfo.avatar_frame
    local level = memberInfo.level
    local vipLevel = 0
    local modelId = 0
    local badge = {}
    local contentType = require("netio.protocol.mzm.gsp.chat.ChatConsts").CONTENT_NORMAL
    local content = require("netio.Octets").rawFromString(answerHtml)
    local position = require("Main.Gang.GangUtility").GetDutyLv(memberInfo.duty)
    require("Main.Question.QuestionModule").SendFakeFactionProtocol(roleId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, position, avatarId, avatarFrameId)
  end
end
def.static("table")._onQuestionError = function(p)
  if p.result == p.HELP_QYXT_ALEARDY_ANSWER then
    Toast(textRes.Question[20])
  elseif p.result == p.HELP_QYXT_ALEARDY_HELP then
    Toast(textRes.Question[24])
  elseif p.result == p.HELP_QYXT_NOT_IN_GANG then
    Toast(textRes.Question[106])
  elseif p.result == p.HELP_QYXT_GANG_CHANGE then
    Toast(textRes.Question[107])
  end
end
def.method().RequestAward = function(self)
  local take = require("netio.protocol.mzm.gsp.question.CTakeQYXTExtraAwardReq").new()
  gmodule.network.sendProtocol(take)
end
def.method().JoinQuestion = function(self)
  local join = require("netio.protocol.mzm.gsp.question.CGetQYXTQuestionReq").new()
  gmodule.network.sendProtocol(join)
end
def.method("number", "number").AnswerQuestion = function(self, questionId, choice)
  local ans = require("netio.protocol.mzm.gsp.question.CAnswerQYXTQuestionReq").new(questionId, choice, self.shuffleSession)
  gmodule.network.sendProtocol(ans)
end
def.method("number", "number", "number", "number", "table").AskQuestion = function(self, questionId, curNum, totalNum, right, answerSequence)
  require("Main.Question.ui.EveryNightQuestionPanel").AskQuestion(questionId, curNum, totalNum, right, answerSequence)
end
def.method("number").AskForGangHelp = function(self, questionId)
  local req = require("netio.protocol.mzm.gsp.question.CQYXTSeekGangHelpReq").new(questionId)
  gmodule.network.sendProtocol(req)
end
def.method("string").AnswerGangHelp = function(self, linkStr)
  local words = string.split(linkStr, "_")
  local questionId = tonumber(words[2])
  local roleId = Int64.new(words[3])
  local myRoleId = require("Main.Hero.HeroModule").Instance().roleId
  if roleId == myRoleId then
    return
  end
  require("Main.Question.ui.EveryNightQuestionHelpDlg").ShowHelp(questionId, function(qid, answer)
    local help = require("netio.protocol.mzm.gsp.question.CQYXTGangHelpAnswerReq").new(qid, roleId, answer)
    gmodule.network.sendProtocol(help)
  end)
end
def.method().StopQuestion = function(self)
  self:CloseAllUI()
  self:ClearData()
end
def.method().CloseAllUI = function(self)
  local hasUIOpen = false
  local EveryNightQuestionPanel = require("Main.Question.ui.EveryNightQuestionPanel")
  if EveryNightQuestionPanel.Instance():IsExistPanel() then
    hasUIOpen = true
    EveryNightQuestionPanel.Instance():DestroyPanel()
  end
  if hasUIOpen then
    Toast(textRes.Question[104])
  end
end
def.method().ClearData = function(self)
  self.answered = 0
  self.right = 0
  self.questionId = 0
  self.totalGangHelp = constant.CQYXTQuestionConst.maxSeekHelpTimes
  self.gangHelpUsed = 0
  self.isInGangHelp = 0
  self.shuffleSession = nil
end
EveryNightQuestionModule.Commit()
return EveryNightQuestionModule
