local DefineTalkType_Fight = 1
local DefineTalkType_Round = 5
local CMonsterView = class("CMonsterView", CRoleViewBase)
function CMonsterView:ctor(pos, roleData, warScene)
  CMonsterView.super.ctor(self, pos, roleData, warScene)
  self.m_FightActionTimes = {}
  local data = data_Monster[self.m_typeId]
  if data then
    talkId = data.FIGHTTALK
    if talkId ~= nil and talkId ~= 0 then
      self.m_FightTalk = data_NpcFightTalk[talkId]
    end
  end
end
function CMonsterView:getType()
  return LOGICTYPE_MONSTER
end
function CMonsterView:getNameColor()
  return ccc3(255, 255, 0)
end
function CMonsterView:checkRoundTalk(round, delay)
  if self.m_FightTalk == nil then
    return 0
  end
  local dt = 2
  local talkDelay = 0.3
  local talkShowTime = 2.2
  local data = self.m_FightTalk[round]
  if data ~= nil and #data > 0 then
    local tempList = {}
    for _, d in pairs(data) do
      if d.tType == DefineTalkType_Round then
        tempList[#tempList + 1] = d
      end
    end
    if #tempList > 0 then
      local temp = tempList[math.random(1, #tempList)]
      self:addNpcFightTalk(temp.talk, delay + talkDelay, talkShowTime)
      return dt
    end
  end
  return 0
end
function CMonsterView:checkFightTalk(seqType, round, param)
  if self.m_FightTalk == nil then
    return 0
  end
  if self.m_TalkBubbleObj ~= nil and self.m_TalkBubbleObj._isTx == true then
    return 0
  end
  local times = 1
  if seqType == SEQTYPE_NORMALATTACK then
    times = self.m_FightActionTimes[SEQTYPE_NORMALATTACK]
    if times == nil then
      times = 1
    else
      times = times + 1
    end
    self.m_FightActionTimes[SEQTYPE_NORMALATTACK] = times
  elseif seqType == SEQTYPE_USESKILL or seqType == SEQTYPE_USENEIDANSKILL or seqType == SEQTYPE_PETSKILL then
    times = self.m_FightActionTimes[SEQTYPE_USESKILL]
    if times == nil then
      times = 1
    else
      times = times + 1
    end
    self.m_FightActionTimes[SEQTYPE_USESKILL] = times
  elseif seqType == SEQTYPE_CALLUP then
    times = self.m_FightActionTimes[SEQTYPE_CALLUP]
    if times == nil then
      times = 1
    else
      times = times + 1
    end
    self.m_FightActionTimes[SEQTYPE_CALLUP] = times
  elseif seqType == SEQTYPE_ESCAPE then
    times = self.m_FightActionTimes[SEQTYPE_ESCAPE]
    if times == nil then
      times = 1
    else
      times = times + 1
    end
    self.m_FightActionTimes[SEQTYPE_ESCAPE] = times
  end
  local dt = 1
  local talkDelay = 0.3
  local talkShowTime = 2.5
  local data = self.m_FightTalk[round]
  if data == nil then
    data = self.m_FightTalk[-1]
  end
  if data ~= nil and #data > 0 then
    local tempList = {}
    for _, d in pairs(data) do
      if d.tType == DefineTalkType_Fight then
        tempList[#tempList + 1] = d
      end
    end
    if #tempList > 0 then
      local temp = tempList[math.random(1, #tempList)]
      self:addNpcFightTalk(temp.talk, talkDelay, talkShowTime)
      return dt
    end
  end
  if seqType == SEQTYPE_NORMALATTACK then
    data = self.m_FightTalk.attack
  elseif seqType == SEQTYPE_USESKILL or seqType == SEQTYPE_USENEIDANSKILL or seqType == SEQTYPE_PETSKILL then
    data = self.m_FightTalk.magic
  elseif seqType == SEQTYPE_CALLUP then
    data = self.m_FightTalk.callup
  elseif seqType == SEQTYPE_ESCAPE then
    if param and param.rtype == RUNAWAY_TYPE_Confuse then
      data = self.m_FightTalk.escapeC
      if data == nil or #data <= 0 then
        data = self.m_FightTalk.escape
      end
    else
      data = self.m_FightTalk.escape
    end
    dt = 1.5
    talkShowTime = dt
  else
    data = nil
  end
  if data ~= nil and #data > 0 then
    local talkList = {}
    for _, d in pairs(data) do
      if d.times ~= nil and (0 > d.times or times <= d.times) then
        talkList[#talkList + 1] = d.talk
      end
    end
    if #talkList > 0 then
      self:addNpcFightTalk(talkList[math.random(1, #talkList)], talkDelay, talkShowTime)
      return dt
    end
  end
  return 0
end
function CMonsterView:checkFightTalk_TX(txType)
  local dt = 1.5
  if txType == MONSTER_TX_6 or txType == MONSTER_TX_7 or txType == MONSTER_TX_9 then
    dt = 2
  end
  local talkDelay = 0.3
  local talkShowTime = 3
  local talkId = 90000 + txType
  local talkList = data_NpcFightTalk[talkId]
  if talkList ~= nil and #talkList > 0 then
    self:addNpcFightTalk(talkList[math.random(1, #talkList)], talkDelay, talkShowTime, true)
    return dt
  end
  return 0
end
function CMonsterView:addNpcFightTalk(talk, dt, talkShowTime, isTx)
  if g_WarScene:isChasing() then
    return
  end
  dt = dt or 0.3
  talkShowTime = talkShowTime or 3
  local act1 = CCDelayTime:create(dt)
  local act2 = CCCallFunc:create(function()
    self:addTalkMsg(talk, talkShowTime, nil, isTx)
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function CMonsterView:addTalkMsg(msg, showTime, yy, isTx)
  isTx = isTx or false
  if self.m_TalkBubbleObj ~= nil and self.m_TalkBubbleObj._isTx == true and not isTx then
    return
  end
  CMonsterView.super.addTalkMsg(self, msg, showTime, yy)
  self.m_TalkBubbleObj._isTx = isTx
end
return CMonsterView
