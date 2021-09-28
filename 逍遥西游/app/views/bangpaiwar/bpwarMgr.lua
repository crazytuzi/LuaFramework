BPWARSTATE_START = 1
BPWARSTATE_END = 2
BPWARSTATE_READY = 3
BPWARSTATE_TREASURE = 4
local BpWarMgr = class(".BpWarMgr", nil)
function BpWarMgr:ctor()
  self.m_BpWarState = -1
  self.m_BpWarLeftTime = 0
  self.m_TimeInfoPoint = 0
  self.m_AttackerInfo = {}
  self.m_DefenderInfo = {}
  self.m_TreasureData = {}
end
function BpWarMgr:_cdTimeControl(attr, cdTime)
  local currTime = cc.net.SocketTCP.getTime()
  local lastTime = self[string.format("_lasttime_%s", attr)]
  if lastTime ~= nil and cdTime > currTime - lastTime then
    return false
  end
  self[string.format("_lasttime_%s", attr)] = currTime
  return true
end
function BpWarMgr:_cdTimeTableControl(attr, key, cdTime)
  local currTime = cc.net.SocketTCP.getTime()
  local tb = self[string.format("_lasttime_%s", attr)]
  if tb == nil then
    tb = {}
    self[string.format("_lasttime_%s", attr)] = tb
  end
  local lastTime = tb[key]
  if lastTime ~= nil and cdTime > currTime - lastTime then
    return false
  end
  tb[key] = currTime
  return true
end
function BpWarMgr:getBpWarState()
  return self.m_BpWarState
end
function BpWarMgr:getBpLeftTime()
  local curTime = cc.net.SocketTCP.getTime()
  local spaceTime = curTime - self.m_TimeInfoPoint
  local leftTime = self.m_BpWarLeftTime - spaceTime
  if leftTime < 0 then
    leftTime = 0
  end
  return math.ceil(leftTime)
end
function BpWarMgr:getAttackerInfo()
  return self.m_AttackerInfo
end
function BpWarMgr:getDefenderInfo()
  return self.m_DefenderInfo
end
function BpWarMgr:getIsAttacker(bpId)
  if self.m_AttackerInfo.orgid == bpId then
    return true
  elseif self.m_DefenderInfo.orgid == bpId then
    return false
  else
    return nil
  end
end
function BpWarMgr:getItemNum()
  return getTableLength(self.m_TreasureData)
end
function BpWarMgr:receive_setBpWarState(state)
  self.m_BpWarState = state
  if state ~= BPWARSTATE_TREASURE then
    self.m_TreasureData = {}
  end
  SendMessage(MsgID_BPWar_State, state)
end
function BpWarMgr:receive_setSignUpState(state)
  if state == 1 then
    BangPaiWarSignUpMoney()
  end
end
function BpWarMgr:receive_updateBpWarInfo(info)
  if info.lefttime ~= nil then
    self.m_BpWarLeftTime = info.lefttime
    self.m_TimeInfoPoint = cc.net.SocketTCP.getTime()
    SendMessage(MsgID_BPWar_LeftTime, info.lefttime)
  end
  local attackerInfo = info.attacker
  if attackerInfo ~= nil then
    if attackerInfo.orgid ~= nil then
      self.m_AttackerInfo.orgid = attackerInfo.orgid
      if g_MapMgr:IsInBangPaiWarMap() then
        g_MapMgr:FlushBpWarAttacker()
      end
    end
    if attackerInfo.orgname ~= nil then
      self.m_AttackerInfo.orgname = attackerInfo.orgname
      SendMessage(MsgID_BPWar_AttackName, attackerInfo.orgname)
    end
    if attackerInfo.tili ~= nil then
      self.m_AttackerInfo.tili = attackerInfo.tili
      SendMessage(MsgID_BPWar_AttackTili, attackerInfo.tili)
    end
  end
  local defenderInfo = info.defenser
  if defenderInfo ~= nil then
    if defenderInfo.orgid ~= nil then
      self.m_DefenderInfo.orgid = defenderInfo.orgid
    end
    if defenderInfo.orgname ~= nil then
      self.m_DefenderInfo.orgname = defenderInfo.orgname
      SendMessage(MsgID_BPWar_DefendName, defenderInfo.orgname)
    end
    if defenderInfo.tili ~= nil then
      self.m_DefenderInfo.tili = defenderInfo.tili
      SendMessage(MsgID_BPWar_DefendTili, defenderInfo.tili)
    end
  end
end
function BpWarMgr:receive_setTimeCountDown(t)
  print("receive_setTimeCountDown:", t)
  SendMessage(MsgID_BPWar_CountDown, t)
end
function BpWarMgr:receive_setProtectTimeCountDown(t)
  print("receive_setProtectTimeCountDown:", t)
  SendMessage(MsgID_BPWar_ProtectCountDown, t)
end
function BpWarMgr:receive_setBpWarSummarize(info)
  getCurSceneView():addSubView({
    subView = CBpWarSummarize.new(info),
    zOrder = MainUISceneZOrder.menuView
  })
end
function BpWarMgr:receive_setBpWarResult(info)
end
function BpWarMgr:addMapTreasure(data)
  local sceneid = data.sceneid
  if sceneid >= 200 and sceneid < 210 then
    local items = data.items
    for _, info in pairs(items) do
      local id = info.id
      self.m_TreasureData[id] = true
    end
    SendMessage(MsgID_BPWar_ItemNum, getTableLength(self.m_TreasureData))
  end
end
function BpWarMgr:delMapTreasure(sid, iid)
  if sid >= 200 and sid < 210 then
    self.m_TreasureData[iid] = nil
    SendMessage(MsgID_BPWar_ItemNum, getTableLength(self.m_TreasureData))
  end
end
function BpWarMgr:send_requestSignUp()
  if not self:_cdTimeControl("requestSignUp", 1) then
    return
  end
  netsend.netbangpaiwar.requestSignUp()
end
function BpWarMgr:send_submitMoney(money)
  if not self:_cdTimeControl("submitMoney", 1) then
    return
  end
  netsend.netbangpaiwar.submitMoney(money)
end
function BpWarMgr:send_gotoWarMap()
  if not self:_cdTimeControl("gotoWarMap", 1) then
    return
  end
  netsend.netbangpaiwar.gotoWarMap()
end
function BpWarMgr:send_launchBpFight(pid)
  if not self:_cdTimeControl("launchBpFight", 1) then
    return
  end
  netsend.netbangpaiwar.launchBpFight(pid)
end
function BpWarMgr:Clear()
end
g_BpWarMgr = BpWarMgr.new()
gamereset.registerResetFunc(function()
  if g_BpWarMgr then
    g_BpWarMgr:Clear()
  end
  g_BpWarMgr = BpWarMgr.new()
end)
