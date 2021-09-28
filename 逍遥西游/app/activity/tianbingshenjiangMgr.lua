local tianbingshenjiangMgr = class("tianbingshenjiangMgr")
function tianbingshenjiangMgr:ctor()
  self.m_TBSJCircle = 0
  self.m_State = nil
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_PlayerInfo)
end
function tianbingshenjiangMgr:HasAcceptTBSJMission()
  local curZs = g_LocalPlayer:getObjProperty(1, PROPERTY_ZHUANSHENG)
  local curLv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  local needZs = data_Mission_Activity[TBSJ_MissionId].zs
  local needLv = data_Mission_Activity[TBSJ_MissionId].lv
  if curZs < needZs or curZs == needZs and curLv < needLv then
    return false
  elseif self.m_State ~= 1 then
    return false
  elseif self.m_TBSJCircle > TBSJ_MaxCircle or self.m_TBSJCircle <= 0 then
    return false
  else
    return true
  end
end
function tianbingshenjiangMgr:CanAcceptTBSJMission()
  local curZs = g_LocalPlayer:getObjProperty(1, PROPERTY_ZHUANSHENG)
  local curLv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  local needZs = data_Mission_Activity[TBSJ_MissionId].zs
  local needLv = data_Mission_Activity[TBSJ_MissionId].lv
  if curZs < needZs or curZs == needZs and curLv < needLv then
    return false
  elseif self.m_State ~= 1 then
    return false
  elseif self.m_TBSJCircle > TBSJ_MaxCircle or self.m_TBSJCircle < 0 then
    return false
  else
    return true
  end
end
function tianbingshenjiangMgr:SetTBSJCircleNum(circle)
  local oldCircle = self.m_TBSJCircle
  self.m_TBSJCircle = circle
  if self:CanAcceptTBSJMission() == false then
    g_MissionMgr:delTianBingShenJiang()
  else
    if circle ~= oldCircle then
      g_MissionMgr:delTianBingShenJiang()
    end
    g_MissionMgr:flushTianBingShenJiangMission()
  end
  g_MissionMgr:flushMissionStatusForNpc()
  if g_DataMgr:getIsSendFinished() == true and self.m_TBSJCircle == 1 and (oldCircle > TBSJ_MaxCircle or oldCircle <= 0) then
    getCurSceneView():ShowTalkView(700141, nil, nil)
  end
end
function tianbingshenjiangMgr:setStatus(state)
  self.m_State = state
  self:UpdateTBSJMissionState()
end
function tianbingshenjiangMgr:ReqAcceptTBSJ()
  netsend.netactivity.getTianBingShenJiangMission()
end
function tianbingshenjiangMgr:TrackTBSJMission()
  local npcId, _ = data_getTBSJNPCNameByCircle(self.m_TBSJCircle)
  g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
    if isSucceed and CMainUIScene.Ins and isSucceed then
      CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
    end
  end)
end
function tianbingshenjiangMgr:fightTBSJ()
  netsend.netactivity.fightTianBingShenJiang()
end
function tianbingshenjiangMgr:UpdateTBSJMissionState()
  if self:CanAcceptTBSJMission() == false then
    g_MissionMgr:delTianBingShenJiang()
  else
    g_MissionMgr:flushTianBingShenJiangMission()
  end
  g_MissionMgr:flushMissionStatusForNpc()
end
function tianbingshenjiangMgr:GetTBSJMissionItemTarget()
  if self:HasAcceptTBSJMission() == false then
    return "None"
  else
    local _, npcName = data_getTBSJNPCNameByCircle(self.m_TBSJCircle)
    local _, mapName = data_getTBSJMapNameByCircle(self.m_TBSJCircle)
    return string.format("去%s战胜#<Y>%s#", mapName, npcName)
  end
end
function tianbingshenjiangMgr:GetTBSJMissionViewTarget()
  if self:HasAcceptTBSJMission() == false then
    return "None"
  else
    local _, npcName = data_getTBSJNPCNameByCircle(self.m_TBSJCircle)
    return string.format("战胜#<Y>%s#", npcName)
  end
end
function tianbingshenjiangMgr:GetTBSJMissionViewDes()
  if self:HasAcceptTBSJMission() == false then
    return "逢周一、周三19:30--21:00内，可去#<Y>袁天罡# 处报名参加#<Y>天兵神将#活动。依次到达指定的地方挑战各位仙将， 胜利者将会获得仙人嘉奖。"
  else
    local _, npcName = data_getTBSJNPCNameByCircle(self.m_TBSJCircle)
    local _, mapName = data_getTBSJMapNameByCircle(self.m_TBSJCircle)
    return string.format("去%s战胜#<Y>%s#，赢得仙人嘉奖。", mapName, npcName)
  end
end
function tianbingshenjiangMgr:GetTBSJNpcId()
  if self:HasAcceptTBSJMission() == false then
    return nil
  else
    local npcId, _ = data_getTBSJNPCNameByCircle(self.m_TBSJCircle)
    return npcId
  end
end
function tianbingshenjiangMgr:GetTBSJCircleNum()
  return self.m_TBSJCircle
end
function tianbingshenjiangMgr:GetTBSJMissionState()
  if self.m_TBSJCircle <= 0 then
    return MissionPro_NotAccept
  else
    return MissionPro_0
  end
end
function tianbingshenjiangMgr:popTBSJConfirmView(progress)
  local tips = string.format("             天兵神将(%d/%d)\n\n\n你当前进度与队长不一致,请确定是否以队长进度为准？\n\n#<IRP,CTP,F:18>重复击杀怪物不会获得奖励#", progress, TBSJ_MaxCircle)
  local tempView = CPopWarning.new({
    title = "队长进度",
    text = tips,
    align = CRichText_AlignType_Left,
    autoConfirmTime = 10,
    confirmFunc = function()
      netsend.netactivity.confirmTBSJProgress(1, progress)
    end,
    cancelFunc = function()
      netsend.netactivity.confirmTBSJProgress(0, progress)
    end
  })
  tempView:ShowCloseBtn(false)
end
function tianbingshenjiangMgr:OnMessage(msgSID, ...)
  if msgSID == MsgID_ServerDailyClean then
    self.m_TBSJCircle = 0
    self.m_State = nil
    self:UpdateTBSJMissionState()
  end
end
function tianbingshenjiangMgr:Clean()
  self:RemoveAllMessageListener()
  self.m_TBSJCircle = 0
  self.m_State = nil
end
return tianbingshenjiangMgr
