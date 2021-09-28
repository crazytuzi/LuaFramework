g_XZSCDlg = nil
g_XZSCTestFlag = false
local CXZSCDlg = class("CXZSCDlg", CcsSubView)
function CXZSCDlg:ctor(info)
  CXZSCDlg.super.ctor(self, "views/xzsc.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Closed),
      variName = "btn_close"
    },
    btn_match = {
      listener = handler(self, self.Btn_Match),
      variName = "btn_match"
    },
    btn_help_award = {
      listener = handler(self, self.Btn_Help_Award),
      variName = "btn_help_award"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_RankListData = {}
  self.m_RankListData = info.lst or {}
  self.ranklist = self:getNode("ranklist")
  self.ranklist:addLoadMoreListenerScrollView(function()
    self:LoadMoreRankInfo()
  end)
  local myRank = -1
  local localPlayerId = g_LocalPlayer:getPlayerId()
  for rank, d in pairs(self.m_RankListData) do
    if d.pid == localPlayerId then
      myRank = rank
      break
    end
  end
  if myRank > 0 then
    self:getNode("myrank"):setText(string.format("第%d名", myRank))
  else
    self:getNode("myrank"):setText("未上榜")
  end
  local starNum = info.star or 0
  self.m_StarNum = starNum
  self:getNode("mystar"):setText(tostring(starNum))
  self:setSumAward(starNum)
  local pos_honour = self:getNode("pos_honour")
  pos_honour:setVisible(false)
  local p = pos_honour:getParent()
  local x, y = pos_honour:getPosition()
  local size = pos_honour:getContentSize()
  local honourImg = display.newSprite(data_getResPathByResID(RESTYPE_Honour))
  p:addNode(honourImg)
  honourImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  honourImg:setScale(1)
  local pos_coin = self:getNode("pos_coin")
  pos_coin:setVisible(false)
  local p = pos_coin:getParent()
  local x, y = pos_coin:getPosition()
  local size = pos_coin:getContentSize()
  local coinImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  p:addNode(coinImg)
  coinImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  coinImg:setScale(0.65)
  self.m_AwardItemObj = {}
  for index, k in pairs({
    5,
    10,
    15,
    25
  }) do
    local itempos = self:getNode(string.format("itemwardpos_%d", index))
    local title = self:getNode(string.format("title_ward_%d", index))
    title:setText(string.format("%d战奖励", k))
    itempos:setVisible(false)
    local okFlag = false
    local d = data_XueZhanShaChangAward[string.format("War%d", k)]
    if d then
      local winItems = d.Item or {}
      local itemType, itemNum
      for iType, num in pairs(winItems) do
        itemType = iType
        itemNum = num
        break
      end
      if itemType ~= nil and itemNum ~= nil then
        local p = itempos:getParent()
        local x, y = itempos:getPosition()
        local item = createClickItem({itemID = itemType, num = itemNum})
        p:addChild(item)
        item:setPosition(ccp(x, y))
        self.m_AwardItemObj[k] = item
        local winFlag = info[string.format("war%d", k)] or 0
        self:SetRewardInfo(k, winFlag)
        okFlag = true
      end
    end
    if not okFlag then
      title:setVisible(false)
    end
  end
  self.m_LeftTime = info.lefttime or 0
  self:setXueZhanShaChangStatus()
  if g_XZSCTestFlag then
    local myscore = info.myscore or 0
    local team_score = info.team_score or 0
    self:getNode("txt_score"):setText(string.format("%d/%d", myscore, team_score))
    AutoLimitObjSize(self:getNode("txt_score"), 90)
  else
    self:getNode("title_score"):setVisible(false)
    self:getNode("bg_score"):setVisible(false)
    self:getNode("txt_score"):setVisible(false)
  end
  self:ListenMessage(MsgID_Activity)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_Connect)
  self:ListenMessage(MsgID_MapScene)
  self:ListenMessage(MsgID_MapLoading)
end
function CXZSCDlg:onEnterEvent()
  self:LoadMoreRankInfo()
end
function CXZSCDlg:OnMessage(msgSID, ...)
  if msgSID == MsgID_Activity_XZSCStatus then
    self:setXueZhanShaChangStatus()
  elseif msgSID == MsgID_Activity_XZSCMatching then
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
    self:CloseSelf()
  elseif msgSID == MsgID_MapScene_ChangedMap or msgSID == MsgID_MapLoading_Finished then
    if not g_MapMgr:IsInXueZhanShaChangMap() then
      self:CloseSelf()
    end
  elseif msgSID == MsgID_Activity_XZSCUpdateInfo then
    local arg = {
      ...
    }
    local info = arg[1] or {}
    if info.war10 ~= nil then
      self:SetRewardInfo(10, info.war10)
    end
    if info.war15 ~= nil then
      self:SetRewardInfo(15, info.war15)
    end
    if info.war20 ~= nil then
      self:SetRewardInfo(20, info.war20)
    end
    if info.war30 ~= nil then
      self:SetRewardInfo(30, info.war30)
    end
    if info.star ~= nil then
      self:getNode("mystar"):setText(tostring(info.star))
      self:setSumAward(info.star)
    end
  end
end
function CXZSCDlg:LoadMoreRankInfo()
  local anyData = false
  local cnt = self.ranklist:getCount()
  for rank = cnt + 1, cnt + 15 do
    local data = self.m_RankListData[rank]
    if data then
      local rankItem = CXZSCDlgItem.new(rank, data)
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
function CXZSCDlg:setSumAward(starNum)
  local item_sum = self:getNode("item_sum")
  item_sum:setVisible(false)
  if self.m_ItemSum ~= nil then
    self.m_ItemSum:removeFromParent()
    self.m_ItemSum = nil
  end
  starNum = starNum or 0
  if starNum < 0 then
    starNum = 0
  end
  local _sortDataFunc = function(a, b)
    if a == nil or b == nil then
      if a ~= nil then
        return true
      elseif b ~= nil then
        return false
      else
        return false
      end
    end
    return a[1] < b[1]
  end
  local dataList = {}
  for k, v in pairs(data_XueZhanShaChangStarAward) do
    if v.Honour ~= "" and v.Coin ~= "" then
      dataList[#dataList + 1] = {k, v}
    end
  end
  table.sort(dataList, _sortDataFunc)
  local data
  for _, d in pairs(dataList) do
    local k = d[1]
    local v = d[2]
    if starNum < k then
      break
    end
    data = v
  end
  if data ~= nil then
    Star = starNum
    local honour = math.floor(loadstring("return " .. data.Honour)())
    local coin = math.floor(loadstring("return " .. data.Coin)())
    Star = nil
    self:getNode("txt_honour"):setText(tostring(honour))
    self:getNode("txt_coin"):setText(tostring(coin))
    local itemType, itemNum
    for iType, iNum in pairs(data.Item) do
      itemType = iType
      itemNum = iNum
      break
    end
    if itemType ~= nil and itemNum ~= nil then
      local p = item_sum:getParent()
      local x, y = item_sum:getPosition()
      local item = createClickItem({itemID = itemType, num = itemNum})
      p:addChild(item)
      item:setPosition(ccp(x, y))
      self.m_ItemSum = item
    end
  else
    self:getNode("txt_honour"):setText("0")
    self:getNode("txt_coin"):setText("0")
  end
end
function CXZSCDlg:SetRewardInfo(k, wardFlag)
  if wardFlag == 1 then
    self:addReceiveIconForItem(self.m_AwardItemObj[k])
  else
    self:clearReceiveIconForItem(self.m_AwardItemObj[k])
  end
end
function CXZSCDlg:addReceiveIconForItem(item)
  if item and item._receiveIcon == nil then
    local icon = display.newSprite("views/common/btn/selected.png")
    item:addNode(icon, 10)
    local size = item:getSize()
    icon:setPosition(ccp(size.width / 2 + 8, size.height / 2 - 3))
    item._receiveIcon = icon
  end
end
function CXZSCDlg:clearReceiveIconForItem(item)
  if item and item._receiveIcon ~= nil then
    item._receiveIcon:removeFromParent()
    item._receiveIcon = nil
  end
end
function CXZSCDlg:setXueZhanShaChangStatus()
  local status = activity.xzsc:getStatus()
  if status == 1 then
    self.btn_match:setVisible(true)
    self.btn_match:setTouchEnabled(true)
    self:getNode("tip"):setVisible(false)
    self:stopTimer()
  elseif status == 3 then
    self.btn_match:setVisible(false)
    self.btn_match:setTouchEnabled(false)
    self:getNode("tip"):setVisible(true)
    self:startTimer()
    self:setLeftTime()
  else
    self.btn_match:setVisible(false)
    self.btn_match:setTouchEnabled(false)
    self:getNode("tip"):setVisible(false)
    self:stopTimer()
  end
end
function CXZSCDlg:setLeftTime()
  if self.m_LeftTime > 0 then
    if self.m_LeftTime >= 60 then
      local min = math.floor(self.m_LeftTime / 60)
      self:getNode("tip"):setText(string.format("%d 分钟后开启", min))
    else
      self:getNode("tip"):setText(string.format("%d 秒后开启", self.m_LeftTime))
    end
  else
    self:getNode("tip"):setText("血战沙场即将开启")
  end
end
function CXZSCDlg:startTimer()
  if self.m_Timer == nil then
    self.m_Timer = scheduler.scheduleGlobal(handler(self, self.updateTimer), 1)
  end
end
function CXZSCDlg:stopTimer()
  if self.m_Timer ~= nil then
    scheduler.unscheduleGlobal(self.m_Timer)
    self.m_Timer = nil
  end
end
function CXZSCDlg:updateTimer(dt)
  self.m_LeftTime = self.m_LeftTime - dt
  self:setLeftTime()
end
function CXZSCDlg:Btn_Closed(obj, objType)
  self:CloseSelf()
end
function CXZSCDlg:Btn_Match(obj, objType)
  netsend.netactivity.matchXZSC(1)
end
function CXZSCDlg:Btn_Help_Award()
  getCurSceneView():addSubView({
    subView = CXZSCRule_Award.new(self.m_StarNum),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CXZSCDlg:Clear()
  self:stopTimer()
  if g_XZSCDlg == self then
    g_XZSCDlg = nil
  end
  if g_Click_Item_View ~= nil then
    g_Click_Item_View:removeFromParentAndCleanup(true)
    g_Click_Item_View = nil
  end
  if g_XZSCRuleDlg ~= nil then
    g_XZSCRuleDlg:CloseSelf()
    g_XZSCRuleDlg = nil
  end
end
function ShowXueZhanShaChangDlg()
  netsend.netactivity.getXZSCBaseInfo()
end
function ShowXueZhanShaChangDlgWithBaseInfo(info)
  if g_CXZSCMatchingDlg ~= nil then
    return
  end
  if g_XZSCDlg ~= nil then
    g_XZSCDlg:CloseSelf()
    g_XZSCDlg = nil
  end
  g_XZSCDlg = getCurSceneView():addSubView({
    subView = CXZSCDlg.new(info),
    zOrder = MainUISceneZOrder.menuView
  })
end
