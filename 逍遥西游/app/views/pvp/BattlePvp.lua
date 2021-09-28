CBattlePvp = class("CBattlePvp", CcsSubView)
function CBattlePvp:ctor()
  CBattlePvp.super.ctor(self, "views/battle.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_change = {
      listener = handler(self, self.Btn_Change),
      variName = "btn_change"
    },
    btn_rule = {
      listener = handler(self, self.Btn_Rule),
      variName = "btn_rule"
    },
    btn_leaderboard = {
      listener = handler(self, self.Btn_LeaderBoard),
      variName = "btn_leaderboard",
      param = {2}
    },
    btn_shop = {
      listener = handler(self, self.Btn_Shop),
      variName = "btn_shop",
      param = {2}
    },
    btn_treasure = {
      listener = handler(self, self.Btn_treasure),
      variName = "btn_treasure",
      param = {2}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_AllPlayers = {}
  self.m_Chance = 0
  self:InitViews()
  self:SetAttrTips()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_Pvp)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_MapScene)
  g_PvpMgr:send_requestPvpBaseInfo()
end
function CBattlePvp:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("bg_honour"), "reshonour")
end
function CBattlePvp:InitViews()
  self.txt_myrank_num = self:getNode("txt_myrank_num")
  self.txt_limit_num = self:getNode("txt_limit_num")
  self.txt_honour = self:getNode("txt_honour")
  self.txt_win = self:getNode("txt_win")
  self.list_log = self:getNode("list_log")
  self.txt_honour:setAnchorPoint(ccp(0.5, 0.5))
  self.txt_myrank_num:setVisible(false)
  self.txt_limit_num:setVisible(false)
  self.txt_win:setVisible(false)
  self.m_CurrHonour = g_LocalPlayer:getHonour()
  self:SetHonour(self.m_CurrHonour)
  for index = 1, 5 do
    local poslayer = self:getNode(string.format("personPos%d", index))
    poslayer:setVisible(false)
  end
  local box_honour = self:getNode("box_honour")
  box_honour:setTouchEnabled(false)
  local x, y = box_honour:getPosition()
  local z = box_honour:getZOrder()
  local size = box_honour:getSize()
  local parent = box_honour:getParent()
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_Honour))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  parent:addNode(tempImg, z)
  local box_liansheng = self:getNode("box_liansheng")
  local x, y = box_liansheng:getPosition()
  local z = box_liansheng:getZOrder()
  local size = box_liansheng:getSize()
  local parent = box_liansheng:getParent()
  local tempImg = display.newSprite("views/pic/pic_bwc_liansheng.png")
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  parent:addNode(tempImg, z)
end
function CBattlePvp:SetMyRank(rank)
  self.txt_myrank_num:setVisible(true)
  self.txt_myrank_num:setText(tostring(rank))
  self.m_rank = rank
end
function CBattlePvp:SetMyChance(chance)
  self.m_Chance = chance
  self.txt_limit_num:setVisible(true)
  self.txt_limit_num:setText(tostring(chance))
end
function CBattlePvp:SetHonour(honour)
  self.txt_honour:setText(tostring(honour))
  local _, y = self.txt_honour:getPosition()
  local size = self.txt_honour:getContentSize()
  local bgSize = self:getNode("bg_honour"):getContentSize()
  local bgX, _ = self:getNode("bg_honour"):getPosition()
  self.txt_honour:setPosition(ccp(bgX + bgSize.width / 2 - size.width / 2 - 5, y))
end
function CBattlePvp:SetPvpWin(win)
  self.txt_win:setVisible(true)
  self.txt_win:setText(tostring(win))
  local _, y = self.txt_win:getPosition()
  local size = self.txt_win:getContentSize()
  local bgSize = self:getNode("bg_win"):getContentSize()
  local bgX, _ = self:getNode("bg_win"):getPosition()
  self.txt_win:setPosition(ccp(bgX + bgSize.width / 2 - size.width / 2 - 5, y))
end
function CBattlePvp:SetEnemyList(enemylist)
  for _, pItem in pairs(self.m_AllPlayers) do
    pItem:removeFromParentAndCleanup(true)
  end
  self.m_AllPlayers = {}
  table.sort(enemylist, function(a, b)
    if a == nil or b == nil then
      return false
    end
    return a.i_rank < b.i_rank
  end)
  for index, data in ipairs(enemylist) do
    local poslayer = self:getNode(string.format("personPos%d", index))
    if poslayer then
      local parent = poslayer:getParent()
      local x, y = poslayer:getPosition()
      local z = poslayer:getZOrder()
      local pItem = CBattlePvpPlayer.new(data.i_pid, data.i_ltype, data.s_name, data.i_zs, data.i_level, data.i_rank, handler(self, self.OnClickPlayer))
      parent:addChild(pItem.m_UINode, z)
      pItem:setPosition(ccp(x, y))
      self.m_AllPlayers[#self.m_AllPlayers + 1] = pItem
      pItem:setVisible(false)
      pItem:runAction(transition.sequence({
        CCDelayTime:create(0.1),
        CCShow:create()
      }))
    end
  end
end
function CBattlePvp:SetPvpLog(loglist)
  self.list_log:removeAllItems()
  for index, log in ipairs(loglist) do
    local lastOneFlag = index == #loglist
    local item = CBattleLogItem.new(log, index, lastOneFlag)
    self.list_log:pushBackCustomItem(item.m_UINode)
  end
  self.list_log:refreshView()
  self.list_log:jumpToBottom()
end
function CBattlePvp:OnMessage(msgSID, ...)
  if self.m_UINode == nil then
    return
  end
  local arg = {
    ...
  }
  if msgSID == MsgID_Pvp_BaseInfo then
    local info = arg[1]
    if info.i_rank ~= nil then
      self:SetMyRank(info.i_rank)
    end
    if info.i_chance ~= nil then
      self:SetMyChance(info.i_chance)
    end
    if info.i_win ~= nil then
      self:SetPvpWin(info.i_win)
    end
    if info.ls_enemy ~= nil then
      self:SetEnemyList(info.ls_enemy)
    end
    if info.ls_log ~= nil then
      self:SetPvpLog(info.ls_log)
    end
  elseif msgSID == MsgID_Pvp_BWCFightNum then
    self:SetMyChance(arg[1])
  elseif msgSID == MsgID_HonourUpdate then
    local data = arg[1]
    local honour = data.newHonour
    self.m_LastHonour = self.m_CurrHonour
    self.m_CurrHonour = honour
    self:SetHonour(honour)
  elseif msgSID == MsgID_MapScene_AutoRoute then
    self:CloseSelf()
  end
end
function CBattlePvp:OnClickPlayer(pid, rank)
  local curTime = cc.net.SocketTCP.getTime()
  if self.m_LastClickTime ~= nil and curTime - self.m_LastClickTime < 0.5 then
    return
  end
  self.m_LastClickTime = curTime
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr and g_MapMgr:IsInBangPaiWarMap() then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if g_MapMgr and g_MapMgr:IsInYiZhanDaoDiMap() then
    ShowNotifyTips("当前地图无法使用此功能")
    return
  end
  if g_MapMgr and g_MapMgr:IsInXueZhanShaChangMap() then
    ShowNotifyTips("当前地图无法使用此功能")
    return
  end
  if g_LocalPlayer and g_LocalPlayer:getIsFollowTeamCommon() >= 0 then
    ShowNotifyTips("组队情况下,不能进行比武")
    return
  end
  if g_WarScene and g_WarScene:getIsWatching() then
    ShowNotifyTips("观战中，不能进行比武")
    return
  end
  if g_WarScene and g_WarScene:getIsReview() then
    ShowNotifyTips("回放中，不能进行比武")
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("在战斗中,不能进行比武")
    return
  end
  print("--->>>OnClickPlayer:", pid, rank)
  if 0 < self.m_Chance then
    g_PvpMgr:send_requestPvpFight(pid, rank)
  else
    BuyBWCNumWithGold()
  end
end
function CBattlePvp:OnBattlePvpShow()
  self:ShowBattlePvp(true)
end
function CBattlePvp:ShowBattlePvp(iShow)
  if self.m_UINode == nil then
    return
  end
  self:setVisible(iShow)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(iShow)
  end
end
function CBattlePvp:Btn_Close(obj, t)
  self:CloseSelf()
end
function CBattlePvp:Btn_Change(obj, t)
  if self.m_Chance > 0 then
    g_PvpMgr:send_requestNewEnemy()
  else
    BuyBWCNumWithGold()
  end
end
function CBattlePvp:Btn_Rule(obj, t)
  getCurSceneView():addSubView({
    subView = CPvpRule.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CBattlePvp:Btn_LeaderBoard(obj, t)
  local rankList = CPvpRankList.new(handler(self, self.OnBattlePvpShow))
  getCurSceneView():addSubView({
    subView = rankList,
    zOrder = MainUISceneZOrder.menuView
  })
  self:ShowBattlePvp(false)
end
function CBattlePvp:Btn_Shop(obj, t)
  getCurSceneView():addSubView({
    subView = PvpShopView.new(handler(self, self.OnBattlePvpShow)),
    zOrder = MainUISceneZOrder.menuView
  })
  self:ShowBattlePvp(false)
end
function CBattlePvp:Btn_treasure(obj, t)
  getCurSceneView():addSubView({
    subView = CBattallAwardView.new({
      ranking = self.m_rank
    }),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CBattlePvp:Clear()
end
function ShowBattlePvpDlg()
  getCurSceneView():addSubView({
    subView = CBattlePvp.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
