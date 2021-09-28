CTeamItemInMainView = class("CTeamItemInMainView", CcsSubView)
function CTeamItemInMainView:ctor(index, teamId, pid)
  CTeamItemInMainView.super.ctor(self, "views/teamitem_mainview.json")
  self.m_TeamId = teamId
  self.m_PlayerId = pid
  self.txt_lv = self:getNode("txt_lv")
  self.txt_name = self:getNode("txt_name")
  self.pic_captain = self:getNode("pic_captain")
  self.pic_leave = self:getNode("pic_leave")
  self.pic_outline = self:getNode("pic_outline")
  self.headbg = self:getNode("headbg")
  self.bg = self:getNode("bg")
  self.m_InitSuccess = false
  local role = g_TeamMgr:getPlayerMainHero(pid)
  if role == nil then
    return
  end
  self.m_InitSuccess = true
  self:SetBaseInfo()
  local isCaptain = role:getProperty(PROPERTY_ISCAPTAIN)
  self:SetIsCaptain(isCaptain)
  local teamState = role:getProperty(PROPERTY_TEAMSTATE)
  self:SetTeamState(teamState)
  local online = role:getProperty(PROPERTY_TEAMSTATUS)
  self:SetTeamOnline(online)
  self:ListenMessage(MsgID_Team)
  self:ListenMessage(MsgID_OtherPlayer)
  self:ListenMessage(MsgID_PlayerInfo)
end
function CTeamItemInMainView:InitSuccess()
  return self.m_InitSuccess
end
function CTeamItemInMainView:SetBaseInfo()
  local role = g_TeamMgr:getPlayerMainHero(self.m_PlayerId)
  if role == nil then
    return
  end
  if self.m_HeadIcon ~= nil then
    self.m_HeadIcon:removeFromParentAndCleanup(true)
    self.m_HeadIcon = nil
  end
  local shapeID = role:getProperty(PROPERTY_SHAPE)
  local headParent = self.headbg:getParent()
  local hx, hy = self.headbg:getPosition()
  local zOrder = self.headbg:getZOrder()
  local scale = self.headbg:getScale()
  self.m_HeadIcon = createHeadIconByShape(shapeID)
  headParent:addNode(self.m_HeadIcon, zOrder + 1)
  self.m_HeadIcon:setScale(scale)
  self.m_HeadIcon:setPosition(ccp(hx, hy + 3))
  local name = role:getProperty(PROPERTY_NAME)
  self.txt_name:setText(name)
  local color = NameColor_MainHero[zs] or NameColor_MainHero[0]
  self.txt_name:setColor(color)
  local zs = role:getProperty(PROPERTY_ZHUANSHENG)
  local lv = role:getProperty(PROPERTY_ROLELEVEL)
  self.txt_lv:setText(string.format("%d转%d级", zs, lv))
end
function CTeamItemInMainView:OnMessage(msgSID, ...)
  if self.m_UINode == nil then
    return
  end
  local arg = {
    ...
  }
  if msgSID == MsgID_Team_TeamState then
    local pid = arg[2]
    if pid == self.m_PlayerId then
      local teamState = arg[3]
      self:SetTeamState(teamState)
    end
  elseif msgSID == MsgID_Team_PlayerOnline then
    local pid = arg[2]
    if pid == self.m_PlayerId then
      local online = arg[3]
      self:SetTeamOnline(online)
    end
  elseif msgSID == MsgID_Team_SetCaptain then
    local pid = arg[2]
    if pid == self.m_PlayerId then
      local isCaptain = arg[3]
      self:SetIsCaptain(isCaptain)
    end
  elseif msgSID == MsgID_OtherPlayer_UpdatePlayer then
    local pid = arg[1]
    if pid == self.m_PlayerId then
      self:SetBaseInfo()
    end
  elseif msgSID == MsgID_HeroUpdate then
    local data = arg[1]
    if data.pid == self.m_PlayerId and data.heroId == g_LocalPlayer:getMainHeroId() then
      local pro = data.pro
      if pro[PROPERTY_NAME] ~= nil or pro[PROPERTY_ROLELEVEL] ~= nil or pro[PROPERTY_ZHUANSHENG] ~= nil then
        self:SetBaseInfo()
      end
    end
  end
end
function CTeamItemInMainView:SetIsCaptain(isCaptain)
  self.m_IsCaptain = isCaptain
  if isCaptain == TEAMCAPTAIN_YES and not self.pic_outline:isVisible() then
    self.pic_captain:setVisible(true)
  else
    self.pic_captain:setVisible(false)
  end
end
function CTeamItemInMainView:SetTeamState(teamState)
  self.m_TeamState = teamState
  if teamState == TEAMSTATE_LEAVE and not self.pic_outline:isVisible() then
    self.pic_leave:setVisible(true)
  else
    self.pic_leave:setVisible(false)
  end
end
function CTeamItemInMainView:SetTeamOnline(online)
  if online == TEAMSTATUS_ONLINE then
    self.pic_outline:setVisible(false)
  else
    self.pic_outline:setVisible(true)
  end
  self:SetIsCaptain(self.m_IsCaptain)
  self:SetTeamState(self.m_TeamState)
end
function CTeamItemInMainView:getPlayerId()
  return self.m_PlayerId
end
function CTeamItemInMainView:isCaptainItem()
  return self.pic_captain:isVisible() or self.m_IsCaptain == TEAMCAPTAIN_YES and self.pic_outline:isVisible()
end
function CTeamItemInMainView:setTouchStatus(isTouch)
  self.bg:stopAllActions()
  if isTouch then
    self.bg:setScaleX(0.96)
    self.bg:setScaleY(0.96)
  else
    self.bg:setScaleX(1)
    self.bg:setScaleY(1)
    self.bg:runAction(transition.sequence({
      CCScaleTo:create(0.1, 1, 1),
      CCScaleTo:create(0.1, 1, 1)
    }))
  end
end
function CTeamItemInMainView:Clear()
end
CTeamPlayerBoard = class("CTeamPlayerBoard", CPlayerInfoOfMapBase)
function CTeamPlayerBoard:ctor(pid, closeListener)
  CTeamPlayerBoard.super.ctor(self, pid, "views/playerInfoOfTeam.json")
  local btnBatchListener = {
    btn_quitteam = {
      listener = handler(self, self.OnBtn_Menu_QuitTeam),
      variName = "btn_quitteam"
    },
    btn_leave = {
      listener = handler(self, self.OnBtn_Menu_Leave),
      variName = "btn_leave"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local role = g_TeamMgr:getPlayerMainHero(pid)
  if role then
    local name = role:getProperty(PROPERTY_NAME)
    local race = role:getProperty(PROPERTY_RACE)
    local zs = role:getProperty(PROPERTY_ZHUANSHENG)
    local lv = role:getProperty(PROPERTY_ROLELEVEL)
    local bpName = role:getProperty(PROPERTY_BPNAME)
    self:SetInfo(name, race, zs, lv, bpName)
  else
    self:HideInfo()
  end
  self:setTeamButton()
  self:updateSize()
  local arrow = display.newSprite("views/pic/pic_arrow_left.png")
  self:addNode(arrow, 999)
  arrow:setScaleX(-1)
  local bsize = self:getContentSize()
  arrow:setPosition(ccp(bsize.width + 5, bsize.height / 2))
  self.m_Arrrow = arrow
end
function CTeamPlayerBoard:updateSize()
  local offy = 0
  offy = self:adjustBtnPos({
    "btn_kickout"
  }, offy)
  offy = self:adjustBtnPos({
    "btn_makecaptain",
    "btn_requestcaptain"
  }, offy)
  offy = self:adjustBtnPos({
    "btn_friend",
    "btn_delfriend"
  }, offy)
  offy = self:adjustBtnPos({"btn_hyd"}, offy)
  offy = self:adjustBtnPos({"btn_chat"}, offy)
  if offy > 0 then
    self.bg = self:getNode("bg")
    local size = self.bg:getSize()
    local w = size.width
    local h = size.height - offy
    self.bg:setSize(CCSize(w, h))
    self.m_UINode:setSize(CCSize(w, h))
  end
end
function CTeamPlayerBoard:setTeamButton()
  if g_TeamMgr:getLocalPlayerTeamId() == 0 then
    self.btn_quitteam:setVisible(false)
    self.btn_quitteam:setEnabled(false)
    self.btn_leave:setVisible(false)
    self.btn_leave:setEnabled(false)
  elseif g_TeamMgr:localPlayerIsCaptain() then
    self.btn_quitteam:setTitleText("退队")
    self.btn_leave:setTitleText("召回")
  else
    local state = g_TeamMgr:getLocalPlayerTeamState()
    if state == TEAMSTATE_LEAVE then
      self.btn_quitteam:setTitleText("退队")
      self.btn_leave:setTitleText("归队")
    else
      self.btn_quitteam:setTitleText("退队")
      self.btn_leave:setTitleText("暂离")
    end
  end
end
function CTeamPlayerBoard:OnBtn_Menu_QuitTeam(obj, t)
  self:CloseSelf()
  g_TeamMgr:send_QuitTeam()
end
function CTeamPlayerBoard:OnBtn_Menu_Leave(obj, t)
  self:CloseSelf()
  if g_TeamMgr:localPlayerIsCaptain() then
    local callList = {}
    local teamId = g_TeamMgr:getLocalPlayerTeamId()
    local teamInfo = g_TeamMgr:getTeamInfo(teamId)
    for _, pid in pairs(teamInfo) do
      if g_TeamMgr:getPlayerTeamState(pid) == TEAMSTATE_LEAVE then
        callList[#callList + 1] = pid
      end
    end
    if #callList > 0 then
      g_TeamMgr:send_CallBackTeamPlayer(callList)
    else
      ShowNotifyTips("没有需要召回的队友", true)
    end
  else
    local state = g_TeamMgr:getLocalPlayerTeamState()
    if state == TEAMSTATE_LEAVE then
      g_TeamMgr:send_ComebackTeam()
    else
      g_TeamMgr:send_TempLeaveTeam()
    end
  end
end
function CTeamPlayerBoard:Clear()
  CTeamPlayerBoard.super.Clear(self)
  if self.m_CloseListener ~= nil then
    self.m_CloseListener()
  end
end
CTeamSelfBoard = class("CTeamSelfBoard", CcsSubView)
function CTeamSelfBoard:ctor(closeListener)
  CTeamSelfBoard.super.ctor(self, "views/playerInfoOfTeamSelf.json")
  local btnBatchListener = {
    btn_quitteam = {
      listener = handler(self, self.OnBtn_Menu_QuitTeam),
      variName = "btn_quitteam"
    },
    btn_leave = {
      listener = handler(self, self.OnBtn_Menu_Leave),
      variName = "btn_leave"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:setTeamButton()
  local arrow = display.newSprite("views/pic/pic_arrow_left.png")
  self:addNode(arrow, 999)
  arrow:setScaleX(-1)
  local bsize = self:getContentSize()
  arrow:setPosition(ccp(bsize.width + 5, bsize.height / 2))
  self:enableCloseWhenTouchOutside(self:getNode("bg"), true)
end
function CTeamSelfBoard:adjustPos()
end
function CTeamSelfBoard:setTeamButton()
  if g_TeamMgr:getLocalPlayerTeamId() == 0 then
    print("CTeamSelfBoard:没有组队？")
  elseif g_TeamMgr:localPlayerIsCaptain() then
    self.btn_quitteam:setTitleText("退队")
    self.btn_leave:setTitleText("召回")
  else
    local state = g_TeamMgr:getLocalPlayerTeamState()
    if state == TEAMSTATE_LEAVE then
      self.btn_quitteam:setTitleText("退队")
      self.btn_leave:setTitleText("归队")
    else
      self.btn_quitteam:setTitleText("退队")
      self.btn_leave:setTitleText("暂离")
    end
  end
end
function CTeamSelfBoard:OnBtn_Menu_QuitTeam(obj, t)
  self:CloseSelf()
  g_TeamMgr:send_QuitTeam()
end
function CTeamSelfBoard:OnBtn_Menu_Leave(obj, t)
  self:CloseSelf()
  if g_TeamMgr:localPlayerIsCaptain() then
    local callList = {}
    local teamId = g_TeamMgr:getLocalPlayerTeamId()
    local teamInfo = g_TeamMgr:getTeamInfo(teamId)
    for _, pid in pairs(teamInfo) do
      if g_TeamMgr:getPlayerTeamState(pid) == TEAMSTATE_LEAVE then
        callList[#callList + 1] = pid
      end
    end
    if #callList > 0 then
      g_TeamMgr:send_CallBackTeamPlayer(callList)
    else
      ShowNotifyTips("没有需要召回的队友", true)
    end
  else
    local state = g_TeamMgr:getLocalPlayerTeamState()
    if state == TEAMSTATE_LEAVE then
      g_TeamMgr:send_ComebackTeam()
    else
      g_TeamMgr:send_TempLeaveTeam()
    end
  end
end
function CTeamSelfBoard:Clear()
  CTeamSelfBoard.super.Clear(self)
  if self.m_CloseListener ~= nil then
    self.m_CloseListener()
    self.m_CloseListener = nil
  end
end
