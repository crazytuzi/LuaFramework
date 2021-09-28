JieqiMgr = class("JieqiMgr")
JieqiMissionId_Shaguai = 110001
JieqiMissionId_Jieqiling = 110002
JieqiMissionId_Lingqi = 110003
JieqiMissionId_Qiyue = 110004
JieqiMissionId_Jieqiling2 = 110005
JieqiMissionId_WaitQiyue = 110006
function JieqiMgr:ctor()
  self.m_RequestJieqiPid = nil
  self.m_JieqiMissionId = nil
  self.m_JieqiMissionState = nil
  self.m_IsCommited = nil
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Connect)
end
function JieqiMgr:getSaveData()
  return {
    self.m_RequestJieqiPid,
    self.m_JieqiMissionId,
    self.m_JieqiMissionState,
    self.m_IsCommited
  }
end
function JieqiMgr:setSaveData(data)
  data = data or {}
  self.m_RequestJieqiPid = data[1]
  self.m_JieqiMissionId = data[2]
  self.m_JieqiMissionState = data[3]
  self.m_IsCommited = data[4]
end
function JieqiMgr:OnMessage(msgSID, ...)
  if msgSID == MsgID_Connect_SendFinished and self.m_SaveLastMissionData ~= nil then
    local param = self.m_SaveLastMissionData
    self.m_SaveLastMissionData = nil
    self:missionDataUpdate(param)
  end
end
function JieqiMgr:canJieqi()
  if g_LocalPlayer == nil then
    return false
  end
  local teamId = g_TeamMgr:getLocalPlayerTeamId()
  if teamId == 0 or teamId == nil or g_TeamMgr:localPlayerIsCaptain() == false then
    return false, "只有队长才可以申请结契"
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
    return false, "结契需要2人组队"
  end
  local myType = g_LocalPlayer:getObjProperty(1, PROPERTY_SHAPE)
  local teamerType = player:getObjProperty(1, PROPERTY_SHAPE)
  if data_getRoleGender(myType) ~= data_getRoleGender(teamerType) then
    return false, "同性别才可以结契"
  end
  return true, teamerPid
end
function JieqiMgr:canShoujiLingqi()
  if g_LocalPlayer == nil then
    return false
  end
  if g_TeamMgr:localPlayerIsCaptain() == false then
    return false, "请让队长引导收集"
  end
  local teamId = g_TeamMgr:getLocalPlayerTeamId()
  if teamId == 0 or teamId == nil or g_TeamMgr:localPlayerIsCaptain() == false then
    return false, "请让队长引导收集"
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
    return false, "收集灵气需要2人组队"
  end
  if g_TeamMgr:getPlayerTeamState(teamerPid) == TEAMSTATE_LEAVE then
    return false, "收集灵气需要队员归队"
  end
  return true, teamerPid
end
function JieqiMgr:requestGiveup()
  netsend.netmarry.GiveupJieqiTask(self.m_JieqiMissionId)
end
function JieqiMgr:getRequest(pid, name, zs, lv, rtype)
  self.m_RequestJieqiPid = pid
  self:showRequestView(name, zs, lv)
end
function JieqiMgr:showRequestView(name, zs, lv)
  local dlg = RequestJiehunOrJieqi.new("views/pop_req_jieqi.csb", name, zs, lv, handler(self, self.requestViewCallback))
  getCurSceneView():addSubView({
    subView = dlg,
    zOrder = MainUISceneZOrder.popZView
  })
end
function JieqiMgr:requestViewCallback(isOK)
  print("requestViewCallback:", isOK)
  local choice = 0
  if isOK then
    choice = 1
  end
  netsend.netmarry.replyJieqiRequest(self.m_RequestJieqiPid, choice)
end
function JieqiMgr:requestJieqiSucceed()
  getCurSceneView():ShowTalkView(501007, function()
  end)
end
function JieqiMgr:missionDataUpdate(param)
  print("JieqiMgr:missionDataUpdate:")
  dump(param, "param")
  if g_DataMgr:getIsSendFinished() ~= true then
    self.m_SaveLastMissionData = param
    return
  end
  local pid = param.id
  local taskid = param.taskid
  local state = param.state
  local ext = param.ext or {}
  if pid == nil or taskid == nil or state == nil then
    print("[ERROR] JieqiMgr:missionDataUpdate 参数错误")
    dump(param, "param", 5)
    return
  end
  self.m_JieqiMissionId = pid
  self.m_JieqiMissionState = state
  self.m_IsCommited = false
  if ext.commited ~= nil or ext.committed ~= nil then
    self.m_IsCommited = true
  end
  if taskid == JieqiMissionId_Shaguai then
    if self.m_JieqiMissionState == 1 then
      self:flushMission(JieqiMissionId_Shaguai)
    else
      self:flushMission(JieqiMissionId_Shaguai, MissionPro_1)
    end
  elseif taskid == JieqiMissionId_Jieqiling then
    if self.m_IsCommited then
      self:flushMission(JieqiMissionId_Jieqiling2)
    else
      self:flushMission(JieqiMissionId_Jieqiling)
    end
  elseif taskid == JieqiMissionId_Lingqi then
    if self.m_JieqiMissionState == 1 then
      self:flushMission(JieqiMissionId_Lingqi)
    else
      self:flushMission(JieqiMissionId_Lingqi, MissionPro_1)
    end
  elseif taskid == JieqiMissionId_Qiyue then
    if self.m_IsCommited then
      self:flushMission(JieqiMissionId_WaitQiyue)
    else
      self:flushMission(JieqiMissionId_Qiyue)
    end
  end
end
function JieqiMgr:missionRequestComplete(missionId, typ)
  print("JieqiMgr:missionRequestComplete:", missionId, typ)
  if missionId == JieqiMissionId_Shaguai then
    if self.m_JieqiMissionState == 1 then
      netsend.netmarry.StartJieqiFight()
    else
      netsend.netmarry.FinishJieqiFight()
    end
  elseif missionId == JieqiMissionId_Jieqiling then
    netsend.netmarry.FinishJieqiLing()
  elseif missionId == JieqiMissionId_Jieqiling2 then
    AwardPrompt.addPrompt("对方还没有提交结契令，请耐心等待")
  elseif missionId == JieqiMissionId_WaitQiyue then
    AwardPrompt.addPrompt("对方还没有缔交结契贡品，请耐心等待")
  elseif missionId == JieqiMissionId_Lingqi then
    if self.m_JieqiMissionState == 1 then
      print("-------------->>> 开始吸收")
      local isCanStart, param = self:canShoujiLingqi()
      if isCanStart then
        local customId = 19002
        g_MapMgr:AutoRouteWithCustomId(customId, function()
          local func = function()
            netsend.netmarry.XinShouLingqi()
          end
          CShowProgressBar.new("收集灵气", func, 10)
        end)
      elseif param then
        AwardPrompt.addPrompt(param)
      end
    else
      netsend.netmarry.FinishedXinShouLQ()
    end
  elseif missionId == JieqiMissionId_Qiyue then
    ShowMarryGiveItemView(110004)
  else
    print("-------------->>> 寻路完成任务了")
  end
end
function JieqiMgr:flushMission(missionId, pro)
  if self.m_CurShowMissionId ~= nil and self.m_CurShowMissionId ~= missionId then
    g_MissionMgr:Server_GiveUpMission(self.m_CurShowMissionId)
  end
  self.m_CurShowMissionId = missionId
  if self.m_CurShowMissionId == nil then
    return
  end
  if pro == nil then
    g_MissionMgr:Server_MissionAccepted(missionId)
  else
    g_MissionMgr:Server_MissionUpdated(missionId, pro)
  end
end
function JieqiMgr:hadMission()
  return self.m_CurShowMissionId ~= nil
end
function JieqiMgr:showGiveupWarningView()
  local dlg = CPopWarning.new({
    title = "提示",
    text = "心志坚毅者方能成功结契，您确定要放弃结契吗?",
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
function JieqiMgr:serverDeletedMission()
  if self.m_CurShowMissionId ~= nil then
    g_MissionMgr:Server_GiveUpMission(self.m_CurShowMissionId)
    self.m_CurShowMissionId = nil
  end
end
function JieqiMgr:touchNpcOption_Jieqi()
  print("touchNpcOption_Jiehun")
  local canStart, param = self:canJieqi()
  if canStart then
    print("---开始结契")
    self.m_IsRequestMarry = true
    netsend.netmarry.requestJieqi(param)
  elseif param then
    AwardPrompt.addPrompt(param)
  end
end
function JieqiMgr:Clean()
  self:RemoveAllMessageListener()
end
function JieqiMgr:test()
  local param = {
    id = 1,
    taskid = JieqiMissionId_Qiyue,
    state = 1,
    ext = {}
  }
  self:missionDataUpdate(param)
end
local new_ins = function()
  print("jiqi new_ins")
  local data = {}
  if g_JieqiMgr then
    data = g_JieqiMgr:getSaveData()
    g_JieqiMgr:Clean()
  end
  g_JieqiMgr = JieqiMgr:new()
  g_JieqiMgr:setSaveData(data)
end
gamereset.registerResetFunc(function()
  new_ins()
end)
new_ins()
