g_CLWZBDlg = nil
local CLWZBDlg = class("CLWZBDlg", CcsSubView)
function CLWZBDlg:ctor(info)
  CLWZBDlg.super.ctor(self, "views/lwzb.json", {isAutoCenter = true, opacityBg = 100})
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
  self.ranklist = self:getNode("ranklist")
  self.ranklist:addLoadMoreListenerScrollView(function()
    self:LoadMoreRankInfo()
  end)
  self:setRankInfo(info.ver, info.lst)
  local firstWinItems = data_LeitaiZhengbai.FirstWin.Item or {}
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
  local fiveWinItems = data_LeitaiZhengbai.FiveWin.Item or {}
  local itemType2, itemNum2
  for itemType, num in pairs(fiveWinItems) do
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
    self.m_FiveRewardItem = item
  else
    itempos2:setVisible(false)
    title_9:setVisible(false)
  end
  local firstwin_bonus = info.firstwin_bonus or 0
  local fivewin_bonus = info.fivewin_bonus or 0
  self:SetRewardInfo(firstwin_bonus, fivewin_bonus)
  self:setLeiTaiStatus()
  self:ListenMessage(MsgID_Activity)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_Connect)
end
function CLWZBDlg:onEnterEvent()
  self:LoadMoreRankInfo()
end
function CLWZBDlg:OnMessage(msgSID, ...)
  if msgSID == MsgID_Activity_LeiTaiStatus then
    self:setLeiTaiStatus()
  elseif msgSID == MsgID_Activity_LeiTaiUpdateReward then
    local arg = {
      ...
    }
    local info = arg[1]
    self:SetRewardInfo(info.firstwin_bonus, info.fivewin_bonus)
  elseif msgSID == MsgID_Activity_LeiTaiUpdateRankInfo then
    local arg = {
      ...
    }
    local info = arg[1]
    self:ReloadRankList(info.ver, info.lst)
  elseif msgSID == MsgID_Activity_LeiTaiMatching then
    local arg = {
      ...
    }
    local status = arg[1]
    if status == 1 then
      self:CloseSelf()
    end
  elseif msgSID == MsgID_Scene_War_Enter then
    self:CloseSelf()
  elseif msgSID == MsgID_Connect_SendFinished then
    ShowLeiWangZhengBaDlg()
  end
end
function CLWZBDlg:setRankInfo(ver, lst)
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
function CLWZBDlg:LoadMoreRankInfo()
  local anyData = false
  local cnt = self.ranklist:getCount()
  for rank = cnt + 1, cnt + 15 do
    local data = self.m_RankListData[rank]
    if data then
      local rankItem = CLWZBDlgItem.new(rank, data)
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
function CLWZBDlg:ReloadRankList(ver, lst)
  self:setRankInfo(ver, lst)
  self.ranklist:removeAllItems()
  self:LoadMoreRankInfo()
end
function CLWZBDlg:SetRewardInfo(firstwin_bonus, fivewin_bonus)
  if firstwin_bonus ~= nil and self.m_FirstRewardItem ~= nil then
    if firstwin_bonus == 1 then
      self:addReceiveIconForItem(self.m_FirstRewardItem)
    else
      self:clearReceiveIconForItem(self.m_FirstRewardItem)
    end
  end
  if fivewin_bonus ~= nil and self.m_FiveRewardItem ~= nil then
    if fivewin_bonus == 1 then
      self:addReceiveIconForItem(self.m_FiveRewardItem)
    else
      self:clearReceiveIconForItem(self.m_FiveRewardItem)
    end
  end
end
function CLWZBDlg:addReceiveIconForItem(item)
  if item._receiveIcon == nil then
    local icon = display.newSprite("views/pic/pic_mark_right.png")
    item:addNode(icon, 10)
    local size = item:getSize()
    icon:setPosition(ccp(size.width / 2 + 5, size.height / 2))
    item._receiveIcon = icon
  end
end
function CLWZBDlg:clearReceiveIconForItem(item)
  if item._receiveIcon ~= nil then
    item._receiveIcon:removeFromParent()
    item._receiveIcon = nil
  end
end
function CLWZBDlg:setLeiTaiStatus()
  local status = activity.leitai:getStatus()
  if status == 1 then
    self.btn_match:setVisible(true)
    self.btn_match:setTouchEnabled(true)
    self:getNode("tip"):setVisible(false)
  else
    self.btn_match:setVisible(false)
    self.btn_match:setTouchEnabled(false)
    self:getNode("tip"):setVisible(true)
  end
end
function CLWZBDlg:Btn_Closed(obj, objType)
  self:CloseSelf()
end
function CLWZBDlg:Btn_Match(obj, objType)
  netsend.netactivity.sendMatchLWZB(1)
end
function CLWZBDlg:Clear()
  if g_CLWZBDlg == self then
    g_CLWZBDlg = nil
  end
  if g_Click_Item_View ~= nil then
    g_Click_Item_View:removeFromParentAndCleanup(true)
    g_Click_Item_View = nil
  end
end
function ShowLeiWangZhengBaDlg()
  netsend.netactivity.sendRequestLWZBBaseInfo()
end
function ShowLeiWangZhengBaDlgWithBaseInfo(info)
  if g_CLWZBDlg ~= nil then
    g_CLWZBDlg:CloseSelf()
    g_CLWZBDlg = nil
  end
  g_CLWZBDlg = getCurSceneView():addSubView({
    subView = CLWZBDlg.new(info),
    zOrder = MainUISceneZOrder.menuView
  })
end
