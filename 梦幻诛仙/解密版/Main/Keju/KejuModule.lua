local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local KejuModule = Lplus.Extend(ModuleBase, "KejuModule")
require("Main.module.ModuleId")
local KejuConst = require("Main.Keju.KejuConst")
local KejuUtils = require("Main.Keju.KejuUtils")
local ExamChoiceDlg = require("Main.Keju.ui.ExamChoiceDlg")
local ExamDlg = require("Main.Keju.ui.ExamDlg")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local def = KejuModule.define
local instance
def.static("=>", KejuModule).Instance = function()
  if instance == nil then
    instance = KejuModule()
    instance.m_moduleId = ModuleId.KEJU
  end
  return instance
end
def.field("table").data = nil
def.override().Init = function(self)
  self.data = {}
  self.data[KejuConst.ExamType.XIANG_SHI] = {}
  self.data[KejuConst.ExamType.XIANG_SHI].enable = KejuConst.ExamStatus.NOTOPEN
  self.data[KejuConst.ExamType.HUI_SHI] = {}
  self.data[KejuConst.ExamType.HUI_SHI].enable = KejuConst.ExamStatus.NOTOPEN
  self.data[KejuConst.ExamType.DIAN_SHI] = {}
  self.data[KejuConst.ExamType.DIAN_SHI].enable = KejuConst.ExamStatus.NOTOPEN
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncKeJuZiGeReq", KejuModule.onSSyncKeJuZiGeReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SXiangShiQuestionRes", KejuModule.onSXiangShiQuestionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SAnswerXiangShiQuestionRes", KejuModule.onSAnswerXiangShiQuestionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncFinishXiangShi", KejuModule.onSSyncFinishXiangShi)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SGetHuiShiQuestionRes", KejuModule.onSGetHuiShiQuestionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SAnswerHuiShiQuestionRes", KejuModule.onSAnswerHuiShiQuestionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncFinishHuiShi", KejuModule.onSSyncFinishHuiShi)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SSyncDianShiQuestionRes", KejuModule.onSSyncDianShiQuestionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.question.SAnswerDianShiQuestionRes", KejuModule.onSAnswerDianShiQuestionRes)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, KejuModule.onMainUIReady)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, KejuModule.onRoleLvUp)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, KejuModule.onActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, KejuModule.onKejuService)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, KejuModule.onKejuEnd)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, KejuModule.OnActivityReset)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, KejuModule.OnActivityStart)
  ModuleBase.Init(self)
end
def.method().ShowKejuPanel = function(self)
  ExamChoiceDlg.ShowKeju(self.data)
end
def.method().GotoXiangShi = function(self)
  warn("GotoXiangShi~~~~~~")
  local npcId = KejuUtils.GetKejuCfg().xiangshiNPC
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
end
def.method().JoinXiangShi = function(self)
  local join = require("netio.protocol.mzm.gsp.question.CGetXiangShiQuestionReq").new()
  gmodule.network.sendProtocol(join)
end
def.method().GotoHuiShi = function(self)
  warn("GotoHuiShi~~~~~~")
  local npcId = KejuUtils.GetKejuCfg().huishiNPC
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
end
def.method().JoinHuiShi = function(self)
  if self.data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.NOTOPEN then
    Toast(textRes.Keju[30])
  elseif self.data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.DENY then
    Toast(textRes.Keju[18])
  elseif self.data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.OPEN then
    local join = require("netio.protocol.mzm.gsp.question.CGetHuiShiQuestionReq").new()
    gmodule.network.sendProtocol(join)
  end
end
def.method().GotoDianShi = function(self)
  warn("GotoDianShi~~~~~~")
  if not self:isInDianShiMap() then
    local npcId = KejuUtils.GetKejuCfg().dianshiEnterNPC
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
  else
    local npcId = KejuUtils.GetKejuCfg().dianshiNPC
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
  end
end
def.method().GotoDianShiMap = function(self)
  if not self:isInDianShiMap() then
    local join = require("netio.protocol.mzm.gsp.question.CJoinDianShiReq").new()
    gmodule.network.sendProtocol(join)
  else
    local npcId = KejuUtils.GetKejuCfg().dianshiNPC
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
  end
end
def.method().JoinDianShi = function(self)
  warn("JoinDianShi~~~~~~~~~~~~~~~~")
  local curTime = GetServerTime()
  local actStartTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(KejuUtils.GetKejuCfg().acticityId)
  local dianshiStartTime = 0
  if actStartTime then
    dianshiStartTime = actStartTime + KejuUtils.GetKejuCfg().xiangShiTime + KejuUtils.GetKejuCfg().huiShiTime + KejuUtils.GetKejuCfg().dianShiPrepareTime
  else
    warn("Bad Keju Time")
    return
  end
  if curTime >= dianshiStartTime then
    local join = require("netio.protocol.mzm.gsp.question.CGetDianShiQuestionInfo").new()
    gmodule.network.sendProtocol(join)
  else
    ExamDlg.ShowLeftTime(dianshiStartTime - curTime)
  end
end
def.method("number", "number", "number", "userdata").AnswerQuestion = function(self, type, questionId, answerIndex, session)
  local answer
  if type == KejuConst.ExamType.XIANG_SHI then
    answer = require("netio.protocol.mzm.gsp.question.CAnswerXiangShiQuestionReq").new(questionId, answerIndex, session)
  elseif type == KejuConst.ExamType.HUI_SHI then
    answer = require("netio.protocol.mzm.gsp.question.CAnswerHuiShiShiQuestionReq").new(questionId, answerIndex, session)
  elseif type == KejuConst.ExamType.DIAN_SHI then
    answer = require("netio.protocol.mzm.gsp.question.CAnswerDianShiShiQuestionReq").new(questionId, answerIndex, session)
  end
  if answer ~= nil then
    gmodule.network.sendProtocol(answer)
  end
end
def.static("table").onSSyncKeJuZiGeReq = function(p)
  local kejuState = p.keJuState
  for k, v in pairs(kejuState) do
    warn("onSSyncKeJuZiGeReq..", k, v.stateType, v.state)
    instance.data[v.stateType].enable = v.state
  end
  KejuModule.CheckExamPanelStatus()
end
def.static().CheckExamPanelStatus = function()
  if instance.data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.FINISH and ExamDlg.Instance().m_panel and ExamDlg.Instance().questionType == KejuConst.ExamType.XIANG_SHI then
    ExamDlg.Close()
    Toast(textRes.Keju[51])
  end
  if instance.data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.FINISH and ExamDlg.Instance().m_panel and ExamDlg.Instance().questionType == KejuConst.ExamType.HUI_SHI then
    ExamDlg.Close()
    Toast(textRes.Keju[52])
  end
  if instance.data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.FINISH and ExamDlg.Instance().m_panel and ExamDlg.Instance().questionType == KejuConst.ExamType.DIAN_SHI then
    ExamDlg.Close()
    Toast(textRes.Keju[53])
  end
end
def.static("table").onSXiangShiQuestionRes = function(p)
  local xiangshiData = instance.data[KejuConst.ExamType.XIANG_SHI]
  xiangshiData.enable = KejuConst.ExamStatus.OPEN
  local actStartTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(KejuUtils.GetKejuCfg().acticityId)
  if actStartTime then
    xiangshiData.endTime = actStartTime + KejuUtils.GetKejuCfg().xiangShiTime
  else
    warn("Bad Keju Time")
  end
  warn("==========", os.date("%X", xiangshiData.endTime), os.date("%X", GetServerTime()))
  xiangshiData.answerdNum = p.alreadyAnswer
  xiangshiData.totalNum = KejuUtils.GetKejuCfg().xiangShiNumber
  xiangshiData.rightNum = p.rightAnswer
  xiangshiData.questionId = p.questionId
  xiangshiData.shuffleSession = p.sessionid
  xiangshiData.sequence = p.answer_sequence
  if xiangshiData.questionId < 0 then
    Toast(textRes.Keju[25])
  else
    ExamDlg.ShowQuestion(KejuConst.ExamType.XIANG_SHI, xiangshiData)
  end
end
def.static("table").onSAnswerXiangShiQuestionRes = function(p)
  local xiangshiData = instance.data[KejuConst.ExamType.XIANG_SHI]
  local oldRightNum = xiangshiData.rightNum
  xiangshiData.answerdNum = p.alreadyAnswer
  xiangshiData.rightNum = p.rightAnswer
  xiangshiData.questionId = p.newQuestionId
  xiangshiData.shuffleSession = p.sessionid
  xiangshiData.sequence = p.answer_sequence
  local waitTime = oldRightNum == p.rightAnswer and 2 or 1
  GameUtil.AddGlobalTimer(waitTime, true, function()
    if xiangshiData.questionId < 0 then
      if ExamDlg.Instance().status == KejuConst.UIType.QUESTION then
        ExamDlg.Close()
      end
    else
      ExamDlg.ShowQuestion(KejuConst.ExamType.XIANG_SHI, xiangshiData)
    end
  end)
end
def.static("table").onSSyncFinishXiangShi = function(p)
  local xiangshiData = instance.data[KejuConst.ExamType.XIANG_SHI]
  local huishiData = instance.data[KejuConst.ExamType.HUI_SHI]
  local dianshiData = instance.data[KejuConst.ExamType.DIAN_SHI]
  local isPass = p.isPass
  warn("xiangshi result is ...", isPass)
  if isPass == 1 then
    xiangshiData.enable = KejuConst.ExamStatus.FINISH
    huishiData.enable = KejuConst.ExamStatus.OPEN
    dianshiData.enable = KejuConst.ExamStatus.NOTOPEN
    ExamDlg.Close()
    do
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      GameUtil.AddGlobalTimer(1, true, function()
        CommonConfirmDlg.ShowConfirmCoundDown(textRes.Keju[17], textRes.Keju[14], textRes.Keju[15], textRes.Keju[16], 0, 300, function(select, tag)
          if select == 1 then
            instance:GotoHuiShi()
          end
        end, nil)
      end)
    end
  else
    xiangshiData.enable = KejuConst.ExamStatus.FINISH
    huishiData.enable = KejuConst.ExamStatus.DENY
    dianshiData.enable = KejuConst.ExamStatus.DENY
    ExamDlg.ShowResult(textRes.Keju[18], -1)
    GameUtil.AddGlobalTimer(5, true, function()
      if ExamDlg.Instance().m_panel then
        ExamDlg.Close()
      end
    end)
  end
end
def.static("table").onSGetHuiShiQuestionRes = function(p)
  local huishiData = instance.data[KejuConst.ExamType.HUI_SHI]
  huishiData.enable = KejuConst.ExamStatus.OPEN
  huishiData.startTime = p.startTime
  local actStartTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(KejuUtils.GetKejuCfg().acticityId)
  if actStartTime then
    huishiData.endTime = actStartTime + KejuUtils.GetKejuCfg().xiangShiTime + KejuUtils.GetKejuCfg().huiShiTime
  else
    warn("Bad Keju Time")
  end
  huishiData.answerdNum = p.alreadyAnswer
  huishiData.totalNum = KejuUtils.GetKejuCfg().huiShiNumber
  huishiData.rightNum = p.rightAnswer
  huishiData.punishTime = p.totalAddTime
  huishiData.questionId = p.questionId
  huishiData.shuffleSession = p.sessionid
  huishiData.sequence = p.answer_sequence
  if huishiData.questionId < 0 then
    Toast(textRes.Keju[26])
  else
    ExamDlg.ShowQuestion(KejuConst.ExamType.HUI_SHI, huishiData)
  end
end
def.static("table").onSAnswerHuiShiQuestionRes = function(p)
  local huishiData = instance.data[KejuConst.ExamType.HUI_SHI]
  huishiData.answerdNum = p.alreadyAnswer
  huishiData.rightNum = p.rightAnswer
  local oldPunishTime = huishiData.punishTime
  huishiData.punishTime = p.totalAddTime
  if oldPunishTime < p.totalAddTime then
    ExamDlg.Instance():AddTime(p.totalAddTime - oldPunishTime)
  end
  huishiData.questionId = p.newQuestionId
  huishiData.shuffleSession = p.sessionid
  huishiData.sequence = p.answer_sequence
  if huishiData.questionId < 0 then
    ExamDlg.ShowResult(textRes.Keju[20], -1)
    huishiData.enable = KejuConst.ExamStatus.FINISH
    local dianshiData = instance.data[KejuConst.ExamType.DIAN_SHI]
    dianshiData.enable = KejuConst.ExamStatus.NOTOPEN
    GameUtil.AddGlobalTimer(5, true, function()
      if ExamDlg.Instance().m_panel then
        ExamDlg.Close()
      end
    end)
  else
    ExamDlg.ShowQuestion(KejuConst.ExamType.HUI_SHI, huishiData)
  end
end
def.static("table").onSSyncFinishHuiShi = function(p)
  local ProtocolsCache = require("Main.Common.ProtocolsCache")
  local protocolsCache = ProtocolsCache.Instance()
  if protocolsCache:CacheProtocol(KejuModule.onSSyncFinishHuiShi, p) == true then
    warn("onSSyncFinishHuiShi protocals  Cache!!!!!")
    return
  end
  local huishiData = instance.data[KejuConst.ExamType.HUI_SHI]
  local dianshiData = instance.data[KejuConst.ExamType.DIAN_SHI]
  local isPass = p.isPass
  warn("huishi result is ...", isPass)
  if isPass == 1 then
    huishiData.enable = KejuConst.ExamStatus.FINISH
    dianshiData.enable = KejuConst.ExamStatus.NOTOPEN
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirmCoundDown(textRes.Keju[17], textRes.Keju[21], textRes.Keju[22], textRes.Keju[16], 0, 60, function(select, tag)
      if select == 1 then
        instance:GotoDianShi()
      end
    end, nil)
  else
    huishiData.enable = KejuConst.ExamStatus.FINISH
    dianshiData.enable = KejuConst.ExamStatus.DENY
  end
end
def.static("table").onSSyncDianShiQuestionRes = function(p)
  local dianshiData = instance.data[KejuConst.ExamType.DIAN_SHI]
  dianshiData.enable = KejuConst.ExamStatus.OPEN
  local actStartTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(KejuUtils.GetKejuCfg().acticityId)
  if actStartTime then
    dianshiData.startTime = actStartTime + KejuUtils.GetKejuCfg().xiangShiTime + KejuUtils.GetKejuCfg().huiShiTime + KejuUtils.GetKejuCfg().dianShiPrepareTime
    dianshiData.endTime = actStartTime + KejuUtils.GetKejuCfg().xiangShiTime + KejuUtils.GetKejuCfg().huiShiTime + KejuUtils.GetKejuCfg().dianShiPrepareTime + KejuUtils.GetKejuCfg().dianShiTime
  else
    warn("Bad Keju Time")
  end
  dianshiData.answerdNum = p.alreadyAnswer
  dianshiData.totalNum = KejuUtils.GetKejuCfg().dianShiNumber
  dianshiData.rightNum = p.rightAnswer
  dianshiData.punishTime = p.totalAddTime
  dianshiData.questionId = p.questionId
  dianshiData.shuffleSession = p.sessionid
  dianshiData.sequence = p.answer_sequence
  if dianshiData.questionId < 0 then
    Toast(textRes.Keju[27])
  else
    ExamDlg.ShowQuestion(KejuConst.ExamType.DIAN_SHI, dianshiData)
  end
end
def.static("table").onSAnswerDianShiQuestionRes = function(p)
  local dianshiData = instance.data[KejuConst.ExamType.DIAN_SHI]
  dianshiData.answerdNum = p.alreadyAnswer
  dianshiData.rightNum = p.rightAnswer
  local oldPunishTime = dianshiData.punishTime
  dianshiData.punishTime = p.totalAddTime
  if oldPunishTime < p.totalAddTime then
    ExamDlg.Instance():MinusTime(p.totalAddTime - oldPunishTime)
  end
  dianshiData.questionId = p.newQuestionId
  dianshiData.shuffleSession = p.sessionid
  dianshiData.sequence = p.answer_sequence
  GameUtil.AddGlobalTimer(1, true, function()
    if dianshiData.questionId < 0 then
      ExamDlg.ShowResult(textRes.Keju[24], -1)
      dianshiData.enable = KejuConst.ExamStatus.FINISH
      GameUtil.AddGlobalTimer(5, true, function()
        if ExamDlg.Instance().m_panel then
          ExamDlg.Close()
        end
      end)
    else
      ExamDlg.ShowQuestion(KejuConst.ExamType.DIAN_SHI, dianshiData)
    end
  end)
end
def.static("table", "table").onMainUIReady = function(p1, p2)
  do return end
  if instance == nil or instance.data == nil then
    return
  end
  if instance.data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.OPEN then
    local hp = require("Main.Hero.HeroModule").Instance()
    local heroLevel = hp:GetHeroProp().level
    local kejuActivityId = KejuUtils.GetKejuCfg().acticityId
    local kejuCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(kejuActivityId)
    if heroLevel >= kejuCfg.levelMin and heroLevel <= kejuCfg.levelMax then
      local confirmPanel = require("GUI.CommonConfirmDlg")
      confirmPanel.ShowConfirmCoundDown(textRes.Keju[17], textRes.Keju[28], textRes.Keju[29], textRes.Keju[16], 0, 300, function(select, tag)
        if select == 1 then
          instance:GotoXiangShi()
        end
      end, nil)
    end
  end
end
def.static("table", "table").onRoleLvUp = function(p1, p2)
end
def.static("table", "table").onActivityTodo = function(p1, p2)
  warn(p1[1], "KEJU", KejuUtils.GetKejuCfg().acticityId)
  if p1[1] == KejuUtils.GetKejuCfg().acticityId then
    instance:ShowKejuPanel()
  end
end
def.static("=>", "boolean").IsInDianShiJinChangTime = function()
  local huishiEnd = KejuModule.CheckExamTimeEnd(NPCServiceConst.Keju_Hui)
  local dianshiJinChangEnd = KejuModule.CheckExamTimeEnd(NPCServiceConst.Keju_DianJinChang)
  return huishiEnd and not dianshiJinChangEnd
end
def.static("number", "=>", "boolean").CheckExamTimeEnd = function(checktype)
  local startTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(KejuUtils.GetKejuCfg().acticityId)
  local xiangshiEndTime = startTime + KejuUtils.GetKejuCfg().xiangShiTime
  local huishiEndTime = startTime + KejuUtils.GetKejuCfg().xiangShiTime + KejuUtils.GetKejuCfg().huiShiTime
  local dianshiJinchangEndTime = startTime + KejuUtils.GetKejuCfg().xiangShiTime + KejuUtils.GetKejuCfg().huiShiTime + KejuUtils.GetKejuCfg().dianShiPrepareTime
  local dianshiEndTime = dianshiJinchangEndTime + KejuUtils.GetKejuCfg().dianShiTime
  if checktype == NPCServiceConst.Keju_Xiang then
    local curTime = GetServerTime()
    if xiangshiEndTime < curTime then
      return true
    end
    return false
  elseif checktype == NPCServiceConst.Keju_Hui then
    local curTime = GetServerTime()
    if huishiEndTime < curTime then
      return true
    end
    return false
  elseif checktype == NPCServiceConst.Keju_DianJinChang then
    local curTime = GetServerTime()
    if dianshiJinchangEndTime < curTime then
      return true
    end
    return false
  elseif checktype == NPCServiceConst.Keju_Dian then
    local curTime = GetServerTime()
    if dianshiEndTime < curTime then
      return true
    end
    return false
  end
end
def.static("table", "table").onKejuService = function(p1, p2)
  local npcId = p1[2]
  local serviceId = p1[1]
  if serviceId == NPCServiceConst.Keju_Xiang then
    warn("xiangshi state is ...", instance.data[KejuConst.ExamType.XIANG_SHI].enable)
    if instance.data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.OPEN then
      instance:JoinXiangShi()
    elseif instance.data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.NOTOPEN then
      Toast(textRes.Keju[41])
    elseif instance.data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.DENY then
      Toast(textRes.Keju[44])
    elseif instance.data[KejuConst.ExamType.XIANG_SHI].enable == KejuConst.ExamStatus.FINISH then
      if KejuModule.CheckExamTimeEnd(NPCServiceConst.Keju_Xiang) then
        Toast(textRes.Keju[48])
      else
        Toast(textRes.Keju[25])
      end
    end
  elseif serviceId == NPCServiceConst.Keju_Hui then
    warn("huishi state is ...", instance.data[KejuConst.ExamType.HUI_SHI].enable)
    if instance.data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.OPEN then
      instance:JoinHuiShi()
    elseif instance.data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.NOTOPEN then
      Toast(textRes.Keju[42])
    elseif instance.data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.DENY then
      Toast(textRes.Keju[45])
    elseif instance.data[KejuConst.ExamType.HUI_SHI].enable == KejuConst.ExamStatus.FINISH then
      if KejuModule.CheckExamTimeEnd(NPCServiceConst.Keju_Hui) then
        Toast(textRes.Keju[49])
      else
        Toast(textRes.Keju[26])
      end
    end
  elseif serviceId == NPCServiceConst.Keju_Dian then
    warn("dianshi state is ...", instance.data[KejuConst.ExamType.DIAN_SHI].enable)
    if instance.data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.OPEN then
      instance:JoinDianShi()
    elseif instance.data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.NOTOPEN then
      instance:JoinDianShi()
    elseif instance.data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.DENY then
      Toast(textRes.Keju[46])
    elseif instance.data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.FINISH then
      if KejuModule.CheckExamTimeEnd(NPCServiceConst.Keju_Dian) then
        Toast(textRes.Keju[50])
      else
        Toast(textRes.Keju[27])
      end
    end
  elseif serviceId == NPCServiceConst.Keju_DianJinChang then
    warn("dianshi state is ...", instance.data[KejuConst.ExamType.DIAN_SHI].enable)
    local correctTime = KejuModule.CheckExamTimeEnd(NPCServiceConst.Keju_DianJinChang)
    if instance.data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.OPEN then
      if correctTime then
        Toast(textRes.Keju[47])
        return
      end
      instance:GotoDianShiMap()
    elseif instance.data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.NOTOPEN then
      if correctTime then
        Toast(textRes.Keju[47])
        return
      end
      local curTime = GetServerTime()
      local startTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(KejuUtils.GetKejuCfg().acticityId)
      local dianshiJinChangStartTime = startTime + KejuUtils.GetKejuCfg().xiangShiTime + KejuUtils.GetKejuCfg().huiShiTime
      if curTime < dianshiJinChangStartTime then
        Toast(textRes.Keju[43])
        return
      end
      instance:GotoDianShiMap()
    elseif instance.data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.DENY then
      Toast(textRes.Keju[46])
    elseif instance.data[KejuConst.ExamType.DIAN_SHI].enable == KejuConst.ExamStatus.FINISH then
      if KejuModule.CheckExamTimeEnd(NPCServiceConst.Keju_Dian) then
        Toast(textRes.Keju[50])
      else
        Toast(textRes.Keju[27])
      end
    end
  end
end
def.static("table", "table").onKejuEnd = function(p1, p2)
  local kejuActId = KejuUtils.GetKejuCfg().acticityId
  if kejuActId == p1[1] then
    Toast(textRes.Keju[54])
    if ExamDlg.Instance().m_panel and ExamDlg.Instance().questionType == KejuConst.ExamType.XIANG_SHI then
      ExamDlg.Close()
      return
    end
    if ExamDlg.Instance().m_panel and ExamDlg.Instance().questionType == KejuConst.ExamType.HUI_SHI then
      ExamDlg.Close()
      return
    end
    if ExamDlg.Instance().m_panel and ExamDlg.Instance().questionType == KejuConst.ExamType.DIAN_SHI then
      ExamDlg.Close()
      return
    end
  end
end
def.static("table", "table").OnActivityReset = function(p1, p2)
  local activityId = p1[1]
  if acticityId == KejuUtils.GetKejuCfg().acticityIdthen then
    instance:OnReset()
  end
end
def.static("table", "table").OnActivityStart = function(p1, p2)
  local kejuActId = KejuUtils.GetKejuCfg().acticityId
  if p1[1] == kejuActId then
    warn("keju Activity_Start")
    local xiangshiData = instance.data[KejuConst.ExamType.XIANG_SHI]
    local huishiData = instance.data[KejuConst.ExamType.HUI_SHI]
    local dianshiData = instance.data[KejuConst.ExamType.DIAN_SHI]
    xiangshiData.enable = KejuConst.ExamStatus.OPEN
    huishiData.enable = KejuConst.ExamStatus.NOTOPEN
    dianshiData.enable = KejuConst.ExamStatus.NOTOPEN
  end
end
def.override().OnReset = function(self)
  self.data = {}
  self.data[KejuConst.ExamType.XIANG_SHI] = {}
  self.data[KejuConst.ExamType.XIANG_SHI].enable = KejuConst.ExamStatus.NOTOPEN
  self.data[KejuConst.ExamType.HUI_SHI] = {}
  self.data[KejuConst.ExamType.HUI_SHI].enable = KejuConst.ExamStatus.NOTOPEN
  self.data[KejuConst.ExamType.DIAN_SHI] = {}
  self.data[KejuConst.ExamType.DIAN_SHI].enable = KejuConst.ExamStatus.NOTOPEN
end
def.method("=>", "boolean").isInDianShiMap = function(self)
  local curMapId = require("Main.Map.Interface").GetCurMapId()
  local dianshiMap = KejuUtils.GetKejuCfg().dianshiMap
  return curMapId == dianshiMap
end
KejuModule.Commit()
return KejuModule
