local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local BiYiLianZhiModule = Lplus.Extend(ModuleBase, "BiYiLianZhiModule")
local AnnouncementTip = require("GUI.AnnouncementTip")
local BiYiLianZhiUtils = require("Main.BiYiLianZhi.BiYiLianZhiUtils")
local CoupleDailyConst = require("netio.protocol.mzm.gsp.coupledaily.CoupleDailyConst")
local CoupleDailyNormalResult = require("netio.protocol.mzm.gsp.coupledaily.SCoupleDailyNormalResult")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local BiYiLianZhiData = require("Main.BiYiLianZhi.BiYiLianZhiData")
require("Main.module.ModuleId")
local def = BiYiLianZhiModule.define
local instance
def.field("table")._confirmDlg = nil
def.static("=>", BiYiLianZhiModule).Instance = function()
  if instance == nil then
    instance = BiYiLianZhiModule()
    instance.m_moduleId = ModuleId.BIYILIANZHI
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.coupledaily.SCoupleDailyNormalResult", BiYiLianZhiModule.OnCheckConditionResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.coupledaily.SGetCoupleDailyInfo", BiYiLianZhiModule.OnShowActivityTasks)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.coupledaily.SRefreshCoupleDailyInfo", BiYiLianZhiModule.OnRefreshCoupleDailyInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.coupledaily.SXinYouLingXiStart", BiYiLianZhiModule.OnStartXinYouLingXiTask)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.coupledaily.SAgreeOrRefuseXinYouLingXi", BiYiLianZhiModule.OnAgreeOrRefuseXinYouLingXi)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.coupledaily.SXinYouLingXiQuestionInfo", BiYiLianZhiModule.OnXinYouLingXiQuestionInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.coupledaily.SAnswerXinYouLingXiResult", BiYiLianZhiModule.OnAnswerXinYouLingXiResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.coupledaily.SCoupleDailyPinTuStart", BiYiLianZhiModule.OnCoupleDailyPinTuStart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.coupledaily.SAgreeOrRefusePinTu", BiYiLianZhiModule.OnAgreeOrRefusePinTu)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.coupledaily.SGetCoupleDailyAward", BiYiLianZhiModule.OnGetCoupleDailyAward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.coupledaily.SCloseCoupleDailyPanel", BiYiLianZhiModule.OnCloseCoupleDailyPanel)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SNewMemberJoinTeamBrd", BiYiLianZhiModule.OnTeamMemberChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SMemberStatusChangedBrd", BiYiLianZhiModule.OnTeamMemberChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SLeaveTeamBrd", BiYiLianZhiModule.OnTeamMemberChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SMemberReturnBrd", BiYiLianZhiModule.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, BiYiLianZhiModule.OnBiYiLianZhiService)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, BiYiLianZhiModule.OnActivityReset)
  ModuleBase.Init(self)
end
def.static("table", "table").OnBiYiLianZhiService = function(p1, p2)
  local npcId = p1[2]
  local serviceId = p1[1]
  local NPCServiceConst = require("Main.npc.NPCServiceConst")
  if constant.CoupleDailyActivityConst.NPC_SERVER_ID == serviceId then
    BiYiLianZhiModule.CheckBiYiLianZhiConditions()
  end
end
def.static().CheckBiYiLianZhiConditions = function(self)
  if not BiYiLianZhiUtils.IsCanDoCoupleActivity() then
    Toast(textRes.BiYiLianZhi[1])
    return
  end
  BiYiLianZhiModule.RequestOpenActivity()
end
def.static().RequestOpenActivity = function()
  local req = require("netio.protocol.mzm.gsp.coupledaily.CGetCoupleDailyInfo").new()
  gmodule.network.sendProtocol(req)
end
def.static("table").OnCheckConditionResult = function(p)
  if p.result == CoupleDailyNormalResult.ACTIVITY_DONE_REFORE then
    Toast(textRes.BiYiLianZhi[2])
  elseif p.result == CoupleDailyNormalResult.PARTNER_ACTIVITY_DONE_REFORE then
    Toast(string.format(textRes.BiYiLianZhi[3], p.args[1]))
  elseif p.result == CoupleDailyNormalResult.FIGHT_FAIL then
    Toast(textRes.BiYiLianZhi[16])
  elseif p.result == CoupleDailyNormalResult.PIN_TU_FAIL then
    Toast(textRes.BiYiLianZhi[15])
  end
end
def.static("table").OnShowActivityTasks = function(p)
  BiYiLianZhiData.Instance():SetReceivedAward(p.isAward == CoupleDailyConst.YES_AWARD)
  local tasks = BiYiLianZhiUtils.CombineTaskStatus(p.taskList, p.finishTaskList)
  local mainPanel = require("Main.BiYiLianZhi.ui.BiYiLianZhiMainPanel").Instance()
  mainPanel:ShowPlayPanel(tasks)
end
def.static("table").OnRefreshCoupleDailyInfo = function(p)
  local quizPanel = require("Main.BiYiLianZhi.ui.QuizPanel").Instance()
  if quizPanel:IsShow() then
    quizPanel:Close()
  end
  BiYiLianZhiData.Instance():SetReceivedAward(p.isAward == CoupleDailyConst.YES_AWARD)
  local tasks = BiYiLianZhiUtils.CombineTaskStatus(p.taskList, p.finishTaskList)
  local mainPanel = require("Main.BiYiLianZhi.ui.BiYiLianZhiMainPanel").Instance()
  if mainPanel:IsExistPanel() then
    mainPanel:UpdateTask(tasks)
  end
end
def.static("table").OnStartXinYouLingXiTask = function(p)
  BiYiLianZhiData.Instance():SetCurrentSession(p.sessionId)
  BiYiLianZhiModule.StartXinYouLingXiConfirm()
end
def.static().StartXinYouLingXiConfirm = function()
  local teamData = require("Main.Team.TeamData").Instance()
  if BiYiLianZhiUtils.IsCoupleActivitySponsor() then
    local quizPanel = require("Main.BiYiLianZhi.ui.QuizPanel").Instance()
    quizPanel:ShowQuizWatingPanel()
  else
    instance._confirmDlg = CommonConfirmDlg.ShowConfirmCoundDown("", textRes.BiYiLianZhi[4], textRes.BiYiLianZhi[5], textRes.BiYiLianZhi[6], 0, constant.CoupleDailyActivityConst.WAIT_COUPLE_QUESTION_CONFIRM_TIME, function(result, tag)
      local operator = result == 0 and CoupleDailyConst.REFUSE or CoupleDailyConst.AGREE
      BiYiLianZhiModule.HandleXinYouLingXiStartOperator(operator)
    end, nil)
  end
end
def.static("number").HandleXinYouLingXiStartOperator = function(operator)
  instance._confirmDlg = nil
  local req = require("netio.protocol.mzm.gsp.coupledaily.CAgreeOrRefuseXinYouLingXi").new(operator, BiYiLianZhiData.Instance():GetCurrentSession())
  gmodule.network.sendProtocol(req)
end
def.static("table").OnAgreeOrRefuseXinYouLingXi = function(p)
  if p.operator == CoupleDailyConst.REFUSE then
    Toast(string.format(textRes.BiYiLianZhi[8], p.memberRoleName))
    local quizPanel = require("Main.BiYiLianZhi.ui.QuizPanel").Instance()
    if quizPanel:IsShow() then
      quizPanel:Close()
    end
  end
end
def.static("table").OnXinYouLingXiQuestionInfo = function(p)
  if BiYiLianZhiUtils.IsCanDoCoupleActivity() then
    BiYiLianZhiData.Instance():SetCurrentSession(p.sessionId)
    local questionId = p.questionCfgId
    local quizPanel = require("Main.BiYiLianZhi.ui.QuizPanel").Instance()
    if quizPanel:IsShow() then
      quizPanel:ShowQuiz(questionId)
    else
      quizPanel:ShowQuizPanel(questionId)
    end
  end
end
def.static("table").OnAnswerXinYouLingXiResult = function(p)
  local quizPanel = require("Main.BiYiLianZhi.ui.QuizPanel").Instance()
  if quizPanel:IsShow() then
    local result = p.isMatch == CoupleDailyConst.YES_MATCH and true or false
    quizPanel:ShowAnswerResult(result)
  end
end
def.static("table").OnCoupleDailyPinTuStart = function(p)
  BiYiLianZhiData.Instance():SetCurrentSession(p.sessionId)
  if BiYiLianZhiUtils.IsCoupleActivitySponsor() then
    local FuqiWatingPanel = require("Main.BiYiLianZhi.ui.FuqiWaitingPanel")
    FuqiWatingPanel.ShowTip(textRes.BiYiLianZhi[7], constant.CoupleDailyActivityConst.WAIT_COUPLE_PINTU_CONFIRM_TIME)
  else
    instance._confirmDlg = CommonConfirmDlg.ShowConfirmCoundDown("", textRes.BiYiLianZhi[11], textRes.BiYiLianZhi[5], textRes.BiYiLianZhi[6], 0, constant.CoupleDailyActivityConst.WAIT_COUPLE_PINTU_CONFIRM_TIME, function(result, tag)
      local operator = result == 0 and CoupleDailyConst.REFUSE or CoupleDailyConst.AGREE
      BiYiLianZhiModule.HandlePinTuStartOperator(operator)
    end, nil)
  end
end
def.static("number").HandlePinTuStartOperator = function(operator)
  instance._confirmDlg = nil
  local req = require("netio.protocol.mzm.gsp.coupledaily.CAgreeOrRefusePinTu").new(operator, BiYiLianZhiData.Instance():GetCurrentSession())
  gmodule.network.sendProtocol(req)
end
def.static("table").OnAgreeOrRefusePinTu = function(p)
  if p.operator == CoupleDailyConst.REFUSE then
    Toast(string.format(textRes.BiYiLianZhi[8], p.memberRoleName))
  end
  local FuqiWatingPanel = require("Main.BiYiLianZhi.ui.FuqiWaitingPanel")
  FuqiWatingPanel.HideTip()
end
def.static("table").OnGetCoupleDailyAward = function(p)
  local mainPanel = require("Main.BiYiLianZhi.ui.BiYiLianZhiMainPanel").Instance()
  if mainPanel:IsShow() then
    mainPanel:OnReceiveAward()
  end
end
def.static("table").OnCloseCoupleDailyPanel = function(p)
  local mainPanel = require("Main.BiYiLianZhi.ui.BiYiLianZhiMainPanel").Instance()
  if mainPanel:IsShow() then
    mainPanel:Close()
  end
end
def.static("table", "table").OnActivityReset = function(params, context)
  local activityId = params[1]
  if activityId == constant.CoupleDailyActivityConst.COUPLE_DAILY_ACTIVITY_ID and BiYiLianZhiModule.CloseAllTask() then
    Toast(textRes.BiYiLianZhi[13])
  end
end
def.static("=>", "boolean").CloseAllTask = function()
  local hasActivity = false
  if instance._confirmDlg ~= nil then
    hasActivity = true
    instance._confirmDlg:DestroyPanel()
  end
  local FuqiWatingPanel = require("Main.BiYiLianZhi.ui.FuqiWaitingPanel")
  if FuqiWatingPanel._Instance():IsExistPanel() then
    hasActivity = true
    FuqiWatingPanel.HideTip()
  end
  local quizPanel = require("Main.BiYiLianZhi.ui.QuizPanel").Instance()
  if quizPanel:IsExistPanel() then
    hasActivity = true
    quizPanel:Close()
  end
  local mainPanel = require("Main.BiYiLianZhi.ui.BiYiLianZhiMainPanel").Instance()
  if mainPanel:IsExistPanel() then
    hasActivity = true
    mainPanel:Close()
  end
  return hasActivity
end
def.static("table").OnTeamMemberChanged = function(p)
  if BiYiLianZhiModule.CloseAllTask() then
    Toast(textRes.BiYiLianZhi[14])
  end
end
BiYiLianZhiModule.Commit()
return BiYiLianZhiModule
