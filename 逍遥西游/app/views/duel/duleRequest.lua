CDuelRequest = class("CDuelRequest", CcsSubView)
function CDuelRequest:ctor(cdTime)
  CDuelRequest.super.ctor(self, "views/duelrequest.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_confirm = {
      listener = handler(self, self.Btn_Confirm),
      variName = "btn_confirm"
    },
    btn_single = {
      listener = handler(self, self.Btn_Single),
      variName = "btn_single"
    },
    btn_team = {
      listener = handler(self, self.Btn_Team),
      variName = "btn_team"
    },
    btn_private = {
      listener = handler(self, self.Btn_Private),
      variName = "btn_private"
    },
    btn_server = {
      listener = handler(self, self.Btn_Server),
      variName = "btn_server"
    },
    btn_find = {
      listener = handler(self, self.Btn_Find),
      variName = "btn_find"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_SelectIconOffx = 16
  self.m_SelectIconOffy = 7
  self.m_IsSettingNameFlag = false
  self.m_CanEditContent = true
  self.m_m_DuelContentDefault = "尔等敢应战否！#<E:118>##<E:118>##<E:118>#"
  self.m_DuelContent = self.m_m_DuelContentDefault
  self.m_IDInput = self:getNode("input_id")
  local size = self.m_IDInput:getContentSize()
  TextFieldEmoteExtend.extend(self.m_IDInput, self.m_UINode, {
    width = size.width,
    align = CRichText_AlignType_Right
  })
  self.m_IDInput:SetFieldText("")
  self.m_IDInput:SetFiledPlaceHolder("请输入ID", {
    color = ccc3(206, 187, 151)
  })
  self.m_NameCharNumMaxLimit = 11
  self.m_IDInput:setMaxLengthEnabled(true)
  self.m_IDInput:setMaxLength(self.m_NameCharNumMaxLimit)
  self.m_IDInput:SetKeyBoardListener(handler(self, self.onKeyBoardListener))
  self.list_leaveword = self:getNode("list_leaveword")
  self.list_leaveword:addTouchItemListenerListView(function(item, index, listObj)
    if self.m_UINode ~= nil and self.m_CanEditContent then
      self:OnClickLeaveWord()
    end
  end)
  self:updateDuleContent()
  self.m_SelectDuelType = nil
  self.m_DuelType_Single = 0
  self.m_DuelType_Team = 1
  self.icon_type = self:getNode("icon_type")
  self:setSelectDuelType(nil)
  self.m_SelectDuelNotice = nil
  self.m_DuelNoctice_Private = 0
  self.m_DuelNoctice_Server = 1
  self.icon_notice = self:getNode("icon_notice")
  self:setSelectDuelNotice(self.m_DuelNoctice_Private)
  self.cost_notice = self:getNode("cost_notice")
  self.cost_notice:setText(string.format("花费%d万", math.floor(data_Variables.HuangGongBulletinCostCoin / 10000)))
  local iconcost_notice = self:getNode("iconcost_notice")
  iconcost_notice:setVisible(false)
  iconcost_notice:setTouchEnabled(false)
  local nx, ny = self.cost_notice:getPosition()
  local nsize = self.cost_notice:getContentSize()
  local size = iconcost_notice:getContentSize()
  local z = iconcost_notice:getZOrder()
  local p = iconcost_notice:getParent()
  local resIcon_notice = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  resIcon_notice:setAnchorPoint(ccp(0.5, 0.5))
  resIcon_notice:setScale(size.width / resIcon_notice:getContentSize().width)
  resIcon_notice:setPosition(ccp(nx + nsize.width + size.width / 2, ny + 3))
  p:addNode(resIcon_notice, z)
  self.ResIcon_notice = resIcon_notice
  self:setRequestCoin()
  local iconcost = self:getNode("iconcost")
  iconcost:setVisible(false)
  iconcost:setTouchEnabled(false)
  local x, y = iconcost:getPosition()
  local size = iconcost:getContentSize()
  local z = iconcost:getZOrder()
  local p = iconcost:getParent()
  local resIcon = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  resIcon:setAnchorPoint(ccp(0.5, 0.5))
  resIcon:setScale(size.width / resIcon:getContentSize().width)
  resIcon:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  p:addNode(resIcon, z)
  self.txt_cd = self:getNode("txt_cd")
  self.m_CdTime = cdTime
  self:setCDTime()
  self:ListenMessage(MsgID_Activity)
  self:ListenMessage(MsgID_PlayerInfo)
end
function CDuelRequest:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Activity_DuelQueryInfo then
    self:OnQueryPlayerInfo(arg[1], arg[2])
  elseif msgSID == MsgID_Activity_DuelStatus then
    local status = arg[1]
    if status ~= 0 then
      self:CloseSelf()
    end
  elseif msgSID == MsgID_HeroUpdate then
    local param = arg[1]
    if param.pid == g_LocalPlayer:getPlayerId() and param.pro and param.pro[PROPERTY_ROLELEVEL] ~= nil then
      self:setRequestCoin()
    end
  elseif msgSID == MsgID_MoneyUpdate then
    local param = arg[1]
    if param.pid == g_LocalPlayer:getPlayerId() and param.newCoin ~= nil then
      self:setRequestCoin()
    end
  end
end
function CDuelRequest:setCDTime()
  if self.m_CdTime > 0 then
    self:getNode("cost_notice"):setVisible(false)
    self.ResIcon_notice:setVisible(false)
    self.txt_cd:setVisible(true)
    local min = math.floor(self.m_CdTime / 60)
    local sec = self.m_CdTime % 60
    self.txt_cd:setText(string.format("剩余时间:%.2d:%.2d", min, sec))
    if self.m_CdTimerHandler == nil then
      self.m_CdTimerHandler = scheduler.scheduleGlobal(handler(self, self.updateTimer), 0.3)
    end
  else
    self:getNode("cost_notice"):setVisible(true)
    self.ResIcon_notice:setVisible(true)
    self.txt_cd:setVisible(false)
    if self.m_CdTimerHandler ~= nil then
      scheduler.unscheduleGlobal(self.m_CdTimerHandler)
      self.m_CdTimerHandler = nil
    end
  end
end
function CDuelRequest:updateTimer(dt)
  self.m_CdTime = self.m_CdTime - dt
  self:setCDTime()
end
function CDuelRequest:setRequestCoin()
  local mainHero = g_LocalPlayer:getMainHero()
  local requestCost = data_Variables.HuangGongCostCoinPerLv * mainHero:getProperty(PROPERTY_ROLELEVEL)
  self:getNode("request_cost"):setText(tostring(requestCost))
  local myCoin = g_LocalPlayer:getCoin()
  if self.m_SelectDuelNotice == self.m_DuelNoctice_Server then
    requestCost = requestCost + data_Variables.HuangGongBulletinCostCoin
  end
  if myCoin >= requestCost then
    self:getNode("request_cost"):setColor(ccc3(255, 255, 255))
  else
    self:getNode("request_cost"):setColor(ccc3(255, 0, 0))
  end
end
function CDuelRequest:OnClickLeaveWord()
  CDuelContentEdit.new(self.m_DuelContent, handler(self, self.OnEditContent))
end
function CDuelRequest:OnEditContent(content)
  if string.len(content) <= 0 then
    content = self.m_m_DuelContentDefault
  end
  self.m_DuelContent = content
  self:updateDuleContent()
end
function CDuelRequest:updateDuleContent()
  self.list_leaveword:removeAllItems()
  local size = self.list_leaveword:getContentSize()
  local richTextBox = CRichText.new({
    with = size.width,
    fontSize = 22
  })
  richTextBox:addRichText(self.m_DuelContent)
  richTextBox:setTouchEnabled(true)
  self.list_leaveword:pushBackCustomItem(richTextBox)
  local conSize = richTextBox:getRichTextSize()
  if conSize.height < size.height then
    local offy = size.height - conSize.height
    for lineNum, lineData in pairs(richTextBox.m_ObjList) do
      local lineObjList = lineData.objs or {}
      for _, obj in pairs(lineObjList) do
        local x, y = obj:getPosition()
        obj:setPosition(ccp(x, y + offy))
      end
    end
    richTextBox:ignoreContentAdaptWithSize(false)
    richTextBox:setSize(CCSize(conSize.width, size.height))
  end
  richTextBox:setTouchEnabled(true)
end
function CDuelRequest:onKeyBoardListener(event)
  if event == TEXTFIELDEXTEND_EVENT_TEXT_CHANGE and not self.m_IsSettingNameFlag then
    self.m_CurFindId = nil
  end
end
function CDuelRequest:setSelectDuelType(duelType)
  self.m_SelectDuelType = duelType
  if self.m_SelectDuelType == self.m_DuelType_Single then
    self.icon_type:setVisible(true)
    local x, y = self.btn_single:getPosition()
    self.icon_type:setPosition(ccp(x + self.m_SelectIconOffx, y + self.m_SelectIconOffy))
  elseif self.m_SelectDuelType == self.m_DuelType_Team then
    self.icon_type:setVisible(true)
    local x, y = self.btn_team:getPosition()
    self.icon_type:setPosition(ccp(x + self.m_SelectIconOffx, y + self.m_SelectIconOffy))
  else
    self.icon_type:setVisible(false)
  end
end
function CDuelRequest:Btn_Single()
  self:setSelectDuelType(self.m_DuelType_Single)
end
function CDuelRequest:Btn_Team()
  self:setSelectDuelType(self.m_DuelType_Team)
end
function CDuelRequest:setSelectDuelNotice(duelNotice)
  self.m_SelectDuelNotice = duelNotice
  if self.m_SelectDuelNotice == self.m_DuelNoctice_Private then
    self.icon_notice:setVisible(true)
    local x, y = self.btn_private:getPosition()
    self.icon_notice:setPosition(ccp(x + self.m_SelectIconOffx, y + self.m_SelectIconOffy))
    self.m_CanEditContent = false
  elseif self.m_SelectDuelNotice == self.m_DuelNoctice_Server then
    self.icon_notice:setVisible(true)
    local x, y = self.btn_server:getPosition()
    self.icon_notice:setPosition(ccp(x + self.m_SelectIconOffx, y + self.m_SelectIconOffy))
    self.m_CanEditContent = true
  else
    self.icon_notice:setVisible(false)
    self.m_CanEditContent = false
  end
end
function CDuelRequest:Btn_Private()
  self:setSelectDuelNotice(self.m_DuelNoctice_Private)
  self:setRequestCoin()
end
function CDuelRequest:Btn_Server()
  if self.m_CdTime > 0 then
    ShowNotifyTips("正在冷却中，请稍后")
    return
  end
  self:setSelectDuelNotice(self.m_DuelNoctice_Server)
  self:setRequestCoin()
end
function CDuelRequest:OnQueryPlayerInfo(pid, name)
  if pid ~= self.m_CurFindId then
    return
  end
  self.m_IsSettingNameFlag = true
  self.m_IDInput:SetFieldText(name)
  self.m_IsSettingNameFlag = false
end
function CDuelRequest:Btn_Find(obj, t)
  local idTxt = self.m_IDInput:getStringValue()
  local curId = tonumber(idTxt)
  if curId == nil then
    ShowNotifyTips("请输入正确的玩家ID")
  else
    local curTime = cc.net.SocketTCP.getTime()
    if self.m_LastFindTime ~= nil and curTime - self.m_LastFindTime < 1 then
      return
    end
    self.m_LastFindTime = curTime
    self.m_CurFindId = curId
    netsend.netactivity.queryDuelPlayer(self.m_CurFindId)
  end
end
function CDuelRequest:Btn_Confirm(obj, t)
  local idTxt = self.m_IDInput:getStringValue()
  if string.len(idTxt) <= 0 then
    ShowNotifyTips("请输入决斗对象ID")
    return
  end
  local playerId
  if self.m_CurFindId ~= nil then
    playerId = self.m_CurFindId
  else
    playerId = tonumber(idTxt)
  end
  if playerId == nil then
    playerId = idTxt
  end
  if self.m_SelectDuelType == nil then
    ShowNotifyTips("请选择一种决斗方式")
    return
  end
  local curTime = cc.net.SocketTCP.getTime()
  if self.m_LastConfirmTime ~= nil and curTime - self.m_LastConfirmTime < 1 then
    return
  end
  self.m_LastConfirmTime = curTime
  local leaveword = self.m_DuelContent
  if string.len(leaveword) <= 0 then
    leaveword = self.m_m_DuelContentDefault
  end
  leaveword = filterChatText_DFAFilter(leaveword)
  netsend.netactivity.launchDule(playerId, self.m_SelectDuelType, self.m_SelectDuelNotice, leaveword)
end
function CDuelRequest:Btn_Close(obj, t)
  self:CloseSelf()
end
function CDuelRequest:Clear()
  self.m_IDInput:ClearTextFieldExtend()
  if self.m_CdTimerHandler ~= nil then
    scheduler.unscheduleGlobal(self.m_CdTimerHandler)
    self.m_CdTimerHandler = nil
  end
end
function ShowDuelRequest(cdTime)
  getCurSceneView():addSubView({
    subView = CDuelRequest.new(cdTime),
    zOrder = MainUISceneZOrder.menuView
  })
end
