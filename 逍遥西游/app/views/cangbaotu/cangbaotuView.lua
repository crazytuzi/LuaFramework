local ITEM_NUM = 14
local TYPE_RES = 1
local TYPE_ITEM = 2
local TYPE_MONSTER = 3
local START_SPEED = 0.03
local END_SPEED = 0.5
local Monster_END_SPEED = 0.03
local MINS_SPEED = 1.6
local AUTO_STOP_TIME = 5
g_CBTView = nil
TEMP_RANDOMLIST = nil
CCBTView = class("CCBTView", CcsSubView)
function CCBTView:ctor(mapId, itemId, rIndex)
  print("CCBTView:ctor")
  CCBTView.super.ctor(self, "views/cangbaotu.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_stop = {
      listener = handler(self, self.OnBtn_Stop),
      variName = "btn_stop"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_CBTMapId = mapId
  self.m_ItemId = itemId
  self.m_SerResultIndex = rIndex
  self.m_RandomList = {}
  self.m_ItemsList = {}
  self.m_CbtType = ITEM_DEF_OTHER_ZBT
  local itemIns = g_LocalPlayer:GetOneItem(self.m_ItemId)
  if itemIns and itemIns:getTypeId() == ITEM_DEF_OTHER_GJZBT then
    self.m_CbtType = ITEM_DEF_OTHER_GJZBT
  end
  self.m_IsMonsterResultFlag = false
  local cbtData = data_Treasure
  if self.m_CbtType == ITEM_DEF_OTHER_GJZBT then
    cbtData = data_GaojiTreasure
  end
  local tempData = cbtData[self.m_SerResultIndex] or {}
  if tempData.etype == TYPE_MONSTER then
    self.m_IsMonsterResultFlag = true
  end
  self.m_Speed = START_SPEED
  self.m_MyIndex = 1
  self.m_ResultIndex = nil
  self.m_FightNpcData = nil
  self.m_HadSend = false
  self.m_HasUsedFlag = false
  self.m_CanShowResult = false
  self.m_CanStopFlag = false
  self:SetItems()
  self:RunToNext()
  self:ListenMessage(MsgID_Team)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_MapScene)
  self:ListenMessage(MsgID_Connect)
  self.m_AutoClickStopHandler = scheduler.performWithDelayGlobal(function()
    self:OnBtn_Stop()
  end, AUTO_STOP_TIME)
  g_CBTView = self
  if g_CMainMenuHandler then
    g_CMainMenuHandler:ShowQuickUseBoard()
  end
end
function CCBTView:OnBtn_Stop(btnObj, touchType)
  if self.m_AutoClickStopHandler then
    scheduler.unscheduleGlobal(self.m_AutoClickStopHandler)
    self.m_AutoClickStopHandler = nil
  end
  for i = 1, #self.m_RandomList do
    if self.m_RandomList[i] == self.m_SerResultIndex then
      self.m_ResultIndex = i
      if self.m_CanShowResult ~= true and self.m_HadSend ~= true then
        netsend.netitem.requestUseItem(self.m_ItemId)
        self.m_HadSend = true
      end
      break
    end
  end
  self.btn_stop:setBright(false)
  self.btn_stop:setTouchEnabled(false)
end
function CCBTView:SetItems()
  local needRandomItemFlag = true
  if TEMP_RANDOMLIST ~= nil then
    local rData = TEMP_RANDOMLIST[self.m_ItemId]
    if rData ~= nil then
      for _, iindex in ipairs(rData) do
        if self.m_SerResultIndex == iindex then
          needRandomItemFlag = false
          self.m_RandomList = DeepCopyTable(rData)
          break
        end
      end
    end
  end
  local cbtData = data_Treasure
  if self.m_CbtType == ITEM_DEF_OTHER_GJZBT then
    cbtData = data_GaojiTreasure
  end
  if needRandomItemFlag then
    local tempList = {}
    for i = 1, #cbtData do
      if i ~= self.m_SerResultIndex then
        tempList[#tempList + 1] = i
      end
    end
    tempList = RandomSortList(tempList)
    local data = {}
    for i = 1, ITEM_NUM - 1 do
      data[#data + 1] = tempList[i]
    end
    data[#data + 1] = self.m_SerResultIndex
    data = RandomSortList(data)
    self.m_RandomList = DeepCopyTable(data)
    if TEMP_RANDOMLIST == nil then
      TEMP_RANDOMLIST = {}
    end
    TEMP_RANDOMLIST[self.m_ItemId] = DeepCopyTable(self.m_RandomList)
  end
  for i = 1, ITEM_NUM do
    local item = CCBTViewItem.new()
    self.m_ItemsList[i] = item
    self:addChild(item.m_UINode)
    local x, y = self:getNode(string.format("itempos_%d", i)):getPosition()
    item:setPosition(ccp(x, y))
    local tempData = cbtData[self.m_RandomList[i]]
    local itemType = tempData.etype
    local nameTxt = "宝物"
    local itemID
    if itemType == TYPE_RES then
      if tempData.data[1] ~= 0 then
        nameTxt = string.format("x%d", tempData.data[1])
        itemID = RESTYPE_COIN
      elseif tempData.data[2] ~= 0 then
        nameTxt = string.format("x%d", tempData.data[2])
        itemID = RESTYPE_GOLD
      elseif tempData.data[3] ~= 0 then
        nameTxt = string.format("x%d", tempData.data[3])
        itemID = RESTYPE_SILVER
      end
    elseif itemType == TYPE_ITEM then
      local itemShapeType, itemShapeNum
      for itemId, num in pairs(tempData.data) do
        itemShapeType = itemId
        itemShapeNum = num
        break
      end
      if itemShapeType ~= nil then
        itemID = itemShapeType
        if data_getIsQHF(itemShapeType) then
          nameTxt = "强化符"
        else
          local tempItemName = data_getItemName(itemShapeType)
          nameTxt = string.format("%s", tempItemName)
        end
      end
    elseif itemType == TYPE_MONSTER then
      nameTxt = "怪物!"
      local warID = tempData.data[1]
      local warData = data_WarRole[warID]
      for warPos, npcID in pairs(warData.posList) do
        if data_getIsNpcBoss(npcID) then
          itemID = npcID
          if self.m_RandomList[i] == self.m_SerResultIndex then
            self.m_MonsterID = itemID
          end
          break
        end
      end
    end
    item:setData(nameTxt, itemType, itemID)
    item:setSelect(false)
  end
end
function CCBTView:SelectItemByIndex(index)
  for i = 1, ITEM_NUM do
    local item = self.m_ItemsList[i]
    item:setSelect(i == index)
  end
end
function CCBTView:RunToNext()
  self:stopAllActions()
  self:SelectItemByIndex(self.m_MyIndex)
  if self.m_ResultIndex ~= nil then
    self.m_Speed = self.m_Speed * MINS_SPEED
    local myEndSpeed = END_SPEED
    if self.m_IsMonsterResultFlag then
      myEndSpeed = Monster_END_SPEED
    end
    if myEndSpeed < self.m_Speed then
      self.m_CanStopFlag = true
      self.m_Speed = myEndSpeed
    end
  end
  if self.m_CanStopFlag and self.m_MyIndex == self.m_ResultIndex then
    local act1
    if self.m_IsMonsterResultFlag then
      act1 = CCDelayTime:create(0)
    else
      act1 = CCDelayTime:create(1)
    end
    local act2 = CCCallFunc:create(function()
      self.m_CanShowResult = true
      if self.m_HasUsedFlag then
        self:ShowResultAndCloseSelf()
      end
    end)
    self:runAction(transition.sequence({act1, act2}))
    return
  end
  local act1 = CCDelayTime:create(self.m_Speed)
  local act2 = CCCallFunc:create(function()
    self.m_MyIndex = (self.m_MyIndex + 1) % ITEM_NUM
    if self.m_MyIndex == 0 then
      self.m_MyIndex = ITEM_NUM
    end
    self:RunToNext()
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function CCBTView:setWarNpc(NPCId)
  if self.m_MonsterID == nil or NPCId == nil or NPCId == 0 then
    return
  end
  local npcData = g_MapMgr:getDynamicNpcDataById(NPCId)
  if npcData == nil then
    return
  end
  if npcData.typeid == self.m_MonsterID and (npcData.state == 1 or npcData.state == nil) then
    self.m_SceneId = npcData.scene
    self.m_ScenePos = npcData.loc
    self.m_RID = NPCId
    self.m_WarNPCName = npcData.name
    self.m_FightNpcData = {}
    self.m_FightNpcData.rID = NPCId
    self.m_FightNpcData.sceneID = npcData.scene
    self.m_FightNpcData.scenePos = npcData.loc
    self.m_FightNpcData.monsterID = self.m_MonsterID
    self.m_FightNpcData.warNPCName = npcData.name
  end
end
function CCBTView:fightWarNpc()
  if self.m_MonsterID == nil then
    return
  end
  if self.m_RID == nil or self.m_ScenePos == nil or self.m_SceneId == nil then
    return
  end
  self.m_GotoFightFlag = true
end
function CCBTView:Clear()
  if self.m_AutoClickStopHandler then
    scheduler.unscheduleGlobal(self.m_AutoClickStopHandler)
    self.m_AutoClickStopHandler = nil
  end
  if g_CBTView == self then
    g_CBTView = nil
  end
  if g_CMainMenuHandler then
    g_CMainMenuHandler:ShowQuickUseBoard()
  end
  print("CCBTView:Clear")
end
function CCBTView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  local fid = self:GetFIDWithSID(msgSID)
  if msgSID == MsgID_Team_TeamState then
    local pid = arg[2]
    local teamState = arg[3]
    if pid == g_LocalPlayer:getPlayerId() and teamState == TEAMSTATE_FOLLOW and g_TeamMgr:localPlayerIsCaptain() == false then
      self:WaBaoBreak()
    end
  elseif msgSID == MsgID_MapScene_AutoRoute then
    self:WaBaoBreak()
  elseif msgSID == MsgID_ItemInfo_ItemUpdate then
    local para = arg[1]
    local objId = para.itemId
    if objId == self.m_ItemId then
      local newNPCId = para.pro[ITEM_PRO_ZBT_RESULTNPCID]
      if newNPCId ~= nil then
        self:setWarNpc(newNPCId)
      end
    end
  elseif msgSID == MsgID_MapScene_ChangedMap then
    local curMapId = g_MapMgr:getCurMapId()
    if self.m_CBTMapId ~= curMapId then
      self:WaBaoBreak()
    end
  elseif msgSID == MsgID_ItemInfo_CangBaoTuFinished then
    print_lua_table(arg)
    print("cbt MsgID_ItemInfo_CangBaoTuFinished")
    local para = arg[1]
    local objId = para.itemId
    print("00%%%%", objId, self.m_ItemId)
    if objId == self.m_ItemId then
      print("m_HasUsedFlag,设置成true")
      self.m_HasUsedFlag = true
    end
  elseif msgSID == MsgID_ItemInfo_DelItem then
    print_lua_table(arg)
    print("cbt MsgID_ItemInfo_DelItem")
    local objId = arg[1]
    print("11%%%%", objId, self.m_CanShowResult, self.m_HasUsedFlag, self.m_ItemId)
    if objId == self.m_ItemId and self.m_CanShowResult == true and self.m_HasUsedFlag == true then
      print("ShowResultAndCloseSelf3333")
      self:ShowResultAndCloseSelf()
    end
  elseif msgSID == MsgID_ItemInfo_ChangeItemNum then
    print_lua_table(arg)
    print("cbt MsgID_ItemInfo_ChangeItemNum")
    local objId = arg[1]
    print("22%%%%", objId, self.m_CanShowResult, self.m_HasUsedFlag, self.m_ItemId)
    if objId == self.m_ItemId and self.m_CanShowResult == true and self.m_HasUsedFlag == true then
      print("ShowResultAndCloseSelf2222")
      self:ShowResultAndCloseSelf()
    end
  elseif msgSID == MsgID_Connect_SendFinished then
    self:CloseSelf()
  elseif msgSID == MsgID_ItemInfo_ShowSafeLock then
    self:CloseSelf()
  end
end
function CCBTView:WaBaoBreak()
  if self.m_GotoFightFlag then
    self:CloseSelf()
    return
  end
  if self.m_HasUsedFlag then
    self:ShowResultAndCloseSelf()
  elseif self.m_HadSend == false then
    ShowNotifyTips("你已经中断了挖宝")
    self:CloseSelf()
    return
  else
    print("包已经发出去，还没有收到服务器回包")
  end
end
function CCBTView:OnBtn_Close()
  if self.m_CanShowResult == true then
    return
  end
  self.m_CanShowResult = true
  if self.m_AutoClickStopHandler then
    scheduler.unscheduleGlobal(self.m_AutoClickStopHandler)
    self.m_AutoClickStopHandler = nil
  end
  self.btn_stop:setBright(false)
  self.btn_stop:setTouchEnabled(false)
  self.btn_close:setTouchEnabled(false)
  if self.m_HadSend ~= true then
    netsend.netitem.requestUseItem(self.m_ItemId)
    self.m_HadSend = true
  elseif self.m_HasUsedFlag == true then
    self:ShowResultAndCloseSelf()
  end
end
function CCBTView:ShowResultAndCloseSelf()
  getCurSceneView():addSubView({
    subView = CCBTResult.new(self.m_ItemId, self.m_CbtType, self.m_SerResultIndex, self.m_FightNpcData),
    zOrder = MainUISceneZOrder.menuView
  })
  self:CloseSelf()
end
CCBTViewItem = class("CCBTViewItem", CcsSubView)
function CCBTViewItem:ctor()
  CCBTResult.super.ctor(self, "views/cangbaotu_item.json")
  self.m_Img = nil
  self.m_Pos1 = nil
  self.m_Pos2 = nil
  self.m_SelectImg = nil
end
function CCBTViewItem:setData(nameTxt, itemType, itemID)
  self:getNode("txt_name"):setText(nameTxt)
  if itemType == TYPE_RES then
    self.m_Img = createClickResItem({
      resID = itemID,
      num = 0,
      autoSize = nil,
      clickListener = nil,
      clickDel = nil,
      noBgFlag = nil,
      LongPressTime = nil,
      LongPressListener = nil,
      LongPressEndListner = nil,
      bgPath = "views/mainviews/pic_headiconbg.png"
    })
    self.m_Pos1 = ccp(3, 33)
    self.m_Pos2 = ccp(12, 40)
  elseif itemType == TYPE_ITEM then
    self.m_Img = createClickItem({
      itemID = itemID,
      autoSize = nil,
      num = 0,
      LongPressTime = nil,
      clickListener = nil,
      LongPressListener = nil,
      LongPressEndListner = nil,
      clickDel = nil,
      noBgFlag = nil,
      bgPath = "views/mainviews/pic_headiconbg.png"
    })
    self.m_Pos1 = ccp(3, 33)
    self.m_Pos2 = ccp(12, 40)
  elseif itemType == TYPE_MONSTER then
    self.m_Img = createClickMonsterHead({
      roleTypeId = itemID,
      isBoss = nil,
      autoSize = nil,
      clickListener = nil,
      noBgFlag = nil,
      offx = nil,
      offy = nil,
      clickDel = nil,
      LongPressTime = nil,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
    self.m_Pos1 = ccp(3, 33)
    self.m_Pos2 = ccp(12, 40)
  end
  if self.m_Img ~= nil then
    self:addChild(self.m_Img)
  end
end
function CCBTViewItem:setSelect(flag)
  if flag then
    self.m_Img:setScale(1)
    self.m_Img:setPosition(self.m_Pos1)
    self.m_Img._BgIcon:setOpacity(255)
    self.m_Img._Icon:setOpacity(255)
    if self.m_SelectImg == nil then
      self.m_SelectImg = display.newSprite("views/rolelist/pic_role_selected.png")
      self:addNode(self.m_SelectImg, 100)
      self.m_SelectImg:setPosition(ccp(52, 80))
    end
  else
    self.m_Img:setScale(0.8)
    self.m_Img:setPosition(self.m_Pos2)
    self.m_Img._BgIcon:setOpacity(200)
    self.m_Img._Icon:setOpacity(200)
    if self.m_SelectImg ~= nil then
      self.m_SelectImg:removeFromParent()
      self.m_SelectImg = nil
    end
  end
end
CCBTResult = class("CCBTResult", CcsSubView)
function CCBTResult:ctor(itemId, cbtType, rIndex, fightNPCData)
  self.m_ItemId = itemId
  self.m_Time = 9
  self.m_RIndex = rIndex
  self.m_MonsterData = fightNPCData
  CCBTResult.super.ctor(self, "views/cangbaotu_result.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_battle = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_battle"
    },
    btn_continue = {
      listener = handler(self, self.OnBtn_Continue),
      variName = "btn_continue"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:ListenMessage(MsgID_ItemInfo)
  self.btn_continue:setTitleText(string.format("继续挖宝(%ds)", self.m_Time))
  local pos_body = self:getNode("pos_body")
  pos_body:setVisible(false)
  local tempData = data_Treasure[rIndex]
  if cbtType == ITEM_DEF_OTHER_GJZBT then
    tempData = data_GaojiTreasure[rIndex]
  end
  self.m_cbtType = cbtType
  local itemType = tempData.etype
  local itemID, obj
  if itemType == TYPE_RES then
    self:getNode("title"):setText("挖出宝藏!")
    if tempData.data[1] ~= 0 then
      itemID = RESTYPE_COIN
      self:getNode("title_name"):setText(string.format("铜钱x%d", tempData.data[1]))
    elseif tempData.data[2] ~= 0 then
      itemID = RESTYPE_GOLD
      self:getNode("title_name"):setText(string.format("元宝x%d", tempData.data[2]))
    elseif tempData.data[3] ~= 0 then
      itemID = RESTYPE_SILVER
      self:getNode("title_name"):setText(string.format("银币x%d", tempData.data[3]))
    end
    obj = createClickResItem({
      resID = itemID,
      num = 0,
      autoSize = nil,
      clickListener = function()
      end,
      clickDel = nil,
      noBgFlag = nil,
      LongPressTime = nil,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
    self:setOnlyShowBtnContinue()
  elseif itemType == TYPE_ITEM then
    self:getNode("title"):setText("挖出宝藏!")
    local itemShapeType, itemShapeNum
    for itemId, num in pairs(tempData.data) do
      itemShapeType = itemId
      itemShapeNum = num
      break
    end
    if itemShapeType ~= nil then
      itemID = itemShapeType
      local tempItemName = data_getItemName(itemShapeType)
      self:getNode("title_name"):setText(string.format("%sx%d", tempItemName, itemShapeNum))
      obj = createClickItem({
        itemID = itemID,
        autoSize = nil,
        num = 0,
        LongPressTime = 0,
        clickListener = nil,
        LongPressListener = nil,
        LongPressEndListner = nil,
        clickDel = nil,
        noBgFlag = nil
      })
    end
    self:setOnlyShowBtnContinue()
  elseif itemType == TYPE_MONSTER then
    self:getNode("title"):setText("遇到怪物!")
    local warID = tempData.data[1]
    local warData = data_WarRole[warID]
    for warPos, npcID in pairs(warData.posList) do
      if data_getIsNpcBoss(npcID) then
        itemID = npcID
        break
      end
    end
    obj = createClickMonsterHead({
      roleTypeId = itemID,
      isBoss = nil,
      autoSize = nil,
      clickListener = function()
      end,
      noBgFlag = nil,
      offx = nil,
      offy = nil,
      clickDel = nil,
      LongPressTime = nil,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
    local _, monsterName = data_getRoleShapeAndName(itemID)
    self:getNode("title_name"):setText(string.format("%s", monsterName))
  end
  if obj ~= nil then
    self:addChild(obj, 100)
    local x, y = pos_body:getPosition()
    local size1 = pos_body:getSize()
    local size2 = obj:getSize()
    obj:setPosition(ccp(x + size1.width / 2 - size2.width / 2, y + size1.height / 2 - size2.height / 2))
    local imgPath = "views/peticon/boxlight1.png"
    local imgSprite = display.newSprite(imgPath)
    imgSprite:setPosition(ccp(x + size1.width / 2, y + size1.height / 2))
    self:addNode(imgSprite)
    imgSprite:setScale(0)
    imgSprite:runAction(transition.sequence({
      CCScaleTo:create(0.3, 1.4),
      CCCallFunc:create(function()
        soundManager.playSound("xiyou/sound/openbox.wav")
      end),
      CCScaleTo:create(0.2, 1)
    }))
    imgSprite:runAction(CCRepeatForever:create(CCRotateBy:create(1.5, 360)))
  end
  if g_MessageMgr then
    local txt = ""
    if itemType == TYPE_RES then
      if tempData.data[1] ~= 0 then
        txt = string.format("获得 %d#<IR%d>#", tempData.data[1], RESTYPE_COIN)
      elseif tempData.data[2] ~= 0 then
        txt = string.format("获得 %d#<IR%d>#", tempData.data[2], RESTYPE_GOLD)
      elseif tempData.data[3] ~= 0 then
        txt = string.format("获得 %d#<IR%d>#", tempData.data[3], RESTYPE_SILVER)
      end
    elseif itemType == TYPE_ITEM then
      for itemId, num in pairs(tempData.data) do
        local itemShapeType = itemId
        local itemShapeNum = num
        local name = data_getItemName(itemShapeType)
        txt = string.format("获得#<II%d>##<CI:%d>%sx%d#", itemShapeType, itemShapeType, name, itemShapeNum)
        break
      end
    end
    if txt ~= "" then
      g_MessageMgr:receivePersonXinxiMessage(txt)
    end
  end
  self:CalculateTime()
end
function CCBTResult:CalculateTime()
  local itemNum = 0
  if self.m_cbtType == ITEM_DEF_OTHER_GJZBT then
    itemNum = g_LocalPlayer:GetItemNum(ITEM_DEF_OTHER_GJZBT)
  else
    itemNum = g_LocalPlayer:GetItemNum(ITEM_DEF_OTHER_ZBT)
  end
  if self.btn_continue:isVisible() and itemNum > 0 then
    self.m_SchedulerHandler = scheduler.scheduleGlobal(handler(self, self.setBtnTxt), 1)
  else
    self.btn_continue:setTitleText("确定")
  end
end
function CCBTResult:setBtnTxt()
  if self.m_Time > 1 then
    self.m_Time = self.m_Time - 1
    self.btn_continue:setTitleText(string.format("继续挖宝(%ds)", self.m_Time))
  else
    if self.m_SchedulerHandler ~= nil then
      scheduler.unscheduleGlobal(self.m_SchedulerHandler)
    end
    self:OnBtn_Continue()
  end
end
function CCBTResult:setOnlyShowBtnContinue()
  self.btn_battle:setVisible(false)
  self.btn_battle:setTouchEnabled(false)
  local x, _ = self:getNode("bg"):getPosition()
  local _, y = self.btn_continue:getPosition()
  self.btn_continue:setPosition(ccp(x, y))
end
function CCBTResult:setOnlyShowBtnConfirm()
  self.btn_continue:setVisible(false)
  self.btn_continue:setTouchEnabled(false)
  local x, _ = self:getNode("bg"):getPosition()
  local _, y = self.btn_continue:getPosition()
  self.btn_battle:setPosition(ccp(x, y))
  self.btn_battle:setTitleText("确定")
end
function CCBTResult:OnBtn_Confirm()
  if self.m_MonsterData ~= nil then
    if g_CBTView then
      g_CBTView:fightWarNpc()
    end
    do
      local rID = self.m_MonsterData.rID
      local sceneID = self.m_MonsterData.sceneID
      local scenePos = self.m_MonsterData.scenePos
      local monsterID = self.m_MonsterData.monsterID
      local warNPCName = self.m_MonsterData.warNPCName
      local function callbackFunc(isSucceed)
        if isSucceed then
          local npcData = g_MapMgr:getDynamicNpcDataById(rID)
          if npcData == nil then
            ShowNotifyTips("怪物已被消灭，请下次赶紧前往")
            return
          end
          CMainUIScene.Ins:ShowMonsterView(monsterID, MapMonsterType_Precious, function()
            netsend.netmap.reqDynamicNpcEvent(rID)
          end, warNPCName)
        end
      end
      g_MapMgr:AutoRouteWithWorldTeleporter(sceneID, scenePos, callbackFunc, RouteType_Monster)
    end
  end
  self:OnBtn_Close()
end
function CCBTResult:OnBtn_Continue()
  local itemNum = 0
  local itemId
  if self.m_ItemId and g_LocalPlayer:GetOneItem(self.m_ItemId) then
    itemId = self.m_ItemId
  end
  if self.m_cbtType == ITEM_DEF_OTHER_GJZBT then
    itemNum = g_LocalPlayer:GetItemNum(ITEM_DEF_OTHER_GJZBT)
    if itemId == nil then
      itemId = g_LocalPlayer:GetOneItemIdByType(ITEM_DEF_OTHER_GJZBT)
    end
  else
    itemNum = g_LocalPlayer:GetItemNum(ITEM_DEF_OTHER_ZBT)
    if itemId == nil then
      itemId = g_LocalPlayer:GetOneItemIdByType(ITEM_DEF_OTHER_ZBT)
    end
  end
  if itemNum > 0 then
    if itemId ~= nil then
      local itemObj = g_LocalPlayer:GetOneItem(itemId)
      local mapId = itemObj:getProperty(ITME_PRO_ZBT_SCENE)
      local pos = itemObj:getProperty(ITME_PRO_ZBT_POS)
      local rIndex = itemObj:getProperty(ITEM_PRO_ZBT_RESULTINDEX)
      if mapId ~= 0 and mapId ~= nil and pos ~= nil and #pos >= 2 and rIndex ~= nil and rIndex ~= 0 then
        if self.m_SchedulerHandler ~= nil then
          scheduler.unscheduleGlobal(self.m_SchedulerHandler)
        end
        g_MapMgr:UseZBT(itemId, mapId, pos, rIndex)
      else
        netsend.netitem.requestUseItem(itemId)
      end
    end
  else
    self:OnBtn_Close()
  end
end
function CCBTResult:OnMessage(msgSID, ...)
  if msgSID == MsgID_ItemInfo_CangBaoTuClose then
    if self.m_SchedulerHandler ~= nil then
      scheduler.unscheduleGlobal(self.m_SchedulerHandler)
    end
    self:CloseSelf()
  end
end
function CCBTResult:OnBtn_Close()
  if self.m_SchedulerHandler ~= nil then
    scheduler.unscheduleGlobal(self.m_SchedulerHandler)
    self.m_SchedulerHandler = nil
  end
  self:CloseSelf()
end
function CCBTResult:Clear()
  if g_CBTView then
    g_CBTView:CloseSelf()
  end
end
