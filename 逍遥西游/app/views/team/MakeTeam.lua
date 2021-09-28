g_MakeTeamDlg = nil
CD_ClickButtonUpdate = 1
function _TeamSortFunc(a, b)
  if a == nil and b == nil then
    return false
  elseif a == nil then
    return false
  elseif b == nil then
    return true
  end
  local hero_a = g_TeamMgr:getPlayerMainHero(a)
  local hero_b = g_TeamMgr:getPlayerMainHero(b)
  if hero_a == nil and hero_b == nil then
    return b < a
  elseif hero_a == nil then
    return false
  elseif hero_b == nil then
    return true
  else
    local isCaptain_a = hero_a:getProperty(PROPERTY_ISCAPTAIN)
    local isCaptain_b = hero_b:getProperty(PROPERTY_ISCAPTAIN)
    if isCaptain_a == TEAMCAPTAIN_YES then
      return true
    elseif isCaptain_b == TEAMCAPTAIN_YES then
      return false
    else
      local zs_a = hero_a:getProperty(PROPERTY_ZHUANSHENG)
      local zs_b = hero_b:getProperty(PROPERTY_ZHUANSHENG)
      if zs_a ~= zs_b then
        return zs_a > zs_b
      else
        local lv_a = hero_a:getProperty(PROPERTY_ROLELEVEL)
        local lv_b = hero_b:getProperty(PROPERTY_ROLELEVEL)
        if lv_a ~= lv_b then
          return lv_a > lv_b
        else
          return b < a
        end
      end
    end
  end
end
local CMakeTeam = class("CMakeTeam", CcsSubView)
function CMakeTeam:ctor(target)
  CMakeTeam.super.ctor(self, "views/maketeam.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_maketeam = {
      listener = handler(self, self.Btn_MakeTeam),
      variName = "btn_maketeam"
    },
    btn_quitTeam = {
      listener = handler(self, self.Btn_QuitTeam),
      variName = "btn_quitTeam"
    },
    btn_TeamTarget = {
      listener = handler(self, self.Btn_TeamTarget),
      variName = "btn_TeamTarget"
    },
    btn_joinrequest = {
      listener = handler(self, self.Btn_JoinRequest),
      variName = "btn_joinrequest"
    },
    btn_leave = {
      listener = handler(self, self.Btn_Leave),
      variName = "btn_leave"
    },
    btn_requestCaptain = {
      listener = handler(self, self.Btn_RequestCaptain),
      variName = "btn_requestCaptain"
    },
    btn_promulgate = {
      listener = handler(self, self.Btn_Promulgate),
      variName = "btn_promulgate"
    },
    btn_automatch = {
      listener = handler(self, self.Btn_AutoMatch),
      variName = "btn_automatch"
    },
    btn_selautomatch = {
      listener = handler(self, self.Btn_SelAutoMatch),
      variName = "btn_selautomatch"
    },
    btn_selautoconfirm = {
      listener = handler(self, self.Btn_SelAutoConfirm),
      variName = "btn_selautoconfirm"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_TeamTarget,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_joinrequest,
      nil,
      ccc3(251, 248, 145)
    }
  })
  self.layer_maketeam = self:getNode("layer_maketeam")
  local x, y = self.layer_maketeam:getPosition()
  self.layer_maketeam._InitPos = ccp(x, y)
  self.layer_searchteam = self:getNode("layer_searchteam")
  local x, y = self.layer_searchteam:getPosition()
  self.layer_searchteam._InitPos = ccp(x, y)
  self.title_right = self:getNode("title_right")
  self.list_teamtarget = self:getNode("list_teamtarget")
  self.list_myteam = self:getNode("list_myteam")
  self.list_joinrequest = self:getNode("list_joinrequest")
  self.list_teamnearby = self:getNode("list_teamnearby")
  self.list_teamkind = self:getNode("list_teamkind")
  self.icon_selautomatch = self:getNode("icon_selautomatch")
  self.title_selautomatch = self:getNode("title_selautomatch")
  self.icon_selautoconfirm = self:getNode("icon_selautoconfirm")
  self.title_selautoconfirm = self:getNode("title_selautoconfirm")
  self.title_teamnum = self:getNode("title_teamnum")
  self.m_TeamTargetItemList = {}
  self.m_LocalTeamItemList = {}
  self.m_JoinRequestItemList = {}
  self.m_TeamNearbyItemList = {}
  self.m_InitTarget = target
  self.m_LocalTeamId = 0
  self.m_TeamState = nil
  self.m_EverOpenPromulgateTeamInfoDlg = false
  self.m_HasInitTeamNearby = false
  self.m_HasInitTeamTarget = false
  self.m_JoinRequestListOfNoInfo = {}
  self.m_SelectTargetKind = -1
  self:InitAll()
  self:ListenMessage(MsgID_Team)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_OtherPlayer)
  g_MakeTeamDlg = self
end
function CMakeTeam:InitAll()
  self:InitMyTeam()
  self:CheckNewJoinTipIcon()
  self:SetAutoMatchingButton()
  self:SetAcceptAutoMatchIcon()
  self:SetAutoCaptainRequest()
end
function CMakeTeam:ReloadAll()
  self.m_TeamTargetItemList = {}
  self.m_LocalTeamItemList = {}
  self.m_JoinRequestItemList = {}
  self.m_TeamNearbyItemList = {}
  self.list_teamtarget:removeAllItems()
  self.list_myteam:removeAllItems()
  self.list_joinrequest:removeAllItems()
  self.list_teamnearby:removeAllItems()
  self.m_HasInitTeamNearby = false
  self.m_HasInitTeamTarget = false
  self.m_JoinRequestListOfNoInfo = {}
  self:SetTeamNearbyNum()
  self:InitAll()
  self:ClearPlayerInfoOfTeam()
end
function CMakeTeam:ShowLayer(showlayer)
  for _, layer in pairs({
    self.layer_maketeam,
    self.layer_searchteam
  }) do
    if showlayer == layer then
      layer:setVisible(true)
      local initPos = layer._InitPos
      layer:setPosition(initPos)
    else
      layer:setVisible(false)
      layer:setPosition(ccp(-10000, -10000))
    end
  end
end
function CMakeTeam:OnMessage(msgSID, ...)
  if self.m_UINode == nil then
    return
  end
  local arg = {
    ...
  }
  if msgSID == MsgID_Team_NewTeam then
    self:onReceiveNewTeam(arg[1], arg[2])
  elseif msgSID == MsgID_Team_PlayerJoinTeam then
    self:onReceiveNewTeamPlayer(arg[1], arg[2])
  elseif msgSID == MsgID_Team_PlayerLeaveTeam then
    self:onReceivePlayerLeaveTeam(arg[1], arg[2])
  elseif msgSID == MsgID_Team_SetCaptain then
    self:onReceiveCaptainChanged(arg[1], arg[3])
  elseif msgSID == MsgID_Team_TeamState then
    self:onReceiveTeamState(arg[1], arg[2], arg[3])
  elseif msgSID == MsgID_Team_AddJoinRequest then
    self:onReceiveAddJoinRequest(arg[1])
  elseif msgSID == MsgID_Team_DelJoinRequest then
    self:onReceiveDelJoinRequest(arg[1])
  elseif msgSID == MsgID_Team_ClearJoinRequest then
    self:onReceiveClearJoinRequest()
  elseif msgSID == MsgID_Team_NewPromulgateTeam then
    self:onReceiveNewPromulgateTeam(arg[1], arg[2])
  elseif msgSID == MsgID_Team_UpdatePromulgateTeam then
    self:onReceiveUpdatePromulgateTeam(arg[1], arg[2])
  elseif msgSID == MsgID_Team_DelPromulgateTeam then
    self:onReceiveDelPromulgateTeam(arg[1])
  elseif msgSID == MsgID_Team_ClearPromulgateTeam then
    self:onReceiveClearPromulgateTeam()
  elseif msgSID == MsgID_Team_PromulgateEffectTeam then
    self:onReceivePromulgateEffectTeam(arg[1], arg[2])
  elseif msgSID == MsgID_OtherPlayer_AddNewPlayer then
    self:onReceiveNewPlayerInfo(arg[1])
  elseif msgSID == MsgID_Scene_Open_PrivateChat then
    self:Btn_Close()
  elseif msgSID == MsgID_Team_IsAutoMatching then
    self:SetAutoMatchingButton()
  elseif msgSID == MsgID_Team_AcceptAutoMatch then
    self:SetAcceptAutoMatchIcon()
  elseif msgSID == MsgID_Team_AutoAgreeCaptainRequest then
    self:SetAutoCaptainRequest()
  end
end
function CMakeTeam:InitMyTeam()
  local teamId, teamInfo = g_TeamMgr:getLocalPlayerTeamInfo()
  print("====>>>本地玩家组队信息", teamId, teamInfo)
  if teamId == nil or teamId == 0 or teamInfo == nil or #teamInfo <= 0 then
    print("-->>本地玩家没有没有组")
    self.m_LocalTeamId = 0
    self:MyTeam_NoTeam()
  else
    print("-->>本地玩家已组队")
    self.m_LocalTeamId = teamId
    self:MyTeam_HasTeam(teamId, teamInfo)
    self:ClosePromulgateTeamInfo()
  end
end
function CMakeTeam:MyTeam_NoTeam()
  self.m_LocalTeamItemList = {}
  self.list_myteam:removeAllItems()
  self:ShowLayer(self.layer_searchteam)
  self:Show_TeamNearby()
  self.btn_maketeam:setEnabled(true)
  self.btn_quitTeam:setEnabled(false)
end
function CMakeTeam:MyTeam_HasTeam(teamId, teamInfo)
  self.m_LocalTeamItemList = {}
  self.list_myteam:removeAllItems()
  table.sort(teamInfo, _TeamSortFunc)
  for _, pid in pairs(teamInfo) do
    local item = CMyTeamItem.new(teamId, pid, pid == g_LocalPlayer:getPlayerId(), handler(self, self.ClickMyTeamPlayerMore))
    self.list_myteam:pushBackCustomItem(item:getUINode())
    self.m_LocalTeamItemList[#self.m_LocalTeamItemList + 1] = item
  end
  self.list_myteam:scrollToTop(0.01, false)
  self:ShowLayer(self.layer_maketeam)
  if g_TeamMgr:localPlayerIsCaptain() then
    self.btn_TeamTarget:setEnabled(true)
    self.btn_joinrequest:setEnabled(true)
    self.btn_leave:setEnabled(false)
    self.btn_requestCaptain:setEnabled(false)
    if g_TeamMgr:getExistNewJoinRequest() then
      self:Btn_JoinRequest(nil, nil, true)
    elseif g_TeamMgr:getTeamTarget() == nil then
      self:Btn_TeamTarget()
    else
      self:Btn_JoinRequest(nil, nil, true)
    end
  else
    self.btn_TeamTarget:setEnabled(false)
    self.btn_joinrequest:setEnabled(false)
    self.btn_leave:setEnabled(true)
    self.btn_requestCaptain:setEnabled(true)
    self:Btn_TeamTarget()
    self:setLeaveButton()
  end
  self.btn_maketeam:setEnabled(false)
  self.btn_quitTeam:setEnabled(true)
end
function CMakeTeam:setLeaveButton()
  if g_TeamMgr:getLocalPlayerTeamState() == TEAMSTATE_FOLLOW then
    self.btn_leave:setTitleText("暂离队伍")
  else
    self.btn_leave:setTitleText("回归队伍")
  end
end
function CMakeTeam:SetAutoMatchingButton()
  local autoFlag = g_TeamMgr:GetIsAutoMatching()
  if autoFlag then
    self.btn_automatch:setTitleText("取消匹配")
    local target = g_TeamMgr:GetIsAutoMatchingTarget()
    self.title_teamnum:setEnabled(true)
  else
    self.btn_automatch:setTitleText("自动匹配")
    self.title_teamnum:setEnabled(false)
  end
end
function CMakeTeam:SetAcceptAutoMatchIcon()
  self.icon_selautomatch:setEnabled(g_TeamMgr:GetAcceptAutoMatch() and self.btn_promulgate:isEnabled())
end
function CMakeTeam:SetAutoCaptainRequest()
  if not g_TeamMgr:localPlayerIsCaptain() then
    self.icon_selautoconfirm:setEnabled(false)
    self.title_selautoconfirm:setEnabled(false)
    self.btn_selautoconfirm:setEnabled(false)
  else
    self.icon_selautoconfirm:setEnabled(g_TeamMgr:getAutoAgreeCaptainRequest())
    self.title_selautoconfirm:setEnabled(true)
    self.btn_selautoconfirm:setEnabled(true)
  end
end
function CMakeTeam:SetTeamNearbyNum()
  local cnt = self.list_teamnearby:getCount()
  self.title_teamnum:setText(string.format("自动匹配中，队伍:%d", cnt))
end
function CMakeTeam:onReceiveNewTeam(teamId, captainId)
  print("====>>>CMakeTeam:onReceiveNewTeam ", teamId, captainId)
  if self.m_LocalTeamId == 0 then
    print("自本地玩家没有组队")
    local localPlayerId = g_LocalPlayer:getPlayerId()
    if g_TeamMgr:IsPlayerOfTeam(localPlayerId, teamId) then
      print("本地玩家进队")
      self:ReloadAll()
    end
  elseif self.m_LocalTeamId == teamId then
    print("新建的队伍是本地玩家的队伍?!!")
    self:ReloadAll()
  end
end
function CMakeTeam:onReceiveNewTeamPlayer(teamId, pid)
  print("====>>>CMakeTeam:onReceiveNewTeamPlayer ", teamId, pid)
  if self.m_LocalTeamId == 0 then
    print("===>>>本地玩家没有组队")
    if pid == g_LocalPlayer:getPlayerId() then
      self:ReloadAll()
    end
  elseif self.m_LocalTeamId == teamId then
    print("===>>玩家加入本地玩家的队伍,", pid)
    self:addPlayerToMyTeam(pid)
  end
end
function CMakeTeam:onReceivePlayerLeaveTeam(teamId, pid)
  if self.m_LocalTeamId ~= 0 and self.m_LocalTeamId == teamId then
    if pid == g_LocalPlayer:getPlayerId() then
      self:ReloadAll()
    else
      self:delPlayerFromMyTeam(pid)
    end
  end
end
function CMakeTeam:onReceiveCaptainChanged(teamId, isCaptain)
  if self.m_LocalTeamId ~= 0 and self.m_LocalTeamId == teamId and isCaptain == TEAMCAPTAIN_YES then
    self:ReloadAll()
  end
end
function CMakeTeam:onReceiveTeamState(teamId, pid, state)
  if pid == g_LocalPlayer:getPlayerId() then
    self:setLeaveButton()
  end
end
function CMakeTeam:addPlayerToMyTeam(pid)
  if self.m_LocalTeamId == 0 then
    return
  end
  for _, item in pairs(self.m_LocalTeamItemList) do
    if item:getPlayerId() == pid then
      return
    end
  end
  self:ClearPlayerInfoOfTeam()
  local item = CMyTeamItem.new(self.m_LocalTeamId, pid, pid == g_LocalPlayer:getPlayerId(), handler(self, self.ClickMyTeamPlayerMore))
  for index, itemObj in pairs(self.m_LocalTeamItemList) do
    local playerId = itemObj:getPlayerId()
    if _TeamSortFunc(pid, playerId) then
      self.list_myteam:insertCustomItem(item:getUINode(), index - 1)
      table.insert(self.m_LocalTeamItemList, index, item)
      return
    end
  end
  self.list_myteam:pushBackCustomItem(item:getUINode())
  self.m_LocalTeamItemList[#self.m_LocalTeamItemList + 1] = item
end
function CMakeTeam:delPlayerFromMyTeam(pid)
  self:ClearPlayerInfoOfTeam()
  for index, item in pairs(self.m_LocalTeamItemList) do
    if item:getPlayerId() == pid then
      table.remove(self.m_LocalTeamItemList, index)
      self.list_myteam:removeItem(index - 1)
      break
    end
  end
end
function CMakeTeam:ClickMyTeamPlayerMore(pid, wPos)
  self:ClearPlayerInfoOfTeam()
  local moreDlg = CPlayerInfoOfTeam.new(pid, handler(self, self.OnPlayerInfoOfTeamClosed))
  self:addChild(moreDlg:getUINode(), 9999)
  local pos = self:getUINode():convertToNodeSpace(wPos)
  local sizeDlg = moreDlg:getContentSize()
  moreDlg:setPosition(ccp(pos.x - sizeDlg.width - 50, pos.y - sizeDlg.height / 2))
  moreDlg:adjustPos()
  self.m_PlayerInfoOfTeam = moreDlg
end
function CMakeTeam:OnPlayerInfoOfTeamClosed()
  if self.m_PlayerInfoOfTeam ~= nil then
    self.m_PlayerInfoOfTeam = nil
  end
end
function CMakeTeam:ClearPlayerInfoOfTeam()
  if self.m_PlayerInfoOfTeam ~= nil then
    self.m_PlayerInfoOfTeam:CloseSelf()
    self.m_PlayerInfoOfTeam = nil
  end
end
function CMakeTeam:Init_JoinRequest()
  self.m_JoinRequestItemList = {}
  self.list_joinrequest:removeAllItems()
  local joinRequestList = g_TeamMgr:getJoinRequest()
  local noInfoList = {}
  self.m_JoinRequestListOfNoInfo = {}
  for _, pid in pairs(joinRequestList) do
    local role = g_TeamMgr:getPlayerMainHero(pid)
    if role ~= nil then
      local item = CJoinPlayerItem.new(pid, handler(self, self.OnClickJoinRequestPlayer))
      self.list_joinrequest:pushBackCustomItem(item:getUINode())
      self.m_JoinRequestItemList[#self.m_JoinRequestItemList + 1] = item
    else
      self.m_JoinRequestListOfNoInfo[pid] = true
      noInfoList[#noInfoList + 1] = pid
    end
  end
  if #noInfoList > 0 then
    netsend.netmap.reqPlayerInfo(noInfoList)
  end
  self.list_joinrequest:scrollToTop(0.01, false)
end
function CMakeTeam:Show_JoinRequest()
  self:Init_JoinRequest()
  self.list_teamtarget:setEnabled(false)
  self.list_joinrequest:setEnabled(true)
  self.list_teamkind:setEnabled(false)
  self.title_right:setText("入队申请")
  self.title_right:setEnabled(true)
  self:SetExistNewJoinRequest(false)
  self.btn_promulgate:setEnabled(false)
  self.icon_selautomatch:setEnabled(false)
  self.title_selautomatch:setEnabled(false)
  self.btn_selautomatch:setEnabled(false)
end
function CMakeTeam:ReloadJoinRequest()
  self:Show_JoinRequest()
end
function CMakeTeam:CheckNewJoinTipIcon()
  if not self.layer_maketeam:isVisible() or not self.list_joinrequest:isEnabled() then
    if g_TeamMgr:getExistNewJoinRequest() then
      self:SetExistNewJoinRequest(true)
    else
      self:SetExistNewJoinRequest(false)
    end
  else
    self:SetExistNewJoinRequest(false)
  end
end
function CMakeTeam:SetExistNewJoinRequest(showFlag)
  if showFlag then
    if self.m_NewJoinTipIcon == nil then
      self.m_NewJoinTipIcon = display.newSprite("views/pic/pic_tipnew.png")
      self.btn_joinrequest:addNode(self.m_NewJoinTipIcon, 10)
      local size = self.btn_joinrequest:getContentSize()
      self.m_NewJoinTipIcon:setPosition(size.width / 2 - 10, size.height / 2 - 10)
    end
    self.m_NewJoinTipIcon:setVisible(true)
  elseif self.m_NewJoinTipIcon then
    self.m_NewJoinTipIcon:setVisible(false)
  end
end
function CMakeTeam:OnClickJoinRequestPlayer(pid)
  if pid == g_LocalPlayer:getPlayerId() then
    self:ReloadJoinRequest()
    return
  end
  if self.m_LocalTeamId == 0 then
    ShowNotifyTips("组队后才能进行此操作")
    self:ReloadAll()
    return
  end
  if not g_TeamMgr:localPlayerIsCaptain() then
    ShowNotifyTips("队长才能邀请其他玩家")
    return
  end
  if g_TeamMgr:getTeamPlayerNum(self.m_LocalTeamId) >= GetTeamPlayerNumLimit() then
    ShowNotifyTips("队伍人数已满")
    return
  end
  if g_TeamMgr:checkJoinRequestIsEffect(pid) then
    g_TeamMgr:send_AgreeRequest(pid)
  else
    ShowNotifyTips("该申请已过期")
    self:ReloadJoinRequest()
  end
end
function CMakeTeam:onReceiveAddJoinRequest(ls)
  if self.layer_maketeam:isVisible() and self.list_joinrequest:isEnabled() then
    local noInfoList = {}
    for _, pid in pairs(ls) do
      local existFlag = false
      for _, tempItem in pairs(self.m_JoinRequestItemList) do
        if tempItem:getPlayerId() == pid then
          existFlag = true
          break
        end
      end
      if not existFlag then
        local role = g_TeamMgr:getPlayerMainHero(pid)
        if role then
          local item = CJoinPlayerItem.new(pid, handler(self, self.OnClickJoinRequestPlayer))
          self.list_joinrequest:pushBackCustomItem(item:getUINode())
          self.m_JoinRequestItemList[#self.m_JoinRequestItemList + 1] = item
        else
          self.m_JoinRequestListOfNoInfo[pid] = true
          noInfoList[#noInfoList + 1] = pid
        end
      end
    end
    if #noInfoList > 0 then
      netsend.netmap.reqPlayerInfo(noInfoList)
    end
  end
  self:CheckNewJoinTipIcon()
end
function CMakeTeam:onReceiveDelJoinRequest(pid)
  if self.layer_maketeam:isVisible() and self.list_joinrequest:isEnabled() then
    for index, item in pairs(self.m_JoinRequestItemList) do
      if item:getPlayerId() == pid then
        table.remove(self.m_JoinRequestItemList, index)
        self.list_joinrequest:removeItem(index - 1)
        break
      end
    end
  end
  self:CheckNewJoinTipIcon()
end
function CMakeTeam:onReceiveClearJoinRequest()
  if self.layer_maketeam:isVisible() and self.list_joinrequest:isEnabled() then
    self.m_JoinRequestItemList = {}
    self.list_joinrequest:removeAllItems()
  end
  self:SetExistNewJoinRequest(false)
end
function CMakeTeam:onReceiveNewPlayerInfo(pid)
  if self.m_JoinRequestListOfNoInfo[pid] ~= nil then
    local item = CJoinPlayerItem.new(pid, handler(self, self.OnClickJoinRequestPlayer))
    self.list_joinrequest:pushBackCustomItem(item:getUINode())
    self.m_JoinRequestItemList[#self.m_JoinRequestItemList + 1] = item
    self.m_JoinRequestListOfNoInfo[pid] = nil
  end
end
function CMakeTeam:IsCheckingJoinRequest()
  return self.layer_maketeam:isVisible() and self.list_joinrequest:isEnabled()
end
function CMakeTeam:Init_TeamNearby()
  if g_TeamMgr:GetIsAutoMatching() then
    self.m_InitTarget = g_TeamMgr:GetIsAutoMatchingTarget()
  end
  self.m_HasInitTeamNearby = true
  self.m_SelectTargetKind = -1
  self.list_teamkind:removeAllItems()
  self.list_teamkind:setEnabled(true)
  local teamTargetList = g_TeamMgr:getTeamTargetList()
  if not g_MapMgr:IsInYiZhanDaoDiMap() then
    table.insert(teamTargetList, 1, {
      0,
      {
        desc = "全部",
        level = 0,
        rebirth = 0,
        AlwaysJudgeLvFlag = 0
      }
    })
  end
  local initTargetId
  local initTargetLv = 0
  local initTargetZs = 0
  local initIndex = 1
  for index, d in pairs(teamTargetList) do
    local targetId = d[1]
    local info = d[2]
    local item = CTeamTargetItem.new(targetId, info, handler(self, self.OnSelectTargetKind))
    self.list_teamkind:pushBackCustomItem(item:getUINode())
    if self.m_InitTarget ~= nil and self.m_InitTarget == targetId or initTargetId == nil then
      initTargetId = targetId
      initTargetLv = info.level
      initTargetZs = info.rebirth
      initIndex = index
    end
  end
  initTargetId = initTargetId or 0
  local mainHero = g_LocalPlayer:getMainHero()
  local myLevel = mainHero:getProperty(PROPERTY_ROLELEVEL)
  local myZs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  if not data_Promulgate[initTargetId] then
    local data = {
      rebirth = 0,
      level = 0,
      AlwaysJudgeLvFlag = 0
    }
  end
  if data_judgeFuncOpen(myZs, myLevel, data.rebirth, data.level, data.AlwaysJudgeLvFlag) == false then
    ShowNotifyTips(string.format("等级不足%d转%d级", initTargetZs, initTargetLv))
    initTargetId = 0
    initTargetZs = 0
    initTargetLv = 0
    initIndex = 1
  end
  self:OnSelectTargetKind(initTargetId, initTargetZs, initTargetLv, true)
  self:ScrollToTargetKind(initIndex - 1)
end
function CMakeTeam:ScrollToTargetKind(index)
  self.list_teamkind:refreshView()
  local cnt = self.list_teamkind:getCount()
  local h = self.list_teamkind:getContentSize().height
  local ih = self.list_teamkind:getInnerContainerSize().height
  if h < ih then
    local y = (1 - (index + 0.5) / cnt) * ih - h / 2
    local percent = (1 - y / (ih - h)) * 100
    percent = math.max(percent, 0)
    percent = math.min(percent, 100)
    self.list_teamkind:scrollToPercentVertical(percent, 0.3, false)
  end
end
function CMakeTeam:OnSelectTargetKind(targetId, targetZs, targetLevel, isInit)
  if self.m_SelectTargetKind == targetId then
    return
  end
  if targetId == PromulgateTeamTarget_BangPai and not g_BpMgr:localPlayerHasBangPai() then
    ShowNotifyTips("加入帮派后才能寻找帮派队伍")
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  local myLevel = mainHero:getProperty(PROPERTY_ROLELEVEL)
  local myZs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  if not data_Promulgate[targetId] then
    local data = {
      rebirth = 0,
      level = 0,
      AlwaysJudgeLvFlag = 0
    }
  end
  if data_judgeFuncOpen(myZs, myLevel, data.rebirth, data.level, data.AlwaysJudgeLvFlag) == false then
    if alwaysJudgeLvFlag == 1 then
      ShowNotifyTips(string.format("等级不足%d级", targetLevel))
    else
      ShowNotifyTips(string.format("等级不足%d转%d级", targetZs, targetLevel))
    end
    return
  end
  self.m_SelectTargetKind = targetId
  self.m_TeamNearbyItemList = {}
  self.list_teamnearby:removeAllItems()
  local teamNearbyList = g_TeamMgr:getPromulgateTeams()
  for _, d in pairs(teamNearbyList) do
    local teamId = d[1]
    local info = d[2]
    if self.m_SelectTargetKind == 0 or self.m_SelectTargetKind == info.i_target then
      local item = CTeamCaptainItem.new(teamId, info, handler(self, self.OnClickTeamNearbyCaptain), handler(self, self.deleteTeamObjFromList_TeamNearby))
      self.list_teamnearby:pushBackCustomItem(item:getUINode())
      self.m_TeamNearbyItemList[#self.m_TeamNearbyItemList + 1] = item
    end
  end
  self.list_teamnearby:jumpToTop()
  local cnt = self.list_teamkind:getCount()
  for i = 0, cnt - 1 do
    local temp = self.list_teamkind:getItem(i)
    local tempItem = temp.m_UIViewParent
    if tempItem:getTargetId() == targetId then
      tempItem:SetSelected(true)
    else
      tempItem:SetSelected(false)
    end
  end
  if isInit ~= true and g_TeamMgr:GetIsAutoMatching() then
    g_TeamMgr:send_requestAutoMatch(true, targetId)
  end
  self:SetTeamNearbyNum()
end
function CMakeTeam:Show_TeamNearby()
  if not self.m_HasInitTeamNearby then
    self:Init_TeamNearby()
  end
  self.title_right:setText("组队目标")
  self.title_right:setEnabled(true)
  self:OpenPromulgateTeamInfo()
end
function CMakeTeam:OnClickTeamNearbyCaptain(teamId, pName)
  if self.m_LocalTeamId ~= 0 then
    ShowNotifyTips("你已经组队")
    self:ReloadAll()
    return
  end
  g_TeamMgr:send_ApplyToTeam(teamId, pName)
end
function CMakeTeam:ClearTeamNearby()
  self.m_TeamNearbyItemList = {}
  self.list_teamnearby:removeAllItems()
  self.list_teamkind:removeAllItems()
  self.m_HasInitTeamNearby = false
  self:SetTeamNearbyNum()
end
function CMakeTeam:onReceiveNewPromulgateTeam(teamId, info)
  if self.m_HasInitTeamNearby and (info.i_num == nil or info.i_num < GetTeamPlayerNumLimit(info.i_target)) then
    if self.m_SelectTargetKind == 0 or info.i_target == self.m_SelectTargetKind and (info.i_target ~= PromulgateTeamTarget_BangPai or info.i_orgid == g_BpMgr:getLocalPlayerBpId()) then
      self:deleteTeamFromList_TeamNearby(teamId)
      local ftime = info.i_time or 0
      local newItem = CTeamCaptainItem.new(teamId, info, handler(self, self.OnClickTeamNearbyCaptain), handler(self, self.deleteTeamObjFromList_TeamNearby))
      for index, item in pairs(self.m_TeamNearbyItemList) do
        local tId = item:getTeamId()
        local tInfo = item:getInfo()
        if g_TeamMgr:_PromulgateSortFunc({teamId, info}, {tId, tInfo}) then
          self.list_teamnearby:insertCustomItem(newItem:getUINode(), index - 1)
          table.insert(self.m_TeamNearbyItemList, index, newItem)
          self:SetTeamNearbyNum()
          return
        end
      end
      self.list_teamnearby:pushBackCustomItem(newItem:getUINode())
      self.m_TeamNearbyItemList[#self.m_TeamNearbyItemList + 1] = newItem
      self:SetTeamNearbyNum()
    else
      self:deleteTeamFromList_TeamNearby(teamId)
    end
  end
  if g_TeamMgr:getLocalPlayerTeamId() == teamId then
    if g_TeamMgr:localPlayerIsCaptain() then
      local targetId = g_TeamMgr:getTeamTarget()
      for _, item in pairs(self.m_TeamTargetItemList) do
        if item:getTargetId() == targetId then
          item:SetIsCurrTarget(true)
        else
          item:SetIsCurrTarget(false)
        end
      end
      if not self.list_joinrequest:isEnabled() then
        self:Btn_JoinRequest(nil, nil, true)
      end
    else
      self:onReceiveUpdatePromulgateTeam(teamId, info)
    end
  end
end
function CMakeTeam:onReceiveDelPromulgateTeam(teamId)
  self:deleteTeamFromList_TeamNearby(teamId)
end
function CMakeTeam:onReceiveClearPromulgateTeam()
  self.m_TeamNearbyItemList = {}
  self.list_teamnearby:removeAllItems()
  self:SetTeamNearbyNum()
end
function CMakeTeam:onReceivePromulgateEffectTeam(teamId, info)
  if self.m_HasInitTeamNearby then
    for index, item in pairs(self.m_TeamNearbyItemList) do
      if item:getTeamId() == teamId then
        return
      end
    end
    self:onReceiveNewPromulgateTeam(teamId, info)
  end
end
function CMakeTeam:deleteTeamFromList_TeamNearby(teamId)
  if self.m_HasInitTeamNearby then
    for index, item in pairs(self.m_TeamNearbyItemList) do
      if item:getTeamId() == teamId and item:getIsEffect() then
        table.remove(self.m_TeamNearbyItemList, index)
        self.list_teamnearby:removeItem(index - 1)
        self:SetTeamNearbyNum()
        break
      end
    end
  end
end
function CMakeTeam:deleteTeamObjFromList_TeamNearby(teamObj)
  if self.m_HasInitTeamNearby then
    for index, item in pairs(self.m_TeamNearbyItemList) do
      if item == teamObj then
        table.remove(self.m_TeamNearbyItemList, index)
        self.list_teamnearby:removeItem(index - 1)
        self:SetTeamNearbyNum()
        break
      end
    end
  end
end
function CMakeTeam:onReceiveUpdatePromulgateTeam(teamId, info)
  if teamId == g_TeamMgr:getLocalPlayerTeamId() then
    if not g_TeamMgr:localPlayerIsCaptain() then
      local currTarget = g_TeamMgr:getTeamTarget()
      if currTarget ~= nil then
        local info = data_getPromulgateInfo(currTarget)
        if info then
          local item = CTeamTargetItem.new(currTarget, info, handler(self, self.OnClickTeamTarget))
          item:SetSelectBtnIsEnabled(false)
          item:SetIsCurrTarget(true)
          self.list_teamtarget:removeAllItems()
          self.m_TeamTargetItemList = {}
          self.list_teamtarget:pushBackCustomItem(item:getUINode())
          self.m_TeamTargetItemList[#self.m_TeamTargetItemList + 1] = item
          self:SetTeamTarget(currTarget)
        end
      end
    end
  else
    local data = g_TeamMgr:getPromulgateTeamInfo(teamId)
    if self.m_SelectTargetKind ~= 0 and (data.i_target ~= self.m_SelectTargetKind or data.i_target == PromulgateTeamTarget_BangPai and data.i_orgid ~= g_BpMgr:getLocalPlayerBpId()) then
      self:deleteTeamFromList_TeamNearby(teamId)
    end
  end
end
function CMakeTeam:Init_TeamTarget()
  self.m_HasInitTeamTarget = true
  self.m_TeamTargetItemList = {}
  self.list_teamtarget:removeAllItems()
  self.m_SelectTeamTarget = g_TeamMgr:getTeamTarget()
  local currTarget = self.m_SelectTeamTarget
  if self.m_SelectTeamTarget == nil or self.m_SelectTeamTarget == 0 then
    self.m_SelectTeamTarget = self.m_SelectTargetKind
  end
  if self.m_SelectTeamTarget == nil or self.m_SelectTeamTarget == 0 then
    self.m_SelectTeamTarget = self.m_InitTarget
  end
  if g_TeamMgr:localPlayerIsCaptain() then
    local teamTargetList = g_TeamMgr:getTeamTargetList(self.m_SelectTeamTarget)
    for _, d in pairs(teamTargetList) do
      local targetId = d[1]
      local info = d[2]
      local item = CTeamTargetItem.new(targetId, info, handler(self, self.OnClickTeamTarget))
      self.list_teamtarget:pushBackCustomItem(item:getUINode())
      self.m_TeamTargetItemList[#self.m_TeamTargetItemList + 1] = item
      if targetId == currTarget then
        item:SetIsCurrTarget(true)
      end
    end
    self.list_teamtarget:jumpToTop()
    if self.m_SelectTeamTarget == nil or self.m_SelectTeamTarget <= 0 then
      local mainHero = g_LocalPlayer:getMainHero()
      local myLevel = mainHero:getProperty(PROPERTY_ROLELEVEL)
      local myZs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
      for _, item in ipairs(self.m_TeamTargetItemList) do
        local tid = item:getTargetId()
        if not data_Promulgate[tid] then
          local data = {
            rebirth = 0,
            level = 0,
            AlwaysJudgeLvFlag = 0
          }
        end
        if data_judgeFuncOpen(myZs, myLevel, data.rebirth, data.level, data.AlwaysJudgeLvFlag) then
          self:SetTeamTarget(tid)
          return
        end
      end
      self:SetTeamTarget(-1)
    else
      self:SetTeamTarget(self.m_SelectTeamTarget)
    end
  elseif currTarget ~= nil then
    local info = data_getPromulgateInfo(currTarget)
    if info then
      local item = CTeamTargetItem.new(currTarget, info, handler(self, self.OnClickTeamTarget))
      item:SetSelectBtnIsEnabled(false)
      item:SetIsCurrTarget(true)
      self.list_teamtarget:pushBackCustomItem(item:getUINode())
      self.m_TeamTargetItemList[#self.m_TeamTargetItemList + 1] = item
    end
    self:SetTeamTarget(currTarget)
  end
end
function CMakeTeam:Show_TeamTarget()
  if not self.m_HasInitTeamTarget then
    self:Init_TeamTarget()
  end
  self.list_teamtarget:setEnabled(true)
  self.list_joinrequest:setEnabled(false)
  self.list_teamkind:setEnabled(false)
  self.title_right:setText("组队目标")
  self.title_right:setEnabled(true)
  if g_TeamMgr:localPlayerIsCaptain() then
    self.btn_promulgate:setEnabled(true)
    self.title_selautomatch:setEnabled(true)
    self.btn_selautomatch:setEnabled(true)
    self:SetAcceptAutoMatchIcon()
  else
    self.btn_promulgate:setEnabled(false)
    self.title_selautomatch:setEnabled(false)
    self.btn_selautomatch:setEnabled(false)
    self.icon_selautomatch:setEnabled(false)
  end
end
function CMakeTeam:OnClickTeamTarget(targetId, targetZs, targetLevel)
  if self.m_SelectTeamTarget == targetId then
    return
  end
  if not g_TeamMgr:localPlayerIsCaptain() then
    return
  end
  if targetId == PromulgateTeamTarget_BangPai and not g_BpMgr:localPlayerHasBangPai() then
    ShowNotifyTips("加入帮派后才能发布该目标")
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  local myLevel = mainHero:getProperty(PROPERTY_ROLELEVEL)
  local myZs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  if not data_Promulgate[targetId] then
    local data = {
      rebirth = 0,
      level = 0,
      AlwaysJudgeLvFlag = 0
    }
  end
  if data_judgeFuncOpen(myZs, myLevel, data.rebirth, data.level, data.AlwaysJudgeLvFlag) then
  else
    if targetZs > myZs then
      ShowNotifyTips(string.format("转生次数不足%d次", targetZs))
      return
    end
    if targetLevel > myLevel then
      ShowNotifyTips(string.format("等级不足%d级", targetLevel))
      return
    end
  end
  self:SetTeamTarget(targetId)
end
function CMakeTeam:SetTeamTarget(targetId)
  self.m_SelectTeamTarget = targetId
  for _, item in pairs(self.m_TeamTargetItemList) do
    if item:getTargetId() == targetId then
      item:SetSelected(true)
    else
      item:SetSelected(false)
    end
  end
end
function CMakeTeam:Btn_Close(obj, t)
  self:CloseSelf()
end
function CMakeTeam:Btn_MakeTeam(obj, t)
  if self.m_LocalTeamId ~= 0 then
    self:ReloadAll()
    return
  end
  g_TeamMgr:send_CreateTeam()
end
function CMakeTeam:Btn_JoinRequest(obj, t, force)
  if not g_TeamMgr:localPlayerIsCaptain() then
    ShowNotifyTips("只有队长才能查看")
    return
  end
  local curTime = g_DataMgr:getServerTime()
  local lastTime = self.btn_joinrequest._lastClickTime or 0
  if curTime - lastTime < CD_ClickButtonUpdate and force ~= true then
    print("===>>>按太快了，不刷新了")
    return
  end
  self.btn_joinrequest._lastClickTime = curTime
  self:Show_JoinRequest()
  g_TeamMgr:setCheckJoinRequest(curTime)
  SendMessage(MsgID_Team_HasCheckJoinRequest)
  self:setGroupBtnSelected(self.btn_joinrequest)
end
function CMakeTeam:Btn_TeamTarget(obj, t)
  self:Show_TeamTarget()
  self:setGroupBtnSelected(self.btn_TeamTarget)
end
function CMakeTeam:Btn_Promulgate(obj, t)
  for _, item in ipairs(self.m_TeamTargetItemList) do
    if item:getSelected() then
      local tid = item:getTargetId()
      g_TeamMgr:send_PromulgateTeam(tid)
      return
    end
  end
  ShowNotifyTips("请先选择一个发布目标")
end
function CMakeTeam:Btn_Leave(obj, t)
  if g_TeamMgr:getLocalPlayerTeamState() == TEAMSTATE_FOLLOW then
    g_TeamMgr:send_TempLeaveTeam()
  else
    g_TeamMgr:send_ComebackTeam()
  end
end
function CMakeTeam:Btn_QuitTeam(obj, t)
  if self.m_LocalTeamId == 0 then
    print("没有组队，怎么退出?")
    self:ReloadAll()
    return
  end
  g_TeamMgr:send_QuitTeam()
end
function CMakeTeam:Btn_RequestCaptain(obj, t)
  if self.m_LocalTeamId == 0 then
    print("没有组队，怎么申请?")
    self:ReloadAll()
    return
  elseif g_TeamMgr:localPlayerIsCaptain() then
    print("你已经是队长，还申请干啥")
    self:ReloadAll()
    return
  end
  g_TeamMgr:send_RequestCaptain()
end
function CMakeTeam:Btn_AutoMatch()
  if self.m_LocalTeamId ~= 0 then
    print("已有队伍，为什么还会发出匹配要求")
    self:ReloadAll()
    return
  end
  local autoFlag = g_TeamMgr:GetIsAutoMatching()
  if autoFlag then
    g_TeamMgr:send_requestAutoMatch(false, self.m_SelectTargetKind)
  else
    g_TeamMgr:send_requestAutoMatch(true, self.m_SelectTargetKind)
  end
end
function CMakeTeam:Btn_SelAutoMatch()
  if g_TeamMgr:GetAcceptAutoMatch() then
    g_TeamMgr:send_acceptAutoMatch(false)
  else
    g_TeamMgr:send_acceptAutoMatch(true)
  end
end
function CMakeTeam:Btn_SelAutoConfirm()
  if g_TeamMgr:getAutoAgreeCaptainRequest() then
    g_TeamMgr:send_AutoConfirmCaptainRequest(false)
  else
    g_TeamMgr:send_AutoConfirmCaptainRequest(true)
  end
end
function CMakeTeam:OpenPromulgateTeamInfo()
  if not self.m_EverOpenPromulgateTeamInfoDlg then
    self.m_EverOpenPromulgateTeamInfoDlg = true
    g_TeamMgr:OnOpenPromulgateTeamInfo()
  end
end
function CMakeTeam:ClosePromulgateTeamInfo()
  if self.m_EverOpenPromulgateTeamInfoDlg then
    self.m_EverOpenPromulgateTeamInfoDlg = false
    g_TeamMgr:OnClosePromulgateTeamInfo()
  end
end
function CMakeTeam:Clear()
  print("======>>>> CMakeTeam:Clear!!")
  self:ClosePromulgateTeamInfo()
  if g_MakeTeamDlg == self then
    g_MakeTeamDlg = nil
  end
end
return CMakeTeam
