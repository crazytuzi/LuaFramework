g_YZDDDlg = nil
local CYZDDDlg = class("CYZDDDlg", CcsSubView)
function CYZDDDlg:ctor(info)
  CYZDDDlg.super.ctor(self, "views/yzdd.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Closed),
      variName = "btn_close"
    },
    btn_match = {
      listener = handler(self, self.Btn_Match),
      variName = "btn_match"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_LocalRank = -1
  self.m_RankVer = 0
  self.m_RankListData = {}
  self.m_StartLeftTime = info.lefttime or 0
  self.m_MatchTime = info.nexttime or 0
  self.m_Counter = 0
  self.ranklist = self:getNode("ranklist")
  self.ranklist:addLoadMoreListenerScrollView(function()
    self:LoadMoreRankInfo()
  end)
  self:setRankInfo(info.ver, info.lst)
  local firstWinItems = data_YiZhanDaoDi.FirstWin.Item or {}
  local itemType1, itemNum1
  for itemType, num in pairs(firstWinItems) do
    itemType1 = itemType
    itemNum1 = num
    break
  end
  local itempos1 = self:getNode("itempos1")
  local title_8 = self:getNode("title_8")
  if itemType1 ~= nil then
    itempos1:setVisible(false)
    local p = itempos1:getParent()
    local x, y = itempos1:getPosition()
    local item = createClickItem({itemID = itemType1, num = itemNum1})
    p:addChild(item)
    item:setPosition(ccp(x, y))
    self.m_FirstRewardItem = item
  else
    itempos1:setVisible(false)
    title_8:setVisible(false)
  end
  local finalWinItems = data_YiZhanDaoDi.FinalWin.Item or {}
  local itemType2, itemNum2
  for itemType, num in pairs(finalWinItems) do
    itemType2 = itemType
    itemNum2 = num
    break
  end
  local itempos2 = self:getNode("itempos2")
  local title_9 = self:getNode("title_9")
  if itemType2 ~= nil then
    itempos2:setVisible(false)
    local p = itempos2:getParent()
    local x, y = itempos2:getPosition()
    local item = createClickItem({itemID = itemType2, num = itemNum2})
    p:addChild(item)
    item:setPosition(ccp(x, y))
    self.m_FinalRewardItem = item
  else
    itempos2:setVisible(false)
    title_9:setVisible(false)
  end
  local firstwin_bonus = info.firstwin_bonus or 0
  local final_bonus = info.final_bonus or 0
  self:SetRewardInfo(firstwin_bonus, final_bonus)
  self:setYZDDStatus()
  self:UpdateStartLeftTime()
  self:UpdateMatchTime()
  self:setFailTimes(info.lostcnt or 0)
  self.m_UpdateHanler = scheduler.scheduleGlobal(handler(self, self.update), 1)
  self:ListenMessage(MsgID_Activity)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_Connect)
  self:ListenMessage(MsgID_MapScene)
  self:ListenMessage(MsgID_MapLoading)
end
function CYZDDDlg:onEnterEvent()
  self:LoadMoreRankInfo()
end
function CYZDDDlg:OnMessage(msgSID, ...)
  if msgSID == MsgID_Activity_YZDDStatus then
    if activity.yzdd:getStatus() == 1 or activity.yzdd:getStatus() == 3 then
      self:setYZDDStatus()
    else
      self:CloseSelf()
    end
  elseif msgSID == MsgID_Activity_YZDDUpdateInfo then
    local arg = {
      ...
    }
    local info = arg[1]
    self:SetRewardInfo(info.firstwin_bonus, info.final_bonus)
    self:setFailTimes(info.lostcnt)
  elseif msgSID == MsgID_Activity_YZDDUpdateRankInfo then
    local arg = {
      ...
    }
    local info = arg[1]
    self:ReloadRankList(info.ver, info.lst)
  elseif msgSID == MsgID_Activity_YZDDMatching then
    self:setYZDDStatus()
  elseif msgSID == MsgID_Scene_War_Enter then
    self:CloseSelf()
  elseif msgSID == MsgID_Connect_SendFinished then
    self:CloseSelf()
  elseif (msgSID == MsgID_MapScene_ChangedMap or msgSID == MsgID_MapLoading_Finished) and not g_MapMgr:IsInYiZhanDaoDiMap() then
    self:CloseSelf()
  end
end
function CYZDDDlg:setRankInfo(ver, lst)
  self.m_RankVer = ver or 0
  self.m_RankListData = lst or {}
  self.m_LocalRank = -1
  for rank, data in pairs(self.m_RankListData) do
    if data.pid == g_LocalPlayer:getPlayerId() then
      self.m_LocalRank = rank
      break
    end
  end
  if 0 < self.m_LocalRank then
    self:getNode("txt_rank"):setText(string.format("第%d名", self.m_LocalRank))
  else
    self:getNode("txt_rank"):setText("未能上榜")
  end
end
function CYZDDDlg:LoadMoreRankInfo()
  local anyData = false
  local cnt = self.ranklist:getCount()
  for rank = cnt + 1, cnt + 15 do
    local data = self.m_RankListData[rank]
    if data then
      local rankItem = CYZDDDlgItem.new(rank, data)
      self.ranklist:pushBackCustomItem(rankItem:getUINode())
      anyData = true
    else
      break
    end
  end
  if anyData then
    self.ranklist:refreshView()
    self.ranklist:setCanLoadMore(true)
  else
    self.ranklist:setCanLoadMore(false)
  end
end
function CYZDDDlg:ReloadRankList(ver, lst)
  self:setRankInfo(ver, lst)
  self.ranklist:removeAllItems()
  self:LoadMoreRankInfo()
end
function CYZDDDlg:SetRewardInfo(firstwin_bonus, final_bonus)
  if firstwin_bonus ~= nil and self.m_FirstRewardItem ~= nil then
    if firstwin_bonus == 1 then
      self:addReceiveIconForItem(self.m_FirstRewardItem)
    else
      self:clearReceiveIconForItem(self.m_FirstRewardItem)
    end
  end
  if final_bonus ~= nil and self.m_FinalRewardItem ~= nil then
    if final_bonus == 1 then
      self:addReceiveIconForItem(self.m_FinalRewardItem)
    else
      self:clearReceiveIconForItem(self.m_FinalRewardItem)
    end
  end
end
function CYZDDDlg:addReceiveIconForItem(item)
  if item._receiveIcon == nil then
    local icon = display.newSprite("views/pic/pic_mark_right.png")
    item:addNode(icon, 10)
    local size = item:getSize()
    icon:setPosition(ccp(size.width / 2 + 5, size.height / 2))
    item._receiveIcon = icon
  end
end
function CYZDDDlg:clearReceiveIconForItem(item)
  if item._receiveIcon ~= nil then
    item._receiveIcon:removeFromParent()
    item._receiveIcon = nil
  end
end
function CYZDDDlg:setYZDDStatus()
  if activity.yzdd:isMatching() then
    self:getNode("layerstart"):setVisible(true)
    self:getNode("endtip"):setVisible(false)
    self:getNode("matchingtip"):setVisible(true)
    self.btn_match:setVisible(false)
    self.btn_match:setTouchEnabled(false)
    self:getNode("warcd"):setVisible(false)
  else
    local status = activity.yzdd:getStatus()
    if status == 1 then
      self:getNode("layerstart"):setVisible(true)
      self:getNode("endtip"):setVisible(false)
      self:getNode("matchingtip"):setVisible(false)
      self.btn_match:setVisible(true)
      self.btn_match:setTouchEnabled(true)
      self:getNode("warcd"):setVisible(true)
    else
      self:getNode("layerstart"):setVisible(false)
      self:getNode("endtip"):setVisible(true)
      self:getNode("matchingtip"):setVisible(false)
      self.btn_match:setVisible(false)
      self.btn_match:setTouchEnabled(false)
      self:getNode("warcd"):setVisible(false)
    end
  end
end
function CYZDDDlg:setFailTimes(times)
  if times == nil then
    return
  end
  self:getNode("deadtxt"):setText(string.format("已死亡次数:%d/10", times))
end
function CYZDDDlg:UpdateStartLeftTime()
  if self.m_StartLeftTime > 0 then
    local m = math.floor(self.m_StartLeftTime / 60)
    local s = self.m_StartLeftTime % 60
    self:getNode("endtip"):setText(string.format("离活动开始还有%.2d:%.2d", m, s))
  else
    self:getNode("endtip"):setText("活动即将开始")
  end
end
function CYZDDDlg:UpdateMatchTime()
  if not activity.yzdd:isMatching() then
    if self.m_MatchTime > 0 then
      self:getNode("warcd"):setText(string.format("(%d)", self.m_MatchTime))
    else
      self:getNode("warcd"):setText("(请等待)")
    end
    self.btn_match:setVisible(true)
    self.btn_match:setTouchEnabled(true)
  end
end
function CYZDDDlg:update()
  if activity.yzdd:isMatching() then
    return
  end
  self.m_StartLeftTime = self.m_StartLeftTime - 1
  if self.m_StartLeftTime < 0 then
    self.m_StartLeftTime = 0
  end
  self:UpdateStartLeftTime()
  self.m_MatchTime = self.m_MatchTime - 1
  if 0 >= self.m_MatchTime and self.m_MatchTime % 3 == 0 and activity.yzdd:getStatus() == 1 then
    self:requestAutoMatch()
  end
  self:UpdateMatchTime()
end
function CYZDDDlg:Btn_Closed(obj, objType)
  self:CloseSelf()
end
function CYZDDDlg:Btn_Match(obj, objType)
  netsend.netactivity.sendMatchYZDD(1)
end
function CYZDDDlg:requestAutoMatch()
  if g_TeamMgr:getLocalPlayerTeamId() == 0 or g_TeamMgr:localPlayerIsCaptain() then
    netsend.netactivity.sendYZDDAutoMatch()
  end
end
function CYZDDDlg:Clear()
  if g_YZDDDlg == self then
    g_YZDDDlg = nil
  end
  if self.m_UpdateHanler ~= nil then
    scheduler.unscheduleGlobal(self.m_UpdateHanler)
    self.m_UpdateHanler = nil
  end
  if g_Click_Item_View ~= nil then
    g_Click_Item_View:removeFromParentAndCleanup(true)
    g_Click_Item_View = nil
  end
end
function ShowYiZhanDaoDiDlg()
  netsend.netactivity.sendRequestYZDDBaseInfo()
end
function ShowYZDDDlgWithBaseInfo(info)
  if g_YZDDDlg ~= nil then
    g_YZDDDlg:CloseSelf()
    g_YZDDDlg = nil
  end
  if g_WarScene ~= nil then
    return
  end
  g_YZDDDlg = getCurSceneView():addSubView({
    subView = CYZDDDlg.new(info),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CloseYZDDDlgWithBaseInfo()
  if g_YZDDDlg ~= nil then
    g_YZDDDlg:CloseSelf()
    g_YZDDDlg = nil
  end
end
