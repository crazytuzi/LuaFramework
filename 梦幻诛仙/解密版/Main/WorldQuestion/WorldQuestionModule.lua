local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local WorldQuestionModule = Lplus.Extend(ModuleBase, "WorldQuestionModule")
local WorldQuestionUtils = require("Main.WorldQuestion.WorldQuestionUtils")
local ChatModule = require("Main.Chat.ChatModule")
local ChatModule = require("Main.Chat.ChatModule")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local PersonalHelper = require("Main.Chat.PersonalHelper")
require("Main.module.ModuleId")
local def = WorldQuestionModule.define
local instance
def.static("=>", WorldQuestionModule).Instance = function()
  if instance == nil then
    instance = WorldQuestionModule()
    instance.m_moduleId = ModuleId.WORLD_QUESTION
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SQuestionIsComingNotice", WorldQuestionModule.OnSQuestionIsComingNotice)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SQuestionContext", WorldQuestionModule.OnSQuestionContext)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SQuestionIsOver", WorldQuestionModule.OnSQuestionIsOver)
  ModuleBase.Init(self)
end
def.static("table").OnSQuestionIsComingNotice = function(p)
  require("GUI.AnnouncementTip").AnnounceWithDuration(textRes.WorldQuestion[3], constant.WorldQuestionConsts.BULLETIN_TIME_BEF_QU)
  ChatModule.Instance():SendWroldQuestionNotice("", textRes.WorldQuestion[4], textRes.WorldQuestion[2], textRes.WorldQuestion[5], constant.WorldQuestionConsts.MASTER_PIC_ID, true)
end
def.static("table").OnSQuestionContext = function(p)
  local question = WorldQuestionUtils.GetWorldQuestionContentById(p.questionId)
  if question == nil then
    return
  end
  ChatModule.Instance():SendWroldQuestion(question, textRes.WorldQuestion[6], textRes.WorldQuestion[2], constant.WorldQuestionConsts.MASTER_PIC_ID)
  if WorldQuestionUtils.IsCurrentPlayerCanViewQuestion() then
    require("Main.WorldQuestion.ui.WorldQuestionPanel").Instance():ShowWorldQuestion(string.format(textRes.WorldQuestion[18], question))
  end
end
def.static("table").OnCorrectAnswer = function(p)
  local awardStr = WorldQuestionUtils.FormatChatAwardInfo(p.items)
  local mainMsg = string.format(textRes.WorldQuestion[7], p.roleName, p.rank, awardStr)
  local chatMsg = string.format(textRes.WorldQuestion[18], p.roleName, p.rank, awardStr)
  ChatModule.Instance():SendWroldQuestionNotice(textRes.WorldQuestion[1], mainMsg, textRes.WorldQuestion[2], chatMsg, constant.WorldQuestionConsts.MASTER_PIC_ID, false)
end
def.static("table").OnSQuestionIsOver = function(p)
  local hasWinner = #p.nbAwardInfo > 0
  if hasWinner then
    WorldQuestionModule.PublishWorldQuestionResult(p)
  else
    WorldQuestionModule.PublishWorldQuestionFailResult()
  end
end
def.static("table").PublishWorldQuestionResult = function(p)
  local nbAwardInfo = p.nbAwardInfo
  if nbAwardInfo ~= nil and #nbAwardInfo > 0 then
    local awardPlayers = {}
    for i = 1, #nbAwardInfo do
      local awardInfo = nbAwardInfo[i]
      table.insert(awardPlayers, awardInfo.roleName)
    end
    local playerStr = table.concat(awardPlayers, "\227\128\129")
    local playerNum = #awardPlayers
    local isRandomAwardOpen = _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_WORLD_QUESTION_RANDOM_AWARD)
    local annoumceFmt = textRes.WorldQuestion[8]
    local selfFmt = textRes.WorldQuestion[9]
    local worldFmt = textRes.WorldQuestion[10]
    if isRandomAwardOpen then
      annoumceFmt = textRes.WorldQuestion[23]
      selfFmt = textRes.WorldQuestion[24]
      worldFmt = textRes.WorldQuestion[25]
    end
    local announceStr = string.format(annoumceFmt, playerStr, playerNum, constant.WorldQuestionConsts.NORMAL_AWARD_ROLE_NUM)
    local selfStr = string.format(selfFmt, playerStr, playerNum, constant.WorldQuestionConsts.NORMAL_AWARD_ROLE_NUM)
    local worldStr = string.format(worldFmt, playerStr, playerNum, constant.WorldQuestionConsts.NORMAL_AWARD_ROLE_NUM)
    require("GUI.AnnouncementTip").AnnounceWithDuration(announceStr, constant.WorldQuestionConsts.BULLETIN_TIME_AFT_RS)
    ChatModule.Instance():SendWroldQuestionNotice("", worldStr, textRes.WorldQuestion[2], selfStr, constant.WorldQuestionConsts.MASTER_PIC_ID, true)
    if WorldQuestionUtils.IsCurrentPlayerCanViewQuestion() then
      local firstPlayerName = nbAwardInfo[1].roleName
      local message = ""
      if not isRandomAwardOpen then
        if playerNum > 1 then
          message = string.format(textRes.WorldQuestion[21], firstPlayerName, playerNum)
        else
          message = string.format(textRes.WorldQuestion[22], firstPlayerName)
        end
      else
        message = textRes.WorldQuestion[26]
      end
      require("Main.WorldQuestion.ui.WorldQuestionPanel").Instance():ShowWorldQuestionResult(message)
    end
  end
  local normalAwardInfo = p.normalAwardInfo
  if normalAwardInfo ~= nil then
    for i = 1, #normalAwardInfo do
      local announceStr = WorldQuestionUtils.FormatAnnounceAward(textRes.WorldQuestion[15], normalAwardInfo[i])
      require("GUI.AnnouncementTip").AnnounceWithDuration(announceStr, constant.WorldQuestionConsts.BULLETIN_TIME_AFT_RS)
      local mainMsg = WorldQuestionUtils.FormatChatAward(textRes.WorldQuestion[16], normalAwardInfo[i])
      local chatMsg = WorldQuestionUtils.FormatChatAward(textRes.WorldQuestion[17], normalAwardInfo[i])
      ChatModule.Instance():SendWroldQuestionNotice("", mainMsg, textRes.WorldQuestion[2], chatMsg, constant.WorldQuestionConsts.MASTER_PIC_ID, true)
    end
  end
end
def.static().PublishWorldQuestionFailResult = function()
  require("GUI.AnnouncementTip").AnnounceWithDuration(textRes.WorldQuestion[12], constant.WorldQuestionConsts.BULLETIN_TIME_AFT_RS)
  ChatModule.Instance():SendWroldQuestionNotice("", textRes.WorldQuestion[13], textRes.WorldQuestion[2], textRes.WorldQuestion[14], constant.WorldQuestionConsts.MASTER_PIC_ID, true)
  if WorldQuestionUtils.IsCurrentPlayerCanViewQuestion() then
    require("Main.WorldQuestion.ui.WorldQuestionPanel").Instance():ShowWorldQuestionResult(textRes.WorldQuestion[14])
  end
end
WorldQuestionModule.Commit()
return WorldQuestionModule
