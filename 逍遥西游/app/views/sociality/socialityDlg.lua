socialityDlg = class("socialityDlg", CcsSubView)
function socialityDlg:ctor()
  socialityDlg.super.ctor(self, "views/sociality.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_group_local = {
      listener = handler(self, self.Btn_Group_Local),
      variName = "btn_group_local"
    },
    btn_group_team = {
      listener = handler(self, self.Btn_Group_Team),
      variName = "btn_group_team"
    },
    btn_group_faction = {
      listener = handler(self, self.Btn_Group_Faction),
      variName = "btn_group_faction"
    },
    btn_group_integration = {
      listener = handler(self, self.Btn_Group_Integration),
      variName = "btn_group_integration"
    },
    btn_group_sys = {
      listener = handler(self, self.Btn_Group_Sys),
      variName = "btn_group_sys"
    },
    btn_group_laba = {
      listener = handler(self, self.Btn_Group_Laba),
      variName = "btn_group_laba"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.btn_group_local:setTitleText("当\n前")
  self.btn_group_team:setTitleText("队\n伍")
  self.btn_group_faction:setTitleText("帮\n派")
  self.btn_group_integration:setTitleText("世\n界")
  self.btn_group_sys:setTitleText("系\n统")
  self.btn_group_laba:setTitleText("喇\n叭")
  self:addBtnSigleSelectGroup({
    {
      self.btn_group_team,
      "views/common/btn/btn_2words_shu_gray.png",
      ccc3(250, 246, 143)
    },
    {
      self.btn_group_faction,
      "views/common/btn/btn_2words_shu_gray.png",
      ccc3(250, 246, 143)
    },
    {
      self.btn_group_integration,
      "views/common/btn/btn_2words_shu_gray.png",
      ccc3(250, 246, 143)
    },
    {
      self.btn_group_local,
      "views/common/btn/btn_2words_shu_gray.png",
      ccc3(250, 246, 143)
    },
    {
      self.btn_group_sys,
      "views/common/btn/btn_2words_shu_gray.png",
      ccc3(250, 246, 143)
    },
    {
      self.btn_group_laba,
      "views/common/btn/btn_2words_shu_gray.png",
      ccc3(250, 246, 143)
    }
  })
  self:InitViews()
  socialityDlgExtend_Team.extend(self)
  socialityDlgExtend_BangPai.extend(self)
  socialityDlgExtend_Local.extend(self)
  socialityDlgExtend_Int.extend(self)
  socialityDlgExtend_Sys.extend(self)
  socialityDlgExtend_LaBa.extend(self)
  self:Btn_Group_Integration()
  self:checkShowLocalChannel()
  self:ListenMessage(MsgID_Message)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_MapLoading)
end
function socialityDlg:InitViews()
  self.m_CurrShowPage = nil
  self.layerteam = self:getNode("layerteam")
  self.layerbangpai = self:getNode("layerbangpai")
  self.layerlocal = self:getNode("layerlocal")
  self.layerintegration = self:getNode("layerintegration")
  self.layersys = self:getNode("layersys")
  self.layerlaba = self:getNode("layerlaba")
  for _, viewIns in pairs({
    self.layerteam,
    self.layerbangpai,
    self.layerintegration,
    self.layersys,
    self.layerlaba,
    self.layerlocal
  }) do
    viewIns:setVisible(true)
    local x, y = viewIns:getPosition()
    viewIns._initPos = ccp(x, y)
  end
  for _, btn in pairs({
    self.btn_group_local,
    self.btn_group_team,
    self.btn_group_faction,
    self.btn_group_integration,
    self.btn_group_sys,
    self.btn_group_laba
  }) do
    local x, y = btn:getPosition()
    btn._initPos = ccp(x, y)
  end
  self:setTouchEnabled(true)
  self:setVisible(false)
  local size = self:getContentSize()
  self.m_InitPos = ccp(-size.width - 20, display.height - size.height)
  self.m_ShowPos = ccp(0, display.height - size.height)
  self:setPosition(ccp(self.m_InitPos.x, self.m_InitPos.y))
  self.m_IsDlgShow = false
  local bgSize = self:getNode("bg"):getContentSize()
  local addH = bgSize.height - display.height
  local newSzie = CCSize(bgSize.width, display.height)
  self:getNode("bg"):setSize(newSzie)
  self:getNode("bg"):setPosition(ccp(0, addH))
end
function socialityDlg:resizeList(listObj)
  local offy = display.height - 640
  if offy ~= 0 then
    local size = listObj:getContentSize()
    listObj:setSize(CCSize(size.width, size.height + offy))
    local x, y = listObj:getPosition()
    listObj:setPosition(ccp(x, y - offy))
  end
end
function socialityDlg:ShowDlg()
  if self.m_IsDlgShow then
    return
  end
  self.m_IsDlgShow = true
  self:stopAllActions()
  local act1 = CCCallFunc:create(function()
    self:setVisible(true)
  end)
  local act2 = CCMoveTo:create(0.3, ccp(self.m_ShowPos.x, self.m_ShowPos.y))
  self:runAction(transition.sequence({act1, act2}))
  self:OnShowDlg_TeamExtend()
  g_FriendsMgr:send_onFriendListOpen()
  if g_FriendsDlg then
    g_FriendsDlg:HideDlg()
  end
end
function socialityDlg:HideDlg()
  if not self.m_IsDlgShow then
    return
  end
  self.m_IsDlgShow = false
  self:stopAllActions()
  local act1 = CCMoveTo:create(0.2, ccp(self.m_InitPos.x, self.m_InitPos.y))
  local act2 = CCCallFunc:create(function()
    self:setVisible(false)
  end)
  self:runAction(transition.sequence({act1, act2}))
  self:OnHideDlg_TeamExtend()
  ClearShowChatDetail()
  self:CloseAllKeyBoard()
end
function socialityDlg:ShowOrHideDlg()
  if self.m_IsDlgShow then
    self:HideDlg()
  else
    self:ShowDlg()
  end
end
function socialityDlg:getIsDlgShow()
  return self.m_IsDlgShow
end
function socialityDlg:CloseAllKeyBoard()
  if self.input_teamchat then
    self.input_teamchat:CloseTheKeyBoard()
  end
  if self.input_intchat then
    self.input_intchat:CloseTheKeyBoard()
  end
  if self.input_localchat then
    self.input_localchat:CloseTheKeyBoard()
  end
  if self.input_bpchat then
    self.input_bpchat:CloseTheKeyBoard()
  end
end
function socialityDlg:ShowPageView(pageView)
  for index, viewIns in pairs({
    self.layerteam,
    self.layerbangpai,
    self.layerintegration,
    self.layersys,
    self.layerlaba,
    self.layerlocal
  }) do
    if viewIns == pageView then
      viewIns:setVisible(true)
      viewIns:setPosition(ccp(viewIns._initPos.x, viewIns._initPos.y))
    else
      viewIns:setVisible(false)
      viewIns:setPosition(ccp(-10000, -10000))
    end
  end
  self.m_CurrShowPage = pageView
  self:CheckNeedUpdatingPromulgateTeamInfo_TeamExtend()
end
function socialityDlg:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Team_NewTeam then
    self:onReceiveNewTeam_TeamExtend(arg[1])
  elseif msgSID == MsgID_Team_PlayerJoinTeam then
    self:onReceivePlayerJoinTeam_TeamExtend(arg[1], arg[2])
  elseif msgSID == MsgID_Team_PlayerLeaveTeam then
    self:onReceivePlayerLeaveTeam_TeamExtend(arg[1], arg[2])
  elseif msgSID == MsgID_Team_CaptainChanged then
    self:onReceiveCaptainChanged_TeamExtend(arg[1], arg[2])
  elseif msgSID == MsgID_Team_NewPromulgateTeam then
    self:onReceiveNewPromulgateTeam_TeamExtend(arg[1], arg[2])
    self:onReceiveNewPromulgateTeam_BpExtend(arg[1], arg[2])
  elseif msgSID == MsgID_Team_DelPromulgateTeam then
    self:onReceiveDelPromulgateTeam_TeamExtend(arg[1])
    self:onReceiveDelPromulgateTeam_BpExtend(arg[1])
  elseif msgSID == MsgID_Team_ClearPromulgateTeam then
    self:onReceiveClearPromulgateTeam_TeamExtend()
    self:onReceiveClearPromulgateTeam_BpExtend()
  elseif msgSID == MsgID_Team_PromulgateEffectTeam then
    self:onReceivePromulgateEffectTeam_TeamExtend(arg[1], arg[2])
    self:onReceivePromulgateEffectTeam_BpExtend(arg[1], arg[2])
  elseif msgSID == MsgID_BP_LocalInfo then
    self:onReceiveBpLocalInfo_BpExtend(arg[1])
  elseif msgSID == MsgID_Message_CD_WorldChannel then
    self:onReceiveWorldChannelCD(arg[1])
  elseif msgSID == MsgID_Message_CD_BpChannel then
    self:onReceiveBpChannelCD(arg[1])
  elseif msgSID == MsgID_Message_CD_LocalChannel then
    self:onReceiveLocalChannelCD(arg[1])
  elseif msgSID == MsgID_HeroUpdate then
    local data = arg[1]
    local playerId = data.pid
    if g_LocalPlayer and playerId == g_LocalPlayer:getPlayerId() and data.pro[PROPERTY_ROLELEVEL] ~= nil then
      self:checkWorldChatFuncIsOpen()
      self:checkLocalChatFuncIsOpen()
    end
  elseif msgSID == MsgID_MapLoading_Finished then
    self:checkShowLocalChannel(true)
  end
end
function socialityDlg:checkShowLocalChannel(tipFlag)
  if not g_MessageMgr:isEnabledLocalChannelOfCurrMap() then
    if self.btn_group_local:isVisible() then
      self.btn_group_local:setVisible(false)
      self.btn_group_local:setTouchEnabled(false)
      self.input_localchat:SetFieldText("")
      self.input_localchat:CloseTheKeyBoard()
      self.list_localchat:removeAllItems()
      if self.m_CurrShowPage == self.layerlocal then
        self:Btn_Group_Integration()
      end
      if tipFlag == true then
        ShowNotifyTips("你离开了当前频道")
      end
    end
  else
    self.btn_group_local:setVisible(true)
    self.btn_group_local:setTouchEnabled(true)
  end
  local i = 1
  local btnList = {
    self.btn_group_local,
    self.btn_group_team,
    self.btn_group_faction,
    self.btn_group_integration,
    self.btn_group_sys,
    self.btn_group_laba
  }
  for index, btn in pairs(btnList) do
    if btn:isVisible() then
      local temp = btnList[i]
      local pos = temp._initPos
      btn:setPosition(pos)
      i = i + 1
    end
  end
end
function socialityDlg:OnClickMessage(obj, msgType, msgPram)
  if msgType == CRichText_MessageType_Item then
    if msgPram then
      local playerId = msgPram.playerId
      local itemId = msgPram.itemId
      local itemTypeId = msgPram.itemTypeId
      self:onCheckItemInMsg(playerId, itemId, itemTypeId)
    end
  elseif msgType == CRichText_MessageType_Pet then
    if msgPram then
      local playerId = msgPram.playerId
      local petId = msgPram.petId
      local petTypeId = msgPram.petTypeId
      self:onCheckPetInMsg(playerId, petId)
    end
  elseif msgType == CRichText_MessageType_BpVote then
    netsend.netbangpai.voteRejectBpLeader()
  elseif msgType == CRichText_MessageType_WatchWar then
    if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
      ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
      return
    end
    if msgPram then
      local warId = msgPram.warId
      local playerId = msgPram.playerId
      if warId and playerId then
        netsend.netteamwar.requestWatchPlayerWar(playerId, warId)
      end
    end
  elseif msgType == CRichText_MessageType_Skill then
    if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
      ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
      return
    end
    if msgPram then
      local playerId = msgPram.playerId
      local petId = msgPram.petId
      local skillId = msgPram.itemTypeId
      local petTypeId = msgPram.petTypeId
      local size = self:getSize()
      local delBtnFlag = false
      local isChatSys = true
      if g_Click_Skill_View ~= nil then
        g_Click_Skill_View:removeFromParentAndCleanup(true)
      end
      g_Click_Skill_View = CSkillDetailView.new(petId, skillId, false, {
        x = -size.width / 3,
        y = 0,
        w = size.width,
        h = size.height
      }, petTypeId, playerId, delBtnFlag, isBaitanPlayer, isChatSys)
    end
  elseif msgType == CRichText_MessageType_ToNPC then
    if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
      ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
      return
    end
    if g_WarScene then
      ShowNotifyTips("战斗中，不能跳转")
      return
    end
    if msgPram then
      local npcID = msgPram.npcId
      local param = msgPram.itemId
      local missType = msgPram.itemTypeId
      self:onCheckToNPCInMsg(npcID, param, missType)
    end
  end
end
function socialityDlg:onCheckToNPCInMsg(npcId, param, missType)
  if missType == CRichText_MessageNPC_MarryTree then
    g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
      if isSucceed then
        openMarryTreeView(param)
      end
    end)
  elseif missType == CRichText_MessageNPC_HunChe then
    if g_HunyinMgr and not g_HunyinMgr:IsInXunYouTime() then
      ShowNotifyTips("#<E:16>#你来晚了，巡游已结束。")
      return
    end
    if g_MapMgr and g_HunyinMgr then
      if g_MapMgr:getCurMapId() == MapId_Changan then
        local x, y = GetHuochePostition()
        if x ~= nil and y ~= nil then
          local mapView = g_MapMgr:getMapViewIns()
          if mapView then
            local gx, gy = mapView:getGridByPos(x, y)
            g_MapMgr:AutoRoute(MapId_Changan, {
              gx,
              128 - gy
            }, function(isSucceed)
            end)
          end
        end
      else
        g_MapMgr:AutoRouteToNpc(NPC_HongNiang_ID, function(isSucceed)
          if isSucceed then
            local mapView = g_MapMgr:getMapViewIns()
            local x, y = GetHuochePostition()
            if x ~= nil and y ~= nil and mapView then
              local gx, gy = mapView:getGridByPos(x, y)
              g_MapMgr:AutoRoute(MapId_Changan, {
                gx,
                128 - gy
              }, function(isSucceed)
              end)
            end
          end
        end, true)
      end
    end
  else
    print("前往到某个npc ---> 还没定义该类型任务：", param)
  end
end
function socialityDlg:onCheckItemInMsg(playerId, itemId, itemTypeId)
  print("-->>onCheckItemInMsg:", playerId, itemId, itemTypeId)
  ShowChatDetail_Item(playerId, itemId, itemTypeId)
end
function socialityDlg:onCheckPetInMsg(playerId, petId)
  print("-->>onCheckPetInMsg:", playerId, petId)
  ShowChatDetail_Pet(playerId, petId)
end
function socialityDlg:setCheckDetailDlg(dlg)
  if dlg == nil then
    return
  end
  local size = self.m_UINode:getContentSize()
  local x, y = self.m_UINode:getPosition()
  local s = self.m_UINode:getScale()
  dlg:setPosition(ccp(size.width * s, y))
end
function socialityDlg:Btn_Close(obj, t)
  self:HideDlg()
end
function socialityDlg:Btn_Group_Local(obj, t)
  if self.m_CurrShowPage ~= self.layerlocal then
    self:ShowPageView(self.layerlocal)
    self:SelectGroupBtnAtCurrPage()
  end
end
function socialityDlg:Btn_Group_Team(obj, t)
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Duiwu)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    self:SelectGroupBtnAtCurrPage()
    return
  end
  if self.m_CurrShowPage ~= self.layerteam then
    self:ShowPageView(self.layerteam)
    self:SelectGroupBtnAtCurrPage()
  end
end
function socialityDlg:Btn_Group_Faction(obj, t)
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_BangPai)
  if openFlag == false then
    if tips ~= nil then
      ShowNotifyTips(tips)
    end
    self:SelectGroupBtnAtCurrPage()
    return
  end
  if self.m_CurrShowPage ~= self.layerbangpai then
    self:ShowPageView(self.layerbangpai)
    self:SelectGroupBtnAtCurrPage()
  end
end
function socialityDlg:Btn_Group_Integration(obj, t)
  if self.m_CurrShowPage ~= self.layerintegration then
    self:ShowPageView(self.layerintegration)
    self:SelectGroupBtnAtCurrPage()
  end
end
function socialityDlg:Btn_Group_Sys()
  if self.m_CurrShowPage ~= self.layersys then
    self:ShowPageView(self.layersys)
    self:SelectGroupBtnAtCurrPage()
  end
end
function socialityDlg:Btn_Group_Mail()
  if self.m_CurrShowPage ~= self.layermail then
    self:ShowPageView(self.layermail)
    self:SelectGroupBtnAtCurrPage()
  end
  self:ShowMailPage(true)
end
function socialityDlg:Btn_Group_Laba()
  print("=================>>>> Btn_Group_Laba  ", self.layerlaba == nil)
  self.layerlaba:setVisible(true)
  if self.m_CurrShowPage ~= self.layerlaba then
    self:ShowPageView(self.layerlaba)
    self:SelectGroupBtnAtCurrPage()
  end
  self.layerlaba:setVisible(true)
end
function socialityDlg:IsInChannel_Sys()
  return self.m_CurrShowPage == self.layersys
end
function socialityDlg:IsInChannel_Laba()
  return self.m_CurrShowPage == self.layerlaba
end
function socialityDlg:SelectGroupBtnAtCurrPage()
  if self.m_CurrShowPage == self.layerteam then
    self:setGroupBtnSelected(self.btn_group_team)
  elseif self.m_CurrShowPage == self.layerbangpai then
    self:setGroupBtnSelected(self.btn_group_faction)
  elseif self.m_CurrShowPage == self.layerintegration then
    self:setGroupBtnSelected(self.btn_group_integration)
  elseif self.m_CurrShowPage == self.layersys then
    self:setGroupBtnSelected(self.btn_group_sys)
  elseif self.m_CurrShowPage == self.layerlaba then
    self:setGroupBtnSelected(self.btn_group_laba)
  elseif self.m_CurrShowPage == self.layerlocal then
    self:setGroupBtnSelected(self.btn_group_local)
  end
end
function socialityDlg:Clear()
  print("------->>>>>>>>socialityDlg clear")
  if g_SocialityDlg == self then
    g_SocialityDlg = nil
  end
  self.m_CurrShowPage = nil
  self:Clear_TeamExtend()
  self:Clear_IntExtend()
  self:Clear_BangPaiExtend()
  self:Clear_SysExtend()
  self:Clear_LocalExtend()
  self:Clear_LaBaExtend()
end
