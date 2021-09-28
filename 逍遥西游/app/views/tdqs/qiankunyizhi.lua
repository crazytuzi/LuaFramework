RollingTime = 2
DelayForResultTime = 1
ShowResultTime = 2
QKYZ_RESULT_VS = 1
QKYZ_RESULT_WIN = 2
QKYZ_RESULT_LOSE = 3
QKYZ_RESULT_TIE = 4
QKYI_Result_Bubble_Win = 1
QKYI_Result_Bubble_Lose = 2
QKYI_Result_Bubble_Open = 3
g_QianKunYiZhi = nil
function ShowQianKunYiZhiResult(npcNumList, myNumList)
  if npcNumList == nil or myNumList == nil then
    ResetQianKunYiZhiView()
    return
  end
  local npcSum, mySum = 0, 0
  for _, num in pairs(npcNumList) do
    npcSum = npcSum + num
  end
  for _, num in pairs(myNumList) do
    mySum = mySum + num
  end
  if g_QianKunYiZhi then
    g_QianKunYiZhi:StopSaiZiAction(npcNumList, myNumList, npcSum, mySum)
  else
    local skgzShape, skgzName = data_getRoleShapeAndName(NPC_ShenKuiGongZi_ID)
    if npcSum > mySum then
      ShowNotifyTips(string.format("你在乾坤一掷中，没有战胜%s", skgzName))
    elseif npcSum == mySum then
      ShowNotifyTips(string.format("你在乾坤一掷中，和%s战成平局", skgzName))
    else
      ShowNotifyTips(string.format("你在乾坤一掷中，战胜了%s", skgzName))
    end
  end
end
function ResetQianKunYiZhiView()
  if g_QianKunYiZhi then
    g_QianKunYiZhi:ResetSaiZiAction()
    return
  end
end
function ShowQianKunYiZhiView()
  if g_QianKunYiZhi then
    return
  end
  getCurSceneView():addSubView({
    subView = CQianKunYiZhiView.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
CQianKunYiZhiView = class("CQianKunYiZhiView", CcsSubView)
function CQianKunYiZhiView:ctor()
  CQianKunYiZhiView.super.ctor(self, "views/qiankunyizhi.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_start = {
      listener = handler(self, self.OnBtn_Start),
      variName = "btn_start"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_offX = 5
  self.m_offY = 8
  self.m_HasSendFlag = false
  self.m_CanCloseFlag = true
  self:InitTalKingMsg()
  self:HidePosObj()
  self:SetHeadImg()
  self:SetJinSaiZiNum()
  self:ResetSaiZiAction()
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_Connect)
  g_QianKunYiZhi = self
  if g_QianKunYiZhi then
    scheduler.performWithDelayGlobal(handler(self, self.ShowTalkingBubble), 0.5)
  end
end
function CQianKunYiZhiView:InitTalKingMsg()
  self.m_SKGZMsg_Win = {
    [1] = "哈哈，我乃当世赌神是也#<E:5>#",
    [2] = "你是赢不了我的#<E:5>#"
  }
  self.m_SKGZMsg_Lose = {
    [1] = "小小的失利不算什么#<E:6>#",
    [2] = "我会赢回来的#<E:2>#"
  }
  self.m_SKGZMsg_Open = {
    [1] = "风吹鸡蛋壳，财散人安乐。",
    [2] = "来来来，赢了我，宝物归你。",
    [3] = "一决胜负吧。"
  }
end
function CQianKunYiZhiView:ShowTalkingBubble(result)
  local index = 1
  local msg = ""
  local parent = self:getNode("headpos1")
  local parentSize = parent:getContentSize()
  if result == QKYI_Result_Bubble_Win then
    index = math.random(1, #self.m_SKGZMsg_Win)
    msg = self.m_SKGZMsg_Win[index]
  elseif result == QKYI_Result_Bubble_Lose then
    index = math.random(1, #self.m_SKGZMsg_Lose)
    msg = self.m_SKGZMsg_Lose[index]
  else
    index = math.random(1, #self.m_SKGZMsg_Open)
    msg = self.m_SKGZMsg_Open[index]
  end
  if self.m_TalkBubbleObj ~= nil then
    self.m_TalkBubbleObj:removeFromParentAndCleanup(true)
    self.m_TalkBubbleObj = nil
  end
  if parent then
    local x, y = parent:getPosition()
    local z = parent:getZOrder()
    self.m_TalkBubbleObj = CMapChatBubble.new(msg, nil, handler(self, self.TalkBubbleClear), 2)
    self:addChild(self.m_TalkBubbleObj, z)
    self.m_TalkBubbleObj:setPosition(ccp(x + parentSize.width / 2, y + parentSize.height))
  end
end
function CQianKunYiZhiView:TalkBubbleClear(obj)
  if self.m_TalkBubbleObj == obj then
    self.m_TalkBubbleObj:removeFromParentAndCleanup(true)
    self.m_TalkBubbleObj = nil
  end
end
function CQianKunYiZhiView:HidePosObj()
  for _, tempName in pairs({
    "headpos1",
    "headpos2",
    "tipspos",
    "dicepos_11",
    "dicepos_12",
    "dicepos_13",
    "dicepos_21",
    "dicepos_22",
    "dicepos_23"
  }) do
    local obj = self:getNode(tempName)
    if obj then
      obj:setVisible(false)
    end
  end
end
function CQianKunYiZhiView:SetHeadImg()
  local skgzShape, skgzName = data_getRoleShapeAndName(NPC_ShenKuiGongZi_ID)
  self:getNode("name1"):setText(skgzName)
  local img = createWidgetFrameHeadIconByRoleTypeID(skgzShape)
  local x, y = self:getNode("headpos1"):getPosition()
  local size = self:getNode("headpos1"):getContentSize()
  img:setScaleX(-1)
  img:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addChild(img)
  local myShape
  local myName = ""
  local myNameColor = ccc3(255, 255, 255)
  if g_LocalPlayer then
    local mainHero = g_LocalPlayer:getMainHero()
    if mainHero then
      local myZs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
      myName = mainHero:getProperty(PROPERTY_NAME)
      myShape = mainHero:getProperty(PROPERTY_SHAPE)
    end
  end
  self:getNode("name2"):setText(myName)
  self:getNode("name2"):setColor(myNameColor)
  local img = createWidgetFrameHeadIconByRoleTypeID(myShape or skgzShape)
  local x, y = self:getNode("headpos2"):getPosition()
  local size = self:getNode("headpos2"):getContentSize()
  img:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addChild(img)
end
function CQianKunYiZhiView:SetJinSaiZiNum()
  local jszNum = 0
  if g_LocalPlayer then
    jszNum = g_LocalPlayer:GetItemNum(ITEM_DEF_OTHER_JSZ)
  end
  local x, y = self:getNode("tipspos"):getPosition()
  local size = self:getNode("tipspos"):getContentSize()
  if self.m_TipsText == nil then
    self.m_TipsText = CRichText.new({
      width = size.width,
      fontSize = 24,
      color = ccc3(255, 222, 0),
      align = CRichText_AlignType_Left
    })
    self:addChild(self.m_TipsText)
  end
  self.m_TipsText:clearAll()
  self.m_TipsText:addRichText(string.format("#<IRP>#剩余次数:#<W>%d#", jszNum))
  self.m_TipsText:setPosition(ccp(x + 30, y))
end
function CQianKunYiZhiView:setResultImg(result)
  self:getNode("pic_vs"):setVisible(result == QKYZ_RESULT_VS)
  self:getNode("pic_win"):setVisible(result == QKYZ_RESULT_WIN)
  self:getNode("pic_lose"):setVisible(result == QKYZ_RESULT_LOSE)
  self:getNode("pic_tie"):setVisible(result == QKYZ_RESULT_TIE)
end
function CQianKunYiZhiView:ResetSaiZiAction()
  self:stopAllActions()
  self.m_HasSendFlag = false
  self.btn_start:setBright(true)
  self.btn_start:setTouchEnabled(true)
  if self.m_DiceObjList == nil then
    self.m_DiceObjList = {}
    for i = 1, 2 do
      for j = 1, 3 do
        local pos = self:getNode(string.format("dicepos_%d%d", i, j))
        local size = pos:getContentSize()
        local x, y = pos:getPosition()
        local obj = display.newSprite("views/pic/pic_shaizi.png")
        self:addNode(obj, 99)
        obj:setPosition(x + size.width / 2 + self.m_offX, y)
        self.m_DiceObjList[i * 10 + j] = obj
      end
    end
  end
  for _, obj in pairs(self.m_DiceObjList) do
    obj:setVisible(true)
  end
  if self.m_ResultDiceList ~= nil then
    for _, obj in pairs(self.m_ResultDiceList) do
      obj:removeFromParentAndCleanup(true)
    end
    self.m_ResultDiceList = nil
  end
  if self.m_RollingDiceList ~= nil then
    for _, obj in pairs(self.m_RollingDiceList) do
      obj:removeFromParentAndCleanup(true)
    end
    self.m_RollingDiceList = nil
  end
  self:setResultImg(QKYZ_RESULT_VS)
  self:getNode("npc_sum"):setText(0)
  self:getNode("my_sum"):setText(0)
end
function CQianKunYiZhiView:StartSaiZiAction()
  self.m_CanCloseFlag = false
  self.btn_start:setBright(false)
  self.btn_start:setTouchEnabled(false)
  if self.m_DiceObjList then
    for _, obj in pairs(self.m_DiceObjList) do
      obj:setVisible(false)
    end
  end
  if self.m_ResultDiceList ~= nil then
    for _, obj in pairs(self.m_ResultDiceList) do
      obj:temoveFromParentAndCleanup(true)
    end
  end
  if self.m_RollingDiceList == nil then
    self.m_RollingDiceList = {}
    local plistpath = "xiyou/ani/qiankunyizhi.plist"
    for i = 1, 2 do
      for j = 1, 3 do
        local pos = self:getNode(string.format("dicepos_%d%d", i, j))
        local size = pos:getContentSize()
        local x, y = pos:getPosition()
        local eff = CreateSeqAnimation(plistpath, -1)
        if eff then
          eff:setPosition(ccp(x + size.width / 2, y + self.m_offY))
          self:addNode(eff, 999)
          self.m_RollingDiceList[i * 10 + j] = eff
        end
      end
    end
  end
  self:setResultImg(QKYZ_RESULT_VS)
  self:getNode("npc_sum"):setText(0)
  self:getNode("my_sum"):setText(0)
  local act1 = CCDelayTime:create(RollingTime)
  local act2 = CCCallFunc:create(function()
    self.m_HasSendFlag = true
    netsend.netactivity.reqQianKunYiZhi()
  end)
  self:stopAllActions()
  self:runAction(transition.sequence({act1, act2}))
end
function CQianKunYiZhiView:StopSaiZiAction(npcNumList, myNumList, npcSum, mySum)
  self:getNode("npc_sum"):setText(tostring(npcSum))
  self:getNode("my_sum"):setText(tostring(mySum))
  local resultImg = QKYZ_RESULT_VS
  local SKGZResult = QKYI_Result_Bubble_Win
  if mySum < npcSum then
    resultImg = QKYZ_RESULT_LOSE
    SKGZResult = QKYI_Result_Bubble_Win
  elseif npcSum == mySum then
    resultImg = QKYZ_RESULT_TIE
    SKGZResult = QKYI_Result_Bubble_Win
  else
    resultImg = QKYZ_RESULT_WIN
    SKGZResult = QKYI_Result_Bubble_Lose
  end
  if self.m_DiceObjList then
    for _, obj in pairs(self.m_DiceObjList) do
      obj:setVisible(false)
    end
  end
  if self.m_ResultDiceList ~= nil then
    for _, obj in pairs(self.m_ResultDiceList) do
      obj:temoveFromParentAndCleanup(true)
    end
  end
  self.m_ResultDiceList = {}
  for i = 1, 2 do
    for j = 1, 3 do
      local dicNum = npcNumList[j]
      if i == 2 then
        dicNum = myNumList[j]
      end
      local pos = self:getNode(string.format("dicepos_%d%d", i, j))
      local size = pos:getContentSize()
      local x, y = pos:getPosition()
      if dicNum > 6 then
        dicNum = 6
      elseif dicNum < 1 then
        dicNum = 1
      end
      local path = string.format("xiyou/pic/pic_shaizi_0000%d.png", dicNum)
      local obj = display.newSprite(path)
      self:addNode(obj, 99)
      obj:setPosition(x + size.width / 2, y + self.m_offY)
      self.m_ResultDiceList[i * 10 + j] = obj
    end
  end
  if self.m_RollingDiceList ~= nil then
    for _, obj in pairs(self.m_RollingDiceList) do
      obj:removeFromParentAndCleanup(true)
    end
    self.m_RollingDiceList = nil
  end
  local act1 = CCDelayTime:create(DelayForResultTime)
  local act2 = CCCallFunc:create(function()
    self:setResultImg(resultImg)
    self:ShowTalkingBubble(SKGZResult)
    self.m_HasSendFlag = false
    self.m_CanCloseFlag = true
  end)
  local act3 = CCDelayTime:create(ShowResultTime)
  local act4 = CCCallFunc:create(function()
    self:ResetSaiZiAction()
  end)
  self:stopAllActions()
  self:runAction(transition.sequence({
    act1,
    act2,
    act3,
    act4
  }))
end
function CQianKunYiZhiView:OnBtn_Start(btnObj, touchType)
  local jszNum = 0
  if g_LocalPlayer then
    jszNum = g_LocalPlayer:GetItemNum(ITEM_DEF_OTHER_JSZ)
  end
  if jszNum == 0 then
    ShowNotifyTips("你没有我需要的金骰子")
    return
  end
  if self.m_HasSendFlag == true then
    return
  end
  self:StartSaiZiAction()
end
function CQianKunYiZhiView:OnBtn_Close()
  if self.m_CanCloseFlag == false then
    ShowNotifyTips("马上就出结果啦，请耐心等候")
  else
    self:CloseSelf()
  end
end
function CQianKunYiZhiView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemInfo_AddItem then
    local itemType = arg[3]
    if itemType == ITEM_DEF_OTHER_JSZ then
      self:SetJinSaiZiNum()
    end
  elseif msgSID == MsgID_ItemInfo_DelItem then
    local itemType = arg[2]
    if itemType == ITEM_DEF_OTHER_JSZ then
      self:SetJinSaiZiNum()
    end
  elseif msgSID == MsgID_ItemInfo_ChangeItemNum then
    local itemType = arg[3]
    if itemType == ITEM_DEF_OTHER_JSZ then
      self:SetJinSaiZiNum()
    end
  elseif msgSID == MsgID_ItemInfo_ItemUpdate then
    local para = arg[1]
    local itemID = g_LocalPlayer:GetItemIdByPos(self.m_ItemPos)
    if para.itemType == ITEM_DEF_OTHER_JSZ then
      self:SetJinSaiZiNum()
    end
  elseif msgSID == MsgID_Connect_SendFinished and self.m_HasSendFlag == true then
    self:CloseSelf()
  end
end
function CQianKunYiZhiView:Clear()
  if g_QianKunYiZhi == self then
    g_QianKunYiZhi = nil
  end
end
