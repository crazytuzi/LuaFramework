CChatInsert = class("CChatInsert", CcsSubView)
function CChatInsert:ctor(dlgHandler, dType, param)
  CChatInsert.super.ctor(self, "views/chatinsert.json")
  self.m_Handler = dlgHandler
  self.m_DailyWordType = dType
  self.m_BoardShow = true
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_keyboard = {
      listener = handler(self, self.OnBtn_Keyboard),
      variName = "btn_keyboard"
    },
    btn_emotion = {
      listener = handler(self, self.OnBtn_Emote),
      variName = "btn_emotion"
    },
    btn_dailyword = {
      listener = handler(self, self.OnBtn_Dailyword),
      variName = "btn_dailyword"
    },
    btn_package = {
      listener = handler(self, self.OnBtn_Package),
      variName = "btn_package"
    },
    btn_pet = {
      listener = handler(self, self.OnBtn_Pet),
      variName = "btn_pet"
    },
    btn_history = {
      listener = handler(self, self.OnBtn_History),
      variName = "btn_history"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_emotion,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_dailyword,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_package,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_pet,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_history,
      nil,
      ccc3(251, 248, 145)
    }
  })
  self:InitViews()
  self:ShowEmote()
  if param and param.showEmoteOnly == true then
    self:ShowEmoteOnly()
  end
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_Message)
end
function CChatInsert:onEnterEvent()
end
function CChatInsert:OnMessage(msgSID, ...)
  if msgSID == MsgID_AddPet or msgSID == MsgID_DeletePet then
    if self.m_InitPet then
      self.m_InitPet = false
      self:InitPetLayer()
    end
  elseif msgSID == MsgID_PetUpdate then
    local arg = {
      ...
    }
    local data = arg[1]
    if data.pid == g_LocalPlayer:getPlayerId() and data.petId == self.m_CurrShowPet then
      local petObj = g_LocalPlayer:getObjById(self.m_CurrShowPet)
      if petObj then
        self.pet_detail:removeAllItems()
        local petIcon = CChatInsertDetail_PetIcon.new(petObj, self.m_PalyerId, self.m_CurrShowPet)
        self.pet_detail:pushBackCustomItem(petIcon:getUINode())
        local listSize = self.pet_detail:getInnerContainerSize()
        local w = listSize.width
        local petDetail = CChatInsertDetail_PetInfo.new(petObj, w)
        self.pet_detail:pushBackCustomItem(petDetail)
        self.pet_detail:jumpToTop()
      end
    end
  elseif msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_DelItem then
    if self.m_InitPackage then
      self:ClearItemDetail()
    end
  elseif msgSID == MsgID_Message_NewSendMsg and self.m_InitHistory then
    self:setChatHistory()
  end
end
function CChatInsert:setBoardShow(iShow)
  self.m_BoardShow = iShow
  if iShow then
    if self.m_AutoDestroyAct ~= nil then
      self:stopAction(self.m_AutoDestroyAct)
      self.m_AutoDestroyAct = nil
    end
  elseif self.m_AutoDestroyAct == nil then
    self.m_AutoDestroyAct = transition.sequence({
      CCDelayTime:create(30),
      CCCallFunc:create(function()
        self:CloseSelf()
      end)
    })
    self:runAction(self.m_AutoDestroyAct)
  end
end
function CChatInsert:ShowEmoteOnly()
  self.btn_emotion:setVisible(false)
  self.btn_emotion:setTouchEnabled(false)
  self.btn_dailyword:setVisible(false)
  self.btn_dailyword:setTouchEnabled(false)
  self.btn_package:setVisible(false)
  self.btn_package:setTouchEnabled(false)
  self.btn_pet:setVisible(false)
  self.btn_pet:setTouchEnabled(false)
  self.btn_history:setVisible(false)
  self.btn_history:setTouchEnabled(false)
end
function CChatInsert:InitViews()
  self.layer_emote = self:getNode("layer_emote")
  self.layer_dailyword = self:getNode("layer_dailyword")
  self.layer_package = self:getNode("layer_package")
  self.layer_pet = self:getNode("layer_pet")
  self.layer_history = self:getNode("layer_history")
  for _, viewIns in pairs({
    self.layer_emote,
    self.layer_dailyword,
    self.layer_package,
    self.layer_pet,
    self.layer_history
  }) do
    viewIns:setVisible(true)
    viewIns:setEnabled(false)
  end
  self.m_InitEmote = false
  self.m_InitDailyWord = false
  self.m_InitPackage = false
  self.m_InitPet = false
  self.m_InitHistory = false
end
function CChatInsert:ShowView(showView)
  for _, viewIns in pairs({
    self.layer_emote,
    self.layer_dailyword,
    self.layer_package,
    self.layer_pet,
    self.layer_history
  }) do
    viewIns:setEnabled(viewIns == showView)
  end
end
function CChatInsert:ShowEmote()
  if not self.m_InitEmote then
    self:InitEmoteLayer()
  end
  self:ShowView(self.layer_emote)
  self:SetEmotionBoardRecently()
end
function CChatInsert:InitEmoteLayer()
  self.list_emote = self:getNode("list_emote")
  local p = self.list_emote:getParent()
  local x, y = self.list_emote:getPosition()
  local param = {
    numPerRow = 5,
    rowsNum = 4,
    rowHeight = 60,
    spaceX = 55,
    clickListener = handler(self, self.OnClickEmotion)
  }
  self.m_EmotionBoard = CEmotionBoard.new(param)
  p:addChild(self.m_EmotionBoard)
  self.m_EmotionBoard:setPosition(ccp(x, y))
  self.m_InitEmote = true
end
function CChatInsert:SetEmotionBoardRecently()
  if self.m_EmotionBoardRecently ~= nil then
    self.m_EmotionBoardRecently:removeFromParentAndCleanup(true)
    self.m_EmotionBoardRecently = nil
  end
  self.list_emote_recent = self:getNode("list_emote_recent")
  local p = self.list_emote_recent:getParent()
  local x, y = self.list_emote_recent:getPosition()
  local recentEmote = g_LocalPlayer:getRecentEmote()
  local param = {
    numPerRow = 3,
    rowHeight = 60,
    spaceX = 55,
    emotionNum = 9,
    emotionIdList = recentEmote,
    clickListener = handler(self, self.OnClickEmotion)
  }
  self.m_EmotionBoardRecently = CEmotionBoardRecently.new(param)
  p:addChild(self.m_EmotionBoardRecently)
  self.m_EmotionBoardRecently:setPosition(ccp(x, y))
  self.m_EmotionBoardRecently:setEnabled(self.m_EmotionBoard:isEnabled())
end
function CChatInsert:OnClickEmotion(emoteNumber)
  if self.m_Handler then
    self.m_Handler:_insertEmotion(emoteNumber)
    g_LocalPlayer:recordRecentEmote(emoteNumber)
  end
end
function CChatInsert:ShowDailyword()
  if not self.m_InitDailyWord then
    self:InitDailyWordLayer()
  end
  self:ShowView(self.layer_dailyword)
end
function CChatInsert:InitDailyWordLayer()
  if self.m_DailyWordType == DailyWordType_Private then
    self.m_DailyWordTable = DeepCopyTable(data_Dailyword)
  elseif self.m_DailyWordType == DailyWordType_Team then
    self.m_DailyWordTable = DeepCopyTable(data_TeamDailyword)
  else
    self.m_DailyWordTable = DeepCopyTable(data_Dailyword)
  end
  for index = 1, 8 do
    btn = self:addBtnListener(string.format("dailyword_%d", index), function()
      self:OnSelectDailyword(index)
    end)
    if btn then
      local desc = self.m_DailyWordTable[index]
      if desc ~= nil then
        btn:setTitleText(desc)
      else
        btn:setVisible(false)
        btn:setTouchEnabled(false)
      end
    end
  end
  self.m_InitDailyWord = true
end
function CChatInsert:OnSelectDailyword(index)
  local desc = self.m_DailyWordTable[index]
  if desc and self.m_Handler then
    self.m_Handler:_onInsertSendText(desc)
  end
end
function CChatInsert:ShowPackage()
  if not self.m_InitPackage then
    self:InitPackageLayer()
  end
  self:ShowView(self.layer_package)
end
function CChatInsert:InitPackageLayer()
  self.list_packge = self:getNode("list_packge")
  self.list_packge:setVisible(false)
  local p = self.list_packge:getParent()
  local x, y = self.list_packge:getPosition()
  local param = {
    xySpace = ccp(5, 0),
    itemSize = CCSize(95, 92),
    pageLines = 3,
    oneLineNum = 5,
    pageIconOffY = -10
  }
  if self.m_PackageFrame then
    self.m_PackageFrame:removeFromParentAndCleanup(true)
    self.m_PackageFrame = nil
  end
  self.m_PackageFrame = CChatItemFrame.new(handler(self, self.ShowPackageDetail), param)
  self.m_PackageFrame:setPosition(ccp(x, y))
  p:addChild(self.m_PackageFrame, 10)
  self.m_CurrSelItemId = nil
  self.m_InitPackage = true
  self.item_detail = self:getNode("item_detail")
  self.item_detail:removeAllItems()
end
function CChatInsert:ShowPackageDetail(itemId)
  if self.m_CurrSelItemId == itemId then
    if self.m_Handler then
      self.m_Handler:_insertItem(itemId)
    end
    return
  end
  self.m_CurrSelItemId = itemId
  self.item_detail:removeAllItems()
  local lSize = self.item_detail:getContentSize()
  local w, h = lSize.width, lSize.height
  itemDetailHead = CItemDetailHead.new({width = w})
  itemDetailHead:ShowItemDetail(self.m_CurrSelItemId)
  self.item_detail:pushBackCustomItem(itemDetailHead)
  local x, y = self.item_detail:getPosition()
  local itemDetailText = CItemDetailText.new(self.m_CurrSelItemId, {
    width = lSize.width
  })
  self.item_detail:pushBackCustomItem(itemDetailText)
  ShowNotifyTips("再次点击发送链接")
end
function CChatInsert:ClearItemDetail()
  self.m_CurrSelItemId = nil
  self.item_detail:removeAllItems()
end
function CChatInsert:ShowPet()
  if not self.m_InitPet then
    self:InitPetLayer()
  end
  self:ShowView(self.layer_pet)
end
function CChatInsert:InitPetLayer()
  self.list_pet = self:getNode("list_pet")
  self.pet_detail = self:getNode("pet_detail")
  local p = self.list_pet:getParent()
  local x, y = self.list_pet:getPosition()
  local param = {
    numPerRow = 4,
    rowsNum = 2,
    rowHeight = 130,
    spaceX = 15,
    clickListener = handler(self, self.OnClickPet)
  }
  if self.m_PetBoard then
    self.m_PetBoard:removeFromParentAndCleanup(true)
    self.m_PetBoard = nil
  end
  self.m_PetBoard = CPetBoard.new(param)
  p:addChild(self.m_PetBoard)
  self.m_PetBoard:setPosition(ccp(x, y))
  self.m_CurrShowPet = nil
  self.m_InitPet = true
end
function CChatInsert:OnClickPet(petId)
  if self.m_CurrShowPet == petId then
    if self.m_Handler then
      self.m_Handler:_insertPet(petId)
    end
    return
  end
  local petObj = g_LocalPlayer:getObjById(petId)
  if petObj then
    self.m_PalyerId = g_LocalPlayer:getPlayerId()
    self.m_CurrShowPet = petId
    self.pet_detail:removeAllItems()
    local petIcon = CChatInsertDetail_PetIcon.new(petObj, self.m_PalyerId, self.m_CurrShowPet)
    self.pet_detail:pushBackCustomItem(petIcon:getUINode())
    local listSize = self.pet_detail:getInnerContainerSize()
    local w = listSize.width
    local petDetail = CChatInsertDetail_PetInfo.new(petObj, w)
    self.pet_detail:pushBackCustomItem(petDetail)
    self.pet_detail:jumpToTop()
    ShowNotifyTips("再次点击发送链接")
  end
end
function CChatInsert:ShowHistory()
  if not self.m_InitHistory then
    self:InitHistoryLayer()
  end
  self:ShowView(self.layer_history)
end
function CChatInsert:InitHistoryLayer()
  for index = 1, 8 do
    self[string.format("history_%d", index)] = self:addBtnListener(string.format("history_%d", index), function()
      self:OnSelectRecentword(index)
    end)
  end
  self:setChatHistory()
  self.m_InitHistory = true
end
function CChatInsert:setChatHistory()
  local historyList = g_LocalPlayer:getRecentChat() or {}
  for index = 1, 8 do
    btn = self[string.format("history_%d", index)]
    if btn then
      if btn._showtxt ~= nil then
        btn._showtxt:removeFromParent()
        btn._showtxt = nil
      end
      local desc = historyList[index]
      if desc ~= nil then
        local showtxt = CRichText.new({
          width = 230,
          color = ccc3(255, 255, 255),
          fontSize = 22,
          align = CRichText_AlignType_Center,
          maxLineNum = 1,
          noMoreText = ".."
        })
        btn:addChild(showtxt, 10)
        showtxt:addRichText(desc)
        btn._showtxt = showtxt
        local size = showtxt:getRichTextSize()
        showtxt:setPosition(ccp(-size.width / 2, -size.height / 2))
        btn:setTouchEnabled(true)
      else
        btn:setTouchEnabled(false)
      end
    end
  end
end
function CChatInsert:OnSelectRecentword(index)
  local historyList = g_LocalPlayer:getRecentChat() or {}
  local desc = historyList[index]
  if desc and self.m_Handler then
    self.m_Handler:SetFieldText(desc)
  end
end
function CChatInsert:OnBtn_Emote(btnObj, touchType)
  self:ShowEmote()
end
function CChatInsert:OnBtn_Dailyword(btnObj, touchType)
  self:ShowDailyword()
end
function CChatInsert:OnBtn_Package(btnObj, touchType)
  self:ShowPackage()
end
function CChatInsert:OnBtn_Pet(btnObj, touchType)
  self:ShowPet()
end
function CChatInsert:OnBtn_History(btnObj, touchType)
  self:ShowHistory()
end
function CChatInsert:OnBtn_Close(btnObj, touchType)
  if self.m_Handler then
    self.m_Handler:closeInsertBoard()
  end
end
function CChatInsert:OnBtn_Keyboard(btnObj, touchType)
  if self.m_Handler then
    self.m_Handler:openKeyBoard()
  end
end
function CChatInsert:Clear()
  if self.m_Handler then
    self.m_Handler:_onInsertBoardDestroy()
    self.m_Handler = nil
  end
end
