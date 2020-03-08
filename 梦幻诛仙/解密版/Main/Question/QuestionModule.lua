local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local QuestionModule = Lplus.Extend(ModuleBase, "QuestionModule")
local AnswerQuestionPanel = require("Main.Question.ui.AnswerQuestionPanel")
local QuestionAwardPanel = require("Main.Question.ui.QuestionAwardPanel")
local ItemModule = require("Main.Item.ItemModule")
require("Main.module.ModuleId")
local def = QuestionModule.define
local instance
def.const("string").QUESTION_INVITE_DAY = "InviteDay"
def.field("number").totalCount = 0
def.field("number").answered = 0
def.field("number").questionId = 0
def.field("userdata").shuffleSession = nil
def.field("string").questionDesc = ""
def.field("number").pageIndex = 0
def.field("number").pageCount = 0
def.field("userdata").curMoney = function()
  return Int64.new(0)
end
def.field("userdata").curExp = function()
  return Int64.new(0)
end
def.field("table").answer = nil
def.field("number").totalGangHelp = 0
def.field("number").gangHelpUsed = 0
def.const("number").questionCfgId = 350300000
def.static("=>", QuestionModule).Instance = function()
  if instance == nil then
    instance = QuestionModule()
    instance.m_moduleId = ModuleId.Question
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SAnswerLunHuiResultRes", QuestionModule._onSAnswerLunHuiResultRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SJoinLunHuiQuestionRes", QuestionModule._onSJoinLunHuiQuestionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncExtraReward", QuestionModule._onSSyncExtraReward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SCallGangHelpRes", QuestionModule.onSynGangHelp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncGangAnswer", QuestionModule.onAnswerGangHelp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncQuestionNormalResult", QuestionModule.onQuestionError)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_HelpAnno, QuestionModule.onGangHelp)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, QuestionModule.OnMainUIReady)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, QuestionModule.OnRoleLvUp)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, QuestionModule._onActivityTodo)
  ModuleBase.Init(self)
end
def.static("table").onQuestionError = function(p)
  if p.result == p.HELP_ANSWER_LH_QUESTION_INVALID then
    Toast(textRes.Question[20])
  end
end
def.static("table", "table")._onActivityTodo = function(params, context)
  local questionConstRecord = DynamicData.GetRecord(CFG_PATH.DATA_EVERYDAYQUESTIONCONST, QuestionModule.questionCfgId)
  local activityId = questionConstRecord:GetIntValue("activityId")
  if activityId == params[1] then
    instance:JoinQuestion()
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
  local invitedDay = PlayerPref.GetRoleInt(QuestionModule.QUESTION_INVITE_DAY)
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
  PlayerPref.SetRoleInt(QuestionModule.QUESTION_INVITE_DAY, dateTbl.yday)
  PlayerPref.Save()
end
def.static("table")._onSAnswerLunHuiResultRes = function(p)
  local questionModule = QuestionModule.Instance()
  questionModule.curMoney = p.money
  questionModule.curExp = p.exp
  print("_onSAnswerLunHuiResultRes", p.isLastAnswerRight)
  if p.nextQuestionId == -1 then
    print("Question Done")
    questionModule.questionId = -1
    questionModule.shuffleSession = nil
    AnswerQuestionPanel.Instance():ShowResultAndNext(p.isLastAnswerRight ~= 0)
  else
    if questionModule.questionId ~= p.nextQuestionId then
      questionModule.answered = questionModule.answered + 1
    end
    AnswerQuestionPanel.Instance():ShowResultAndNext(p.isLastAnswerRight ~= 0)
    questionModule:GenerateAnswers(p.nextQuestionId, p.nextpageIndex, p.sessionid, p.answer_sequence)
  end
end
def.static("table")._onSJoinLunHuiQuestionRes = function(p)
  print("_onSJoinLunHuiQuestionRes")
  local questionModule = QuestionModule.Instance()
  local questionConstRecord = DynamicData.GetRecord(CFG_PATH.DATA_EVERYDAYQUESTIONCONST, QuestionModule.questionCfgId)
  local questionNum = questionConstRecord:GetIntValue("answerNumLimit")
  local helpNum = questionConstRecord:GetIntValue("callHelpLimit")
  questionModule.totalCount = questionNum
  questionModule.answered = p.answeredNum
  questionModule.totalGangHelp = helpNum
  questionModule.gangHelpUsed = p.useHelpNum
  questionModule.curMoney = p.money
  questionModule.curExp = p.exp
  if p.questionId == -1 then
    questionModule.questionId = -1
    questionModule.shuffleSession = nil
    Toast(textRes.Question[19])
  else
    questionModule:GenerateAnswers(p.questionId, p.nextPageIndex, p.sessionid, p.answer_sequence)
    questionModule:StartAnswer()
  end
end
def.static("table")._onSSyncExtraReward = function(p)
  print("_onSSyncExtraReward")
  ItemModule.Instance():BlockItemGetEffect(true)
  require("Main.Chat.PersonalHelper").Block(true)
  instance:NoticeAward(p.awardList[1])
  GameUtil.AddGlobalTimer(3, true, function()
    QuestionAwardPanel.ShowAward(p.awardList, textRes.Question[21], QuestionAwardPanel.Type.QUESTION)
  end)
end
def.method().JoinQuestion = function(self)
  local join = require("netio.protocol.mzm.gsp.question.CJoinLunHuiQuestionReq").new()
  gmodule.network.sendProtocol(join)
end
def.method("number", "number", "number", "userdata").AnswerQuestion = function(self, questionId, pageIndex, choice, session)
  warn("My Choice", choice)
  local ans = require("netio.protocol.mzm.gsp.question.CAnswerLunHuiQuestionReq").new(choice, questionId, pageIndex, session)
  gmodule.network.sendProtocol(ans)
end
def.method("number", "number").UseGangHelp = function(self, questionId, pageIndex)
  if questionId > 0 then
    local help = require("netio.protocol.mzm.gsp.question.CCallGangHelpReq").new(questionId, pageIndex)
    gmodule.network.sendProtocol(help)
  end
end
def.method("string").AnswerGangHelp = function(self, linkStr)
  local words = string.split(linkStr, "_")
  local questionId = tonumber(words[2])
  local pageIndex = tonumber(words[3])
  local roleId = Int64.new(words[4])
  local myRoleId = require("Main.Hero.HeroModule").Instance().roleId
  if roleId == myRoleId then
    return
  end
  require("Main.Question.ui.QuestionHelpDlg").ShowHelp(questionId, pageIndex, function(qid, pid, answer)
    local help = require("netio.protocol.mzm.gsp.question.CGangHelpAnswerReq").new(questionId, pageIndex, roleId, answer)
    gmodule.network.sendProtocol(help)
  end)
end
def.static("table").onSynGangHelp = function(p)
  local useCount = p.useCount
  instance.gangHelpUsed = useCount
  AnswerQuestionPanel.Instance():UpdateGangHelp()
end
def.static("table", "table").onGangHelp = function(p1, p2)
  local SSyncGangHelp = require("netio.protocol.mzm.gsp.gang.SSyncGangHelp")
  local helpType = p1[1]
  local paramString = p1[2]
  local paramLong = p1[3]
  local paramInt = p1[4]
  if helpType == SSyncGangHelp.TYPE_LUNHUIQUESTION then
    local roleId = paramLong[SSyncGangHelp.ROLE_ID]
    local questionId = paramInt[SSyncGangHelp.QUESTION_ID]
    local pageIndex = paramInt[SSyncGangHelp.PAGE_INDEX]
    warn("roleId, questionId, pageIndex", roleId, questionId, pageIndex)
    if questionId and questionId > 0 then
      local questionItemCfg = DynamicData.GetRecord(CFG_PATH.DATA_EVERYDAYQUESTIONITEM, questionId)
      local questionDesc = questionItemCfg:GetStringValue("questionDesc")
      local questionHtml = string.format(textRes.Question[15], questionId, pageIndex, roleId:tostring(), questionDesc)
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
      QuestionModule.SendFakeFactionProtocol(roleId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, position, avatarId, avatarFrameId)
    end
  end
end
def.static("table").onAnswerGangHelp = function(p)
  local questionId = p.questionid
  local pageIndex = p.pageIndex
  local roleId = p.answerRoleId
  local answerString = p.answerString
  local answerRoleId = p.roleId
  local memberInfo = require("Main.Gang.GangModule").Instance().data:GetMemberInfoByRoleId(roleId)
  local answerMemberInfo = require("Main.Gang.GangModule").Instance().data:GetMemberInfoByRoleId(answerRoleId)
  if memberInfo and answerMemberInfo then
    local questionItemCfg = DynamicData.GetRecord(CFG_PATH.DATA_EVERYDAYQUESTIONITEM, questionId)
    local questionDesc = questionItemCfg:GetStringValue("questionDesc")
    local answerHtml = string.format(textRes.Question[16], answerMemberInfo.name, questionDesc, answerString)
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
    QuestionModule.SendFakeFactionProtocol(roleId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, position, avatarId, avatarFrameId)
  end
end
def.static("userdata", "string", "number", "number", "number", "number", "number", "table", "number", "userdata", "number", "number", "number").SendFakeFactionProtocol = function(roleId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, position, avatarId, avatarFrameId)
  local SChatInFaction = require("netio.protocol.mzm.gsp.chat.SChatInFaction")
  local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
  local time = _G.GetServerTime()
  local chatCnt = ChatContent.new(roleId, roleName, gender, occupationId, avatarId, avatarFrameId, level, vipLevel, modelId, badge, contentType, content, 0, Int64.new(time) * 1000)
  local chatFaction = SChatInFaction.new(chatCnt, position)
  require("Main.Chat.ChatModule").OnNewFactionChat(chatFaction)
end
def.method("number", "number").TextZXQY = function(self, id, page)
  local questionModule = QuestionModule.Instance()
  questionModule.totalCount = 1
  questionModule.answered = 0
  questionModule.totalGangHelp = 0
  questionModule.gangHelpUsed = 0
  questionModule.curMoney = Int64.new()
  questionModule.curExp = Int64.new()
  AnswerQuestionPanel.Instance():DestroyPanel()
  AnswerQuestionPanel.Instance().debug = true
  questionModule:GenerateAnswers(id, page, nil, {
    1,
    2,
    3
  })
  questionModule:StartAnswer()
end
def.method().StartAnswer = function(self)
  local panel = AnswerQuestionPanel.Instance()
  panel:CreatePanel(RESPATH.QUESTION_PANEL, 1)
  panel:SetModal(true)
end
def.method("number", "number", "userdata", "table").GenerateAnswers = function(self, questionId, pageIndex, shuffleSession, shuffleSequence)
  self.questionId = questionId
  self.shuffleSession = shuffleSession
  self.pageIndex = pageIndex
  local questionItemCfg = DynamicData.GetRecord(CFG_PATH.DATA_EVERYDAYQUESTIONITEM, questionId)
  local questionDesc = questionItemCfg:GetStringValue("questionDesc")
  self.questionDesc = questionDesc
  local answerStruct = questionItemCfg:GetStructValue("answerStruct")
  local size = answerStruct:GetVectorSize("answerList")
  local answerCount = 0
  for i = 0, size - 1 do
    local rec = answerStruct:GetVectorValueByIdx("answerList", i)
    local answer = rec:GetStringValue("answer")
    if answer ~= "" then
      answerCount = answerCount + 1
    else
      break
    end
  end
  self.pageCount = answerCount / 3
  self.answer = {}
  for i = pageIndex * 3, pageIndex * 3 + 2 do
    local rec = answerStruct:GetVectorValueByIdx("answerList", i)
    local answer = rec:GetStringValue("answer")
    local refIcon = rec:GetIntValue("answerRefIcon")
    local opt = {
      icon = refIcon,
      text = answer,
      id = i
    }
    table.insert(self.answer, opt)
  end
  require("Common.MathHelper").ShuffleTableBySequence(self.answer, shuffleSequence)
end
def.method("table").NoticeAward = function(self, info)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local RewardItem = require("netio.protocol.mzm.gsp.question.RewardItem")
  local type = info.rewardType
  if type == RewardItem.TYPE_ITEM then
    local itemId = info.paramMap[RewardItem.PARAM_ITEM_ID]
    local num = info.paramMap[RewardItem.PARAM_ITEM_NUM]
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.ItemMap, {
      [itemId] = num
    })
  elseif type == RewardItem.TYPE_ROLE_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.RoleExp, tostring(exp))
  elseif type == RewardItem.TYPE_PET_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
  elseif type == RewardItem.TYPE_XIULIAN_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.ColorText, textRes.BaoTu[3], "00ff00", PersonalHelper.Type.Text, tostring(exp))
  elseif type == RewardItem.TYPE_SILVER then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.Silver, Int64.new(money))
  elseif type == RewardItem.TYPE_GOLD then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.Gold, Int64.new(money))
  elseif type == RewardItem.TYPE_BANGGONG then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.ColorText, textRes.BaoTu[2], "00ff00", PersonalHelper.Type.Text, tostring(money))
  elseif type == RewardItem.TYPE_CONTROLLER then
  elseif type == RewardItem.TYPE_YUANBAO then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.Yuanbao, Int64.new(money))
  end
end
QuestionModule.Commit()
return QuestionModule
