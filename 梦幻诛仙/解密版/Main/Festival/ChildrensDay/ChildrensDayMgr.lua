local Lplus = require("Lplus")
local ChildrensDayMgr = Lplus.Class("ChildrensDayMgr")
local def = ChildrensDayMgr.define
local instance
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityInterface = require("Main.activity.ActivityInterface")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local ChildrensDayUtils = require("Main.Festival.ChildrensDay.ChildrensDayUtils")
local TeamData = require("Main.Team.TeamData")
local DrawAndGuessConst = require("netio.protocol.mzm.gsp.drawandguess.DrawAndGuessConst")
local G_actId = 0
local G_sessionId
local G_bIsReconn = true
local G_linesInfo, G_chatInfo
local G_operaId = -1
local G_Timer = 0
local G_FakeRcvTimer = 0
local G_restoreChatTimer = 0
local ENUM_DECISION = {
  AGREE = DrawAndGuessConst.AGREE,
  DISAGREE = DrawAndGuessConst.REFUSE
}
local ENUM_IS_RIGHT = {
  RIGHT = DrawAndGuessConst.RIGHT,
  WRONG = DrawAndGuessConst.WRONG
}
def.const("number").Z_VAL = 0
def.static("=>", ChildrensDayMgr).Instance = function()
  if instance == nil then
    instance = ChildrensDayMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SApplyJoinDrawAndGuessSuccessRep", ChildrensDayMgr.OnAttenActSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SApplyJoinDrawAndGuessFailRep", ChildrensDayMgr.OnAttenActFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SNotifyDrawAndGuessInvite", ChildrensDayMgr.OnSNotifyAttendGame)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SAgreeOrRefuseDrawAndGuessSuccessRep", ChildrensDayMgr.OnSAttendActDecisionSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SAgreeOrRefuseDrawAndGuessFailRep", ChildrensDayMgr.OnSAttendActDecisionFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SNotifyAgreeOrRefuseDrawAndGuess", ChildrensDayMgr.OnSSTeamDecisions)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SSynDrawAndGuessQuestionInfo", ChildrensDayMgr.OnSSQuestionInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SAnswerDrawAndGuessQuestionSuccessRep", ChildrensDayMgr.OnSendAnswerSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SAnswerDrawAndGuessQuestionFailRep", ChildrensDayMgr.OnSendAnswerFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SNotifyDrawAndGuessAnswer", ChildrensDayMgr.OnSSMembersAnswers)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SSynRoleGetJifenInfoList", ChildrensDayMgr.OnSSMembersIntegrals)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SReportLineInfoSuccessRep", ChildrensDayMgr.OnSReportLineInfoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SReportLineInfoFailRep", ChildrensDayMgr.OnSReportLineInfoFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SNotifyDrawLineInfo", ChildrensDayMgr.OnSSDrawLineInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SAppendLineInfoSuccessRep", ChildrensDayMgr.OnSAppendLineSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SAppendLineInfoFailRep", ChildrensDayMgr.OnSAppendLineFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SNotifyAppendLineInfo", ChildrensDayMgr.OnSSAppendLineInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SSynAnswerDrawAndGuessFinished", ChildrensDayMgr.OnRoundFinish)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SSynAnswerInfoList", ChildrensDayMgr.OnSSHistoryAnswersList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SClearLineInfoFailRep", ChildrensDayMgr.OnSClearCanvasFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SClearLineInfoSuccessRep", ChildrensDayMgr.OnSClearCanvasSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SNotifyClearLineInfo", ChildrensDayMgr.OnSClearCanvas)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SSynDrawLineInfoList", ChildrensDayMgr.OnSSHistoryLineInfoList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawandguess.SSynDrawAndGuessNoReward", ChildrensDayMgr.OnSSynDrawAndGuessNoReward)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, ChildrensDayMgr.OnFeatureInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ChildrensDayMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, ChildrensDayMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, ChildrensDayMgr.OnNPCService)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ChildrensDayMgr.OnLeaveWorld)
end
local G_bFeatureOpened = false
def.static("=>", "boolean").IsFeatureOpen = function()
  return G_bFeatureOpened
end
def.static("boolean").SetFeatureOpen = function(bOpened)
  G_bFeatureOpened = bOpened
end
def.static("number").SetActId = function(actId)
  G_actId = actId
end
def.static("=>", "number").GetActId = function()
  if G_actId == 0 then
    G_actId = ChildrensDayUtils.GetActIdByModuleId(Feature.TYPE_DRAW_AND_GUESS) or 0
  end
  return G_actId
end
def.static("userdata").SetSessionId = function(session)
  G_sessionId = session
end
def.static("=>", "userdata").GetSessionId = function()
  return G_sessionId
end
def.static("boolean").UpdateActivityInterface = function(bOpened)
  local activityInterface = ActivityInterface.Instance()
  local actId = ChildrensDayMgr.GetActId()
  if bOpened then
    activityInterface:removeCustomCloseActivity(actId)
  else
    activityInterface:addCustomCloseActivity(actId)
  end
end
def.static("userdata", "userdata").ShowAsk = function(timestamp, sessionId)
  local roles, leaderId = ChildrensDayMgr.GetMemberInfos()
  local tmpRoles = {}
  if roles ~= nil then
    for _, roleInfo in pairs(roles) do
      if roleInfo.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL then
        table.insert(tmpRoles, roleInfo)
      end
    end
  end
  roles = tmpRoles
  local desc = ""
  if leaderId == require("Main.Hero.HeroModule").Instance().roleId then
    desc = textRes.Festival.ChildrensDay[4]
  else
    desc = textRes.Festival.ChildrensDay[5]
  end
  local desc2 = textRes.Festival.ChildrensDay[6]
  local title = ""
  local UIChildrensDayAsk = require("Main.Festival.ChildrensDay.ui.UIChildrensDayAsk")
  local actCfg = ChildrensDayUtils.GetGameRulesByActId(ChildrensDayMgr.GetActId(), true)
  local svrTime = _G.GetServerTime()
  ChildrensDayMgr.SetIsReconnect(false)
  warn("svrTime = " .. svrTime, " timeStamp = " .. Int64.ToNumber(timestamp))
  UIChildrensDayAsk.SetClickAgreeCallback(ChildrensDayMgr.ClickAgreeCallback)
  UIChildrensDayAsk.SetClickDisagreeCallback(ChildrensDayMgr.ClickDisAgreeCallback)
  UIChildrensDayAsk.SetWaitTime(actCfg.prepareTime or 30)
  UIChildrensDayAsk.ShowAsk(title, desc, desc2, roles, leaderId, 0)
end
def.static("=>", "table", "userdata").GetMemberInfos = function()
  local roles = {}
  local leaderId = require("Main.Hero.HeroModule").Instance():GetHeroProp().id
  local members = TeamData.Instance():GetAllTeamMembers()
  for k, v in pairs(members) do
    if k == 1 then
      leaderId = v.roleid
    end
    local role = {}
    role.roleName = v.name
    role.occupation = v.menpai
    role.gender = v.gender
    role.roleid = v.roleid
    role.avatarId = v.avatarId
    role.level = v.level
    role.status = v.status
    role.avatarFrameId = v.avatarFrameid
    table.insert(roles, role)
  end
  return roles, leaderId
end
def.static("table", "=>", "table").TransArr2Tbl = function(roles)
  local retData = {}
  for i = 1, #roles do
    local role = roles[i]
    retData[role.roleid:tostring()] = role
  end
  return retData
end
local G_decision = 0
def.static("number").SetDecision = function(code)
  G_decision = code
end
def.static("=>", "number").GetDecision = function()
  return G_decision
end
def.static("=>", "table").GetPenCfg = function()
  return ChildrensDayUtils.GetPenCfgByActId(ChildrensDayMgr.GetActId())
end
def.static("table", "table").OnActivityTodo = function(p, c)
  if not ChildrensDayMgr.IsFeatureOpen() then
    return
  end
  local actId = ChildrensDayMgr.GetActId()
  if p[1] ~= actId then
    return
  end
  local gameCfg = ChildrensDayUtils.GetGameRulesByActId(actId, false)
  local npc_id = gameCfg.npcId
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npc_id})
end
def.static("table", "table").OnNPCService = function(p, c)
  if not ChildrensDayMgr.IsFeatureOpen() then
    return
  end
  local srvcId, npc_id = p[1], p[2]
  local actId = ChildrensDayMgr.GetActId()
  local gameCfg = ChildrensDayUtils.GetGameRulesByActId(actId, false)
  local npc_id, srvc_id = gameCfg.npcId, gameCfg.npcServiceId
  if srvc_id ~= srvcId then
    return
  end
  local teamData = TeamData.Instance()
  if not teamData:HasTeam() then
    Toast(textRes.Festival.ChildrensDay[3])
    return
  end
  if not teamData:MeIsCaptain() then
    Toast(textRes.Festival.ChildrensDay[1])
    return
  end
  local teamMemNum = 0
  local roles = ChildrensDayMgr.GetMemberInfos()
  for _, v in pairs(roles) do
    if v.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL then
      teamMemNum = teamMemNum + 1
    end
  end
  if teamMemNum < gameCfg.minTeamMembersNum or teamMemNum > gameCfg.maxTeamMembersNum then
    Toast(textRes.Festival.ChildrensDay[2]:format(gameCfg.minTeamMembersNum))
    return
  end
  ChildrensDayMgr.SendAttendGameReq(actId, npc_id)
end
def.static("table", "table").OnFeatureInit = function(p, c)
  local allActCfg = ChildrensDayUtils.GetAllActIds()
  if allActCfg == nil then
    return
  end
  for feature, actId in pairs(allActCfg) do
    local featureOpenModule = FeatureOpenListModule.Instance()
    local bFeatureOpen = featureOpenModule:CheckFeatureOpen(feature)
    ChildrensDayMgr.SetActId(actId)
    ChildrensDayMgr.SetFeatureOpen(bFeatureOpen)
    ChildrensDayMgr.UpdateActivityInterface(bFeatureOpen)
  end
end
def.static("table", "table").OnFeatureOpenChange = function(p, c)
  local actId = ChildrensDayUtils.GetActIdByModuleId(p.feature)
  if actId ~= 0 then
    ChildrensDayMgr.SetActId(actId)
    local featureOpenModule = FeatureOpenListModule.Instance()
    local bFeatureOpen = featureOpenModule:CheckFeatureOpen(p.feature)
    ChildrensDayMgr.SetFeatureOpen(bFeatureOpen)
    ChildrensDayMgr.UpdateActivityInterface(bFeatureOpen)
    local gameCfg = ChildrensDayUtils.GetGameRulesByActId(actId, false)
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
      npcid = gameCfg.npcId,
      show = bFeatureOpen
    })
  end
end
def.static().ClickAgreeCallback = function()
  ChildrensDayMgr.SetIsReconnect(false)
  warn(">>>send sessionId = " .. Int64.ToNumber(ChildrensDayMgr.GetSessionId()))
  ChildrensDayMgr.SetDecision(ENUM_DECISION.AGREE)
  ChildrensDayMgr.SendAttendGameDecisionReq(ENUM_DECISION.AGREE, ChildrensDayMgr.GetSessionId())
end
def.static().ClickDisAgreeCallback = function()
  ChildrensDayMgr.SetIsReconnect(false)
  ChildrensDayMgr.SetDecision(ENUM_DECISION.DISAGREE)
  ChildrensDayMgr.SendAttendGameDecisionReq(ENUM_DECISION.DISAGREE, ChildrensDayMgr.GetSessionId())
  local UIChildrensDayAsk = require("Main.Festival.ChildrensDay.ui.UIChildrensDayAsk")
  UIChildrensDayAsk.CloseAsk()
end
def.static("table", "table").OnLeaveWorld = function(p, c)
  ChildrensDayMgr.SetIsReconnect(true)
  _G.GameUtil.RemoveGlobalTimer(G_Timer)
  G_Timer = 0
  _G.GameUtil.RemoveGlobalTimer(G_FakeRcvTimer)
  G_FakeRcvTimer = 0
  _G.GameUtil.RemoveGlobalTimer(G_restoreChatTimer)
  G_restoreChatTimer = 0
  Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.CLEAR_CANVAS, nil)
  G_chatInfo = nil
  G_linesInfo = nil
  G_operaId = -1
end
def.static("=>", "boolean").IsReconnect = function()
  return G_bIsReconn
end
def.static("boolean").SetIsReconnect = function(b)
  G_bIsReconn = b
end
def.static("number", "number").SendAttendGameReq = function(actId, npcId)
  warn(">>>>Send CApplyJoinDrawAndGuessReq<<<<")
  local p = require("netio.protocol.mzm.gsp.drawandguess.CApplyJoinDrawAndGuessReq").new(actId, npcId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnAttenActSuccess = function(p)
  local timestamp = p.timeStamp or 0
  local sessionId = p.sessionId or 0
  ChildrensDayMgr.ShowAsk(timestamp, sessionId)
end
def.static("table").OnAttenActFailed = function(p)
  if p.error_code == -1 then
    warn(">>>>ERROR_SYSTEM<<<<")
  elseif p.error_code == -2 then
    warn(">>>>ERROR_USERID<<<<")
  elseif p.error_code == -3 then
    warn(">>>>ERROR_CFG<<<<")
  elseif p.error_code == -4 then
    warn(">>>>ERROR_PARAM<<<<")
  elseif p.error_code == -5 then
    warn(">>>>ERROR_NPC_SERVER<<<<")
  elseif p.error_code == -6 then
    warn(">>>>ERROR_MEMBER_IN_DRAW_AND_GUESS<<<<")
  elseif p.error_code == -7 then
    warn(">>>>ERROR_TEAM_MEMBER_ERROR<<<<")
  elseif p.error_code == -8 then
    warn(">>>>ERROR_CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.error_code == -9 then
    warn(">>>>ERROR_NO_TEAM<<<<")
  elseif p.error_code == -10 then
    warn(">>>>ERROR_NOT_TEAM_LEADER<<<<")
  end
end
def.static("table").OnSNotifyAttendGame = function(p)
  local timestamp = p.timeStamp or 0
  local sessionId = p.sessionId or 0
  ChildrensDayMgr.SetSessionId(sessionId)
  ChildrensDayMgr.ShowAsk(timestamp, sessionId)
end
def.static("number", "userdata").SendAttendGameDecisionReq = function(opera, sessionId)
  warn(">>>>Send CAgreeOrRefuseDrawAndGuessReq<<<<")
  local p = require("netio.protocol.mzm.gsp.drawandguess.CAgreeOrRefuseDrawAndGuessReq").new(opera, sessionId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSAttendActDecisionSuccess = function(p)
  if ChildrensDayMgr.GetDecision() == ENUM_DECISION.DISAGREE then
    return
  end
  local memRoleId = require("Main.Hero.HeroModule").Instance():GetHeroProp().id
  local UIChildrensDayAsk = require("Main.Festival.ChildrensDay.ui.UIChildrensDayAsk")
  local dlg = UIChildrensDayAsk.Instance()
  if dlg:IsLoaded() then
    dlg:SetRoleReady(memRoleId)
  end
end
def.static("table").OnSAttendActDecisionFailed = function(p)
  if p.error_code == -1 then
    warn(">>>>ERROR_SYSTEM<<<<")
  elseif p.error_code == -2 then
    warn(">>>>ERROR_USERID<<<<")
  elseif p.error_code == -3 then
    warn(">>>>ERROR_CFG<<<<")
  elseif p.error_code == -4 then
    warn(">>>>ERROR_MEMBER_IN_DRAW_AND_GUESS<<<<")
  elseif p.error_code == -5 then
    warn(">>>>ERROR_LEADER_CANNOT_CHOOSE<<<<")
  elseif p.error_code == -6 then
    warn(">>>>ERROR_CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.error_code == -7 then
    warn(">>>>ERROR_NOT_IN_TEAM<<<<")
  elseif p.error_code == -8 then
    warn(">>>>ERROR_TIME_OUT<<<<")
  elseif p.error_code == -9 then
    warn(">>>>ERROR_CHOOSED_ALREADY<<<<")
  end
end
def.static("table").OnSSTeamDecisions = function(p)
  warn(">>>>rcv OnSSTeamDecisions")
  local memRoleId = p.member_roleId
  local opera = p.operator
  local UIChildrensDayAsk = require("Main.Festival.ChildrensDay.ui.UIChildrensDayAsk")
  local dlg = UIChildrensDayAsk.Instance()
  if opera == ENUM_DECISION.AGREE then
    if dlg:IsLoaded() then
      dlg:SetRoleReady(memRoleId)
    end
  else
    local memsInfo = ChildrensDayMgr.GetMemberInfos()
    for i = 1, #memsInfo do
      local roleInfo = memsInfo[i]
      if roleInfo.roleid == memRoleId then
        Toast(textRes.Festival.ChildrensDay[21]:format(roleInfo.roleName))
        break
      end
    end
    UIChildrensDayAsk.CloseAsk()
  end
end
def.static("table").OnSSQuestionInfo = function(p)
  warn(">>rcv OnSSQuestionInfo")
  local UIChildrensDayAsk = require("Main.Festival.ChildrensDay.ui.UIChildrensDayAsk")
  UIChildrensDayAsk.CloseAsk()
  local UIScore = require("Main.Festival.ChildrensDay.ui.UIScores")
  UIScore.Instance():HidePanel()
  local UIChildrensDay = require("Main.Festival.ChildrensDay.ui.UIChildrensDay")
  local uiMainDlg = UIChildrensDay.Instance()
  local drawerRoleId = p.drawerId
  local questionCfgId = p.questionCfgId
  local timestamp = p.timeStamp
  local sessionId = p.sessionId
  local tblMemIntegral = p.jifen_list
  ChildrensDayMgr.SetSessionId(sessionId)
  ChildrensDayMgr.SetIsReconnect(p.sendType == DrawAndGuessConst.LOGIN)
  local roles
  if uiMainDlg:IsLoaded() then
    roles = uiMainDlg._roles
  else
    roles = ChildrensDayMgr.GetMemberInfos()
    local tblRoles = ChildrensDayMgr.TransArr2Tbl(roles)
    local tmpRoles = {}
    for i = 1, #p.roleId_list do
      local roleInfo = tblRoles[p.roleId_list[i]:tostring()]
      if roleInfo ~= nil then
        table.insert(tmpRoles, roleInfo)
      end
    end
    roles = tmpRoles
  end
  local tblRoles = ChildrensDayMgr.TransArr2Tbl(roles)
  if tblMemIntegral ~= nil then
    for _, scoreInfo in pairs(tblMemIntegral) do
      local roleInfo = tblRoles[scoreInfo.member_roleId:tostring()]
      if roleInfo ~= nil and roleInfo.roleid == scoreInfo.member_roleId then
        roleInfo.integral = scoreInfo.jifen
      end
    end
  end
  for _, roleInfo in pairs(roles) do
    if drawerRoleId == roleInfo.roleid then
      roleInfo.state = 1
    else
      roleInfo.state = 0
    end
  end
  local UIAnswerTips = require("Main.Festival.ChildrensDay.ui.UIAnswerTips")
  local uiDlg = UIAnswerTips.Instance()
  uiDlg:HidePanel()
  uiMainDlg._timestamp = Int64.ToNumber(timestamp)
  if uiMainDlg:IsLoaded() then
    uiMainDlg:UpdateRoleState(drawerRoleId, questionCfgId, Int64.ToNumber(timestamp))
  else
    uiMainDlg:ShowPanel(roles, drawerRoleId, Int64.ToNumber(timestamp), questionCfgId)
  end
end
def.static("string").SendAnswerReq = function(strAnswer)
  warn(">>>>Send CAnswerDrawAndGuessQuestionReq<<<<")
  local sessionId = ChildrensDayMgr.GetSessionId()
  local p = require("netio.protocol.mzm.gsp.drawandguess.CAnswerDrawAndGuessQuestionReq").new(sessionId, strAnswer)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSendAnswerSuccess = function(p)
  local result = p.result == ENUM_IS_RIGHT.RIGHT
  Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SEND_MSG_SUCCESS, {result = result})
end
def.static("table").OnSendAnswerFailed = function(p)
  local param
  if p.error_code == -1 then
    warn(">>>>ERROR_SYSTEM<<<<")
  elseif p.error_code == -2 then
    warn(">>>>ERROR_USERID<<<<")
  elseif p.error_code == -3 then
    warn(">>>>ERROR_CFG<<<<")
  elseif p.error_code == -4 then
    warn(">>>>ERROR_DRAWER_CANNOT_ANSWER<<<<")
  elseif p.error_code == -5 then
    warn(">>>>ERROR_CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.error_code == -6 then
    warn(">>>>ERROR_NOT_IN_TEAM<<<<")
  elseif p.error_code == -7 then
    warn(">>>>ERROR_TIME_OUT<<<<")
  elseif p.error_code == -8 then
    warn(">>>>ERROR_ANSWER_ILLEGAL<<<<")
    Toast(textRes.Festival.ChildrensDay[30])
  elseif p.error_code == -9 then
    warn(">>>>ERROR_NOT_IN_GAME<<<<")
  elseif p.error_code == -10 then
    warn(">>>>ERROR_HAS_SENSITIVE_WORDS<<<<")
    p.state = 10
  elseif p.error_code == -11 then
    warn(">>>>ERROR_ANSWER_TOO_QUICK<<<<")
    p.state = 11
  end
  Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SEND_MSG_FAILED, p)
end
local AnswerInfo = require("netio.protocol.mzm.gsp.drawandguess.AnswerInfo")
def.static("table").OnSSMembersAnswers = function(p)
  warn(">>>>OnSSMembersAnswers")
  local answerInfo = p.answerInfo
  local memRoleId = answerInfo.member_roleId
  local strAnswer = answerInfo.answer
  local UIChildrensDay = require("Main.Festival.ChildrensDay.ui.UIChildrensDay")
  local uiMainDlg = UIChildrensDay.Instance()
  local result = ENUM_IS_RIGHT.RIGHT == answerInfo.result
  local p = {
    roleId = memRoleId,
    answer = strAnswer,
    result = result
  }
  if ChildrensDayMgr.IsReconnect() then
    G_chatInfo = G_chatInfo or {}
    table.insert(G_chatInfo.answerInfo_list, answerInfo)
  else
    Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.RCV_ANSWER, p)
  end
end
local StructIntegral = require("netio.protocol.mzm.gsp.drawandguess.RoleGetJifenInfo")
def.static("table").OnSSMembersIntegrals = function(p)
  warn("rcv OnSSMembersIntegrals ")
  local integral_lists = p.jifen_list
  local uiChildrensDay = require("Main.Festival.ChildrensDay.ui.UIChildrensDay").Instance()
  local roles
  if uiChildrensDay:IsLoaded() then
    roles = uiChildrensDay._roles
  else
    roles = ChildrensDayMgr.GetMemberInfos()
  end
  local tblRoles = ChildrensDayMgr.TransArr2Tbl(roles)
  for _, val in pairs(integral_lists) do
    local roleId = val.member_roleId
    local integral = val.jifen
    local roleInfo = tblRoles[roleId:tostring()]
    roleInfo.integral = integral
  end
  uiChildrensDay:HidePanel()
  local uiAnswerTips = require("Main.Festival.ChildrensDay.ui.UIAnswerTips").Instance()
  local rules = ChildrensDayUtils.GetGameRulesByActId(ChildrensDayMgr.GetActId(), true)
  if rules == nil then
    return
  end
  _G.GameUtil.AddGlobalTimer(rules.RoundEndShowTime, true, function()
    uiAnswerTips:HidePanel()
    local UIScore = require("Main.Festival.ChildrensDay.ui.UIScores")
    UIScore.Instance():ShowPanel(roles)
  end)
end
local PointInfo = require("netio.protocol.mzm.gsp.drawandguess.PointInfo")
def.static("number", "table", "number").SendLineInfoReq = function(lineIdx, line, widthidx)
  warn(">>>>Send CReportLineInfoReq<<<<")
  if #line.vertices < 2 then
    return
  end
  local vertices = {}
  for i = 1, #line.vertices do
    local vert = line.vertices[i]
    table.insert(vertices, PointInfo.new(vert.x, vert.y))
  end
  local p = require("netio.protocol.mzm.gsp.drawandguess.CReportLineInfoReq").new(ChildrensDayMgr.GetSessionId(), lineIdx, line.color, widthidx, vertices)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSReportLineInfoSuccess = function(p)
  Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SYN_LINEDATA_SUCCESS, nil)
end
def.static("table").OnSReportLineInfoFailed = function(p)
  if p.error_code == -1 then
    warn(">>>>ERROR_SYSTEM<<<<")
  elseif p.error_code == -2 then
    warn(">>>>ERROR_USERID<<<<")
  elseif p.error_code == -3 then
    warn(">>>>ERROR_CFG<<<<")
  elseif p.error_code == -4 then
    warn(">>>>ERROR_ANSWERER_CANNOT_DRAW<<<<")
  elseif p.error_code == -5 then
    warn(">>>>ERROR_CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.error_code == -6 then
    warn(">>>>ERROR_NOT_IN_TEAM<<<<")
  elseif p.error_code == -7 then
    warn(">>>>ERROR_TIME_OUT<<<<")
  elseif p.error_code == -8 then
    warn(">>>>ERROR_POINTS_ILLEGAL<<<<")
    Toast(textRes.Festival.ChildrensDay[29])
  elseif p.error_code == -9 then
    warn(">>>>ERROR_NOT_IN_GAME<<<<")
  end
  Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.STOP_SYN_LINEDATA, nil)
end
local DrawLineInfo = require("netio.protocol.mzm.gsp.drawandguess.DrawLineInfo")
local G_QueueLineInfo
local ENUM_RCVLINE_TYPE = {
  NEW_LINE = 1,
  APPEND = 2,
  CLEAR_CANVAS = 3
}
def.static("table").OnSSDrawLineInfo = function(p)
  warn("rcv OnSSDrawLineInfo")
  local verts = {}
  local line = p.drawLineInfo
  for i = 1, #line.point_list do
    local vert = line.point_list[i]
    table.insert(verts, {
      x = vert.point_x,
      y = vert.point_y,
      z = ChildrensDayMgr.Z_VAL
    })
  end
  warn(" lineIdx = " .. line.line_id, " colorIdx = " .. line.color)
  local line = {
    lineIdx = line.line_id,
    colorIdx = line.color,
    width = line.size,
    vertices = verts,
    action_id = line.action_id
  }
  if ChildrensDayMgr.IsReconnect() then
    G_QueueLineInfo = G_QueueLineInfo or {}
    table.insert(G_QueueLineInfo, {
      data = line,
      type = ENUM_RCVLINE_TYPE.NEW_LINE
    })
  else
    Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.RCV_LINEDATA, line)
  end
end
def.static("number", "table", "number", "number").SendAppendLineReq = function(lineIdx, vertices, iStart, iEnd)
  warn(">>>>Send CAppendLineInfoReq<<<<")
  local verts = {}
  for i = iStart, iEnd do
    local vert = vertices[i]
    table.insert(verts, PointInfo.new(vert.x, vert.y))
  end
  local p = require("netio.protocol.mzm.gsp.drawandguess.CAppendLineInfoReq").new(ChildrensDayMgr.GetSessionId(), lineIdx, verts)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSAppendLineSuccess = function(p)
  Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SYN_LINEDATA_SUCCESS, nil)
end
def.static("table").OnSAppendLineFailed = function(p)
  if p.error_code == -1 then
    warn(">>>>ERROR_SYSTEM<<<<")
  elseif p.error_code == -2 then
    warn(">>>>ERROR_USERID<<<<")
  elseif p.error_code == -3 then
    warn(">>>>ERROR_CFG<<<<")
  elseif p.error_code == -4 then
    warn(">>>>ERROR_ANSWERER_CANNOT_DRAW<<<<")
  elseif p.error_code == -5 then
    warn(">>>>ERROR_CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.error_code == -6 then
    warn(">>>>ERROR_NOT_IN_TEAM<<<<")
  elseif p.error_code == -7 then
    warn(">>>>ERROR_TIME_OUT<<<<")
  elseif p.error_code == -8 then
    warn(">>>>ERROR_POINTS_ILLEGAL<<<<")
    Toast(textRes.Festival.ChildrensDay[29])
  elseif p.error_code == -9 then
    warn(">>>>ERROR_NOT_IN_GAME<<<<")
  end
  Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.STOP_SYN_LINEDATA, nil)
end
def.static("table").OnSSAppendLineInfo = function(p)
  warn("rcv OnSSAppendLineInfo")
  local verts = {}
  for i = 1, #p.point_list do
    local vert = p.point_list[i]
    table.insert(verts, {
      x = vert.point_x,
      y = vert.point_y,
      z = ChildrensDayMgr.Z_VAL
    })
  end
  local p = {
    lineIdx = p.line_id,
    vertices = verts,
    action_id = p.action_id
  }
  if ChildrensDayMgr.IsReconnect() then
    G_QueueLineInfo = G_QueueLineInfo or {}
    table.insert(G_QueueLineInfo, {
      data = p,
      type = ENUM_RCVLINE_TYPE.APPEND
    })
  else
    Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.RCV_LINE_APPEND, p)
  end
end
def.static().SendEmptyCanvasReq = function()
  warn(">>>Send CClearLineInfoReq")
  local p = require("netio.protocol.mzm.gsp.drawandguess.CClearLineInfoReq").new(ChildrensDayMgr.GetSessionId())
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSClearCanvasSuccess = function(p)
  Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.CLEAR_CANVAS, nil)
end
def.static("table").OnSClearCanvasFailed = function(p)
  if p.error_code == -1 then
    warn(">>>>ERROR_SYSTEM")
  elseif p.error_code == -2 then
    warn(">>>>ERROR_USERID")
  elseif p.error_code == -3 then
    warn(">>>>ERROR_CFG")
  elseif p.error_code == -4 then
    warn(">>>>ERROR_ANSWERER_CANNOT_CLEAR")
  elseif p.error_code == -5 then
    warn(">>>>ERROR_CAN_NOT_JOIN_ACTIVITY")
  elseif p.error_code == -6 then
    warn(">>>>ERROR_NOT_IN_TEAM")
  elseif p.error_code == -7 then
    warn(">>>>ERROR_TIME_OUT")
  elseif p.error_code == -8 then
    warn(">>>>ERROR_NOT_IN_GAME")
  end
end
def.static("table").OnSClearCanvas = function(p)
  if ChildrensDayMgr.IsReconnect() then
    G_QueueLineInfo = G_QueueLineInfo or {}
    table.insert(G_QueueLineInfo, {
      data = p,
      type = ENUM_RCVLINE_TYPE.CLEAR_CANVAS
    })
  else
    Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.CLEAR_CANVAS, nil)
  end
end
def.static("table").OnRoundFinish = function(p)
  if ChildrensDayMgr.IsReconnect() then
    ChildrensDayMgr.SetIsReconnect(false)
  end
  Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.ROUND_FINISH, {
    p.rightAnswer
  })
  Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.CLEAR_CANVAS, nil)
end
def.static().SendPullHistoryInfoReq = function()
  ChildrensDayMgr.FakeRestoreLineInfo()
  ChildrensDayMgr.FakeRestoreChatInfo()
end
def.static("table").OnSSHistoryAnswersList = function(p)
  warn(">>>>rcv history answer")
  G_chatInfo = p or {}
  ChildrensDayMgr.NotityUI()
end
def.static("table").OnSSHistoryLineInfoList = function(p)
  warn(">>>>rcv history line info")
  G_linesInfo = p or {}
  ChildrensDayMgr.NotityUI()
end
def.static().NotityUI = function()
  if G_chatInfo ~= nil and G_linesInfo ~= nil then
    local UIChildrensDay = require("Main.Festival.ChildrensDay.ui.UIChildrensDay")
    local uiMainDlg = UIChildrensDay.Instance()
    uiMainDlg:ToShow()
  end
end
def.static().FakeRestoreLineInfo = function()
  local p = G_linesInfo
  local curLineId = 1
  local lineInfoList = p.drawLineInfo_list or {}
  local totalLineSize = #lineInfoList
  local numVertices = 0
  warn("reconnect line number = " .. totalLineSize)
  G_Timer = _G.GameUtil.AddGlobalTimer(0.025, false, function()
    if curLineId > totalLineSize then
      _G.GameUtil.RemoveGlobalTimer(G_Timer)
      G_Timer = 0
      G_linesInfo = nil
      local param = {}
      param.lineIdx = totalLineSize
      param.vIdxStart = 1
      param.vIdxEnd = numVertices
      if totalLineSize == 0 then
        Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SYN_HISTORY_LINEDATA_DONE, nil)
      else
        Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SYN_HISTORY_LINEDATA_DONE, param)
      end
      ChildrensDayMgr.FakeRcvLineData()
    else
      local verts = {}
      local line = p.drawLineInfo_list[curLineId]
      for i = 1, #line.point_list do
        local vert = line.point_list[i]
        table.insert(verts, {
          x = vert.point_x,
          y = vert.point_y,
          z = ChildrensDayMgr.Z_VAL
        })
      end
      numVertices = #verts
      warn("===>reconnect lineIdx = " .. line.line_id, " colorIdx = " .. tonumber(line.color), " vertices = " .. numVertices)
      local param = {
        lineIdx = line.line_id,
        colorIdx = line.color,
        width = line.size,
        vertices = verts
      }
      Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.RCV_LINEDATA, param)
      curLineId = curLineId + 1
      if G_operaId == -1 then
        G_operaId = line.action_id
      elseif G_operaId < line.action_id then
        G_operaId = line.action_id
      end
    end
  end)
end
def.static().FakeRestoreChatInfo = function()
  if G_chatInfo == nil then
    return
  end
  G_restoreChatTimer = _G.GameUtil.AddGlobalTimer(0.025, false, function()
    if G_chatInfo == nil or G_chatInfo.answersList == nil or #G_chatInfo.answersList == 0 then
      _G.GameUtil.RemoveGlobalTimer(G_restoreChatTimer)
      G_restoreChatTimer = 0
      G_chatInfo = nil
      return
    end
    local UIChildrensDay = require("Main.Festival.ChildrensDay.ui.UIChildrensDay")
    local uiMainDlg = UIChildrensDay.Instance()
    local roles
    if uiMainDlg:IsLoaded() then
      roles = uiMainDlg._roles
    else
      roles = ChildrensDayMgr.GetMemberInfos()
    end
    local tblRoles = ChildrensDayMgr.TransArr2Tbl(roles)
    local answerInfo = answersList[1]
    table.remove(answersList, 1)
    local param = {}
    param.roleId = answerInfo.member_roleId
    param.answer = answerInfo.answer
    param.result = answerInfo.result == ENUM_IS_RIGHT.RIGHT
    warn("====>history answer.." .. param.answer)
    Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.RCV_ANSWER, param)
  end)
end
def.static().FakeRcvLineData = function()
  if G_QueueLineInfo == nil or #G_QueueLineInfo == 0 then
    ChildrensDayMgr.SetIsReconnect(false)
  else
    G_FakeRcvTimer = _G.GameUtil.AddGlobalTimer(0.025, false, function()
      if #G_QueueLineInfo == 0 or not ChildrensDayMgr.IsReconnect() then
        ChildrensDayMgr.SetIsReconnect(false)
        _G.GameUtil.RemoveGlobalTimer(G_FakeRcvTimer)
        G_FakeRcvTimer = 0
        return
      else
        local lineData = G_QueueLineInfo[1]
        table.remove(G_QueueLineInfo, 1)
        if lineData.type == ENUM_RCVLINE_TYPE.NEW_LINE then
          if lineData.data.action_id <= G_operaId then
            return
          else
            G_operaId = lineData.data.action_id
            Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.RCV_LINEDATA, lineData.data)
          end
        elseif lineData.type == ENUM_RCVLINE_TYPE.APPEND then
          if lineData.data.action_id <= G_operaId then
            return
          else
            G_operaId = lineData.data.action_id
            Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.RCV_LINE_APPEND, lineData.data)
          end
        elseif lineData.type == ENUM_RCVLINE_TYPE.CLEAR_CANVAS then
          G_operaId = -1
          Event.DispatchEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.CLEAR_CANVAS, nil)
        end
      end
    end)
  end
end
def.static("=>", "boolean").HasHistoryInfo = function()
  if G_chatInfo == nil and G_linesInfo == nil then
    return false
  end
  return true
end
def.static("table").OnSSynDrawAndGuessNoReward = function(p)
  Toast(textRes.Festival.ChildrensDay[28])
end
return ChildrensDayMgr.Commit()
