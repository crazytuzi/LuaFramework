g_DuleMatchingDlg = nil
CDuelMatching = class("CDuelMatching", CcsSubView)
function CDuelMatching:ctor(restTime, attackInfo, defenderInfo)
  CDuelMatching.super.ctor(self, "views/duelmatching.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_confirm = {
      listener = handler(self, self.Btn_Confirm),
      variName = "btn_confirm"
    },
    btn_cancel = {
      listener = handler(self, self.Btn_Cancel),
      variName = "btn_cancel"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_AttackItems = {}
  self.m_DefendItems = {}
  self.m_AttackInfo = {}
  self.m_DefendInfo = {}
  self.m_LocalPlayerIsCaptain = false
  self.m_RestTime = restTime
  if self.m_RestTime < 0 then
    self.m_RestTime = 0
  end
  self.m_Timer = scheduler.scheduleGlobal(handler(self, self.updateTimer), 0.5)
  self:setRestTime()
  self:setFightTeamInfo(attackInfo, true)
  self:setFightTeamInfo(defenderInfo, false)
  self:ListenMessage(MsgID_Activity)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_ReConnect)
  self:ListenMessage(MsgID_MapScene)
  if g_DuleMatchingDlg ~= nil then
    g_DuleMatchingDlg:CloseSelf()
    g_DuleMatchingDlg = nil
  end
  g_DuleMatchingDlg = self
end
function CDuelMatching:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Activity_DuelReady then
    local pid = arg[1]
    local ready = arg[2]
    self:updateReadyToCache(pid, ready, self.m_AttackInfo)
    self:updateReadyToCache(pid, ready, self.m_DefendInfo)
    if pid == g_LocalPlayer:getPlayerId() then
      self:setLocalReady(ready == 1)
    end
  elseif msgSID == MsgID_Activity_DuelNewPlayer then
    local data = arg[1]
    if data.flag == 1 then
      data.flag = nil
      self:addDataToCache(self.m_AttackInfo, data)
      self:setFightTeamInfo(self.m_AttackInfo, true)
    else
      data.flag = nil
      self:addDataToCache(self.m_DefendInfo, data)
      self:setFightTeamInfo(self.m_DefendInfo, false)
    end
  elseif msgSID == MsgID_Activity_DuelPlayerQuit then
    local pid = arg[1]
    if self:deleteFromCache(self.m_AttackInfo, pid) then
      self:setFightTeamInfo(self.m_AttackInfo, true)
    end
    if self:deleteFromCache(self.m_DefendInfo, pid) then
      self:setFightTeamInfo(self.m_DefendInfo, false)
    end
  elseif msgSID == MsgID_Activity_DuelStatus then
    if not g_DuleMgr:isWaitingForDule() then
      self:CloseSelf()
    end
  elseif msgSID == MsgID_Scene_War_Enter then
    self:CloseSelf()
  elseif msgSID == MsgID_ReConnect_ReLogin then
    self:CloseSelf()
    if g_MapMgr:IsInDuelMap() and g_DuleMgr:isWaitingForDule() then
      netsend.netactivity.getDuelMatchInfo()
    end
  elseif msgSID == MsgID_MapScene_ChangedMap and not g_MapMgr:IsInDuelMap() then
    self:CloseSelf()
  end
end
function CDuelMatching:addDataToCache(infoCache, data)
  for index, info in pairs(infoCache) do
    if info.pid == data.pid then
      table.remove(infoCache, index)
      break
    end
  end
  infoCache[#infoCache + 1] = data
end
function CDuelMatching:deleteFromCache(infoCache, pid)
  for index, info in pairs(infoCache) do
    if info.pid == pid then
      table.remove(infoCache, index)
      return true
    end
  end
  return false
end
function CDuelMatching:updateReadyToCache(pid, ready, infoCache)
  for index, info in pairs(infoCache) do
    if info.pid == pid then
      info.ready = ready
      break
    end
  end
end
function CDuelMatching:setRestTime()
  local restTime = math.floor(self.m_RestTime)
  local timetitle_1 = self:getNode("timetitle_1")
  local time = self:getNode("time")
  local timetitle_2 = self:getNode("timetitle_2")
  time:setText(tostring(restTime))
  local x, y = timetitle_1:getPosition()
  local size = timetitle_1:getContentSize()
  x = x + size.width + 3
  time:setPosition(ccp(x, y))
  local size2 = time:getContentSize()
  x = x + size2.width + 2
  timetitle_2:setPosition(ccp(x, y))
end
function CDuelMatching:_sortMatchFunc(a, b)
  if a.cp == 1 and b.cp ~= 1 then
    return true
  elseif a.cp ~= 1 and b.cp == 1 then
    return false
  elseif a.zs ~= b.zs then
    return a.zs > b.zs
  elseif a.lv ~= b.lv then
    return a.lv > b.lv
  else
    return a.pid < b.pid
  end
end
function CDuelMatching:ClearItems(itemList)
  for _, item in pairs(itemList) do
    item:removeFromParent()
  end
  itemList = {}
end
function CDuelMatching:setFightTeamInfo(info, isAttack)
  local tag = "att"
  local itemList
  if isAttack then
    self:ClearItems(self.m_AttackItems)
    self.m_AttackItems = {}
    itemList = self.m_AttackItems
    self.m_AttackInfo = info
  else
    tag = "def"
    self:ClearItems(self.m_DefendItems)
    self.m_DefendItems = {}
    itemList = self.m_DefendItems
    self.m_DefendInfo = info
  end
  local captainName
  info = info or {}
  table.sort(info, handler(self, self._sortMatchFunc))
  for index = 1, 5 do
    local posObj = self:getNode(string.format("pos_%s_%d", tag, index))
    posObj:setVisible(false)
    local parent = posObj:getParent()
    local x, y = posObj:getPosition()
    local data = info[index]
    local item = CDuelMatchingItem.new(data)
    parent:addChild(item.m_UINode, 10)
    item:setPosition(ccp(x, y))
    if data and index == 1 then
      captainName = data.name
    end
    if data and data.pid == g_LocalPlayer:getPlayerId() then
      if index == 1 then
        self.m_LocalPlayerIsCaptain = true
      end
      self:setLocalReady(data.ready == 1)
    end
    itemList[#itemList + 1] = item
  end
  local teamTitile = self:getNode(string.format("team_%s", tag))
  if captainName ~= nil then
    teamTitile:setVisible(true)
    teamTitile:setText(string.format("%s的队伍", captainName))
  else
    teamTitile:setVisible(false)
  end
end
function CDuelMatching:setLocalReady(readyFlag)
  readyFlag = not readyFlag
  self.btn_confirm:setTouchEnabled(readyFlag)
  self.btn_confirm:setBright(readyFlag)
  self.btn_cancel:setTouchEnabled(readyFlag)
  self.btn_cancel:setBright(readyFlag)
end
function CDuelMatching:updateTimer(dt)
  self.m_RestTime = self.m_RestTime - dt
  if self.m_RestTime < 0 then
    self.m_RestTime = 0
  end
  self:setRestTime()
end
function CDuelMatching:Btn_Confirm(obj, t)
  netsend.netactivity.declareDuel(1)
end
function CDuelMatching:Btn_Cancel(obj, t)
  local txt = "你确定要放弃本场决斗吗？"
  if self.m_LocalPlayerIsCaptain then
    txt = "你确定要放弃本场决斗吗？(一旦确定，本场决斗将被取消)"
  end
  self.m_CancelDlg = CPopWarning.new({
    title = "提示",
    text = txt,
    confirmFunc = function()
      netsend.netactivity.declareDuel(0)
    end,
    confirmText = "确定",
    cancelText = "取消",
    clearFunc = handler(self, self.onCancelDlgClosed)
  })
  self.m_CancelDlg:ShowCloseBtn(false)
end
function CDuelMatching:onCancelDlgClosed(dlg)
  if self.m_CancelDlg == dlg then
    self.m_CancelDlg = nil
  end
end
function CDuelMatching:Btn_Close(obj, t)
  self:CloseSelf()
end
function CDuelMatching:Clear()
  if g_DuleMatchingDlg == self then
    g_DuleMatchingDlg = nil
  end
  if self.m_Timer then
    scheduler.unscheduleGlobal(self.m_Timer)
    self.m_Timer = nil
  end
end
function ShowDuelMatching(restTime, attackInfo, defenderInfo)
  getCurSceneView():addSubView({
    subView = CDuelMatching.new(restTime, attackInfo, defenderInfo),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CloseDuelMatching(restTime, attackInfo, defenderInfo)
  if g_DuleMatchingDlg ~= nil then
    g_DuleMatchingDlg:CloseSelf()
    g_DuleMatchingDlg = nil
  end
end
