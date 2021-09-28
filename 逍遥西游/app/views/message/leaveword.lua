CLeaveWordBoard = class("CLeaveWordBoard", CcsSubView)
function CLeaveWordBoard:ctor()
  CLeaveWordBoard.super.ctor(self, "views/leaveword.json", {isAutoCenter = true, opacityBg = 100})
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
  self:ListenMessage(MsgID_Message)
  self:showLoading(true)
  netsend.netmessage.requestLeaveWord()
end
function CLeaveWordBoard:OnMessage(msgSID, ...)
  if msgSID == MsgID_Message_LocalLeaveWord then
    local arg = {
      ...
    }
    local msg = arg[1] or ""
    self:setLocalLeaveWord(msg)
  elseif msgSID == MsgID_Message_RandomLeaveWord then
    local arg = {
      ...
    }
    local lst = arg[1]
    self:setRandomLeaveWord(lst)
  end
end
function CLeaveWordBoard:setCanEdit(flag)
  self.m_CanEdit = flag
  self.btn_write:setVisible(flag)
  self.btn_write:setTouchEnabled(flag)
end
function CLeaveWordBoard:setLocalLeaveWord(msg)
  local mainHero = g_LocalPlayer:getMainHero()
  local lType = mainHero:getTypeId()
  local name = mainHero:getProperty(PROPERTY_NAME)
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  local item = CLeaveWordBoardItem.new(lType, name, zs, lv, msg, true)
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
function CLeaveWordBoard:setRandomLeaveWord(lst)
  local index = 2
  if #lst >= 6 then
    index = 1
  end
  if self.m_CanEdit then
    index = 2
  end
  for _, data in pairs(lst) do
    if index > 6 then
      break
    end
    local item = CLeaveWordBoardItem.new(data.ltype, data.name, data.zs, data.lv, data.msg, false)
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
function CLeaveWordBoard:getWordItemPos(index)
  local pos = self:getNode(string.format("pos%d", index))
  if pos then
    local x, y = pos:getPosition()
    return x, y
  else
    return 0, 0
  end
end
function CLeaveWordBoard:showLoading(isloading)
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
function CLeaveWordBoard:Btn_Close(obj, t)
  self:CloseSelf()
end
function CLeaveWordBoard:Btn_Write(obj, t)
  if activity.leaveword:getStatus() == 1 then
    CLeaveWordEdit.new(handler(self, self.OnEditContent))
  else
    ShowNotifyTips("活动已经结束")
  end
end
function CLeaveWordBoard:OnEditContent(text)
  if self.m_CanEdit then
    local item = self.m_AllItems[1]
    if item then
      item:setMsg(text)
    end
  end
end
function CLeaveWordBoard:Btn_Update(obj, t)
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
    netsend.netmessage.updateLeaveWord()
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function CLeaveWordBoard:Clear()
end
function ShowLeaveWordBoard()
  getCurSceneView():addSubView({
    subView = CLeaveWordBoard.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
