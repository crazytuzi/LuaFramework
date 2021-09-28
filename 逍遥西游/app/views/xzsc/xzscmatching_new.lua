g_CXZSCMatchingDlg = nil
CXZSCMatchingDlg = class("CXZSCMatchingDlg", CcsSubView)
function CXZSCMatchingDlg:ctor(info, teamScore)
  CXZSCMatchingDlg.super.ctor(self, "views/xzscmatching.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close"
    },
    btn_cancel = {
      listener = handler(self, self.Btn_Cancel),
      variName = "btn_cancel"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.mathingtip = self:getNode("mathingtip")
  self.m_CanCancel = false
  self:setFightTeamInfo(info, teamScore, true)
  if self.m_CanCancel == true then
    self.btn_cancel:setVisible(true)
    self.btn_cancel:setTouchEnabled(true)
    self.mathingtip:setVisible(false)
  else
    self.btn_cancel:setVisible(false)
    self.btn_cancel:setTouchEnabled(false)
    self.mathingtip:setVisible(true)
  end
  self:startRandomEnmeyAni()
  if not g_XZSCTestFlag then
    self:getNode("team_jf_m"):setVisible(false)
    self:getNode("team_jf_e"):setVisible(false)
  end
  self:ListenMessage(MsgID_Activity)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_ReConnect)
  self:ListenMessage(MsgID_MapScene)
end
function CXZSCMatchingDlg:setFightTeamInfo(info, teamScore, isLocalTeam)
  local _sortMatchFunc = function(a, b)
    if a.cp == 1 and b.cp ~= 1 then
      return true
    elseif a.cp ~= 1 and b.cp == 1 then
      return false
    elseif a.jf ~= b.jf then
      return a.jf > b.jf
    else
      return a.pid < b.pid
    end
  end
  local tag = "m"
  if not isLocalTeam then
    tag = "e"
  end
  info = info or {}
  table.sort(info, _sortMatchFunc)
  for index = 1, 5 do
    local headBg = self:getNode(string.format("head_%s%d", tag, index))
    local name = self:getNode(string.format("name_%s%d", tag, index))
    local star = self:getNode(string.format("score_%s%d", tag, index))
    local starImg = self:getNode(string.format("starimg_%s%d", tag, index))
    local jf = self:getNode(string.format("jf_%s%d", tag, index))
    local data = info[index]
    if data ~= nil then
      name:setVisible(true)
      star:setVisible(true)
      jf:setVisible(true)
      starImg:setVisible(true)
      headBg:setOpacity(255)
      local p = headBg:getParent()
      local x, y = headBg:getPosition()
      local s = headBg:getScale()
      local rTypeId = data.rtype
      local headObj = createHeadIconByRoleTypeID(rTypeId)
      p:addNode(headObj, 10)
      headObj:setPosition(ccp(x + HEAD_OFF_X * s, y + HEAD_OFF_Y * s))
      headObj:setScale(s)
      name:setText(data.name)
      AutoLimitObjSize(name, 110)
      star:setText(tostring(data.star or 0))
      jf:setText(tostring(data.score or 0))
      local x, y = star:getPosition()
      local ssize = star:getContentSize()
      local isize = starImg:getContentSize()
      x = x + ssize.width + isize.width / 2 + 3
      starImg:setPosition(ccp(x, y))
      x = x + isize.width / 2 + 5
      jf:setPosition(ccp(x, y))
      if not g_XZSCTestFlag then
        jf:setVisible(false)
      end
    else
      name:setVisible(false)
      star:setVisible(false)
      jf:setVisible(false)
      starImg:setVisible(false)
      headBg:setOpacity(102)
    end
    if index == 1 then
      self:getNode(string.format("teamflag_%s", tag)):setVisible(data and data.cp == 1)
      if data.pid == g_LocalPlayer:getPlayerId() then
        self.m_CanCancel = true
      end
    end
  end
  teamScore = teamScore or 0
  local teamJF = self:getNode(string.format("team_jf_%s", tag))
  teamJF:setText(string.format("当前实力:%d", teamScore))
end
function CXZSCMatchingDlg:setEnemyInfo(info, teamScore)
  self:stopRandomEnmeyAni()
  if self.mathingtip:isVisible() then
    self.mathingtip:stopAllActions()
    self.mathingtip:runAction(CCFadeOut:create(0.5))
    self.mathingtip:setVisible(false)
  end
  self.btn_cancel:setVisible(false)
  self.btn_cancel:setTouchEnabled(false)
  self.btn_close:setVisible(false)
  self.btn_close:setTouchEnabled(false)
  self:setFightTeamInfo(info, teamScore, false)
end
function CXZSCMatchingDlg:OnMessage(msgSID, ...)
  if msgSID == MsgID_Activity_XZSCEnemyInfo then
    local arg = {
      ...
    }
    local info = arg[1]
    local teamScore = arg[2]
    self:setEnemyInfo(info, teamScore)
  elseif msgSID == MsgID_Scene_War_Enter then
    self:CloseSelf()
  elseif msgSID == MsgID_Activity_XZSCStatus then
    local arg = {
      ...
    }
    local state = arg[1]
    if state == 2 then
      self:CloseSelf()
    end
  elseif msgSID == MsgID_Activity_XZSCMatching then
    local arg = {
      ...
    }
    local status = arg[1]
    if status == 2 then
      self:CloseSelf()
    end
  elseif msgSID == MsgID_ReConnect_ReLogin then
    self:CloseSelf()
  elseif msgSID == MsgID_MapScene_ChangedMap and not g_MapMgr:IsInXueZhanShaChangMap() then
    self:CloseSelf()
  end
end
function CXZSCMatchingDlg:startRandomEnmeyAni()
  self:getNode("teamflag_e"):setVisible(false)
  for index = 1, 5 do
    local name = self:getNode(string.format("name_e%d", index))
    local jf = self:getNode(string.format("jf_e%d", index))
    local star = self:getNode(string.format("score_e%d", index))
    local starImg = self:getNode(string.format("starimg_e%d", index))
    name:setVisible(false)
    jf:setVisible(false)
    star:setVisible(false)
    starImg:setVisible(false)
  end
  local typeIdList = data_getAllMainHeroTypeId()
  local act1 = CCCallFunc:create(function()
    for i = 1, 5 do
      local typeId = typeIdList[math.random(1, #typeIdList)]
      self:setEnemyHead(typeId, i)
    end
  end)
  local act2 = CCDelayTime:create(0.3)
  self:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
end
function CXZSCMatchingDlg:setEnemyHead(rTypeId, index)
  local head_e = self:getNode(string.format("head_e%d", index))
  if head_e == nil then
    return
  end
  if head_e._headObj then
    if head_e._rTypeId == rTypeId then
      return
    end
    head_e._headObj:removeFromParent()
    head_e._headObj = nil
  end
  local p = head_e:getParent()
  local x, y = head_e:getPosition()
  local s = head_e:getScale()
  local headObj_e = createHeadIconByRoleTypeID(rTypeId)
  p:addNode(headObj_e, 10)
  headObj_e:setPosition(ccp(x + HEAD_OFF_X * s, y + HEAD_OFF_Y * s))
  headObj_e:setScale(s)
  head_e._headObj = headObj_e
  head_e._rTypeId = rTypeId
end
function CXZSCMatchingDlg:stopRandomEnmeyAni()
  self:stopAllActions()
  for index = 1, 5 do
    local head_e = self:getNode(string.format("head_e%d", index))
    if head_e and head_e._headObj ~= nil then
      head_e._headObj:removeFromParentAndCleanup(true)
      head_e._headObj = nil
      head_e._rTypeId = nil
    end
  end
end
function CXZSCMatchingDlg:Btn_Close()
  self:CloseSelf()
end
function CXZSCMatchingDlg:Btn_Cancel()
  netsend.netactivity.matchXZSC(0)
end
function CXZSCMatchingDlg:Clear()
  if g_CXZSCMatchingDlg == self then
    g_CXZSCMatchingDlg = nil
  end
end
function ShowXZSCMatchingDlg(info, teamScore)
  if g_CXZSCMatchingDlg ~= nil then
    g_CXZSCMatchingDlg:CloseSelf()
    g_CXZSCMatchingDlg = nil
  end
  g_CXZSCMatchingDlg = getCurSceneView():addSubView({
    subView = CXZSCMatchingDlg.new(info, teamScore),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CloseXZSCMatchingDlg()
  if g_CXZSCMatchingDlg ~= nil then
    g_CXZSCMatchingDlg:CloseSelf()
    g_CXZSCMatchingDlg = nil
  end
end
