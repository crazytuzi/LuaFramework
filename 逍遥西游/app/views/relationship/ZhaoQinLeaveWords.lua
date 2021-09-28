CZhaoQinLeaveWordBoard = class("CZhaoQinLeaveWordBoard", CcsSubView)
function CZhaoQinLeaveWordBoard:ctor()
  CZhaoQinLeaveWordBoard.super.ctor(self, "views/zhaoqinleaveword.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_write = {
      listener = handler(self, self.Btn_Write),
      variName = "btn_write"
    },
    btn_update = {
      listener = handler(self, self.Btn_Update),
      variName = "btn_update"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_AllItems = {}
  self:setCanEdit(false)
  for index = 1, 6 do
    local pos = self:getNode(string.format("pos%d", index))
    if pos then
      pos:setVisible(false)
    end
  end
  self:ListenMessage(MsgID_Activity)
  self:showLoading(true)
  netsend.netactivity.flushLeaveWords()
  netsend.netactivity.requestLocalLeaveWords()
end
function CZhaoQinLeaveWordBoard:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Activity_ZhaoQinLocalLeaveWords then
    local msg = arg[1] or ""
    self:setLocalLeaveWord(msg)
  elseif msgSID == MsgID_Activity_ZhaoQinLeaveWords then
    local lst = arg[1]
    self:setRandomLeaveWord(lst)
  end
end
function CZhaoQinLeaveWordBoard:setCanEdit(flag)
  self.m_CanEdit = flag
  self.btn_write:setVisible(flag)
  self.btn_write:setTouchEnabled(flag)
end
function CZhaoQinLeaveWordBoard:setLocalLeaveWord(msg)
  local pid = g_LocalPlayer:getPlayerId()
  if g_FriendsMgr:getBanLvId() ~= nil then
    self:setCanEdit(true)
    self.m_CanEdit = false
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  local rtype = mainHero:getTypeId()
  local name = mainHero:getProperty(PROPERTY_NAME)
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  local item = CZhaoQinLeaveWordBoardItem.new({
    rtype = rtype,
    name = name,
    zs = zs,
    lv = lv,
    msg = msg
  }, true, handler(self, self.ClickAtLocalItemListener))
  local x, y = self:getWordItemPos(1)
  self:addChild(item.m_UINode)
  item:setPosition(ccp(x, y))
  local oldItem = self.m_AllItems[1]
  if oldItem ~= nil then
    oldItem:removeFromParent()
  end
  self.m_AllItems[1] = item
  self:showLoading(false)
  self:setCanEdit(true)
end
function CZhaoQinLeaveWordBoard:ShowConfirmView(obj)
  local itmeInfo = obj:getItemInfo() or {}
  local name = itmeInfo.name or ""
  local pid = itmeInfo.pid
  if pid == nil then
    print("yyyyyyyyyyyyyyyyyyyyyyyy:好友不存在")
    return
  end
  local title = "提示"
  local text = string.format("你申请添加好友:#<G>%s#", name)
  if text ~= nil then
    local temp = CPopWarning.new({
      title = title,
      text = text,
      confirmText = "确定",
      confirmText = "确定",
      confirmFunc = function()
        netsend.netfriends.addFriend(pid)
      end,
      align = CRichText_AlignType_Center
    })
    temp:ShowCloseBtn(false)
  end
end
function CZhaoQinLeaveWordBoard:setRandomLeaveWord(lst)
  local index = 2
  if #lst >= 6 or g_FriendsMgr:getBanLvId() ~= nil then
    index = 1
  end
  if self.m_CanEdit then
    index = 2
  end
  for _, data in pairs(lst) do
    if index > 6 then
      break
    end
    local item = CZhaoQinLeaveWordBoardItem.new(data, false, handler(self, self.callBackListener))
    self:addChild(item.m_UINode)
    local x, y = self:getWordItemPos(index)
    item:setPosition(ccp(x, y))
    local oldItem = self.m_AllItems[index]
    if oldItem ~= nil then
      oldItem:removeFromParent()
    end
    self.m_AllItems[index] = item
    index = index + 1
  end
  self:showLoading(false)
end
function CZhaoQinLeaveWordBoard:callBackListener(obj)
  if obj == nil then
    return
  end
  self:ShowConfirmView(obj)
end
function CZhaoQinLeaveWordBoard:ClickAtLocalItemListener(obj)
  local mainHero = g_LocalPlayer:getMainHero()
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  if obj == nil then
    return
  end
  if lv >= 60 or zs >= 1 then
    CZhaoQinLeaveWordEdit.new(handler(self, self.OnEditContent))
  else
    ShowNotifyTips("等级高于60级才能招亲")
  end
end
function CZhaoQinLeaveWordBoard:getWordItemPos(index)
  local pos = self:getNode(string.format("pos%d", index))
  if pos then
    local x, y = pos:getPosition()
    return x, y
  else
    return 0, 0
  end
end
function CZhaoQinLeaveWordBoard:showLoading(isloading)
  if isloading then
    if self.m_LoadingImg == nil then
      self.m_LoadingImg = CreateALoadingSprite()
      local x, y = self:getNode("bg"):getPosition()
      self:addNode(self.m_LoadingImg, 999)
      self.m_LoadingImg:setPosition(ccp(x, y - 20))
    else
      self.m_LoadingImg:setVisible(true)
    end
  elseif self.m_LoadingImg then
    self.m_LoadingImg:setVisible(false)
  end
end
function CZhaoQinLeaveWordBoard:Btn_Close(obj, t)
  self:CloseSelf()
end
function CZhaoQinLeaveWordBoard:Btn_Write(obj, t)
  local mainHero = g_LocalPlayer:getMainHero()
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  if lv < 60 and zs < 1 then
    ShowNotifyTips("等级高于60级才能招亲")
    return
  end
  if g_FriendsMgr:getBanLvId() ~= nil then
    ShowNotifyTips("你已结婚或结契，不需要再发布启事")
    return
  end
  CZhaoQinLeaveWordEdit.new(handler(self, self.OnEditContent))
end
function CZhaoQinLeaveWordBoard:OnEditContent(text)
  local costMoney = data_Variables.QixiMsgCostCoin
  if self.m_CanEdit then
    local item = self.m_AllItems[1]
    if item then
      if costMoney > g_LocalPlayer:getCoin() then
        return
      end
      item:setMsg(text)
    end
  end
end
function CZhaoQinLeaveWordBoard:Btn_Update(obj, t)
  local curTime = cc.net.SocketTCP.getTime()
  if self.m_lastUpdateTime ~= nil and curTime - self.m_lastUpdateTime < 1 then
    ShowNotifyTips("刷新太频繁了")
    return
  end
  self.m_lastUpdateTime = curTime
  for index = #self.m_AllItems, 1, -1 do
    local item = self.m_AllItems[index]
    if item and not item:getIsLocal() then
      item:CloseSelf()
      table.remove(self.m_AllItems, index)
    end
  end
  self:showLoading(true)
  local act1 = CCDelayTime:create(0.01)
  local act2 = CCCallFunc:create(function()
    netsend.netactivity.flushLeaveWords()
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function CZhaoQinLeaveWordBoard:Clear()
end
function ShowZhaoQinLeaveWordBoard()
  getCurSceneView():addSubView({
    subView = CZhaoQinLeaveWordBoard.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
