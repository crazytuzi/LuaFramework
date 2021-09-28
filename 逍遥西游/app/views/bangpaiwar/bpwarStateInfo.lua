BpwarStateInfo = {}
function BpwarStateInfo.extend(object, posLayer, isMainUiFlag)
  function object:InitBpwarStateInfo(pLayer)
    object.__BpWarStateInfoPosLayer = pLayer
    object.__BpWarFlagIsMainUi = isMainUiFlag
    object.__BpWarStateInfoPosLayer:setTouchEnabled(false)
    object.__BpWarStateInfoDlgIsShow = false
    object:checkBpWarStateInfo()
  end
  function object:checkBpWarStateInfo()
    if g_MapMgr:IsInBangPaiWarMap() then
      if object.__BpWarStateInfoDlg == nil then
        object.__BpWarStateInfoDlg = CBpWarStateInfoDlg.new(object.__BpWarFlagIsMainUi)
        object.__BpWarStateInfoPosLayer:addChild(object.__BpWarStateInfoDlg.m_UINode)
      end
      object.__BpWarStateInfoPosLayer:setVisible(true)
      object.__BpWarStateInfoDlgIsShow = true
      if object.checkShowBpWarStateInfoDlg then
        object:checkShowBpWarStateInfoDlg()
      end
    else
      if object.__BpWarStateInfoDlg ~= nil then
        object.__BpWarStateInfoDlg:CloseSelf()
        object.__BpWarStateInfoDlg = nil
      end
      object.__BpWarStateInfoPosLayer:setVisible(false)
      object.__BpWarStateInfoDlgIsShow = false
      if object.checkShowBpWarStateInfoDlg then
        object:checkShowBpWarStateInfoDlg()
      end
    end
  end
  function object:clearBpWarStateInfo()
    if object.__BpWarStateInfoDlg ~= nil then
      object.__BpWarStateInfoDlg:setUIConfigViewClear(true)
      object.__BpWarStateInfoDlg:CloseSelf()
      object.__BpWarStateInfoDlg = nil
    end
  end
  object:InitBpwarStateInfo(posLayer)
end
CBpWarStateInfoDlg = class("CBpWarStateInfoDlg", CcsSubView)
function CBpWarStateInfoDlg:ctor(isMainUiFlag)
  CBpWarStateInfoDlg.super.ctor(self, "views/bpwarstateinfo.json")
  local btnBatchListener = {
    btn_help = {
      listener = handler(self, self.OnBtn_Help),
      variName = "btn_help"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_BpWarFlagIsMainUi = isMainUiFlag
  self.bpwar_timer = self:getNode("bpwar_timer")
  self.bpwar_attname = self:getNode("bpwar_attname")
  self.bpwar_atttili = self:getNode("bpwar_atttili")
  self.bpwar_defname = self:getNode("bpwar_defname")
  self.bpwar_deftili = self:getNode("bpwar_deftili")
  self.bpwar_itemnum = self:getNode("bpwar_itemnum")
  self.m_TimeCountDown = nil
  self:InitInfo()
  self.m_SchedulerHandler = scheduler.scheduleGlobal(handler(self, self.setLeftTime), 1)
  self:ListenMessage(MsgID_BPWar)
end
function CBpWarStateInfoDlg:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_BPWar_State then
    self:setLeftTime()
    if g_BpWarMgr:getBpWarState() ~= BPWARSTATE_READY then
      self:ClearTimeCountDown()
    end
  elseif msgSID == MsgID_BPWar_LeftTime then
    self:setLeftTime()
  elseif msgSID == MsgID_BPWar_AttackName then
    self.bpwar_attname:setText(string.format("红方:%s", arg[1]))
  elseif msgSID == MsgID_BPWar_AttackTili then
    self.bpwar_atttili:setText(string.format("人数:%s", arg[1]))
  elseif msgSID == MsgID_BPWar_DefendName then
    self.bpwar_defname:setText(string.format("蓝方:%s", arg[1]))
  elseif msgSID == MsgID_BPWar_DefendTili then
    self.bpwar_deftili:setText(string.format("人数:%s", arg[1]))
  elseif msgSID == MsgID_BPWar_ItemNum then
    self.bpwar_itemnum:setText(string.format("剩余宝箱：%d", arg[1]))
  elseif msgSID == MsgID_BPWar_CountDown then
    self:setTimeCountDown(arg[1])
    self:setLeftTime()
  elseif msgSID == MsgID_BPWar_ProtectCountDown and self.m_BpWarFlagIsMainUi == true then
    self:setProtectTimeCountDown(arg[1])
  end
end
function CBpWarStateInfoDlg:InitInfo()
  self:setLeftTime()
  local attInfo = g_BpWarMgr:getAttackerInfo()
  self.bpwar_attname:setText(string.format("红方:%s", attInfo.orgname or ""))
  self.bpwar_atttili:setText(string.format("人数:%d", attInfo.tili or 0))
  self.bpwar_attname:setColor(BpNameColorOfBpWarAttacker)
  self.bpwar_atttili:setColor(BpNameColorOfBpWarAttacker)
  local defInfo = g_BpWarMgr:getDefenderInfo()
  self.bpwar_defname:setText(string.format("蓝方:%s", defInfo.orgname or ""))
  self.bpwar_deftili:setText(string.format("人数:%d", defInfo.tili or 0))
  self.bpwar_defname:setColor(BpNameColorOfBpWarDefender)
  self.bpwar_deftili:setColor(BpNameColorOfBpWarDefender)
  local num = g_BpWarMgr:getItemNum()
  self.bpwar_itemnum:setText(string.format("剩余宝箱：%d", num))
end
function CBpWarStateInfoDlg:setLeftTime()
  local state = g_BpWarMgr:getBpWarState()
  local lefttime = g_BpWarMgr:getBpLeftTime()
  local h = math.floor(lefttime / 3600)
  lefttime = lefttime % 3600
  local m = math.floor(lefttime / 60)
  local s = lefttime % 60
  if state == BPWARSTATE_READY then
    if lefttime > 0 and self.m_TimeCountDown == nil then
      self.bpwar_timer:setText(string.format("开始倒计时: %.2d:%.2d:%.2d", h, m, s))
    else
      self.bpwar_timer:setText("开始倒计时: 即将开始……")
    end
  elseif state == BPWARSTATE_START then
    self.bpwar_timer:setText(string.format("剩余时间: %.2d:%.2d:%.2d", h, m, s))
  elseif state == BPWARSTATE_TREASURE then
    self.bpwar_timer:setText(string.format("离开时间: %.2d:%.2d:%.2d", h, m, s))
  else
    self.bpwar_timer:setText("剩余时间: 00:00:00")
  end
  local tilishow = state == BPWARSTATE_READY or state == BPWARSTATE_START
  self.bpwar_attname:setVisible(tilishow)
  self.bpwar_atttili:setVisible(tilishow)
  self.bpwar_defname:setVisible(tilishow)
  self.bpwar_deftili:setVisible(tilishow)
  self.bpwar_itemnum:setVisible(not tilishow)
end
function CBpWarStateInfoDlg:setTimeCountDown(time)
  self.m_TimeCountDown = time
  if g_BpWarMgr:getBpWarState() == BPWARSTATE_READY then
    if time >= 0 then
      if self.m_TimeCountDownText == nil then
        self.m_TimeCountDownText = CCLabelBMFont:create(tostring(self.m_TimeCountDown), "views/common/num/num_fnt/number2.fnt")
        self.m_TimeCountDownText:setAnchorPoint(ccp(0.5, 0.5))
        self.m_UINode:addNode(self.m_TimeCountDownText)
        local size = self.m_UINode:getSize()
        self.m_TimeCountDownText:setPosition(ccp(size.width / 2, -25))
      else
        self.m_TimeCountDownText:setVisible(true)
        self.m_TimeCountDownText:setString(tostring(self.m_TimeCountDown))
      end
      if self.m_SchedulerCountDown == nil then
        self.m_SchedulerCountDown = scheduler.scheduleGlobal(handler(self, self.updateTimeCountDown), 1)
      end
    elseif self.m_TimeCountDownText ~= nil then
      self.m_TimeCountDownText:setVisible(false)
    end
  elseif g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    self:ClearTimeCountDown()
  elseif self.m_TimeCountDownText ~= nil then
    self.m_TimeCountDownText:setVisible(false)
  end
end
function CBpWarStateInfoDlg:updateTimeCountDown()
  if self.m_TimeCountDown ~= nil then
    self:setTimeCountDown(self.m_TimeCountDown - 1)
  end
end
function CBpWarStateInfoDlg:ClearTimeCountDown()
  if self.m_TimeCountDownText ~= nil then
    self.m_TimeCountDownText:removeFromParent()
    self.m_TimeCountDownText = nil
  end
  if self.m_SchedulerCountDown then
    scheduler.unscheduleGlobal(self.m_SchedulerCountDown)
    self.m_SchedulerCountDown = nil
  end
end
function CBpWarStateInfoDlg:setProtectTimeCountDown(time)
  self.m_ProtectTimeCountDown = time
  if time > 0 then
    if self.m_ProtectTimeCountDownText == nil then
      self.m_ProtectTimeCountDownText = CCLabelBMFont:create(tostring(self.m_ProtectTimeCountDown), "views/common/num/num_fnt/number2.fnt")
      self.m_ProtectTimeCountDownText:setAnchorPoint(ccp(0.5, 0.5))
      self.m_UINode:addNode(self.m_ProtectTimeCountDownText)
      local size = self.m_UINode:getSize()
      self.m_ProtectTimeCountDownText:setPosition(ccp(size.width / 2, -25))
    else
      self.m_ProtectTimeCountDownText:setVisible(true)
      self.m_ProtectTimeCountDownText:setString(tostring(self.m_ProtectTimeCountDown))
    end
    if self.m_SchedulerProtectCountDown == nil then
      self.m_SchedulerProtectCountDown = scheduler.scheduleGlobal(handler(self, self.updateProtectTimeCountDown), 1)
    end
  else
    if self.m_ProtectTimeCountDownText ~= nil then
      self.m_ProtectTimeCountDownText:setVisible(false)
    end
    if self.m_SchedulerProtectCountDown then
      scheduler.unscheduleGlobal(self.m_SchedulerProtectCountDown)
      self.m_SchedulerProtectCountDown = nil
    end
  end
end
function CBpWarStateInfoDlg:updateProtectTimeCountDown()
  if self.m_ProtectTimeCountDown ~= nil then
    self:setProtectTimeCountDown(self.m_ProtectTimeCountDown - 1)
  end
end
function CBpWarStateInfoDlg:OnBtn_Help()
  getCurSceneView():addSubView({
    subView = CBpWarRule.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CBpWarStateInfoDlg:Clear()
  if self.m_SchedulerHandler then
    scheduler.unscheduleGlobal(self.m_SchedulerHandler)
    self.m_SchedulerHandler = nil
  end
  if self.m_SchedulerCountDown then
    scheduler.unscheduleGlobal(self.m_SchedulerCountDown)
    self.m_SchedulerCountDown = nil
  end
  if self.m_SchedulerProtectCountDown then
    scheduler.unscheduleGlobal(self.m_SchedulerProtectCountDown)
    self.m_SchedulerProtectCountDown = nil
  end
end
CBpWarRule = class("CBpWarRule", CcsSubView)
function CBpWarRule:ctor()
  CBpWarRule.super.ctor(self, "views/bpwarrule.json", {isAutoCenter = true, opacityBg = 0})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
end
function CBpWarRule:Btn_Close(obj, t)
  self:CloseSelf()
end
function CBpWarRule:Clear()
end
