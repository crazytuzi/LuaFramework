HunyinMgr = class("HunyinMgr")
MarryMission_Bless = 100002
MarryMission_HunYan = 100004
ServerXunyouTime = 200
function HunyinMgr:ctor()
  self.m_RequestMarryPid = nil
  self.m_QuestionView = nil
  self.m_MarryMissionId = nil
  self.m_CurShowMissionId = nil
  self.m_XunyouEndTime = 0
  self.m_HuaCheYouXingData = nil
  self.m_XunyouPlayerIds = {}
  self.m_SaveLastMissionData = nil
  self.m_zhufuProgress = {}
  self.m_zhufuEndTime = 0
  self.m_XitangRestTime = nil
  self.m_IsRequestMarry = false
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Connect)
  self:ListenMessage(MsgID_MapLoading)
end
function HunyinMgr:OnMessage(msgSID, ...)
  if msgSID == MsgID_Connect_SendFinished then
    if self.m_SaveLastMissionData ~= nil then
      local param = self.m_SaveLastMissionData
      self.m_SaveLastMissionData = nil
      self:missionDataUpdate(param)
    end
  elseif msgSID == MsgID_MapLoading_Finished then
    self:UpdateHuaCheState()
  end
end
function HunyinMgr:canJiehun()
  if g_LocalPlayer == nil then
    return false
  end
  local teamId = g_TeamMgr:getLocalPlayerTeamId()
  if teamId == 0 or teamId == nil or g_TeamMgr:localPlayerIsCaptain() == false then
    return false, "只有队长才可以申请结婚"
  end
  local teamInfo = g_TeamMgr:getTeamInfo(teamId) or {}
  local teamerPid = teamInfo[1]
  for i, v in ipairs(teamInfo) do
    if v ~= g_LocalPlayer:getPlayerId() then
      teamerPid = v
    end
  end
  local player = g_DataMgr:getPlayer(teamerPid)
  print("teamerPid:", teamerPid)
  print("player:", player)
  if #teamInfo ~= 2 or teamerPid == nil or player == nil then
    return false, "结婚需要2人组队"
  end
  local myType = g_LocalPlayer:getObjProperty(1, PROPERTY_SHAPE)
  if data_getRoleGender(myType) ~= HERO_MALE then
    return false, "队长必须为男性"
  end
  local teamerType = player:getObjProperty(1, PROPERTY_SHAPE)
  print("teamerType:", teamerType, data_getRoleGender(teamerType))
  if data_getRoleGender(teamerType) ~= HERO_FEMALE then
    return false, "结婚对象只能是女性"
  end
  return true, teamerPid
end
function HunyinMgr:missionDataUpdate(param)
  if g_DataMgr:getIsSendFinished() ~= true then
    self.m_SaveLastMissionData = param
    return
  end
  local pid = param.id
  local taskType = param.taskid
  local state = param.state
  local ext = param.ext or {}
  if pid == nil or taskType == nil or state == nil or ext == nil then
    print("[ERROR] missionDataUpdate 参数错误")
    dump(param, "param", 5)
    return
  end
  self.m_MarryMissionId = pid
  if taskType == 0 then
    self:flushMission(100001, pro)
    if self.m_IsRequestMarry == true then
      getCurSceneView():ShowTalkView(501000, function()
      end)
      self.m_IsRequestMarry = false
    end
  elseif taskType == 1 then
    local totalNum = ext.target
    local curNum = ext.num
    local qid = ext.qid
    local rigthNum = ext.right
    local leftTime = ext.lefttime
    if qid <= 0 then
      return
    end
    if totalNum == nil or curNum == nil or qid == nil or rigthNum == nil or leftTime == nil then
      print("[ERROR] missionDataUpdate 答题任务 参数错误")
      dump(param, "param", 5)
      return
    end
    self:showDatiView(qid, curNum, totalNum, rigthNum, leftTime)
  elseif taskType == 2 then
    self:flushMission(100002)
  elseif taskType == 3 then
    local progress = ext.progress
    local target = ext.target
    local lefttime = ext.lefttime
    self.m_zhufuProgress = {progress, target}
    self.m_zhufuEndTime = g_DataMgr:getServerTime() + lefttime
    self:flushMission(100003)
  elseif taskType == 4 then
    self:flushMission(100004)
  elseif taskType == 5 then
    self.m_XitangRestTime = ext.leftnum
  end
end
function HunyinMgr:flushMission(missionId, pro)
  if missionId == nil then
    return
  end
  if self.m_CurShowMissionId ~= nil and self.m_CurShowMissionId ~= missionId then
    g_MissionMgr:Server_GiveUpMission(self.m_CurShowMissionId)
  end
  self.m_CurShowMissionId = missionId
  if pro == nil then
    g_MissionMgr:Server_MissionAccepted(missionId)
  else
    g_MissionMgr:Server_MissionUpdated(missionId, pro)
  end
end
function HunyinMgr:missionRequestComplete(missionId, typ)
  if missionId == 100001 then
    if typ == MissionType_JiehunDati then
      g_MapMgr:AutoRouteToNpc(90029, function(isSucceed)
        if isSucceed then
          print("---->> 开始答题")
          netsend.netmarry.requestDati()
        end
      end)
    end
  elseif missionId == 100002 then
    print("---->> 100002 请求提交爱情种子 完成")
    netsend.netmarry.requestGiveGuozi()
  elseif missionId == 100003 then
    print("---->> 100003 收集祝福")
    do
      local npcId = NPC_ChangEXianZi_ID
      g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
        if isSucceed and CMainUIScene.Ins then
          CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
        end
      end)
    end
  elseif missionId == 100004 then
    print("-------->> 主持婚礼，开始巡游 11 ")
    if self:canTraceMission(missionId) == false then
      return
    end
    do
      local npcId = 90983
      g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
        if isSucceed and CMainUIScene.Ins then
          CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
        end
      end)
    end
  end
end
function HunyinMgr:canTraceMission(missionId)
  print("canTraceMission-->> 11 ")
  if missionId == 100002 or missionId == 100004 then
    print("canTraceMission-->> 22 ")
    local myType = g_LocalPlayer:getObjProperty(1, PROPERTY_SHAPE)
    print("canTraceMission-->> 33:", myType, HERO_MALE)
    if data_getRoleGender(myType) ~= HERO_MALE then
      AwardPrompt.addPrompt("一切交给男方做就可以了")
      return false
    end
  end
  return true
end
function HunyinMgr:getZhufuProc()
  return self.m_zhufuProgress[1], self.m_zhufuProgress[2]
end
function HunyinMgr:getZhufuEndTime()
  return self.m_zhufuEndTime
end
function HunyinMgr:zhufuMissionOutTime()
  netsend.netmarry.checkSjzfMission(self.m_MarryMissionId)
end
function HunyinMgr:requestGiveup()
  netsend.netmarry.requestGiveup(self.m_MarryMissionId)
end
function HunyinMgr:serverDeletedMission()
  if self.m_CurShowMissionId ~= nil then
    g_MissionMgr:Server_GiveUpMission(self.m_CurShowMissionId)
    self.m_CurShowMissionId = nil
  end
  self:closeQuestionView()
end
function HunyinMgr:closeJiehunDatiView()
  self:serverDeletedMission()
end
function HunyinMgr:showGiveupWarningView()
  local dlg = CPopWarning.new({
    title = "提示",
    text = "婚姻路上难以一路风顺,确定要放弃结婚吗?",
    confirmText = "确定",
    confirmFunc = function()
      print("--->> 放弃结婚")
      self:requestGiveup()
    end,
    cancelText = "取消",
    cancelFunc = function()
      print("--->> 取消")
    end,
    clearFunc = function()
    end
  })
end
function HunyinMgr:touchNpcOption_Jiehun()
  print("touchNpcOption_Jiehun")
  local canStart, param = self:canJiehun()
  if canStart then
    print("---开始结婚")
    self.m_IsRequestMarry = true
    netsend.netmarry.requestJiehun(param)
  elseif param then
    AwardPrompt.addPrompt(param)
  end
end
function HunyinMgr:touchNpcOption_Hunyan()
  if self:canTraceMission(100004) == false then
    return true
  end
  getCurSceneView():ShowTalkView(501004, function()
    ShowMarryGiveItemView(100004)
  end)
  return true
end
function HunyinMgr:touchNpcOption_Lihun()
  print("--->> 离婚")
  local dlg = CPopWarning.new({
    title = "提示",
    text = string.format("确定要解除与对方的婚姻关系吗？（解除之后所有的相关功能将无法使用并需要缴纳#<IR1>#%d手续费)", data_Variables.DivorceNeedCoin),
    confirmText = "解除",
    confirmFunc = function()
      print("--->> 解除")
      netsend.netmarry.requestLihun()
    end,
    cancelText = "再想一下",
    cancelFunc = function()
      print("--->> 再想一下")
    end,
    clearFunc = function()
    end
  })
end
function HunyinMgr:touchNpcOption_Jiechujieqi()
  print("--->> 接触结契")
  local dlg = CPopWarning.new({
    title = "提示",
    text = string.format("确定要解除与对方的结契关系吗？（解除之后所有的相关功能将无法使用并需要缴纳#<IR1>#%d手续费)", data_Variables.DivorceNeedCoin),
    confirmText = "解除",
    confirmFunc = function()
      print("--->> 解除")
      netsend.netmarry.BreakupJieTi()
    end,
    cancelText = "再想一下",
    cancelFunc = function()
      print("--->> 再想一下")
    end,
    clearFunc = function()
    end
  })
end
function HunyinMgr:getRequest(pid, name, zs, lv, rtype)
  self.m_RequestMarryPid = pid
  self:showRequestView(name, zs, lv)
end
function HunyinMgr:showRequestView(name, zs, lv)
  local dlg = RequestJiehunOrJieqi.new("views/pop_req_jiehun.csb", name, zs, lv, handler(self, self.requestViewCallback))
  getCurSceneView():addSubView({
    subView = dlg,
    zOrder = MainUISceneZOrder.popZView
  })
end
function HunyinMgr:requestViewCallback(isOK)
  print("requestViewCallback:", isOK)
  local choice = 0
  if isOK then
    choice = 1
  end
  netsend.netmarry.replyRequest(self.m_RequestMarryPid, choice)
end
function HunyinMgr:showDatiView(qid, curNum, totalNum, rightNum, leftTime)
  if leftTime <= 0 then
    netsend.netmarry.answerQeustion(qid, "")
    return
  end
  if self.m_QuestionView == nil then
    self.m_QuestionView = JiehunDati.new(handler(self, self.questionViewClosed))
    getCurSceneView():addSubView({
      subView = self.m_QuestionView,
      zOrder = MainUISceneZOrder.popZView
    })
  end
  self.m_QuestionView:flushData(qid, curNum, totalNum, rightNum, leftTime)
end
function HunyinMgr:questionViewClosed()
  self.m_QuestionView = nil
end
function HunyinMgr:closeQuestionView()
  if self.m_QuestionView then
    self.m_QuestionView:CloseSelf()
    self.m_QuestionView = nil
  end
end
function HunyinMgr:answerQuestionWrongTimes(num)
  if num and num >= 3 then
    self:closeQuestionView()
    self:showAnswerWrongToomuch()
  end
end
function HunyinMgr:showAnswerWrongToomuch()
  local dlg = CPopWarning.new({
    title = "提示",
    text = "好遗憾，本轮已有3道题目答错了，挑战失败了!",
    confirmText = "再来一次",
    confirmFunc = function()
      print("--->> 重来答题")
      netsend.netmarry.requestDati()
    end,
    cancelText = "稍后再试",
    cancelFunc = function()
      print("--->> 暂时不再答题")
    end,
    clearFunc = function()
    end
  })
end
function HunyinMgr:hadMission()
  return self.m_CurShowMissionId ~= nil
end
function HunyinMgr:isShowDatiOption()
  return self.m_CurShowMissionId == 100001
end
function HunyinMgr:isCollectBless()
  return self.m_CurShowMissionId == 100003
end
function HunyinMgr:isJuBanHunYan()
  return self.m_CurShowMissionId == 100004
end
function HunyinMgr:setHuaCheYouXingData(leftTime, data)
  if leftTime <= 2 then
    self:EndXunyou()
    return
  end
  local male = data.male or {}
  local female = data.female or {}
  local pid1 = self.m_XunyouPlayerIds[1]
  local pid2 = self.m_XunyouPlayerIds[2]
  local maleId, femaleId
  if male then
    maleId = male.pid
  end
  if female then
    femaleId = female.pid
  end
  if pid1 ~= maleId or pid2 ~= femaleId then
    self:EndXunyou()
  end
  self.m_XunyouPlayerIds = {maleId, femaleId}
  self.m_XunyouEndTime = g_DataMgr:getServerTime() + leftTime
  self.m_HuaCheYouXingData = data
  if g_MapMgr ~= nil and soundManager then
    local mapId = g_MapMgr:getCurMapId()
    soundManager.playSceneMusic(mapId)
  end
  self:UpdateHuaCheState()
end
function HunyinMgr:getXunyouData()
  return self.m_HuaCheYouXingData
end
function HunyinMgr:GetHuaCheYouXingEndTime()
  if self.m_XunyouEndTime > 0 and self.m_XunyouEndTime > g_DataMgr:getServerTime() then
    return self.m_XunyouEndTime
  end
  return nil
end
function HunyinMgr:IsInXunYouTime()
  if self.m_XunyouEndTime > 0 and self.m_XunyouEndTime > g_DataMgr:getServerTime() then
    return true
  end
  return false
end
function HunyinMgr:IsLocalRoleInHuaChe()
  if self.m_XunyouEndTime > 0 and self.m_XunyouEndTime > g_DataMgr:getServerTime() and g_LocalPlayer ~= nil then
    for i, pid in ipairs(self.m_XunyouPlayerIds) do
      if g_LocalPlayer:getPlayerId() == pid then
        return true
      end
    end
  end
  return false
end
function HunyinMgr:isInXunyouMap()
  if g_MapMgr == nil then
    return false
  end
  local mapId = g_MapMgr:getCurMapId()
  return mapId == MapId_Changan
end
function HunyinMgr:UpdateHuaCheState()
  SendMessage(MsgID_Marry_HuaCheDataUpdate)
  if g_MapMgr:getMapViewIns() == nil then
    return
  end
  if self:isInXunyouMap() and self:IsInXunYouTime() then
    local huacheObj = CreateMarryHuaCheObj()
    if huacheObj then
      huacheObj:StratXunYou(ServerXunyouTime - (self.m_XunyouEndTime - g_DataMgr:getServerTime()))
    end
  else
    DelMarryHuaCheObj()
  end
end
function HunyinMgr:getXunyouPlayerIds()
  return self.m_XunyouPlayerIds
end
function HunyinMgr:EndXunyou()
  DelMarryHuaCheObj()
  self.m_XunyouPlayerIds = {}
  self.m_XunyouEndTime = 0
  if g_MapMgr ~= nil and soundManager then
    local mapId = g_MapMgr:getCurMapId()
    soundManager.playSceneMusic(mapId)
  end
  SendMessage(MsgID_Marry_HuaCheDataUpdate)
end
function HunyinMgr:SaXiTang()
  print("SaXiTang")
  local x, y = GetHuochePostition()
  if x ~= nil and y ~= nil then
    netsend.netmarry.requestSaXiTang(x, y)
  else
    print("[ERROR]获取到的花车位置为空!!!!!!!!!!!!!!!")
  end
end
function HunyinMgr:GetXiTangRestTime()
  return self.m_XitangRestTime or 0
end
function HunyinMgr:test()
  local lefttime = 30
  if g_HunyinMgr then
    local data = {
      lefttime = lefttime,
      male = {
        pid = g_LocalPlayer:getPlayerId(),
        name = "男结婚",
        zs = 1,
        lv = 60,
        rtype = 1005
      },
      female = {
        pid = 10003,
        name = "女结婚",
        zs = 0,
        lv = 90,
        rtype = 1006
      }
    }
    g_HunyinMgr:setHuaCheYouXingData(lefttime, data)
  end
end
function HunyinMgr:Clean()
  self:RemoveAllMessageListener()
end
local new_ins = function()
  if g_HunyinMgr then
    g_HunyinMgr:Clean()
  end
  g_HunyinMgr = HunyinMgr:new()
end
gamereset.registerResetFunc(function()
  new_ins()
end)
new_ins()
